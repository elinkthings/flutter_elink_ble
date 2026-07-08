import AILinkBleSDK
import CoreBluetooth
import Flutter
import UIKit

public class ElinkBlePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private static let methodChannelName = "flutter_elink_ble/methods"
  private static let eventChannelName = "flutter_elink_ble/events"

  let bleManager = ELAILinkBleManager()
  private var methodChannel: FlutterMethodChannel?
  var eventSink: FlutterEventSink?
  private var scanTimer: Timer?
  var scanResults: [String: ELAILinkPeripheral] = [:]
  private var lastScanServiceUuids: [CBUUID] = []
  var deviceSessions: [String: ElinkIosDeviceSession] = [:]
  var lastConnectionEventKeys: [String: String] = [:]
  var handshakeSeeds: [String: Data] = [:]
  var defaultHandshakeSeed: Data?
  var nativeScanRunning = false
  var suppressedScanStoppedCallbacks = 0

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
    ElinkNativeLogger.setEventHandler { [weak self] level, message, timestampMs in
      self?.emitNativeLog(level: level, message: message, timestampMs: timestampMs)
    }
  }

  deinit {
    ElinkNativeLogger.setEventHandler(nil)
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
      disconnect(remoteId: remoteId, result: result)
    case "readRssi":
      guard
        let args = call.arguments as? [String: Any],
        let remoteId = args["remoteId"] as? String
      else {
        result(FlutterError(code: "bad_args", message: "Missing remoteId", details: nil))
        return
      }
      if let error = readRssi(remoteId: remoteId) {
        result(error)
        return
      }
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
      if let error = write(data: data.data, remoteId: remoteId) {
        result(error)
        return
      }
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
      if let error = writeA6(payload: payload.data, remoteId: remoteId) {
        result(error)
        return
      }
      result(nil)
    case "getBmVersion":
      guard
        let args = call.arguments as? [String: Any],
        let remoteId = args["remoteId"] as? String
      else {
        result(FlutterError(code: "bad_args", message: "Missing remoteId", details: nil))
        return
      }
      if let error = getBmVersion(remoteId: remoteId) {
        result(error)
        return
      }
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
      if let error = writeA7(payload: payload.data, remoteId: remoteId) {
        result(error)
        return
      }
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
    ElinkNativeLogger.info("openBluetooth refresh adapter state")
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
        ElinkNativeLogger.warning("startScan rejected state=\(self.adapterStateName(state))")
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
    ElinkNativeLogger.debug("startScan timeoutMs=\(timeoutMs) services=\(serviceUuids.map { shortUuid($0) })")
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
    ElinkNativeLogger.debug("stopScan emitStopped=\(emitStopped)")
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
      ElinkNativeLogger.warning("connect failed, device not found remoteId=\(remoteId)")
      emitError(code: "device_not_found", message: "Device not found: \(remoteId)")
      return
    }
    ElinkNativeLogger.info("connect remoteId=\(remoteId) timeoutMs=\(timeoutMs)")
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

  private func disconnect(remoteId: String, result: @escaping FlutterResult) {
    guard let session = deviceSessions[remoteId] else {
      ElinkNativeLogger.warning("disconnect ignored, no session remoteId=\(remoteId)")
      clearHandshakeSeed(remoteId: remoteId)
      result(nil)
      return
    }
    ElinkNativeLogger.info("disconnect remoteId=\(remoteId)")
    session.disconnect(result: result)
  }

  private func readRssi(remoteId: String) -> FlutterError? {
    let readiness = requireReadySession(remoteId: remoteId)
    guard let session = readiness.session else { return readiness.error }
    ElinkNativeLogger.debug("readRssi remoteId=\(remoteId)")
    session.readRssi()
    return nil
  }

  /// 获取指定 iOS 外设的最大单次写入 payload 长度。
  /// Get maximum one-shot write payload lengths for the selected iOS peripheral.
  private func getIosMtu(remoteId: String, result: @escaping FlutterResult) {
    let readiness = requireReadySession(remoteId: remoteId)
    guard let session = readiness.session else {
      result(readiness.error ?? deviceNotConnectedError(remoteId: remoteId))
      return
    }
    guard let peripheral = session.currentPeripheral else {
      result(deviceNotConnectedError(remoteId: remoteId))
      return
    }
    ElinkNativeLogger.debug(
      "getIosMtu remoteId=\(remoteId) withoutResponse=\(peripheral.maximumWriteValueLength(for: .withoutResponse)) withResponse=\(peripheral.maximumWriteValueLength(for: .withResponse))"
    )
    result([
      "remoteId": remoteId,
      "maxWriteWithoutResponse": peripheral.maximumWriteValueLength(for: .withoutResponse),
      "maxWriteWithResponse": peripheral.maximumWriteValueLength(for: .withResponse),
    ])
  }

  private func write(data: Data, remoteId: String) -> FlutterError? {
    let readiness = requireReadySession(remoteId: remoteId)
    guard let session = readiness.session else { return readiness.error }
    // 透传写入统一交给 AILink SDK 管理队列和 characteristic。
    // Raw write uses the AILink SDK queue and characteristic handling.
    ElinkNativeLogger.debug("write remoteId=\(remoteId) data=\(ElinkNativeLogger.hex(data))")
    session.write(data)
    return nil
  }

  private func writeA6(payload: Data, remoteId: String) -> FlutterError? {
    let readiness = requireReadySession(remoteId: remoteId)
    guard let session = readiness.session else { return readiness.error }
    ElinkNativeLogger.debug("writeA6 remoteId=\(remoteId) payload=\(ElinkNativeLogger.hex(payload))")
    session.writeA6(payload)
    return nil
  }

  /// 通过 iOS SDK 增强版 0x46 指令查询 BM 版本。
  private func getBmVersion(remoteId: String) -> FlutterError? {
    let readiness = requireReadySession(remoteId: remoteId)
    guard let session = readiness.session else { return readiness.error }
    ElinkNativeLogger.debug("getBmVersion remoteId=\(remoteId) command=0x46")
    session.getBmVersion()
    return nil
  }

  private func writeA7(payload: Data, remoteId: String) -> FlutterError? {
    let readiness = requireReadySession(remoteId: remoteId)
    guard let session = readiness.session else { return readiness.error }
    ElinkNativeLogger.debug("writeA7 remoteId=\(remoteId) payload=\(ElinkNativeLogger.hex(payload))")
    session.writeA7(payload)
    return nil
  }

  private func disposeSdkResources() {
    ElinkNativeLogger.info("dispose sdk resources")
    stopScan(emitStopped: false)
    deviceSessions.values.forEach { $0.dispose() }
    scanResults.removeAll()
    deviceSessions.removeAll()
    lastScanServiceUuids.removeAll()
    handshakeSeeds.removeAll()
    defaultHandshakeSeed = nil
    lastConnectionEventKeys.removeAll()
  }

  func adapterStateName(_ state: CBManagerState) -> String {
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
      removeSession: { [weak self] remoteId, sessionId in
        self?.removeDeviceSession(remoteId: remoteId, sessionId: sessionId)
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

  /// 移除指定 iOS 设备连接 session；只允许当前 sessionId 清理当前 map 项，避免旧回调误删新 session。
  private func removeDeviceSession(remoteId: String, sessionId: String) {
    guard deviceSessions[remoteId]?.sessionId == sessionId else {
      return
    }
    clearHandshakeSeed(remoteId: remoteId)
    deviceSessions.removeValue(forKey: remoteId)?.clearDelegate()
  }

  func shortUuid(_ uuid: CBUUID) -> String {
    let text = uuid.uuidString.uppercased()
    if text.hasPrefix("0000") && text.hasSuffix("-0000-1000-8000-00805F9B34FB") {
      let start = text.index(text.startIndex, offsetBy: 4)
      let end = text.index(text.startIndex, offsetBy: 8)
      return String(text[start..<end])
    }
    return text
  }
}
