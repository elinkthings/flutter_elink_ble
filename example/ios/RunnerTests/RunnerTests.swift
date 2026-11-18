import CoreBluetooth
import Flutter
import UIKit
import XCTest

@testable import flutter_elink_ble

final class RunnerTests: XCTestCase {
  /// 真实执行写入分支，确认服务、特征、数据及请求类型都交给指定 peripheral。
  func testCustomWriteSubmitsToSelectedPeripheralWithoutChangingData() {
    let target = makeWritePeripheral(properties: [.write, .writeWithoutResponse])
    let other = makeWritePeripheral(properties: [.write])
    let bytes = Data([0x01, 0x02, 0xFE])
    XCTAssertNil(ElinkIosCustomWrite.write(bytes, peripheral: target, serviceUuid: "FFF0", characteristicUuid: "FFF1", type: "withResponse"))
    XCTAssertEqual(target.writes.count, 1)
    XCTAssertEqual(target.writes[0].data, bytes)
    XCTAssertTrue(target.writes[0].characteristic === target.services?[0].characteristics?[0])
    XCTAssertEqual(target.writes[0].type, .withResponse)
    XCTAssertTrue(other.writes.isEmpty)
    XCTAssertNil(ElinkIosCustomWrite.write(bytes, peripheral: target, serviceUuid: "FFF0", characteristicUuid: "FFF1", type: "withoutResponse"))
    XCTAssertEqual(target.writes[1].type, .withoutResponse)
  }

  /// 写入容量不足、超长及不支持类型时不调用 CoreBluetooth，长度上限本身可写。
  func testCustomWriteRejectsBackpressureOversizeAndUnsupportedTypes() {
    let target = makeWritePeripheral(properties: [.write, .writeWithoutResponse])
    target.maxLength = 3
    target.canSendWriteWithoutResponse = false
    XCTAssertEqual(ElinkIosCustomWrite.write(Data([1]), peripheral: target, serviceUuid: "FFF0", characteristicUuid: "FFF1", type: "withoutResponse")?.code, "write_not_ready")
    XCTAssertEqual(ElinkIosCustomWrite.write(Data([1, 2, 3, 4]), peripheral: target, serviceUuid: "FFF0", characteristicUuid: "FFF1", type: "withResponse")?.code, "data_too_long")
    XCTAssertEqual(ElinkIosCustomWrite.write(Data([1]), peripheral: target, serviceUuid: "FFF0", characteristicUuid: "FFF1", type: "invalid")?.code, "write_not_supported")
    XCTAssertTrue(target.writes.isEmpty)
    // 无应答容量不影响有应答写入；边界长度必须允许。
    XCTAssertNil(ElinkIosCustomWrite.write(Data([1, 2, 3]), peripheral: target, serviceUuid: "FFF0", characteristicUuid: "FFF1", type: "withResponse"))
    XCTAssertEqual(target.writes.count, 1)
    let readOnly = makeWritePeripheral(properties: [.read])
    XCTAssertEqual(ElinkIosCustomWrite.write(Data([1]), peripheral: readOnly, serviceUuid: "FFF0", characteristicUuid: "FFF1", type: "withResponse")?.code, "write_not_supported")
    XCTAssertTrue(readOnly.writes.isEmpty)
  }

  /// 缺失、重复及非法目标在执行分支中均返回错误，不能产生任何发送副作用。
  func testCustomWriteDoesNotSubmitInvalidOrAmbiguousTargets() {
    let target = makeWritePeripheral(properties: [.write])
    for (service, characteristic, expected) in [
      ("invalid", "FFF1", "bad_args"),
      ("FFF2", "FFF1", "service_not_found"),
      ("FFF0", "FFF2", "characteristic_not_found"),
    ] {
      XCTAssertEqual(ElinkIosCustomWrite.write(Data([1]), peripheral: target, serviceUuid: service, characteristicUuid: characteristic, type: "withResponse")?.code, expected)
    }
    let duplicateService = target.services![0]
    target.services?.append(duplicateService)
    XCTAssertEqual(ElinkIosCustomWrite.write(Data([1]), peripheral: target, serviceUuid: "FFF0", characteristicUuid: "FFF1", type: "withResponse")?.code, "service_not_found")
    XCTAssertTrue(target.writes.isEmpty)
  }

