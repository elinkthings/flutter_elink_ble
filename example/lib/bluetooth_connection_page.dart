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
    required this.onGetLegacyBmVersion,
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

  /// 查询旧版 BM 模块版本的回调。
  final VoidCallback onGetLegacyBmVersion;

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

  static final RegExp _logTimePattern = RegExp(r'^\[([^\]]+)\]\s*(.*)$');
  static final RegExp _logSourcePattern = RegExp(r'^\[([^\]]+)\]\s*(.*)$');

  /// Build the Bluetooth connection page (构建蓝牙连接页面).
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: _buildConnectionPanel(context),
        ),
        const Divider(height: 1),
        Expanded(child: _buildLogSection()),
      ],
    );
  }

  /// Build connected device controls and parse settings (构建已连接设备控制和解析设置).
  Widget _buildConnectionPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDeviceHeader(context),
        const SizedBox(height: 10),
        _buildInfoGrid(context),
        const SizedBox(height: 10),
        _buildActionButtons(),
        if (showAndroidCommandResendSetting)
          AndroidResendCountSetting(
            resendCount: androidCommandResendCount,
            onChanged: onAndroidCommandResendCountChanged,
          ),
        _buildParseControls(context),
      ],
    );
  }

  /// 构建设备标题行和常用图标操作。
  Widget _buildDeviceHeader(BuildContext context) {
    final remoteId = connectedDevice.remoteId;
    return Row(
      children: [
        const Icon(Icons.bluetooth_connected),
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
    );
  }

  /// 构建紧凑设备信息区。
  Widget _buildInfoGrid(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _buildInfoItem(
          context,
          label: 'MAC',
          value: connectedDevice.macAddress.isEmpty
              ? '--'
              : connectedDevice.macAddress,
        ),
        _buildInfoItem(
          context,
          label: 'BM',
          value: connectedDevice.bmVersion ?? '--',
        ),
        _buildInfoItem(
          context,
          label: 'Handshake',
          value: connectedDevice.handshakeReady ? 'ready' : '--',
        ),
      ],
    );
  }

  /// 构建单个设备信息字段。
  Widget _buildInfoItem(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 320),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: Theme.of(context).textTheme.bodySmall),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建设备操作按钮区。
  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.tonalIcon(
          onPressed: onGetBmVersion,
          icon: const Icon(Icons.info_outline),
          label: const Text('BM 0x46'),
        ),
        FilledButton.tonalIcon(
          onPressed: onGetLegacyBmVersion,
          icon: const Icon(Icons.history),
          label: const Text('BM 0x0E'),
        ),
        FilledButton.tonalIcon(
          onPressed: onMtuAction,
          icon: const Icon(Icons.swap_vert),
          label: Text(mtuActionLabel),
        ),
      ],
    );
  }

  /// 构建 payload 解析模式控制区。
  Widget _buildParseControls(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.data_object, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parse payload as TLV',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                enableTlvParse ? 'TLV entries' : 'type + data',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Switch(value: enableTlvParse, onChanged: onEnableTlvParseChanged),
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
        return _buildLogItem(context, log);
      },
    );
  }

  /// 构建单条结构化 BLE 日志。
  Widget _buildLogItem(BuildContext context, String log) {
    final time = _logTime(log);
    final source = _logSource(log);
    final body = _logBody(log);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                Text(time, style: Theme.of(context).textTheme.labelSmall),
                if (source.isNotEmpty)
                  Text(source, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: 3),
            SelectableText(
              body,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }

  /// 从日志中提取时间。
  String _logTime(String log) {
    return _logTimePattern.firstMatch(log)?.group(1) ?? '--:--:--';
  }

  /// 从日志中提取来源标签。
  String _logSource(String log) {
    final withoutTime = _logTimePattern.firstMatch(log)?.group(2) ?? log;
    return _logSourcePattern.firstMatch(withoutTime)?.group(1) ?? '';
  }

  /// 从日志中提取正文并去掉重复 remoteId 前缀。
  String _logBody(String log) {
    final withoutTime = _logTimePattern.firstMatch(log)?.group(2) ?? log;
    final withoutSource =
        _logSourcePattern.firstMatch(withoutTime)?.group(2) ?? withoutTime;
    final remotePrefix = '${connectedDevice.remoteId}: ';
    if (withoutSource.startsWith(remotePrefix)) {
      return withoutSource.substring(remotePrefix.length);
    }
    return withoutSource;
  }
}
