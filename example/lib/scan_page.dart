import 'package:flutter/material.dart';
import 'package:flutter_elink_ble/flutter_elink_ble.dart';

import 'android_resend_count_setting.dart';

/// Sample page for scanning BLE devices (BLE 设备扫描示例页面).
class ScanPage extends StatelessWidget {
  /// Create the scan sample page (创建扫描示例页面).
  const ScanPage({
    super.key,
    required this.adapterState,
    required this.isScanning,
    required this.scanResults,
    required this.connectedRemoteIds,
    required this.onOpenBluetooth,
    required this.onStartScan,
    required this.onStopScan,
    required this.onConnect,
    required this.showAndroidCommandResendSetting,
    required this.androidCommandResendCount,
    required this.onAndroidCommandResendCountChanged,
  });

  /// Current BLE adapter state (当前 BLE adapter 状态).
  final ElinkAdapterState adapterState;

  /// Whether a BLE scan is currently running (当前是否正在扫描 BLE).
  final bool isScanning;

  /// Latest BLE scan results (最新 BLE 扫描结果).
  final List<ElinkScanResult> scanResults;

  /// 已连接 BLE 设备 remoteId 集合。
  final Set<String> connectedRemoteIds;

  /// Callback for asking the system to open Bluetooth (请求系统打开蓝牙的回调).
  final VoidCallback onOpenBluetooth;

  /// Callback for starting a BLE scan (启动 BLE 扫描的回调).
  final VoidCallback onStartScan;

  /// Callback for stopping a BLE scan (停止 BLE 扫描的回调).
  final VoidCallback onStopScan;

  /// Callback for connecting to one scanned BLE device (连接单个已扫描 BLE 设备的回调).
  final ValueChanged<ElinkDevice> onConnect;

  /// Whether to show Android command resend setting (是否展示 Android 指令重发设置).
  final bool showAndroidCommandResendSetting;

  /// Current Android command resend count (当前 Android 指令重发次数).
  final int androidCommandResendCount;

  /// Callback for changing Android command resend count (修改 Android 指令重发次数的回调).
  final ValueChanged<int> onAndroidCommandResendCountChanged;

  /// Build the BLE scan page (构建 BLE 扫描页面).
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildScanToolbar(),
              if (showAndroidCommandResendSetting) ...[
                const SizedBox(height: 8),
                AndroidResendCountSetting(
                  resendCount: androidCommandResendCount,
                  onChanged: onAndroidCommandResendCountChanged,
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: scanResults.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  itemCount: scanResults.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return _buildScanResultTile(scanResults[index]);
                  },
                ),
        ),
      ],
    );
  }

  /// Build scan control buttons (构建扫描控制按钮).
  Widget _buildScanToolbar() {
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Open Bluetooth',
          onPressed: adapterState == ElinkAdapterState.on
              ? null
              : onOpenBluetooth,
          icon: const Icon(Icons.bluetooth),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: isScanning ? null : onStartScan,
          icon: const Icon(Icons.bluetooth_searching),
          label: const Text('Scan'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: isScanning ? onStopScan : null,
          icon: const Icon(Icons.stop),
          label: const Text('Stop'),
        ),
      ],
    );
  }

  /// Build the empty scan result state (构建扫描结果为空的状态).
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        isScanning ? 'Scanning...' : 'No BLE devices',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  /// Build one scan result row (构建单条扫描结果行).
  Widget _buildScanResultTile(ElinkScanResult result) {
    final isConnected = connectedRemoteIds.contains(result.device.remoteId);
    return ListTile(
      title: Text(_deviceTitle(result.device)),
      subtitle: Text(_scanResultSubtitle(result)),
      trailing: FilledButton.tonal(
        onPressed: isConnected ? null : () => onConnect(result.device),
        child: Text(isConnected ? 'Connected' : 'Connect'),
      ),
    );
  }

  /// Format the scan result device title (格式化扫描结果设备标题).
  String _deviceTitle(ElinkDevice device) {
    return device.platformName.isEmpty ? 'Unknown' : device.platformName;
  }

  /// Format the scan result subtitle (格式化扫描结果副标题).
  String _scanResultSubtitle(ElinkScanResult result) {
    final data = result.advertisementData.identity;
    final macAddress = result.device.macAddress.isNotEmpty
        ? result.device.macAddress
        : data.macAddress;
    return [
      result.device.remoteId,
      'RSSI ${result.rssi}',
      'MAC ${macAddress.isEmpty ? "--" : macAddress}',
      'CID ${data.cidValue}',
      'VID ${data.vidValue}',
      'PID ${data.pidValue}',
    ].join('  ');
  }
}
