import AILinkBleSDK
import CoreBluetooth
import Flutter
import Foundation

/// iOS 单设备连接会话，每个 remoteId 使用独立 ELAILinkBleManager，避免 current peripheral 覆盖多连状态。
final class ElinkIosDeviceSession: NSObject, ELAILinkBleManagerDelegate {
  let sessionId = UUID().uuidString
  private let manager = ELAILinkBleManager()
  private let remoteId: String
  private let callbacks: ElinkIosDeviceSessionCallbacks
  private var ailinkPeripheral: ELAILinkPeripheral?
  private var pendingConnectRemoteId: String?
  private var pendingScanServices: [CBUUID] = []
  private var connectTimer: Timer?
  private var disconnectResults: [FlutterResult] = []
  private var disconnecting = false
  private var invalidated = false
  private(set) var connectionReady = false

  /// EventChannel 重新监听时用于恢复当前 session 的连接状态。
  var currentConnectionStateName: String? {
    guard !invalidated else { return nil }
    if disconnecting {
      return "disconnecting"
    }
    return connectionReady ? "connected" : "connecting"
  }

  /// 创建指定 remoteId 的 iOS 连接会话。
  init(remoteId: String, callbacks: ElinkIosDeviceSessionCallbacks) {
    self.remoteId = remoteId
    self.callbacks = callbacks
    super.init()
    manager.ailinkDelegate = self
    ElinkNativeLogger.debug("session init remoteId=\(remoteId) sessionId=\(sessionId)")
  }

  /// 当前 session 对应的 CoreBluetooth peripheral。
  var currentPeripheral: CBPeripheral? {
    manager.currentAILinkPeripheral()?.peripheral ?? ailinkPeripheral?.peripheral
  }

  /// 发起当前 session 的 BLE 连接，优先使用本 session manager retrieve 的外设，未命中再扫描。
  func connect(
    knownPeripheral: ELAILinkPeripheral,
    timeoutMs: Int,
    scanServices: [CBUUID]
  ) {
    guard !invalidated else { return }
    guard !disconnecting else {
      ElinkNativeLogger.warning("connect rejected, disconnecting remoteId=\(remoteId) sessionId=\(sessionId)")
      callbacks.emitError("device_disconnecting", "Device is disconnecting: \(remoteId)")
      return
    }
    ElinkNativeLogger.info(
      "session connect remoteId=\(remoteId) sessionId=\(sessionId) timeoutMs=\(timeoutMs) services=\(scanServices.map { callbacks.shortUuid($0) })"
    )
    ailinkPeripheral = knownPeripheral
    pendingConnectRemoteId = remoteId
    pendingScanServices = scanServices
    connectionReady = false
    callbacks.emitConnection(remoteId, "connecting", nil)
    clearConnectTimer()
    let timeout = TimeInterval(max(timeoutMs, 1000)) / 1000.0
    connectTimer = Timer.scheduledTimer(
      withTimeInterval: timeout,
      repeats: false
    ) { [weak self] _ in
      self?.finishConnectFailure("Connect timeout: \(self?.remoteId ?? "")")
    }
    startConnectWhenBluetoothReady(attemptsRemaining: 8)
  }

  /// 断开当前 session 的 BLE 连接。
  func disconnect(result: @escaping FlutterResult) {
    guard !invalidated else {
      result(nil)
      return
    }
    disconnectResults.append(result)
    guard !disconnecting else { return }
    disconnecting = true
    ElinkNativeLogger.info("session disconnect requested remoteId=\(remoteId) sessionId=\(sessionId)")
    callbacks.emitConnection(remoteId, "disconnecting", nil)
    connectionReady = false
    pendingConnectRemoteId = nil
    clearConnectTimer()
    if invalidateAdapterSessionIfShuttingDown() { return }
    let adapterState = manager.central.state
    guard adapterState == .poweredOn else {
      finishDisconnect(error: nil)
      return
    }
    manager.stopScan()
    guard let peripheral = currentPeripheral, peripheral.state != .disconnected else {
      ElinkNativeLogger.info("session already disconnected remoteId=\(remoteId) sessionId=\(sessionId)")
      finishDisconnect(error: nil)
      return
    }
    manager.disconnectPeripheral()
  }

