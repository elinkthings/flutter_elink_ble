import 'package:flutter/material.dart';

import 'android_resend_count_setting.dart';
import 'connected_device_info.dart';

/// Sample page for connected BLE device operations (BLE 已连接设备操作示例页面).
class BluetoothConnectionPage extends StatelessWidget {
  /// Create the Bluetooth connection sample page (创建蓝牙连接示例页面).
  const BluetoothConnectionPage({
    super.key,
    required this.connectedDevice,
    required this.enableTlvParse,
    required this.logs,
    required this.onClearLogs,
    required this.onDisconnect,
    required this.onGetBmVersion,
    required this.mtuActionLabel,
    required this.onMtuAction,
    required this.onOpenWifiProvisioning,
    required this.onEnableTlvParseChanged,
    required this.showAndroidCommandResendSetting,
    required this.androidCommandResendCount,
    required this.onAndroidCommandResendCountChanged,
  });

  /// 当前 tab 对应的已连接 BLE 设备。
  final ConnectedDeviceInfo connectedDevice;

  /// Whether protocol payload logs are parsed as TLV (协议 payload 日志是否按 TLV 解析).
  final bool enableTlvParse;

  /// BLE connection and protocol logs (BLE 连接和协议日志).
  final List<String> logs;

  /// 清空当前设备 tab 日志的回调。
  final VoidCallback onClearLogs;

  /// Callback for disconnecting the selected BLE device (断开选中 BLE 设备的回调).
  final VoidCallback onDisconnect;

  /// Callback for querying BM module version (查询 BM 模块版本的回调).
  final VoidCallback onGetBmVersion;

  /// MTU 操作按钮文案，Android 设置 MTU，iOS 查询最大写入长度。
  /// MTU action button text; Android sets MTU, iOS reads maximum write length.
  final String mtuActionLabel;

  /// Callback for running the platform MTU action (执行平台 MTU 操作的回调).
  final VoidCallback onMtuAction;

  /// Callback for opening the WiFi provisioning page (打开 WiFi 配网页面的回调).
  final VoidCallback onOpenWifiProvisioning;

  /// Callback for changing TLV parse mode (修改 TLV 解析模式的回调).
  final ValueChanged<bool> onEnableTlvParseChanged;

  /// Whether to show Android command resend setting (是否展示 Android 指令重发设置).
  final bool showAndroidCommandResendSetting;

  /// Current Android command resend count (当前 Android 指令重发次数).
  final int androidCommandResendCount;

  /// Callback for changing Android command resend count (修改 Android 指令重发次数的回调).
  final ValueChanged<int> onAndroidCommandResendCountChanged;

  /// Build the Bluetooth connection page (构建蓝牙连接页面).
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: _buildConnectionPanel(context),
        ),
        Expanded(child: _buildLogSection()),
      ],
    );
  }

  /// Build connected device controls and parse settings (构建已连接设备控制和解析设置).
  Widget _buildConnectionPanel(BuildContext context) {
    final remoteId = connectedDevice.remoteId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bluetooth_connected),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                remoteId,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Clear logs',
              onPressed: logs.isEmpty ? null : onClearLogs,
              icon: const Icon(Icons.delete_sweep),
            ),
            IconButton(
              tooltip: 'Disconnect',
              onPressed: onDisconnect,
              icon: const Icon(Icons.bluetooth_disabled),
            ),
            IconButton(
              tooltip: 'WiFi Provisioning',
              onPressed: onOpenWifiProvisioning,
              icon: const Icon(Icons.wifi),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MAC: ${connectedDevice.macAddress.isEmpty ? "--" : connectedDevice.macAddress}',
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'BM Version: ${connectedDevice.bmVersion ?? "--"}',
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Handshake: ${connectedDevice.handshakeReady ? "ready" : "--"}',
              overflow: TextOverflow.ellipsis,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onGetBmVersion,
                  icon: const Icon(Icons.info_outline),
                  label: const Text('GetBmVersion'),
                ),
                FilledButton.tonalIcon(
                  onPressed: onMtuAction,
                  icon: const Icon(Icons.swap_vert),
                  label: Text(mtuActionLabel),
                ),
              ],
            ),
          ],
        ),
        if (showAndroidCommandResendSetting)
          AndroidResendCountSetting(
            resendCount: androidCommandResendCount,
            onChanged: onAndroidCommandResendCountChanged,
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Parse payload as TLV'),
          subtitle: const Text('Off: type + data, On: TLV entries'),
          value: enableTlvParse,
          onChanged: onEnableTlvParseChanged,
        ),
      ],
    );
  }

  /// Build the BLE log viewer (构建 BLE 日志视图).
  Widget _buildLogSection() {
    if (logs.isEmpty) {
      return const Center(child: Text('No BLE logs'));
    }
    return ListView.builder(
      reverse: true,
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[logs.length - 1 - index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(log, style: const TextStyle(fontSize: 12)),
        );
      },
    );
  }
}
