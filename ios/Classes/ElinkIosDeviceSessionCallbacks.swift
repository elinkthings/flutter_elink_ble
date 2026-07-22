import CoreBluetooth
import Foundation

/// iOS 单设备连接会话回调集合，由插件注入以保持访问控制收敛。
struct ElinkIosDeviceSessionCallbacks {
  let emitConnection: (String, String, String?) -> Void
  let emitHandshake: (String, Bool) -> Void
  let emitBmVersion: (String, String, Int, Data) -> Void
  let emitError: (String, String) -> Void
  let emitEvent: ([String: Any]) -> Void
  let emitCharacteristicEvent: (String, String, CBCharacteristic) -> Void
  let emitRssi: (String, Int) -> Void
  let emitProtocolData: (Data, String, String) -> Void
  let emitPassthroughData: (Data, String) -> Void
  /// 将设备 manager 观察到的关闭或重置状态交给插件统一失效全部 adapter session。
  let invalidateAdapterSession: (CBManagerState) -> Void
  let removeSession: (String, String) -> Void
  let remoteId: (CBPeripheral) -> String
  let shortUuid: (CBUUID) -> String
  let normalizeA6ProtocolData: (Data) -> Data
}