  /// 主动读取当前 session 的 RSSI。
  func readRssi() {
    ElinkNativeLogger.debug("session readRssi remoteId=\(remoteId) sessionId=\(sessionId)")
    manager.readRSSI()
  }

  /// 向当前 session 发送完整 BLE 指令。
  func write(_ data: Data) {
    ElinkNativeLogger.debug("session write remoteId=\(remoteId) sessionId=\(sessionId) bytes=\(data.count)")
    manager.sendCmd(data)
  }

  /// 向当前 session 发送 A6 payload。
  func writeA6(_ payload: Data) {
    ElinkNativeLogger.debug("session writeA6 remoteId=\(remoteId) sessionId=\(sessionId) bytes=\(payload.count)")
    manager.sendA6Payload(payload)
  }

  /// 查询增强版 BM 模块版本，使用 SDK `0x46` 指令入口。
  func getBmVersion() {
    ElinkNativeLogger.debug("session getBmVersion remoteId=\(remoteId) sessionId=\(sessionId)")
    manager.getBluetoothInfo(with: .cmdTypeGetBMVersionPro)
  }

  /// 向当前 session 发送 A7 payload。
  func writeA7(_ payload: Data) {
    ElinkNativeLogger.debug("session writeA7 remoteId=\(remoteId) sessionId=\(sessionId) bytes=\(payload.count)")
    manager.sendA7Payload(payload)
  }

  /// 释放 session 资源并断开代理。
  func dispose() {
    ElinkNativeLogger.info("session dispose remoteId=\(remoteId) sessionId=\(sessionId)")
    invalidate(disconnectPeripheral: true)
  }

  /// 清理 SDK delegate，避免 session 移除后继续回调插件。
  func clearDelegate() {
    invalidate(disconnectPeripheral: false)
  }

  /// 立即失效当前 session，阻断后续异步回调继续影响插件状态。
  private func invalidate(disconnectPeripheral: Bool) {
    guard !invalidated else { return }
    invalidated = true
    ElinkNativeLogger.debug(
      "session invalidate remoteId=\(remoteId) sessionId=\(sessionId) disconnectPeripheral=\(disconnectPeripheral)"
    )
    completeDisconnectResults()
    connectionReady = false
    disconnecting = false
    pendingConnectRemoteId = nil
    clearConnectTimer()
    if manager.central.state == .poweredOn {
      manager.stopScan()
      if disconnectPeripheral {
        manager.disconnectPeripheral()
      }
    }
    manager.ailinkDelegate = nil
  }

  /// 等待当前 session 的蓝牙 manager 可用后优先快速连接，未命中再启动目标扫描。
  private func startConnectWhenBluetoothReady(attemptsRemaining: Int) {
    guard !invalidated else { return }
    if invalidateAdapterSessionIfShuttingDown() { return }
    switch manager.central.state {
    case .poweredOn:
      ElinkNativeLogger.debug("session bluetooth poweredOn remoteId=\(remoteId) sessionId=\(sessionId)")
      if !connectRetrievedPeripheralIfAvailable() {
        startConnectScan()
      }
    case .poweredOff, .resetting:
      return
    case .unauthorized:
      ElinkNativeLogger.warning("session bluetooth unauthorized remoteId=\(remoteId) sessionId=\(sessionId)")
      finishConnectFailure("Bluetooth permission is not authorized")
    case .unsupported:
      ElinkNativeLogger.warning("session bluetooth unsupported remoteId=\(remoteId) sessionId=\(sessionId)")
      finishConnectFailure("Bluetooth LE is not supported on this device")
    case .unknown:
      guard attemptsRemaining > 0 else {
        finishConnectFailure("Bluetooth adapter is not ready")
        return
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
        self?.startConnectWhenBluetoothReady(attemptsRemaining: attemptsRemaining - 1)
      }
    @unknown default:
      finishConnectFailure("Bluetooth adapter is not ready")
    }
  }

