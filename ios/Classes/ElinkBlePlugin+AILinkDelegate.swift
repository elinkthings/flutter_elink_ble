import AILinkBleSDK
import CoreBluetooth
import Foundation

/// ElinkBlePlugin 的 AILink SDK 扫描和蓝牙状态回调扩展。
extension ElinkBlePlugin: ELAILinkBleManagerDelegate {
  public func managerDidUpdateState(_ central: CBCentralManager) {
    // 蓝牙开关、权限、不可用等状态变化。
    // Bluetooth power, permission, and availability state changes.
    ElinkNativeLogger.info("adapter state=\(adapterStateName(central.state))")
    handleAdapterStateChanged(central.state)
  }

  public func managerScanState(_ scanning: Bool) {
    ElinkNativeLogger.debug("scan state scanning=\(scanning)")
    if scanning {
      guard bleManager.central.state == .poweredOn, isCurrentScanSession else {
        ElinkNativeLogger.debug("ignore stale scan started callback")
        return
      }
      nativeScanRunning = true
    } else if suppressedScanStoppedCallbacks > 0 {
      suppressedScanStoppedCallbacks -= 1
    } else if nativeScanRunning {
      nativeScanRunning = false
      activeScanGeneration = nil
      emit(["type": "scanStopped"])
    }
  }

  public func managerDidDiscover(_ peripheral: ELAILinkPeripheral) {
    guard nativeScanRunning,
          bleManager.central.state == .poweredOn,
          isCurrentScanSession else {
      ElinkNativeLogger.debug("ignore stale scan result")
      return
    }
    emitScanResult(peripheral)
  }

  public func managerDidDiscoverMorePeripheral(_ peripherals: [NSUUID: ELAILinkPeripheral]) {
    guard nativeScanRunning,
          bleManager.central.state == .poweredOn,
          isCurrentScanSession else {
      ElinkNativeLogger.debug("ignore stale batch scan results")
      return
    }
    peripherals.values.forEach { emitScanResult($0) }
  }
}
