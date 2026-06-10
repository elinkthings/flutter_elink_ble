import AILinkBleSDK
import CoreBluetooth
import Flutter
import UIKit

public class ElinkBlePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private static let methodChannelName = "flutter_elink_ble/methods"
  private static let eventChannelName = "flutter_elink_ble/events"

  private let bleManager = ELAILinkBleManager()
  private var methodChannel: FlutterMethodChannel?
  private var eventSink: FlutterEventSink?
  private var scanTimer: Timer?
  private var scanResults: [String: ELAILinkPeripheral] = [:]
  private var connectedRemoteId: String?
  private var connectionReady = false
  private var lastConnectionEventKeys: [String: String] = [:]
  private var handshakeSeed: Data?
  private var nativeScanRunning = false
  private var suppressedScanStoppedCallbacks = 0

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = ElinkBlePlugin()
    let methodChannel = FlutterMethodChannel(
      name: methodChannelName,
      binaryMessenger: registrar.messenger()
    )
    let eventChannel = FlutterEventChannel(
      name: eventChannelName,
      binaryMessenger: registrar.messenger()
    )
    instance.methodChannel = methodChannel
    methodChannel.setMethodCallHandler(instance.handle)
    eventChannel.setStreamHandler(instance)
  }

  override init() {
    super.init()
    // 将 SDK delegate 生命周期事件桥接到 Flutter EventChannel。
    // Bridge SDK delegate lifecycle events to Flutter EventChannel.
    bleManager.ailinkDelegate = self
  }

  deinit {
    bleManager.ailinkDelegate = nil
  }

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    emitAdapterState()
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isSupported":
      result(true)
    case "getAdapterState":
      result(["state": adapterStateName(bleManager.central.state)])
    case "openBluetooth":
      openBluetooth(result: result)
    case "startScan":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "bad_args", message: "Missing scan arguments", details: nil))
        return
      }
      let timeoutMs = args["timeoutMs"] as? Int ?? 10000
      let services = args["withServices"] as? [String] ?? []
      startScan(timeoutMs: timeoutMs, withServices: services, result: result)
    case "stopScan":
      stopScan()
      result(nil)
    case "connect":
      guard
        let args = call.arguments as? [String: Any],
        let remoteId = args["remoteId"] as? String
      else {
        result(FlutterError(code: "bad_args", message: "Missing remoteId", details: nil))
        return
      }
      connect(remoteId: remoteId)
      result(nil)
    case "disconnect":
      guard
        let args = call.arguments as? [String: Any],
        let remoteId = args["remoteId"] as? String
      else {
        result(FlutterError(code: "bad_args", message: "Missing remoteId", details: nil))
        return
      }
      disconnect(remoteId: remoteId)
      result(nil)
    case "disconnectCurrent":
      disconnectCurrent()
      result(nil)
    case "readRssi":
      guard
        let args = call.arguments as? [String: Any],
        let remoteId = args["remoteId"] as? String
      else {
        result(FlutterError(code: "bad_args", message: "Missing remoteId", details: nil))
        return
      }
      readRssi(remoteId: remoteId)
      result(nil)
    case "getIosMtu":
      guard
        let args = call.arguments as? [String: Any],
        let remoteId = args["remoteId"] as? String
      else {
        result(FlutterError(code: "bad_args", message: "Missing remoteId", details: nil))
        return
      }
      getIosMtu(remoteId: remoteId, result: result)
    case "setAndroidMtu", "setAndroidPreferredPhy":
      result(
        FlutterError(
          code: "unsupported_platform",
          message: "\(call.method) is only supported on Android",
          details: nil
        )
      )
    case "write":
      guard
        let args = call.arguments as? [String: Any],
        let remoteId = args["remoteId"] as? String,
        let data = args["data"] as? FlutterStandardTypedData
      else {
        result(FlutterError(code: "bad_args", message: "Missing write arguments", details: nil))
        return
      }
      write(data: data.data, remoteId: remoteId)
      result(nil)
    case "writeA6":
      guard
        let args = call.arguments as? [String: Any],
        let remoteId = args["remoteId"] as? String,
        let payload = args["payload"] as? FlutterStandardTypedData
      else {
        result(FlutterError(code: "bad_args", message: "Missing A6 payload", details: nil))
        return
      }
      writeA6(payload: payload.data, remoteId: remoteId)
      result(nil)
    case "writeA7":
      guard
        let args = call.arguments as? [String: Any],
        let remoteId = args["remoteId"] as? String,
        let payload = args["payload"] as? FlutterStandardTypedData
      else {
        result(FlutterError(code: "bad_args", message: "Missing A7 payload", details: nil))
        return
      }
      writeA7(payload: payload.data, remoteId: remoteId)
      result(nil)
    case "decryptBroadcast":
      guard let payload = call.arguments as? FlutterStandardTypedData else {
        result(FlutterStandardTypedData(bytes: Data()))
        return
      }
      result(FlutterStandardTypedData(bytes: decryptBroadcast(payload.data)))
    case "initHandshake":
      let packet = ELEncryptTool.handshake()
      handshakeSeed = handshakePayload(from: packet)
      result(FlutterStandardTypedData(bytes: packet))
    case "getHandshakeEncryptData":
      guard let payload = call.arguments as? FlutterStandardTypedData else {
        result(FlutterStandardTypedData(bytes: Data()))
        return
      }
      let receiveData = handshakePayload(from: payload.data) ?? payload.data
      result(
        FlutterStandardTypedData(
          bytes: ELEncryptTool.blueToothHandshake(with: receiveData)
        )
      )
    case "checkHandshakeStatus":
      guard
        let seed = handshakeSeed,
        let receiveData = handshakePayload(from: (call.arguments as? FlutterStandardTypedData)?.data ?? Data())
      else {
        result(false)
        return
      }
      result(ELEncryptTool.encryptTEA(seed) == receiveData)
    case "mcuEncrypt":
      if
        let args = call.arguments as? [String: Any],
        let payload = args["payload"] as? FlutterStandardTypedData
      {
        let cid = args["cid"] as? FlutterStandardTypedData
        let mac = args["mac"] as? FlutterStandardTypedData
        result(
          FlutterStandardTypedData(
            bytes: ELEncryptTool.encryptXOR(
              mac?.data ?? Data(),
              deviceTypeXOR: cid?.data ?? Data(),
              withXORData: payload.data
            )
          )
        )
      } else {
        result(FlutterStandardTypedData(bytes: Data()))
      }
    case "mcuDecrypt":
      if
        let args = call.arguments as? [String: Any],
        let payload = args["payload"] as? FlutterStandardTypedData
      {
        let mac = args["mac"] as? FlutterStandardTypedData
        let cid = payload.data.count >= 3
          ? payload.data.subdata(in: 1..<3)
          : Data()
        let data = payload.data.count > 4
          ? payload.data.subdata(in: 4..<(payload.data.count - 2))
          : payload.data
        result(
          FlutterStandardTypedData(
            bytes: ELEncryptTool.encryptXOR(
              mac?.data ?? Data(),
              deviceTypeXOR: cid,
              withXORData: data
            )
          )
        )
      } else {
        result(FlutterStandardTypedData(bytes: Data()))
      }
    case "dispose":
      disposeSdkResources()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// iOS 不允许 App 直接开启蓝牙，这里只回传当前蓝牙状态。
  /// iOS cannot enable Bluetooth directly; this only publishes current state.
  private func openBluetooth(result: @escaping FlutterResult) {
    emitAdapterState()
    result(nil)
  }

  private func startScan(
    timeoutMs: Int,
    withServices: [String],
    result: @escaping FlutterResult
  ) {
    waitForBluetoothReady(attemptsRemaining: 8) { [weak self] state in
      guard let self else {
        result(FlutterError(code: "plugin_disposed", message: "BLE plugin was disposed", details: nil))
        return
      }
      self.emitAdapterState()
      guard state == .poweredOn else {
        let code = self.bluetoothErrorCode(for: state)
        let message = self.bluetoothErrorMessage(for: state)
        self.emitError(code: code, message: message)
        result(FlutterError(code: code, message: message, details: ["state": self.adapterStateName(state)]))
        return
      }
      self.startScanNow(timeoutMs: timeoutMs, withServices: withServices)
      result(nil)
    }
  }

  private func startScanNow(timeoutMs: Int, withServices: [String]) {
    stopScan(emitStopped: false)
    scanResults.removeAll()
    // 使用 AILink SDK 扫描实现。Dart service filters 是 UUID 语义。
    // Use AILink SDK scan implementation. Dart service filters are UUID-based.
    let serviceUuids = withServices.compactMap { CBUUID(string: $0) }
    if serviceUuids.isEmpty {
      bleManager.scanAll()
    } else {
      bleManager.scan(withServices: serviceUuids, options: nil)
    }
    nativeScanRunning = true
    scanTimer = Timer.scheduledTimer(
      withTimeInterval: TimeInterval(timeoutMs) / 1000.0,
      repeats: false
    ) { [weak self] _ in
      self?.stopScan()
    }
  }

  private func waitForBluetoothReady(
    attemptsRemaining: Int,
    completion: @escaping (CBManagerState) -> Void
  ) {
    let state = bleManager.central.state
    if state == .poweredOn || state == .poweredOff || state == .unauthorized || state == .unsupported {
      completion(state)
      return
    }
    guard attemptsRemaining > 0 else {
      completion(state)
      return
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      guard let self else {
        completion(.unknown)
        return
      }
      self.waitForBluetoothReady(attemptsRemaining: attemptsRemaining - 1, completion: completion)
    }
  }

  private func stopScan(emitStopped: Bool = true) {
    scanTimer?.invalidate()
    scanTimer = nil
    let wasRunning = nativeScanRunning
    if !emitStopped && wasRunning {
      suppressedScanStoppedCallbacks += 1
    }
    nativeScanRunning = false
    bleManager.stopScan()
    if emitStopped && wasRunning {
      emit(["type": "scanStopped"])
    }
  }

  private func connect(remoteId: String) {
    guard let peripheral = scanResults[remoteId] else {
      emitError(code: "device_not_found", message: "Device not found: \(remoteId)")
      return
    }
    stopScan()
    connectedRemoteId = remoteId
    connectionReady = false
    handshakeSeed = nil
    emitConnection(remoteId: remoteId, state: "connecting")
    bleManager.connect(peripheral)
  }

  private func disconnect(remoteId: String) {
    guard connectedRemoteId == remoteId else { return }
    emitConnection(remoteId: remoteId, state: "disconnecting")
    connectionReady = false
    handshakeSeed = nil
    bleManager.disconnectPeripheral()
  }

  private func disconnectCurrent() {
    guard let remoteId = connectedRemoteId else { return }
    disconnect(remoteId: remoteId)
  }

  private func readRssi(remoteId: String) {
    guard connectedRemoteId == remoteId, connectionReady else {
      emitError(code: "device_not_connected", message: "Device is not connected: \(remoteId)")
      return
    }
    bleManager.readRSSI()
  }

  /// 获取 iOS 当前连接外设的最大单次写入 payload 长度。
  /// Get maximum one-shot write payload lengths for the current iOS peripheral.
  private func getIosMtu(remoteId: String, result: @escaping FlutterResult) {
    guard
      connectedRemoteId == remoteId,
      connectionReady,
      let peripheral = bleManager.currentAILinkPeripheral()?.peripheral
    else {
      result(
        FlutterError(
          code: "device_not_connected",
          message: "Device is not connected: \(remoteId)",
          details: nil
        )
      )
      return
    }
    result([
      "remoteId": remoteId,
      "maxWriteWithoutResponse": peripheral.maximumWriteValueLength(for: .withoutResponse),
      "maxWriteWithResponse": peripheral.maximumWriteValueLength(for: .withResponse),
    ])
  }

  private func write(data: Data, remoteId: String) {
    guard ensureCanWrite(remoteId: remoteId) else {
      return
    }
    // 透传写入统一交给 AILink SDK 管理队列和 characteristic。
    // Raw write uses the AILink SDK queue and characteristic handling.
    bleManager.sendCmd(data)
  }

  private func writeA6(payload: Data, remoteId: String) {
    guard ensureCanWrite(remoteId: remoteId) else {
      return
    }
    bleManager.sendA6Payload(payload)
  }

  private func writeA7(payload: Data, remoteId: String) {
    guard ensureCanWrite(remoteId: remoteId) else {
      return
    }
    bleManager.sendA7Payload(payload)
  }

  private func disposeSdkResources() {
    stopScan(emitStopped: false)
    bleManager.disconnectPeripheral()
    scanResults.removeAll()
    connectedRemoteId = nil
    connectionReady = false
    handshakeSeed = nil
    lastConnectionEventKeys.removeAll()
  }

  private func emitAdapterState() {
    emit(["type": "adapterState", "state": adapterStateName(bleManager.central.state)])
  }

  private func decryptBroadcast(_ payload: Data) -> Data {
    guard payload.count >= 20 else { return payload }
    let bytes = [UInt8](payload)
    let cid = bytes[0]
    let vid = bytes[1]
    let pid = bytes[2]
    let sum = bytes[9]
    let encrypted = payload.subdata(in: 10..<20)
    let check = [UInt8](encrypted).reduce(UInt8(0)) { partial, byte in
      partial &+ byte
    }
    guard sum == check else { return payload }
    return ELEncryptTool.broadcastDecryptTEA(encrypted, cid: cid, vid: vid, pid: pid)
  }

  private func handshakePayload(from packet: Data) -> Data? {
    // SDK 握手包是完整 A6 包；用于校验/加密的是第 3~18 位 payload。
    // SDK handshake packets are A6 full packets; the encrypted payload lives at byte 3...18.
    if packet.count == 16 {
      return packet
    }
    guard packet.count >= 19 else {
      return nil
    }
    return packet.subdata(in: 3..<19)
  }

  private func normalizeA6ProtocolData(_ packet: Data) -> Data {
    if let payload = a6Payload(from: packet) {
      return payload
    }
    if packet.count > 1, packet.first == 0xA6, packet[packet.index(packet.startIndex, offsetBy: 1)] == 0xA6 {
      let withoutExtraHead = packet.dropFirst()
      if let payload = a6Payload(from: Data(withoutExtraHead)) {
        return payload
      }
    }
    return packet
  }

  private func a6Payload(from packet: Data) -> Data? {
    guard packet.count >= 4 else {
      return nil
    }
    let bytes = [UInt8](packet)
    guard bytes.first == 0xA6, bytes.last == 0x6A else {
      return nil
    }
    let payloadLength = Int(bytes[1])
    guard packet.count == payloadLength + 4 else {
      return nil
    }
    let checksumBytes = bytes[1..<(bytes.count - 2)]
    let checksum = checksumBytes.reduce(UInt8(0)) { partial, byte in
      partial &+ byte
    }
    guard checksum == bytes[bytes.count - 2] else {
      return nil
    }
    return packet.subdata(in: 2..<(2 + payloadLength))
  }

  private func remoteId(for peripheral: CBPeripheral) -> String {
    peripheral.identifier.uuidString
  }

  private func currentRemoteId() -> String {
    if let peripheral = bleManager.currentAILinkPeripheral()?.peripheral {
      return remoteId(for: peripheral)
    }
    return connectedRemoteId ?? ""
  }

  private func ensureCanWrite(remoteId: String) -> Bool {
    guard connectedRemoteId == remoteId, connectionReady else {
      emitError(code: "device_not_connected", message: "Device is not connected: \(remoteId)")
      return false
    }
    return true
  }

  private func emitScanResult(_ peripheral: ELAILinkPeripheral) {
    let cbPeripheral = peripheral.peripheral
    let remoteId = remoteId(for: cbPeripheral)
    scanResults[remoteId] = peripheral
    let advertisementData = peripheral.value(forKey: "advertisementData") as? [String: Any] ?? [:]
    let rssi = (peripheral.value(forKey: "RSSI") as? NSNumber)?.intValue ?? 0
    let serviceUuids = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] ?? [])
      .map { shortUuid($0) }
    let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data ?? Data()
    let advName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? cbPeripheral.name ?? ""
    emit([
      "type": "scanResult",
      "remoteId": remoteId,
      "platformName": cbPeripheral.name ?? advName,
      "macAddress": peripheral.macAddressString,
      "macData": FlutterStandardTypedData(bytes: peripheral.macData),
      "rssi": rssi,
      "advertisementData": [
        "advName": advName,
        "serviceUuids": serviceUuids,
        "manufacturerData": FlutterStandardTypedData(bytes: manufacturerData),
      ],
    ])
  }

  private func emitConnection(remoteId: String, state: String, reason: String? = nil) {
    let eventKey = "\(state)|\(reason ?? "")"
    if lastConnectionEventKeys[remoteId] == eventKey {
      return
    }
    lastConnectionEventKeys[remoteId] = eventKey
    emit([
      "type": "connectionState",
      "remoteId": remoteId,
      "state": state,
      "reason": reason as Any,
    ])
  }

  private func emitProtocolData(
    _ data: Data,
    protocolName: String,
    remoteId: String? = nil,
    characteristicUuid: String = "",
    deviceType: Int? = nil
  ) {
    let resolvedRemoteId = remoteId ?? connectedRemoteId ?? ""
    emit([
      "type": "protocolData",
      "remoteId": resolvedRemoteId,
      "protocol": protocolName,
      "characteristicUuid": characteristicUuid,
      "deviceType": deviceType as Any,
      "data": FlutterStandardTypedData(bytes: data),
    ])
  }

  private func emitPassthroughData(
    _ data: Data,
    remoteId: String? = nil,
    characteristicUuid: String = ""
  ) {
    let resolvedRemoteId = remoteId ?? connectedRemoteId ?? ""
    emit([
      "type": "passthroughData",
      "remoteId": resolvedRemoteId,
      "characteristicUuid": characteristicUuid,
      "data": FlutterStandardTypedData(bytes: data),
    ])
  }

  private func emitCharacteristicEvent(
    operation: String,
    characteristic: CBCharacteristic
  ) {
    emit([
      "type": "characteristicEvent",
      "remoteId": currentRemoteId(),
      "operation": operation,
      "serviceUuid": characteristic.service.map { shortUuid($0.uuid) } ?? "",
      "characteristicUuid": shortUuid(characteristic.uuid),
      "descriptorUuid": "",
      "data": FlutterStandardTypedData(bytes: characteristic.value ?? Data()),
    ])
  }

  private func emitRssi(remoteId: String, rssi: Int) {
    emit(["type": "rssi", "remoteId": remoteId, "rssi": rssi])
  }

  private func emitError(code: String, message: String) {
    emit(["type": "error", "code": code, "message": message])
  }

  private func emit(_ event: [String: Any]) {
    DispatchQueue.main.async { [weak self] in
      self?.eventSink?(event)
    }
  }

  private func adapterStateName(_ state: CBManagerState) -> String {
    switch state {
    case .poweredOn:
      return "on"
    case .poweredOff:
      return "off"
    case .unauthorized:
      return "unauthorized"
    case .unsupported:
      return "unavailable"
    case .resetting:
      return "turningOff"
    case .unknown:
      return "unknown"
    @unknown default:
      return "unknown"
    }
  }

  private func bluetoothErrorCode(for state: CBManagerState) -> String {
    switch state {
    case .poweredOff:
      return "bluetooth_off"
    case .unauthorized:
      return "bluetooth_unauthorized"
    case .unsupported:
      return "bluetooth_unsupported"
    case .resetting, .unknown:
      return "bluetooth_not_ready"
    case .poweredOn:
      return "ok"
    @unknown default:
      return "bluetooth_not_ready"
    }
  }

  private func bluetoothErrorMessage(for state: CBManagerState) -> String {
    switch state {
    case .poweredOff:
      return "Bluetooth is powered off"
    case .unauthorized:
      return "Bluetooth permission is not authorized"
    case .unsupported:
      return "Bluetooth LE is not supported on this device"
    case .resetting:
      return "Bluetooth adapter is resetting"
    case .unknown:
      return "Bluetooth adapter is not ready"
    case .poweredOn:
      return "Bluetooth is powered on"
    @unknown default:
      return "Bluetooth adapter is not ready"
    }
  }

  private func shortUuid(_ uuid: CBUUID) -> String {
    let text = uuid.uuidString.uppercased()
    if text.hasPrefix("0000") && text.hasSuffix("-0000-1000-8000-00805F9B34FB") {
      let start = text.index(text.startIndex, offsetBy: 4)
      let end = text.index(text.startIndex, offsetBy: 8)
      return String(text[start..<end])
    }
    return text
  }
}