  /// 尝试从当前 session 的 CBCentralManager retrieve 目标外设并直接连接。
  private func connectRetrievedPeripheralIfAvailable() -> Bool {
    guard !invalidated else { return false }
    guard pendingConnectRemoteId == remoteId,
          let identifier = UUID(uuidString: remoteId),
          let knownPeripheral = ailinkPeripheral else {
      return false
    }
    let retrievedPeripherals = manager.central.retrievePeripherals(
      withIdentifiers: [identifier]
    )
    guard let cbPeripheral = retrievedPeripherals.first(where: {
      callbacks.remoteId($0) == remoteId
    }) else {
      ElinkNativeLogger.debug("retrievePeripheral miss remoteId=\(remoteId) sessionId=\(sessionId)")
      return false
    }
    ElinkNativeLogger.debug("retrievePeripheral hit remoteId=\(remoteId) sessionId=\(sessionId)")
    connectPeripheral(
      copyAILinkPeripheral(from: knownPeripheral, peripheral: cbPeripheral)
    )
    return true
  }

  /// 使用当前 session 的 manager 扫描待连接的目标设备。
  private func startConnectScan() {
    guard !invalidated else { return }
    guard pendingConnectRemoteId != nil else { return }
    ElinkNativeLogger.debug(
      "session startConnectScan remoteId=\(remoteId) sessionId=\(sessionId) services=\(pendingScanServices.map { callbacks.shortUuid($0) })"
    )
    if pendingScanServices.isEmpty {
      manager.scanAll()
      return
    }
    manager.scan(withServices: pendingScanServices, options: nil)
  }

  /// 如果扫描结果匹配目标 remoteId，则停止扫描并发起 SDK 连接。
  private func connectDiscoveredPeripheral(_ peripheral: ELAILinkPeripheral) {
    guard !invalidated else { return }
    guard isTargetPeripheral(peripheral) else { return }
    ElinkNativeLogger.debug("session discovered target remoteId=\(remoteId) sessionId=\(sessionId)")
    connectPeripheral(peripheral)
  }

  /// 使用当前 session manager 持有的目标外设发起 SDK 连接。
  private func connectPeripheral(_ peripheral: ELAILinkPeripheral) {
    guard !invalidated else { return }
    pendingConnectRemoteId = nil
    manager.stopScan()
    ailinkPeripheral = peripheral
    ElinkNativeLogger.debug("session connectPeripheral remoteId=\(remoteId) sessionId=\(sessionId)")
    manager.connect(peripheral)
  }

  /// 复制扫描缓存中的 AiLink 元数据，并替换为当前 session manager retrieve 出来的 CBPeripheral。
  private func copyAILinkPeripheral(
    from knownPeripheral: ELAILinkPeripheral,
    peripheral cbPeripheral: CBPeripheral
  ) -> ELAILinkPeripheral {
    let copiedPeripheral = ELAILinkPeripheral()
    copiedPeripheral.peripheral = cbPeripheral
    copiedPeripheral.advertisementData = knownPeripheral.advertisementData
    copiedPeripheral.rssi = knownPeripheral.rssi
    copiedPeripheral.timestamp = knownPeripheral.timestamp
    copiedPeripheral.macAddressString = knownPeripheral.macAddressString
    copiedPeripheral.macData = knownPeripheral.macData
    copiedPeripheral.cid = knownPeripheral.cid
    copiedPeripheral.vid = knownPeripheral.vid
    copiedPeripheral.pid = knownPeripheral.pid
    copiedPeripheral.identifier = cbPeripheral.identifier
    return copiedPeripheral
  }

  /// 结束当前连接流程并上报失败原因。
  private func finishConnectFailure(_ message: String) {
    guard !invalidated else { return }
    if invalidateAdapterSessionIfShuttingDown() { return }
    ElinkNativeLogger.warning("session connect failure remoteId=\(remoteId) sessionId=\(sessionId) message=\(message)")
    pendingConnectRemoteId = nil
    connectionReady = false
    disconnecting = false
    clearConnectTimer()
    if manager.central.state == .poweredOn {
      manager.stopScan()
      manager.disconnectPeripheral()
    }
    callbacks.emitConnection(remoteId, "disconnected", message)
    callbacks.removeSession(remoteId, sessionId)
    completeDisconnectResults()
  }

  /// 清理连接超时定时器。
  private func clearConnectTimer() {
    connectTimer?.invalidate()
    connectTimer = nil
  }

