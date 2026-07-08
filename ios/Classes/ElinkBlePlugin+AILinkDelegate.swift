import AILinkBleSDK
import CoreBluetooth
import Foundation

/// ElinkBlePlugin 的 AILink SDK 扫描和蓝牙状态回调扩展。
extension ElinkBlePlugin: ELAILinkBleManagerDelegate {
  public func managerDidUpdateState(_ central: CBCentralManager) {
    // 蓝牙开关、权限、不可用等状态变化。
    // Bluetooth power, permission, and availability state changes.
    ElinkNativeLogger.info("adapter state=\(adapterStateName(central.state))")
    emitAdapterState()
  }

  public func managerScanState(_ scanning: Bool) {
    ElinkNativeLogger.debug("scan state scanning=\(scanning)")
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