  /// 创建独立可记录的 peripheral 替身，服务和特征使用真实 CoreBluetooth 类型。
  private func makeWritePeripheral(properties: CBCharacteristicProperties) -> RecordingWritePeripheral {
    let service = CBMutableService(type: CBUUID(string: "FFF0"), primary: true)
    service.characteristics = [CBMutableCharacteristic(type: CBUUID(string: "FFF1"), properties: properties, value: nil, permissions: [.writeable])]
    return RecordingWritePeripheral(services: [service])
  }

  /// 自定义 UUID 支持短/完整格式，非法输入不能进入 CBUUID 初始化。
  func testCustomWriteUuidValidation() {
    XCTAssertEqual(ElinkIosCustomWrite.parseUuid("FFF0"), ElinkIosCustomWrite.parseUuid("0000fff0-0000-1000-8000-00805f9b34fb"))
    XCTAssertEqual(ElinkIosCustomWrite.parseUuid("1234ABCD"), CBUUID(string: "1234abcd-0000-1000-8000-00805f9b34fb"))
    for value in ["", "XYZ0", "1-2-3-4-5", " FFF0", "FFF0\n"] {
      XCTAssertNil(ElinkIosCustomWrite.parseUuid(value))
    }
  }

  /// 按服务和特征共同匹配，跨服务同名特征不会选错，缺失目标返回错误。
  func testCustomWriteSelectsCharacteristicWithinRequestedService() {
    let first = CBMutableService(type: CBUUID(string: "FFF0"), primary: true)
    let second = CBMutableService(type: CBUUID(string: "FFF2"), primary: true)
    let firstCharacteristic = CBMutableCharacteristic(type: CBUUID(string: "FFF1"), properties: [.write], value: nil, permissions: [.writeable])
    let secondCharacteristic = CBMutableCharacteristic(type: CBUUID(string: "FFF1"), properties: [.writeWithoutResponse], value: nil, permissions: [.writeable])
    first.characteristics = [firstCharacteristic]
    second.characteristics = [secondCharacteristic]
    let target = ElinkIosCustomWrite.resolveCharacteristic(services: [first, second], serviceUuid: "FFF2", characteristicUuid: "FFF1")
    XCTAssertNil(target.error)
    XCTAssertTrue(target.characteristic === secondCharacteristic)
    XCTAssertEqual(ElinkIosCustomWrite.writeType("withResponse", characteristic: firstCharacteristic), .withResponse)
    XCTAssertEqual(ElinkIosCustomWrite.writeType("withoutResponse", characteristic: secondCharacteristic), .withoutResponse)
    XCTAssertNil(ElinkIosCustomWrite.writeType("withoutResponse", characteristic: firstCharacteristic))
    XCTAssertNil(ElinkIosCustomWrite.writeType("withResponse", characteristic: secondCharacteristic))
    XCTAssertEqual(ElinkIosCustomWrite.resolveCharacteristic(services: [first], serviceUuid: "FFF2", characteristicUuid: "FFF1").error?.code, "service_not_found")
    XCTAssertEqual(ElinkIosCustomWrite.resolveCharacteristic(services: [first], serviceUuid: "FFF0", characteristicUuid: "FFF3").error?.code, "characteristic_not_found")
  }

  /// 统一配置入口在 iOS 返回未执行或正常完成，旧入口继续保留原错误契约。
  func testUnifiedSettingsDoNotRequirePlatformChecks() {
    let plugin = ElinkBlePlugin()
    for method in ["setMtu", "setPreferredPhy", "setConnectPriority"] {
      var called = false
      plugin.handle(FlutterMethodCall(methodName: method, arguments: ["remoteId": "device-a"])) { result in
        called = true
        XCTAssertEqual(result as? Bool, false)
      }
      XCTAssertTrue(called)
    }
    plugin.handle(FlutterMethodCall(methodName: "setCommandResendCount", arguments: ["resendCount": 3])) { result in
      XCTAssertNil(result)
    }
    plugin.handle(FlutterMethodCall(methodName: "setAndroidMtu", arguments: ["remoteId": "device-a", "mtu": 247])) { result in
      XCTAssertEqual((result as? FlutterError)?.code, "unsupported_platform")
    }
  }