  /// 完成等待原生断开结果的 MethodChannel 回调，避免 Dart 在真实断开前继续重连。
  private func completeDisconnectResults() {
    let results = disconnectResults
    disconnectResults.removeAll()
    results.forEach { $0(nil) }
  }

  /// 处理真实断开完成后的统一清理，确保 session 和 delegate 在回调后才释放。
  private func finishDisconnect(error: Error?) {
    guard !invalidated else { return }
    if invalidateAdapterSessionIfShuttingDown() { return }
    pendingConnectRemoteId = nil
    connectionReady = false
    disconnecting = false
    clearConnectTimer()
    callbacks.emitConnection(remoteId, "disconnected", error?.localizedDescription)
    callbacks.removeSession(remoteId, sessionId)
    completeDisconnectResults()
  }

  /// 判断扫描到的外设是否为本 session 要连接的目标。
  private func isTargetPeripheral(_ peripheral: ELAILinkPeripheral) -> Bool {
    guard let targetRemoteId = pendingConnectRemoteId else { return false }
    return callbacks.remoteId(peripheral.peripheral) == targetRemoteId
  }

  /// 在连接终态回调前识别关闭或重置状态，并交给插件统一失效全部 session。
  private func invalidateAdapterSessionIfShuttingDown() -> Bool {
    let state = manager.central.state
    guard state == .poweredOff || state == .resetting else { return false }
    ElinkNativeLogger.warning(
      "session adapter invalidated remoteId=\(remoteId) sessionId=\(sessionId) state=\(state.rawValue)"
    )
    callbacks.invalidateAdapterSession(state)
    return true
  }

  /// 判断当前 SDK 回调是否应被丢弃，并在适配器关闭阶段优先触发统一失效。
  private func shouldIgnoreSdkCallback() -> Bool {
    if invalidated { return true }
    return invalidateAdapterSessionIfShuttingDown()
  }

  /// 处理当前 session manager 的蓝牙状态变化。
  func managerDidUpdateState(_ central: CBCentralManager) {
    guard !shouldIgnoreSdkCallback() else { return }
    guard pendingConnectRemoteId != nil, central.state == .poweredOn else {
      return
    }
    ElinkNativeLogger.debug("managerDidUpdateState poweredOn remoteId=\(remoteId) sessionId=\(sessionId)")
    startConnectScan()
  }

  /// 处理当前 session manager 扫描到的单个外设。
  func managerDidDiscover(_ peripheral: ELAILinkPeripheral) {
    guard !shouldIgnoreSdkCallback() else { return }
    connectDiscoveredPeripheral(peripheral)
  }

  /// 处理当前 session manager 批量扫描到的外设。
  func managerDidDiscoverMorePeripheral(_ peripherals: [NSUUID: ELAILinkPeripheral]) {
    guard !shouldIgnoreSdkCallback() else { return }
    peripherals.values.forEach { connectDiscoveredPeripheral($0) }
  }

  /// 处理 AILink SDK 连接成功回调。
  func managerDidConnect(_ peripheral: CBPeripheral) {
    guard !shouldIgnoreSdkCallback() else { return }
    ElinkNativeLogger.info("managerDidConnect remoteId=\(remoteId) sessionId=\(sessionId)")
    connectionReady = false
    callbacks.emitConnection(remoteId, "connecting", nil)
  }

  /// 处理 AILink SDK 连接失败回调。
  func managerDidFail(toConnect peripheral: CBPeripheral, error: Error) {
    guard !shouldIgnoreSdkCallback() else { return }
    ElinkNativeLogger.error(
      "managerDidFail remoteId=\(remoteId) sessionId=\(sessionId) error=\(error.localizedDescription)"
    )
    pendingConnectRemoteId = nil
    connectionReady = false
    disconnecting = false
    clearConnectTimer()
    callbacks.emitConnection(remoteId, "disconnected", error.localizedDescription)
    callbacks.removeSession(remoteId, sessionId)
    completeDisconnectResults()
  }

  /// 处理 AILink SDK 真实断开回调。
  func managerDidDisconnect(_ peripheral: CBPeripheral, error: Error?) {
    guard !shouldIgnoreSdkCallback() else { return }
    ElinkNativeLogger.info(
      "managerDidDisconnect remoteId=\(remoteId) sessionId=\(sessionId) error=\(error?.localizedDescription ?? "")"
    )
    finishDisconnect(error: error)
  }