extension ElinkBlePlugin: ELAILinkBleManagerDelegate {
  public func managerDidUpdateState(_ central: CBCentralManager) {
    // 蓝牙开关、权限、不可用等状态变化。
    // Bluetooth power, permission, and availability state changes.
    emitAdapterState()
  }

  public func managerScanState(_ scanning: Bool) {
    if scanning {
      nativeScanRunning = true
    } else if suppressedScanStoppedCallbacks > 0 {
      suppressedScanStoppedCallbacks -= 1
    } else if nativeScanRunning {
      nativeScanRunning = false
      emit(["type": "scanStopped"])
    }
  }

  public func managerDidDiscover(_ peripheral: ELAILinkPeripheral) {
    emitScanResult(peripheral)
  }

  public func managerDidDiscoverMorePeripheral(_ peripherals: [NSUUID: ELAILinkPeripheral]) {
    peripherals.values.forEach { emitScanResult($0) }
  }

  public func managerDidConnect(_ peripheral: CBPeripheral) {
    let id = remoteId(for: peripheral)
    connectedRemoteId = id
    connectionReady = false
    // SDK Sample 将 `Passed` 视为可用；物理 BLE 连接此时仍在握手。
    // The SDK sample treats `Passed` as ready while the physical BLE link is still handshaking.
    emitConnection(remoteId: id, state: "connecting")
  }

