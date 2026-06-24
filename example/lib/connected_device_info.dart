/// example 中用于展示已连接 BLE 设备的轻量信息。
class ConnectedDeviceInfo {
  /// 创建已连接 BLE 设备展示信息。
  const ConnectedDeviceInfo({
    required this.remoteId,
    required this.macAddress,
    required this.bmVersion,
    required this.handshakeReady,
  });

  /// 已连接 BLE 设备 remote identifier。
  final String remoteId;

  /// 已连接 BLE 设备 MAC，可能为空。
  final String macAddress;

  /// BM 模块版本，未读取时为空。
  final String? bmVersion;

  /// 当前设备是否已完成 A6 handshake。
  final bool handshakeReady;
}
