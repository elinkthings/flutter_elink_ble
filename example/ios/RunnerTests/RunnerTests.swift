import CoreBluetooth
import Flutter
import UIKit
import XCTest

@testable import flutter_elink_ble

final class RunnerTests: XCTestCase {
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