  public func managerDidFail(toConnect peripheral: CBPeripheral, error: Error) {
    let id = remoteId(for: peripheral)
    emitConnection(remoteId: id, state: "disconnected", reason: error.localizedDescription)
    if connectedRemoteId == id {
      connectedRemoteId = nil
      connectionReady = false
      handshakeSeed = nil
    }
  }

  public func managerDidDisconnect(_ peripheral: CBPeripheral, error: Error?) {
    let id = remoteId(for: peripheral)
    emitConnection(remoteId: id, state: "disconnected", reason: error?.localizedDescription)
    if connectedRemoteId == id {
      connectedRemoteId = nil
      connectionReady = false
      handshakeSeed = nil
    }
  }

  public func managerDidUpdateConnect(_ state: NELBleManagerConnectState) {
    guard let remoteId = connectedRemoteId else { return }
    switch state.rawValue {
    case 0x03, 0x04, 0x05:
      emitConnection(remoteId: remoteId, state: "connecting")
    case 0x06:
      connectionReady = true
      emitConnection(remoteId: remoteId, state: "connected")
    case 0x01, 0x02, 0x0F:
      emitConnection(remoteId: remoteId, state: "disconnected")
      connectedRemoteId = nil
      connectionReady = false
      handshakeSeed = nil
    default:
      break
    }
  }