  func managerDidUpdateConnect(_ state: NELBleManagerConnectState) {
    guard !shouldIgnoreSdkCallback() else { return }
    ElinkNativeLogger.debug(
      "managerDidUpdateConnect remoteId=\(remoteId) sessionId=\(sessionId) state=0x\(String(format: "%02X", state.rawValue))"
    )
    switch state.rawValue {
    case 0x03, 0x04, 0x05:
      guard !disconnecting else {
        ElinkNativeLogger.debug("ignore connecting state while disconnecting remoteId=\(remoteId) sessionId=\(sessionId)")
        return
      }
      callbacks.emitConnection(remoteId, "connecting", nil)
    case 0x06:
      guard !disconnecting else {
        ElinkNativeLogger.debug("ignore passed state while disconnecting remoteId=\(remoteId) sessionId=\(sessionId)")
        return
      }
      pendingConnectRemoteId = nil
      disconnecting = false
      connectionReady = true
      clearConnectTimer()
      callbacks.emitHandshake(remoteId, true)
      callbacks.emitConnection(remoteId, "connected", nil)
    case 0x0F:
      finishSdkTerminalState(state: state.rawValue, reason: "Validation failed", emitHandshakeFailure: true)
    case 0x01:
      finishSdkTerminalState(state: state.rawValue, reason: nil, emitHandshakeFailure: false)
    case 0x02:
      finishSdkTerminalState(state: state.rawValue, reason: "Connection failed", emitHandshakeFailure: false)
    default:
      break
    }
  }

  /// 处理 iOS SDK 连接状态终态，主动断开时等待真实断开回调，非主动断开时清理旧 session。
  private func finishSdkTerminalState(state: Int, reason: String?, emitHandshakeFailure: Bool) {
    if disconnecting {
      if state == 0x01 || currentPeripheral?.state == .disconnected || currentPeripheral == nil {
        finishDisconnect(error: nil)
        return
      }
      ElinkNativeLogger.debug(
        "sdk terminal state while disconnecting remoteId=\(remoteId) sessionId=\(sessionId) state=0x\(String(format: "%02X", state)), wait managerDidDisconnect"
      )
      return
    }
    pendingConnectRemoteId = nil
    connectionReady = false
    disconnecting = false
    clearConnectTimer()
    if emitHandshakeFailure {
      callbacks.emitHandshake(remoteId, false)
    }
    callbacks.emitConnection(remoteId, "disconnected", reason)
    callbacks.removeSession(remoteId, sessionId)
    completeDisconnectResults()
  }

  func managerDidDisconnectError(_ error: Error?) {
    guard !shouldIgnoreSdkCallback() else { return }
    if let error {
      ElinkNativeLogger.error(
        "managerDidDisconnectError remoteId=\(remoteId) sessionId=\(sessionId) error=\(error.localizedDescription)"
      )
      callbacks.emitError("disconnect_error", error.localizedDescription)
    }
  }

  func peripheralDidDiscover(_ services: [CBService]) {
    guard !shouldIgnoreSdkCallback() else { return }
    let serviceUuids = services.map { callbacks.shortUuid($0.uuid) }
    ElinkNativeLogger.debug("peripheralDidDiscover remoteId=\(remoteId) services=\(serviceUuids)")
    callbacks.emitEvent([
      "type": "servicesDiscovered",
      "remoteId": remoteId,
      "serviceUuid": serviceUuids.first ?? "",
      "characteristicUuids": [],
    ])
  }

  func peripheralDidDiscoverCharacteristics(forService characteristics: [CBCharacteristic]) {
    guard !shouldIgnoreSdkCallback() else { return }
    let characteristicUuids = characteristics.map {
      callbacks.shortUuid($0.uuid)
    }
    ElinkNativeLogger.debug(
      "peripheralDidDiscoverCharacteristics remoteId=\(remoteId) characteristics=\(characteristicUuids)"
    )
    callbacks.emitEvent([
      "type": "servicesDiscovered",
      "remoteId": remoteId,
      "serviceUuid": characteristics.first.flatMap { $0.service }.map {
        callbacks.shortUuid($0.uuid)
      } ?? "",
      "characteristicUuids": characteristicUuids,
    ])
  }