  /// A6 和其他完整包只接受各自对应的可写特征，缺失或空包时拒绝。
  func testImmediateWriteCharacteristicRouting() {
    let a6 = CBMutableCharacteristic(type: CBUUID(string: "FFE3"), properties: [.writeWithoutResponse], value: nil, permissions: [.writeable])
    let a7 = CBMutableCharacteristic(type: CBUUID(string: "FFE1"), properties: [.write], value: nil, permissions: [.writeable])
    let notify = CBMutableCharacteristic(type: CBUUID(string: "FFE3"), properties: [.notify], value: nil, permissions: [])
    XCTAssertTrue(ElinkIosDeviceSession.hasImmediateWriteCharacteristic(Data([0xA6]), characteristics: [a6]))
    XCTAssertTrue(ElinkIosDeviceSession.hasImmediateWriteCharacteristic(Data([0xA7]), characteristics: [a7]))
    XCTAssertFalse(ElinkIosDeviceSession.hasImmediateWriteCharacteristic(Data([0xA6]), characteristics: [a7]))
    XCTAssertFalse(ElinkIosDeviceSession.hasImmediateWriteCharacteristic(Data([0xA7]), characteristics: [a6]))
    XCTAssertFalse(ElinkIosDeviceSession.hasImmediateWriteCharacteristic(Data([0xA6]), characteristics: [notify]))
    XCTAssertFalse(ElinkIosDeviceSession.hasImmediateWriteCharacteristic(Data(), characteristics: [a6, a7]))
  }

  /// 空包不提交 SDK，未连接的指定设备不能借用其他 session 发送。
  func testImmediateWriteRejectsEmptyAndUnreadyTargets() {
    let plugin = ElinkBlePlugin()
    let session = ElinkIosDeviceSession(remoteId: "device-a", callbacks: makeSessionCallbacks())
    plugin.deviceSessions["device-a"] = session
    XCTAssertFalse(session.sendDataNow(Data([0xA6])))
    plugin.handle(FlutterMethodCall(methodName: "sendDataNow", arguments: [
      "remoteId": "device-b", "data": FlutterStandardTypedData(bytes: Data()),
    ])) { result in
      XCTAssertEqual(result as? Bool, false)
    }
    plugin.handle(FlutterMethodCall(methodName: "sendDataNow", arguments: [
      "remoteId": "device-b", "data": FlutterStandardTypedData(bytes: Data([0xA6])),
    ])) { result in
      XCTAssertEqual((result as? FlutterError)?.code, "device_not_connected")
    }
    session.clearDelegate()
    XCTAssertFalse(session.sendDataNow(Data([0xA6])))
  }

  /// 验证 CoreBluetooth 关闭和重置状态映射为统一的 Dart adapter state。
  func testAdapterStateMapping() {
    let plugin = ElinkBlePlugin()

    XCTAssertEqual(plugin.adapterStateName(.poweredOn), "on")
    XCTAssertEqual(plugin.adapterStateName(.poweredOff), "off")
    XCTAssertEqual(plugin.adapterStateName(.resetting), "turningOff")
  }

  /// 验证 session 失效后不再向 EventChannel 恢复旧连接状态。
  func testInvalidatedSessionHasNoRestorableConnectionState() {
    let session = ElinkIosDeviceSession(
      remoteId: "00000000-0000-0000-0000-000000000001",
      callbacks: makeSessionCallbacks()
    )

    XCTAssertEqual(session.currentConnectionStateName, "connecting")
    session.clearDelegate()
    XCTAssertNil(session.currentConnectionStateName)
  }