  public func managerDidDisconnectError(_ error: Error?) {
    if let error {
      emitError(code: "disconnect_error", message: error.localizedDescription)
    }
  }

  public func peripheralDidDiscover(_ services: [CBService]) {
    let serviceUuids = services.map { shortUuid($0.uuid) }
    emit([
      "type": "servicesDiscovered",
      "remoteId": currentRemoteId(),
      "serviceUuid": serviceUuids.first ?? "",
      "characteristicUuids": [],
    ])
  }

  public func peripheralDidDiscoverCharacteristics(forService characteristics: [CBCharacteristic]) {
    let characteristicUuids = characteristics.map { shortUuid($0.uuid) }
    emit([
      "type": "servicesDiscovered",
      "remoteId": currentRemoteId(),
      "serviceUuid": characteristics.first.flatMap { $0.service }.map { shortUuid($0.uuid) } ?? "",
      "characteristicUuids": characteristicUuids,
    ])
  }

  public func peripheralDidUpdateNotificationState(forCharacteristic characteristic: CBCharacteristic) {
    emitCharacteristicEvent(operation: "notificationStateChanged", characteristic: characteristic)
  }

  public func peripheralDidUpdateValue(forCharacteristic characteristic: CBCharacteristic) {
    emitCharacteristicEvent(operation: "changed", characteristic: characteristic)
  }