  func peripheralDidUpdateNotificationState(forCharacteristic characteristic: CBCharacteristic) {
    guard !shouldIgnoreSdkCallback() else { return }
    ElinkNativeLogger.debug(
      "notificationStateChanged remoteId=\(remoteId) uuid=\(callbacks.shortUuid(characteristic.uuid))"
    )
    callbacks.emitCharacteristicEvent(remoteId, "notificationStateChanged", characteristic)
  }

  func peripheralDidUpdateValue(forCharacteristic characteristic: CBCharacteristic) {
    guard !shouldIgnoreSdkCallback() else { return }
    ElinkNativeLogger.debug("characteristicChanged remoteId=\(remoteId) uuid=\(callbacks.shortUuid(characteristic.uuid))")
    callbacks.emitCharacteristicEvent(remoteId, "changed", characteristic)
  }

  func didWriteValue(forCharacteristic characteristic: CBCharacteristic) {
    guard !shouldIgnoreSdkCallback() else { return }
    ElinkNativeLogger.debug("didWriteValue remoteId=\(remoteId) uuid=\(callbacks.shortUuid(characteristic.uuid))")
    callbacks.emitCharacteristicEvent(remoteId, "write", characteristic)
  }

  func peripheralDidReadRSSI(_ RSSI: NSNumber) {
    guard !shouldIgnoreSdkCallback() else { return }
    ElinkNativeLogger.debug("peripheralDidReadRSSI remoteId=\(remoteId) rssi=\(RSSI.intValue)")
    callbacks.emitRssi(remoteId, RSSI.intValue)
  }

  // 只实现带 peripheral 的协议数据入口，避免 SDK 同时回调多个 optional selector。
  func aiLinkBleReceiveA7Data(_ packet: Data, aILinkPeripheral: ELAILinkPeripheral) {
    guard !shouldIgnoreSdkCallback() else { return }
    let packetRemoteId = callbacks.remoteId(aILinkPeripheral.peripheral)
    ElinkNativeLogger.debug("aiLinkBleReceiveA7Data remoteId=\(packetRemoteId) bytes=\(packet.count)")
    callbacks.emitProtocolData(packet, "a7", packetRemoteId)
  }

  func aiLinkBleReceiveA6Data(_ packet: Data, aILinkPeripheral: ELAILinkPeripheral) {
    guard !shouldIgnoreSdkCallback() else { return }
    let packetRemoteId = callbacks.remoteId(aILinkPeripheral.peripheral)
    let payload = callbacks.normalizeA6ProtocolData(packet)
    ElinkNativeLogger.debug("aiLinkBleReceiveA6Data remoteId=\(packetRemoteId) bytes=\(payload.count)")
    emitBmVersionIfNeeded(remoteId: packetRemoteId, payload: payload)
    callbacks.emitProtocolData(payload, "a6", packetRemoteId)
  }

  func aiLinkBleReceiveRawData(_ rawData: Data, aILinkPeripheral: ELAILinkPeripheral) {
    guard !shouldIgnoreSdkCallback() else { return }
    let packetRemoteId = callbacks.remoteId(aILinkPeripheral.peripheral)
    ElinkNativeLogger.debug("aiLinkBleReceiveRawData remoteId=\(packetRemoteId) bytes=\(rawData.count)")
    callbacks.emitPassthroughData(rawData, packetRemoteId)
  }

  /// 如果 A6 payload 是 BM 版本回包，则读取 SDK 已解析的版本属性并统一回调。
  private func emitBmVersionIfNeeded(remoteId: String, payload: Data) {
    guard let command = payload.first else { return }
    switch command {
    case 0x0E:
      guard !manager.bmVersion.isEmpty else { return }
      callbacks.emitBmVersion(remoteId, manager.bmVersion, Int(command), payload)
    case 0x46:
      guard !manager.bmVersionPro.isEmpty else { return }
      callbacks.emitBmVersion(remoteId, manager.bmVersionPro, Int(command), payload)
    default:
      return
    }
  }
}
