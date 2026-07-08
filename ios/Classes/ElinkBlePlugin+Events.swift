import AILinkBleSDK
import CoreBluetooth
import Flutter
import Foundation

/// ElinkBlePlugin 的 EventChannel 事件发送扩展。
extension ElinkBlePlugin {
  func emitAdapterState() {
    emit(["type": "adapterState", "state": adapterStateName(bleManager.central.state)])
  }

  func emitScanResult(_ peripheral: ELAILinkPeripheral) {
    let cbPeripheral = peripheral.peripheral
    let remoteId = remoteId(for: cbPeripheral)
    scanResults[remoteId] = peripheral
    let advertisementData = peripheral.value(forKey: "advertisementData") as? [String: Any] ?? [:]
    let rssi = (peripheral.value(forKey: "RSSI") as? NSNumber)?.intValue ?? 0
    let serviceUuids = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] ?? [])
      .map { shortUuid($0) }
    let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data ?? Data()
    let advName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? cbPeripheral.name ?? ""
    ElinkNativeLogger.debug("scan result remoteId=\(remoteId) name=\(advName) rssi=\(rssi)")
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

  func emitConnection(remoteId: String, state: String, reason: String? = nil) {
    let eventKey = "\(state)|\(reason ?? "")"
    if lastConnectionEventKeys[remoteId] == eventKey {
      return
    }
    ElinkNativeLogger.info("connection remoteId=\(remoteId) state=\(state) reason=\(reason ?? "")")
    lastConnectionEventKeys[remoteId] = eventKey
    emit([
      "type": "connectionState",
      "remoteId": remoteId,
      "state": state,
      "reason": reason as Any,
    ])
  }

  /// 上报原生 SDK 握手状态给 Dart 层。
  func emitHandshake(remoteId: String, success: Bool) {
    ElinkNativeLogger.info("handshake remoteId=\(remoteId) success=\(success)")
    emit([
      "type": "handshake",
      "remoteId": remoteId,
      "success": success,
    ])
  }

  /// 上报原生 SDK 解析后的 BM 版本。
  func emitBmVersion(
    remoteId: String,
    version: String,
    command: Int,
    rawPayload: Data
  ) {
    ElinkNativeLogger.info(
      "bmVersion remoteId=\(remoteId) command=\(String(format: "0x%02X", command)) version=\(version) raw=\(ElinkNativeLogger.hex(rawPayload))"
    )
    emit([
      "type": "bmVersion",
      "remoteId": remoteId,
      "version": version,
      "command": command,
      "rawPayload": FlutterStandardTypedData(bytes: rawPayload),
    ])
  }

  func emitProtocolData(
    _ data: Data,
    protocolName: String,
    remoteId: String? = nil,
    characteristicUuid: String = "",
    deviceType: Int? = nil
  ) {
    let resolvedRemoteId = remoteId ?? ""
    ElinkNativeLogger.debug(
      "receive\(protocolName.uppercased()) remoteId=\(resolvedRemoteId) uuid=\(characteristicUuid) data=\(ElinkNativeLogger.hex(data))"
    )
    emit([
      "type": "protocolData",
      "remoteId": resolvedRemoteId,
      "protocol": protocolName,
      "characteristicUuid": characteristicUuid,
      "deviceType": deviceType as Any,
      "data": FlutterStandardTypedData(bytes: data),
    ])
  }

  func emitPassthroughData(
    _ data: Data,
    remoteId: String? = nil,
    characteristicUuid: String = ""
  ) {
    let resolvedRemoteId = remoteId ?? ""
    ElinkNativeLogger.debug(
      "receiveRaw remoteId=\(resolvedRemoteId) uuid=\(characteristicUuid) data=\(ElinkNativeLogger.hex(data))"
    )
    emit([
      "type": "passthroughData",
      "remoteId": resolvedRemoteId,
      "characteristicUuid": characteristicUuid,
      "data": FlutterStandardTypedData(bytes: data),
    ])
  }

  func emitCharacteristicEvent(
    remoteId: String,
    operation: String,
    characteristic: CBCharacteristic
  ) {
    ElinkNativeLogger.debug(
      "characteristic \(operation) remoteId=\(remoteId) uuid=\(shortUuid(characteristic.uuid)) data=\(ElinkNativeLogger.hex(characteristic.value ?? Data()))"
    )
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

  func emitRssi(remoteId: String, rssi: Int) {
    ElinkNativeLogger.debug("rssi remoteId=\(remoteId) rssi=\(rssi)")
    emit(["type": "rssi", "remoteId": remoteId, "rssi": rssi])
  }

  func emitError(code: String, message: String) {
    ElinkNativeLogger.error("error code=\(code) message=\(message)")
    emit(["type": "error", "code": code, "message": message])
  }

  /// 上报 native 插件日志事件给 Dart 层，由 Flutter 统一输出和写入导出日志。
  func emitNativeLog(level: String, message: String, timestampMs: Int64) {
    emit([
      "type": "nativeLog",
      "platform": "iOS",
      "level": level,
      "message": message,
      "timestampMs": timestampMs,
    ])
  }

  func emit(_ event: [String: Any]) {
    DispatchQueue.main.async { [weak self] in
      self?.eventSink?(event)
    }
  }
}