  public func didWriteValue(forCharacteristic characteristic: CBCharacteristic) {
    emitCharacteristicEvent(operation: "write", characteristic: characteristic)
  }

  public func peripheralDidReadRSSI(_ RSSI: NSNumber) {
    emitRssi(remoteId: currentRemoteId(), rssi: RSSI.intValue)
  }

  // 只实现带 peripheral 的协议数据入口，避免 SDK 同时回调多个 optional selector。
  // Implement only the per-peripheral data callbacks to avoid duplicate optional-selector callbacks.
  public func aiLinkBleReceiveA7Data(_ packet: Data, aILinkPeripheral: ELAILinkPeripheral) {
    let remoteId = remoteId(for: aILinkPeripheral.peripheral)
    emitProtocolData(packet, protocolName: "a7", remoteId: remoteId)
  }

  public func aiLinkBleReceiveA6Data(_ packet: Data, aILinkPeripheral: ELAILinkPeripheral) {
    let remoteId = remoteId(for: aILinkPeripheral.peripheral)
    let payload = normalizeA6ProtocolData(packet)
    emitProtocolData(payload, protocolName: "a6", remoteId: remoteId)
  }

  public func aiLinkBleReceiveRawData(_ rawData: Data, aILinkPeripheral: ELAILinkPeripheral) {
    let remoteId = remoteId(for: aILinkPeripheral.peripheral)
    emitPassthroughData(rawData, remoteId: remoteId)
  }
}
