import CoreBluetooth
import Flutter
import Foundation

/// 自定义写入使用的最小 peripheral 能力，生产环境由 CBPeripheral 提供。
protocol ElinkIosWritePeripheral {
  /// 当前已发现的服务及其特征。
  var services: [CBService]? { get }
  /// 当前是否还有无应答写入容量。
  var canSendWriteWithoutResponse: Bool { get }
  /// 返回指定写入类型的单次最大数据长度。
  func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int
  /// 向指定特征提交数据；提交不等于收到对端应答。
  func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType)
}

/// 使用 CoreBluetooth 原有实现，保持 delegate 和连接所有权不变。
extension CBPeripheral: ElinkIosWritePeripheral {}

/// 自定义 UUID 的写入校验与提交；不接管 peripheral delegate，不改变 SDK 会话配置。
enum ElinkIosCustomWrite {
  /// 校验后展开 16/32-bit UUID；拒绝非法文本，避免 CBUUID 抛出 Objective-C 异常。
  static func parseUuid(_ value: String) -> CBUUID? {
    if value.count == 4 && value.range(of: "^[0-9a-fA-F]{4}$", options: .regularExpression) != nil {
      return CBUUID(string: "0000\(value)-0000-1000-8000-00805F9B34FB")
    }
    if value.count == 8 && value.range(of: "^[0-9a-fA-F]{8}$", options: .regularExpression) != nil {
      return CBUUID(string: "\(value)-0000-1000-8000-00805F9B34FB")
    }
    guard value.count == 36,
      value.range(of: "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", options: .regularExpression) != nil else {
      return nil
    }
    return CBUUID(string: value)
  }

  /// 严格按服务和特征二元组定位，避免不同服务下同名特征互相误写。
  static func resolveCharacteristic(
    services: [CBService], serviceUuid: String, characteristicUuid: String
  ) -> (characteristic: CBCharacteristic?, error: FlutterError?) {
    guard let serviceId = parseUuid(serviceUuid), let characteristicId = parseUuid(characteristicUuid) else {
      return (nil, FlutterError(code: "bad_args", message: "Invalid service or characteristic UUID", details: nil))
    }
    let matches = services.filter { parseUuid($0.uuid.uuidString) == serviceId }
    guard matches.count == 1 else {
      return (nil, FlutterError(code: "service_not_found", message: "Service is missing or ambiguous: \(serviceUuid)", details: nil))
    }
    let characteristics = (matches[0].characteristics ?? []).filter {
      parseUuid($0.uuid.uuidString) == characteristicId
    }
    guard characteristics.count == 1 else {
      return (nil, FlutterError(code: "characteristic_not_found", message: "Characteristic is missing or ambiguous: \(characteristicUuid)", details: nil))
    }
    return (characteristics[0], nil)
  }

  /// 校验指定写入类型是否被特征支持；不静默降级写入类型。
  static func writeType(_ type: String, characteristic: CBCharacteristic) -> CBCharacteristicWriteType? {
    switch type {
    case "withResponse" where characteristic.properties.contains(.write):
      return .withResponse
    case "withoutResponse" where characteristic.properties.contains(.writeWithoutResponse):
      return .withoutResponse
    default:
      return nil
    }
  }

  /// 校验单次写入长度及无响应写入容量后提交；返回 nil 仅表示请求已提交。
  static func write(
    _ data: Data, peripheral: ElinkIosWritePeripheral, serviceUuid: String,
    characteristicUuid: String, type: String
  ) -> FlutterError? {
    let target = resolveCharacteristic(
      services: peripheral.services ?? [], serviceUuid: serviceUuid,
      characteristicUuid: characteristicUuid
    )
    guard let characteristic = target.characteristic else { return target.error }
    guard let writeType = writeType(type, characteristic: characteristic) else {
      return FlutterError(code: "write_not_supported", message: "Characteristic does not support write type: \(type)", details: nil)
    }
    let maxLength = peripheral.maximumWriteValueLength(for: writeType)
    guard data.count <= maxLength else {
      return FlutterError(code: "data_too_long", message: "Write exceeds maximum length: \(maxLength)", details: nil)
    }
    if writeType == .withoutResponse && !peripheral.canSendWriteWithoutResponse {
      return FlutterError(code: "write_not_ready", message: "Peripheral cannot currently accept a write without response", details: nil)
    }
    peripheral.writeValue(data, for: characteristic, type: writeType)
    return nil
  }
}