  /// 验证 adapter session 首次关闭只递增一次代次，并统一失效全部设备 session。
  func testAdapterSessionInvalidationIsIdempotent() {
    let plugin = ElinkBlePlugin()
    let remoteId = "00000000-0000-0000-0000-000000000001"
    let session = ElinkIosDeviceSession(
      remoteId: remoteId,
      callbacks: makeSessionCallbacks()
    )
    let initialGeneration = plugin.adapterSessionGeneration
    plugin.deviceSessions[remoteId] = session
    plugin.nativeScanRunning = true
    plugin.activeScanGeneration = initialGeneration

    plugin.handleAdapterStateChanged(.resetting)

    XCTAssertEqual(plugin.adapterSessionGeneration, initialGeneration + 1)
    XCTAssertTrue(plugin.adapterSessionInvalidated)
    XCTAssertTrue(plugin.deviceSessions.isEmpty)
    XCTAssertFalse(plugin.nativeScanRunning)
    XCTAssertNil(plugin.activeScanGeneration)
    XCTAssertNil(session.currentConnectionStateName)
    XCTAssertFalse(plugin.isAdapterSessionCurrent(initialGeneration))

    plugin.handleAdapterStateChanged(.poweredOff)
    XCTAssertEqual(plugin.adapterSessionGeneration, initialGeneration + 1)
    XCTAssertTrue(plugin.adapterShutdownReachedPoweredOff)

    plugin.handleAdapterStateChanged(.resetting)
    XCTAssertEqual(plugin.adapterSessionGeneration, initialGeneration + 1)
    XCTAssertTrue(plugin.adapterShutdownReachedPoweredOff)
  }

  /// 验证蓝牙重新打开后仅接受新代次操作，旧代次不会恢复扫描或连接。
  func testPoweredOnAcceptsOnlyCurrentAdapterGeneration() {
    let plugin = ElinkBlePlugin()
    let initialGeneration = plugin.adapterSessionGeneration

    plugin.handleAdapterStateChanged(.poweredOff)
    let currentGeneration = plugin.adapterSessionGeneration
    plugin.handleAdapterStateChanged(.poweredOn)

    XCTAssertFalse(plugin.adapterSessionInvalidated)
    XCTAssertFalse(plugin.adapterShutdownReachedPoweredOff)
    XCTAssertFalse(plugin.isAdapterSessionCurrent(initialGeneration))
    XCTAssertTrue(plugin.isAdapterSessionCurrent(currentGeneration))
  }

  /// 创建不产生外部副作用的 session 回调，供生命周期单元测试使用。
  private func makeSessionCallbacks() -> ElinkIosDeviceSessionCallbacks {
    return ElinkIosDeviceSessionCallbacks(
      emitConnection: { _, _, _ in },
      emitHandshake: { _, _ in },
      emitBmVersion: { _, _, _, _ in },
      emitError: { _, _ in },
      emitEvent: { _ in },
      emitCharacteristicEvent: { _, _, _ in },
      emitRssi: { _, _ in },
      emitProtocolData: { _, _, _ in },
      emitPassthroughData: { _, _ in },
      invalidateAdapterSession: { _ in },
      removeSession: { _, _ in },
      remoteId: { $0.identifier.uuidString },
      shortUuid: { $0.uuidString },
      normalizeA6ProtocolData: { $0 }
    )
  }
}

/// 记录原生写入调用，测试路由及拒绝路径，不模拟或声称无线链路发送成功。
private final class RecordingWritePeripheral: ElinkIosWritePeripheral {
  var services: [CBService]?
  var canSendWriteWithoutResponse = true
  var maxLength = 20
  var writes: [(data: Data, characteristic: CBCharacteristic, type: CBCharacteristicWriteType)] = []

  /// 为测试提供当前已发现的服务。
  init(services: [CBService]) {
    self.services = services
  }

  /// 返回测试指定的单次写入上限。
  func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int {
    return maxLength
  }

  /// 记录完整写入参数，供测试核对目标、数据及类型。
  func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
    writes.append((data, characteristic, type))
  }
}
