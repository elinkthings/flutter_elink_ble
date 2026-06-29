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
  private var lastScanServiceUuids: [CBUUID] = []
  private var deviceSessions: [String: ElinkIosDeviceSession] = [:]
  private var lastConnectionEventKeys: [String: String] = [:]
  private var handshakeSeeds: [String: Data] = [:]
  private var defaultHandshakeSeed: Data?
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
      let timeoutMs = args["timeoutMs"] as? Int ?? 15000
      connect(remoteId: remoteId, timeoutMs: timeoutMs)
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
    case "setAndroidCommandResendCount":
      // Android 专用重发配置；iOS 侧无对应 SDK 能力，保持 no-op 以稳定跨端调用。
      result(nil)
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
    case "getBmVersion":
      guard
        let args = call.arguments as? [String: Any],
        let remoteId = args["remoteId"] as? String
      else {
        result(FlutterError(code: "bad_args", message: "Missing remoteId", details: nil))
        return
      }
      getBmVersion(remoteId: remoteId)
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
      storeHandshakeSeed(
        handshakePayload(from: packet),
        remoteId: remoteIdArgument(from: call.arguments)
      )
      result(FlutterStandardTypedData(bytes: packet))
    case "getHandshakeEncryptData":
      guard let payload = handshakePayloadArgument(from: call.arguments) else {
        result(FlutterStandardTypedData(bytes: Data()))
        return
      }
      let receiveData = handshakePayload(from: payload) ?? payload
      result(
        FlutterStandardTypedData(
          bytes: ELEncryptTool.blueToothHandshake(with: receiveData)
        )
      )
    case "checkHandshakeStatus":
      guard
        let seed = handshakeSeed(for: remoteIdArgument(from: call.arguments)),
        let payload = handshakePayloadArgument(from: call.arguments),
        let receiveData = handshakePayload(from: payload)
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
    lastScanServiceUuids = serviceUuids
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

  /// 使用独立 iOS session 连接指定 remoteId。
  private func connect(remoteId: String, timeoutMs: Int) {
    guard let peripheral = scanResults[remoteId] else {
      emitError(code: "device_not_found", message: "Device not found: \(remoteId)")
      return
    }
    clearHandshakeSeed(remoteId: remoteId)
    let session = deviceSessions[remoteId] ?? ElinkIosDeviceSession(
      remoteId: remoteId,
      callbacks: makeDeviceSessionCallbacks()
    )
    deviceSessions[remoteId] = session
    session.connect(
      knownPeripheral: peripheral,
      timeoutMs: timeoutMs,
      scanServices: lastScanServiceUuids
    )
  }

  private func disconnect(remoteId: String) {
    guard let session = deviceSessions[remoteId] else { return }
    session.disconnect()
  }

  private func readRssi(remoteId: String) {
    guard let session = readySession(remoteId: remoteId) else { return }
    session.readRssi()
  }

  /// 获取指定 iOS 外设的最大单次写入 payload 长度。
  /// Get maximum one-shot write payload lengths for the selected iOS peripheral.
  private func getIosMtu(remoteId: String, result: @escaping FlutterResult) {
    guard let session = readySession(remoteId: remoteId),
          let peripheral = session.currentPeripheral else {
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
    guard let session = readySession(remoteId: remoteId) else { return }
    // 透传写入统一交给 AILink SDK 管理队列和 characteristic。
    // Raw write uses the AILink SDK queue and characteristic handling.
    session.write(data)
  }

  private func writeA6(payload: Data, remoteId: String) {
    guard let session = readySession(remoteId: remoteId) else { return }
    session.writeA6(payload)
  }

  /// 通过 iOS SDK 增强版 0x46 指令查询 BM 版本。
  private func getBmVersion(remoteId: String) {
    guard let session = readySession(remoteId: remoteId) else { return }
    session.getBmVersion()
  }

  private func writeA7(payload: Data, remoteId: String) {
    guard let session = readySession(remoteId: remoteId) else { return }
    session.writeA7(payload)
  }

  private func disposeSdkResources() {
    stopScan(emitStopped: false)
    deviceSessions.values.forEach { $0.dispose() }
    scanResults.removeAll()
    deviceSessions.removeAll()
    lastScanServiceUuids.removeAll()
    handshakeSeeds.removeAll()
    defaultHandshakeSeed = nil
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

  /// 从 MethodChannel 参数中读取可选 remoteId。
  private func remoteIdArgument(from arguments: Any?) -> String? {
    let remoteId = (arguments as? [String: Any])?["remoteId"] as? String
    return remoteId?.isEmpty == false ? remoteId : nil
  }

  /// 从 MethodChannel 参数中读取握手 payload，兼容旧版直接传二进制参数。
  private func handshakePayloadArgument(from arguments: Any?) -> Data? {
    if let payload = arguments as? FlutterStandardTypedData {
      return payload.data
    }
    return ((arguments as? [String: Any])?["payload"] as? FlutterStandardTypedData)?.data
  }

  /// 保存握手 seed；带 remoteId 时按设备隔离，缺省时保留旧版全局行为。
  private func storeHandshakeSeed(_ seed: Data?, remoteId: String?) {
    guard let seed else { return }
    if let remoteId {
      handshakeSeeds[remoteId] = seed
      return
    }
    defaultHandshakeSeed = seed
  }

  /// 获取握手 seed；优先按 remoteId 获取，缺省时使用旧版全局 seed。
  private func handshakeSeed(for remoteId: String?) -> Data? {
    if let remoteId {
      return handshakeSeeds[remoteId]
    }
    return defaultHandshakeSeed
  }

  /// 清理指定设备的握手 seed。
  private func clearHandshakeSeed(remoteId: String) {
    handshakeSeeds.removeValue(forKey: remoteId)
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

  /// 获取已就绪的 iOS 连接 session；未就绪时统一发出错误事件。
  private func readySession(remoteId: String) -> ElinkIosDeviceSession? {
    guard let session = deviceSessions[remoteId], session.connectionReady else {
      emitError(code: "device_not_connected", message: "Device is not connected: \(remoteId)")
      return nil
    }
    return session
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

  /// 上报原生 SDK 握手状态给 Dart 层。
  private func emitHandshake(remoteId: String, success: Bool) {
    emit([
      "type": "handshake",
      "remoteId": remoteId,
      "success": success,
    ])
  }

  /// 上报原生 SDK 解析后的 BM 版本。
  private func emitBmVersion(
    remoteId: String,
    version: String,
    command: Int,
    rawPayload: Data
  ) {
    emit([
      "type": "bmVersion",
      "remoteId": remoteId,
      "version": version,
      "command": command,
      "rawPayload": FlutterStandardTypedData(bytes: rawPayload),
    ])
  }

  private func emitProtocolData(
    _ data: Data,
    protocolName: String,
    remoteId: String? = nil,
    characteristicUuid: String = "",
    deviceType: Int? = nil
  ) {
    let resolvedRemoteId = remoteId ?? ""
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
    let resolvedRemoteId = remoteId ?? ""
    emit([
      "type": "passthroughData",
      "remoteId": resolvedRemoteId,
      "characteristicUuid": characteristicUuid,
      "data": FlutterStandardTypedData(bytes: data),
    ])
  }

  private func emitCharacteristicEvent(
    remoteId: String,
    operation: String,
    characteristic: CBCharacteristic
  ) {
    emit([
      "type": "characteristicEvent",
      "remoteId": remoteId,
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

  /// 创建 iOS 单设备 session 回调，避免 session 直接访问插件私有实现。
  private func makeDeviceSessionCallbacks() -> ElinkIosDeviceSessionCallbacks {
    return ElinkIosDeviceSessionCallbacks(
      emitConnection: { [weak self] remoteId, state, reason in
        self?.emitConnection(remoteId: remoteId, state: state, reason: reason)
      },
      emitHandshake: { [weak self] remoteId, success in
        self?.emitHandshake(remoteId: remoteId, success: success)
      },
      emitBmVersion: { [weak self] remoteId, version, command, rawPayload in
        self?.emitBmVersion(
          remoteId: remoteId,
          version: version,
          command: command,
          rawPayload: rawPayload
        )
      },
      emitError: { [weak self] code, message in
        self?.emitError(code: code, message: message)
      },
      emitEvent: { [weak self] event in
        self?.emit(event)
      },
      emitCharacteristicEvent: { [weak self] remoteId, operation, characteristic in
        self?.emitCharacteristicEvent(
          remoteId: remoteId,
          operation: operation,
          characteristic: characteristic
        )
      },
      emitRssi: { [weak self] remoteId, rssi in
        self?.emitRssi(remoteId: remoteId, rssi: rssi)
      },
      emitProtocolData: { [weak self] data, protocolName, remoteId in
        self?.emitProtocolData(data, protocolName: protocolName, remoteId: remoteId)
      },
      emitPassthroughData: { [weak self] data, remoteId in
        self?.emitPassthroughData(data, remoteId: remoteId)
      },
      removeSession: { [weak self] remoteId in
        self?.removeDeviceSession(remoteId: remoteId)
      },
      remoteId: { peripheral in
        peripheral.identifier.uuidString
      },
      shortUuid: { [weak self] uuid in
        self?.shortUuid(uuid) ?? uuid.uuidString
      },
      normalizeA6ProtocolData: { [weak self] packet in
        self?.normalizeA6ProtocolData(packet) ?? packet
      }
    )
  }

  /// 移除指定 iOS 设备连接 session。
  private func removeDeviceSession(remoteId: String) {
    clearHandshakeSeed(remoteId: remoteId)
    deviceSessions.removeValue(forKey: remoteId)?.clearDelegate()
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
}

/// iOS 单设备连接会话回调集合，由插件注入以保持访问控制收敛。
private struct ElinkIosDeviceSessionCallbacks {
  let emitConnection: (String, String, String?) -> Void
  let emitHandshake: (String, Bool) -> Void
  let emitBmVersion: (String, String, Int, Data) -> Void
  let emitError: (String, String) -> Void
  let emitEvent: ([String: Any]) -> Void
  let emitCharacteristicEvent: (String, String, CBCharacteristic) -> Void
  let emitRssi: (String, Int) -> Void
  let emitProtocolData: (Data, String, String) -> Void
  let emitPassthroughData: (Data, String) -> Void
  let removeSession: (String) -> Void
  let remoteId: (CBPeripheral) -> String
  let shortUuid: (CBUUID) -> String
  let normalizeA6ProtocolData: (Data) -> Data
}

/// iOS 单设备连接会话，每个 remoteId 使用独立 ELAILinkBleManager，避免 current peripheral 覆盖多连状态。
private final class ElinkIosDeviceSession: NSObject, ELAILinkBleManagerDelegate {
  private let manager = ELAILinkBleManager()
  private let remoteId: String
  private let callbacks: ElinkIosDeviceSessionCallbacks
  private var ailinkPeripheral: ELAILinkPeripheral?
  private var pendingConnectRemoteId: String?
  private var pendingScanServices: [CBUUID] = []
  private var connectTimer: Timer?
  private(set) var connectionReady = false

  /// 创建指定 remoteId 的 iOS 连接会话。
  init(remoteId: String, callbacks: ElinkIosDeviceSessionCallbacks) {
    self.remoteId = remoteId
    self.callbacks = callbacks
    super.init()
    manager.ailinkDelegate = self
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
  func disconnect() {
    callbacks.emitConnection(remoteId, "disconnecting", nil)
    connectionReady = false
    pendingConnectRemoteId = nil
    clearConnectTimer()
    manager.stopScan()
    manager.disconnectPeripheral()
  }

  /// 主动读取当前 session 的 RSSI。
  func readRssi() {
    manager.readRSSI()
  }

  /// 向当前 session 发送完整 BLE 指令。
  func write(_ data: Data) {
    manager.sendCmd(data)
  }

  /// 向当前 session 发送 A6 payload。
  func writeA6(_ payload: Data) {
    manager.sendA6Payload(payload)
  }

  /// 查询增强版 BM 模块版本，使用 SDK `0x46` 指令入口。
  func getBmVersion() {
    manager.getBluetoothInfo(with: .cmdTypeGetBMVersionPro)
  }

  /// 向当前 session 发送 A7 payload。
  func writeA7(_ payload: Data) {
    manager.sendA7Payload(payload)
  }

  /// 释放 session 资源并断开代理。
  func dispose() {
    connectionReady = false
    pendingConnectRemoteId = nil
    clearConnectTimer()
    manager.stopScan()
    manager.disconnectPeripheral()
    manager.ailinkDelegate = nil
  }

  /// 清理 SDK delegate，避免 session 移除后继续回调插件。
  func clearDelegate() {
    clearConnectTimer()
    manager.ailinkDelegate = nil
  }

  /// 等待当前 session 的蓝牙 manager 可用后优先快速连接，未命中再启动目标扫描。
  private func startConnectWhenBluetoothReady(attemptsRemaining: Int) {
    switch manager.central.state {
    case .poweredOn:
      if !connectRetrievedPeripheralIfAvailable() {
        startConnectScan()
      }
    case .poweredOff:
      finishConnectFailure("Bluetooth is powered off")
    case .unauthorized:
      finishConnectFailure("Bluetooth permission is not authorized")
    case .unsupported:
      finishConnectFailure("Bluetooth LE is not supported on this device")
    case .resetting, .unknown:
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
      return false
    }
    connectPeripheral(
      copyAILinkPeripheral(from: knownPeripheral, peripheral: cbPeripheral)
    )
    return true
  }

  /// 使用当前 session 的 manager 扫描待连接的目标设备。
  private func startConnectScan() {
    guard pendingConnectRemoteId != nil else { return }
    if pendingScanServices.isEmpty {
      manager.scanAll()
      return
    }
    manager.scan(withServices: pendingScanServices, options: nil)
  }

  /// 如果扫描结果匹配目标 remoteId，则停止扫描并发起 SDK 连接。
  private func connectDiscoveredPeripheral(_ peripheral: ELAILinkPeripheral) {
    guard isTargetPeripheral(peripheral) else { return }
    connectPeripheral(peripheral)
  }

  /// 使用当前 session manager 持有的目标外设发起 SDK 连接。
  private func connectPeripheral(_ peripheral: ELAILinkPeripheral) {
    pendingConnectRemoteId = nil
    manager.stopScan()
    ailinkPeripheral = peripheral
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
    pendingConnectRemoteId = nil
    connectionReady = false
    clearConnectTimer()
    manager.stopScan()
    manager.disconnectPeripheral()
    callbacks.emitConnection(remoteId, "disconnected", message)
    callbacks.removeSession(remoteId)
  }

  /// 清理连接超时定时器。
  private func clearConnectTimer() {
    connectTimer?.invalidate()
    connectTimer = nil
  }

  /// 判断扫描到的外设是否为本 session 要连接的目标。
  private func isTargetPeripheral(_ peripheral: ELAILinkPeripheral) -> Bool {
    guard let targetRemoteId = pendingConnectRemoteId else { return false }
    return callbacks.remoteId(peripheral.peripheral) == targetRemoteId
  }

  /// 处理当前 session manager 的蓝牙状态变化。
  func managerDidUpdateState(_ central: CBCentralManager) {
    guard pendingConnectRemoteId != nil, central.state == .poweredOn else {
      return
    }
    startConnectScan()
  }

  /// 处理当前 session manager 扫描到的单个外设。
  func managerDidDiscover(_ peripheral: ELAILinkPeripheral) {
    connectDiscoveredPeripheral(peripheral)
  }

  /// 处理当前 session manager 批量扫描到的外设。
  func managerDidDiscoverMorePeripheral(_ peripherals: [NSUUID: ELAILinkPeripheral]) {
    peripherals.values.forEach { connectDiscoveredPeripheral($0) }
  }

  func managerDidConnect(_ peripheral: CBPeripheral) {
    connectionReady = false
    callbacks.emitConnection(remoteId, "connecting", nil)
  }

  func managerDidFail(toConnect peripheral: CBPeripheral, error: Error) {
    pendingConnectRemoteId = nil
    connectionReady = false
    clearConnectTimer()
    callbacks.emitConnection(remoteId, "disconnected", error.localizedDescription)
    callbacks.removeSession(remoteId)
  }

  func managerDidDisconnect(_ peripheral: CBPeripheral, error: Error?) {
    pendingConnectRemoteId = nil
    connectionReady = false
    clearConnectTimer()
    callbacks.emitConnection(remoteId, "disconnected", error?.localizedDescription)
    callbacks.removeSession(remoteId)
  }

  func managerDidUpdateConnect(_ state: NELBleManagerConnectState) {
    switch state.rawValue {
    case 0x03, 0x04, 0x05:
      callbacks.emitConnection(remoteId, "connecting", nil)
    case 0x06:
      pendingConnectRemoteId = nil
      connectionReady = true
      clearConnectTimer()
      callbacks.emitHandshake(remoteId, true)
      callbacks.emitConnection(remoteId, "connected", nil)
    case 0x0F:
      pendingConnectRemoteId = nil
      connectionReady = false
      clearConnectTimer()
      callbacks.emitHandshake(remoteId, false)
      callbacks.emitConnection(remoteId, "disconnected", nil)
      callbacks.removeSession(remoteId)
    case 0x01, 0x02:
      pendingConnectRemoteId = nil
      connectionReady = false
      clearConnectTimer()
      callbacks.emitConnection(remoteId, "disconnected", nil)
      callbacks.removeSession(remoteId)
    default:
      break
    }
  }

  func managerDidDisconnectError(_ error: Error?) {
    if let error {
      callbacks.emitError("disconnect_error", error.localizedDescription)
    }
  }

  func peripheralDidDiscover(_ services: [CBService]) {
    let serviceUuids = services.map { callbacks.shortUuid($0.uuid) }
    callbacks.emitEvent([
      "type": "servicesDiscovered",
      "remoteId": remoteId,
      "serviceUuid": serviceUuids.first ?? "",
      "characteristicUuids": [],
    ])
  }

  func peripheralDidDiscoverCharacteristics(forService characteristics: [CBCharacteristic]) {
    let characteristicUuids = characteristics.map {
      callbacks.shortUuid($0.uuid)
    }
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
    callbacks.emitCharacteristicEvent(remoteId, "notificationStateChanged", characteristic)
  }

  func peripheralDidUpdateValue(forCharacteristic characteristic: CBCharacteristic) {
    callbacks.emitCharacteristicEvent(remoteId, "changed", characteristic)
  }

  func didWriteValue(forCharacteristic characteristic: CBCharacteristic) {
    callbacks.emitCharacteristicEvent(remoteId, "write", characteristic)
  }

  func peripheralDidReadRSSI(_ RSSI: NSNumber) {
    callbacks.emitRssi(remoteId, RSSI.intValue)
  }

  // 只实现带 peripheral 的协议数据入口，避免 SDK 同时回调多个 optional selector。
  func aiLinkBleReceiveA7Data(_ packet: Data, aILinkPeripheral: ELAILinkPeripheral) {
    let packetRemoteId = callbacks.remoteId(aILinkPeripheral.peripheral)
    callbacks.emitProtocolData(packet, "a7", packetRemoteId)
  }

  func aiLinkBleReceiveA6Data(_ packet: Data, aILinkPeripheral: ELAILinkPeripheral) {
    let packetRemoteId = callbacks.remoteId(aILinkPeripheral.peripheral)
    let payload = callbacks.normalizeA6ProtocolData(packet)
    emitBmVersionIfNeeded(remoteId: packetRemoteId, payload: payload)
    callbacks.emitProtocolData(payload, "a6", packetRemoteId)
  }

  func aiLinkBleReceiveRawData(_ rawData: Data, aILinkPeripheral: ELAILinkPeripheral) {
    let packetRemoteId = callbacks.remoteId(aILinkPeripheral.peripheral)
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
