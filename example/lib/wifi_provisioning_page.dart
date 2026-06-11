import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_elink_ble/flutter_elink_ble.dart';

import 'example_time_utils.dart';

/// Sample page for WiFi provisioning commands (WiFi 配网命令示例页面).
class WifiProvisioningPage extends StatefulWidget {
  /// Create the WiFi provisioning sample page (创建 WiFi 配网示例页面).
  const WifiProvisioningPage({
    super.key,
    this.initialRemoteId,
    this.showAppBar = true,
  });

  /// Initial BLE remote identifier copied from the connected device (从已连接设备带入的初始 BLE remote identifier).
  final String? initialRemoteId;

  /// Whether this page should build its own app bar (是否构建页面自带 AppBar).
  final bool showAppBar;

  /// Create the mutable state object for this page (创建此页面的可变状态对象).
  @override
  State<WifiProvisioningPage> createState() => _WifiProvisioningPageState();
}

/// State object for the WiFi provisioning sample page (WiFi 配网示例页面的状态对象).
class _WifiProvisioningPageState extends State<WifiProvisioningPage> {
  static const int _maxLogCount = 120;
  static const Duration _duplicateLogWindow = Duration(milliseconds: 500);
  static const String _defaultServerHost = 'ailink.iot.aicare.net.cn';
  static const int _defaultServerPort = 80;
  static const String _defaultServerPath = '';

  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  final List<String> _logs = <String>[];
  final Map<String, DateTime> _recentLogTimes = <String, DateTime>{};
  final TextEditingController _remoteIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _pathController = TextEditingController();

  List<ElinkWifiAccessPoint> _accessPoints = const <ElinkWifiAccessPoint>[];
  ElinkWifiAccessPoint? _selectedAccessPoint;
  ElinkWifiStatusEvent? _latestStatus;
  ElinkWifiResponseEvent? _latestResponse;
  bool _busy = false;
  bool _commandLogsEnabled = false;

  /// Initialize WiFi event subscriptions and default form values (初始化 WiFi 事件订阅和默认表单值).
  @override
  void initState() {
    super.initState();
    _remoteIdController.text = widget.initialRemoteId ?? '';
    _hostController.text = _defaultServerHost;
    _portController.text = _defaultServerPort.toString();
    _pathController.text = _defaultServerPath;
    ElinkWifi.commandLoggingEnabled = _commandLogsEnabled;
    _subscriptions
      ..add(
        ElinkWifi.scanResults.listen((results) {
          if (!mounted) return;
          final selectedKey = _selectedAccessPoint?.key;
          setState(() {
            _accessPoints = results;
            _selectedAccessPoint =
                _findAccessPointByKey(results, selectedKey) ??
                (results.isEmpty ? null : results.first);
          });
          _addLog('[rx][scanResults] count=${results.length}');
        }),
      )
      ..add(
        ElinkWifi.statusEvents.listen((event) {
          if (!mounted) return;
          setState(() => _latestStatus = event);
          _addLog(
            '[rx][status] ${event.remoteId}: '
            'ble=${_formatStatusValue(event.bleStatus, event.rawBleStatus)} '
            'wifi=${_formatStatusValue(event.wifiStatus, event.rawWifiStatus)} '
            'work=${_formatStatusValue(event.workStatus, event.rawWorkStatus)} '
            'fail=${_formatNullableStatusValue(event.failStatus, event.rawFailStatus)}',
          );
        }),
      )
      ..add(
        ElinkWifi.responseEvents.listen((event) {
          if (!mounted) return;
          setState(() => _latestResponse = event);
          _addLog(
            '[rx][response] ${event.remoteId}: '
            'command=${_formatCommand(event.command)} '
            'status=${event.status.name}',
          );
        }),
      )
      ..add(
        ElinkWifi.events.listen((event) {
          if (!mounted) return;
          if (_isTypedWifiLogEvent(event.type)) return;
          if (event.type == 'wifiCommand' && !_commandLogsEnabled) return;
          _addLog(_formatWifiEvent(event));
        }),
      );
  }

  /// Sync a new connected remote identifier into the form when appropriate (在合适时同步新的已连接 remote identifier 到表单).
  @override
  void didUpdateWidget(covariant WifiProvisioningPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextRemoteId = widget.initialRemoteId;
    if (nextRemoteId == null ||
        nextRemoteId.isEmpty ||
        nextRemoteId == oldWidget.initialRemoteId) {
      return;
    }
    final currentRemoteId = _remoteIdController.text.trim();
    final previousRemoteId = oldWidget.initialRemoteId ?? '';
    if (currentRemoteId.isEmpty || currentRemoteId == previousRemoteId) {
      _remoteIdController.text = nextRemoteId;
    }
  }

  /// Dispose form controllers and WiFi subscriptions (释放表单控制器和 WiFi 订阅).
  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _remoteIdController.dispose();
    _passwordController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _pathController.dispose();
    ElinkWifi.commandLoggingEnabled = false;
    unawaited(ElinkWifi.dispose());
    super.dispose();
  }

  /// Build the WiFi provisioning page scaffold (构建 WiFi 配网页面脚手架).
  @override
  Widget build(BuildContext context) {
    final content = _buildContent();
    if (!widget.showAppBar) {
      return content;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('WiFi Provisioning')),
      body: content,
    );
  }

  /// Build the scrollable WiFi provisioning content (构建可滚动的 WiFi 配网内容).
  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildRemoteIdSection(),
        const SizedBox(height: 16),
        _buildStatusSection(),
        const SizedBox(height: 16),
        _buildAccessPointSection(),
        const SizedBox(height: 16),
        _buildProvisioningSection(),
        const SizedBox(height: 16),
        _buildQuerySection(),
        const SizedBox(height: 16),
        _buildServerSection(),
        const SizedBox(height: 16),
        _buildMaintenanceSection(),
        const SizedBox(height: 16),
        _buildLogSection(),
      ],
    );
  }

  /// Build the remote identifier input and primary command row (构建设备 remote identifier 输入和主命令区).
  Widget _buildRemoteIdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.bluetooth_connected, 'Device'),
        const SizedBox(height: 8),
        TextField(
          controller: _remoteIdController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Remote ID',
          ),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCommandButton(
              icon: Icons.wifi_find,
              label: 'Scan WiFi',
              onPressed: _scanWifi,
            ),
            _buildCommandButton(
              icon: Icons.settings_input_antenna,
              label: 'Get State',
              onPressed: _getCurrentState,
            ),
          ],
        ),
      ],
    );
  }

  /// Build the latest WiFi status and command response snapshot (构建最近 WiFi 状态和命令响应快照).
  Widget _buildStatusSection() {
    final status = _latestStatus;
    final response = _latestResponse;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.monitor_heart_outlined, 'State'),
        const SizedBox(height: 8),
        _buildKeyValueRow(
          'BLE',
          status == null
              ? '--'
              : _formatStatusValue(status.bleStatus, status.rawBleStatus),
        ),
        _buildKeyValueRow(
          'WiFi',
          status == null
              ? '--'
              : _formatStatusValue(status.wifiStatus, status.rawWifiStatus),
        ),
        _buildKeyValueRow(
          'Work',
          status == null
              ? '--'
              : _formatStatusValue(status.workStatus, status.rawWorkStatus),
        ),
        _buildKeyValueRow(
          'Fail',
          status == null
              ? '--'
              : _formatNullableStatusValue(
                  status.failStatus,
                  status.rawFailStatus,
                ),
        ),
        const Divider(height: 20),
        _buildKeyValueRow(
          'Last Command',
          response == null ? '--' : _formatCommand(response.command),
        ),
        _buildKeyValueRow('Last Result', response?.status.name ?? '--'),
      ],
    );
  }

  /// Build the scanned WiFi access point list (构建扫描到的 WiFi 热点列表).
  Widget _buildAccessPointSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.wifi, 'Access Points'),
        const SizedBox(height: 8),
        if (_accessPoints.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No WiFi scan results'),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _accessPoints.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final accessPoint = _accessPoints[index];
              final selected = _selectedAccessPoint?.key == accessPoint.key;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                selected: selected,
                onTap: () => setState(() => _selectedAccessPoint = accessPoint),
                title: Text(_formatAccessPointTitle(accessPoint)),
                subtitle: Text(_formatAccessPointSubtitle(accessPoint)),
              );
            },
          ),
      ],
    );
  }

  /// Build WiFi password and connection commands (构建 WiFi 密码和连接命令区).
  Widget _buildProvisioningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.router_outlined, 'Provisioning'),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'WiFi Password',
          ),
          obscureText: true,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCommandButton(
              icon: Icons.link,
              label: 'Configure & Connect',
              onPressed: _configureAndConnect,
              filled: true,
            ),
            _buildCommandButton(
              icon: Icons.wifi,
              label: 'Connect',
              onPressed: _connectWifi,
            ),
            _buildCommandButton(
              icon: Icons.wifi_off,
              label: 'Disconnect',
              onPressed: _disconnectWifi,
            ),
          ],
        ),
      ],
    );
  }

  /// Build WiFi information query commands (构建 WiFi 信息查询命令区).
  Widget _buildQuerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.manage_search, 'Query'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCommandButton(
              icon: Icons.badge_outlined,
              label: 'SSID',
              onPressed: _getConnectedSsid,
            ),
            _buildCommandButton(
              icon: Icons.memory,
              label: 'MAC',
              onPressed: _getConnectedMac,
            ),
            _buildCommandButton(
              icon: Icons.key,
              label: 'Password',
              onPressed: _getConnectedPassword,
            ),
            _buildCommandButton(
              icon: Icons.confirmation_number_outlined,
              label: 'SN',
              onPressed: _getDeviceSn,
            ),
          ],
        ),
      ],
    );
  }

  /// Build server setting fields and commands (构建服务器参数输入和命令区).
  Widget _buildServerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.dns_outlined, 'Server'),
        const SizedBox(height: 8),
        TextField(
          controller: _hostController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Host',
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _portController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Port',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: TextField(
                controller: _pathController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Path',
                ),
                textInputAction: TextInputAction.done,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCommandButton(
              icon: Icons.cloud_download_outlined,
              label: 'Get Server',
              onPressed: _getServerInfo,
            ),
            _buildCommandButton(
              icon: Icons.cloud_upload_outlined,
              label: 'Set Server',
              onPressed: _setServerInfo,
            ),
          ],
        ),
      ],
    );
  }

  /// Build restart and factory reset commands (构建重启和恢复出厂命令区).
  Widget _buildMaintenanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.build_circle_outlined, 'Maintenance'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCommandButton(
              icon: Icons.restart_alt,
              label: 'Restart',
              onPressed: _restartModule,
            ),
            _buildCommandButton(
              icon: Icons.restore,
              label: 'Factory Reset',
              onPressed: _resetModule,
              destructive: true,
            ),
          ],
        ),
      ],
    );
  }

  /// Build the WiFi command log viewer (构建 WiFi 命令日志视图).
  Widget _buildLogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildSectionTitle(Icons.receipt_long, 'Logs')),
            const Text('Command logs'),
            Switch(
              value: _commandLogsEnabled,
              onChanged: _setCommandLogsEnabled,
            ),
          ],
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            height: 220,
            child: ListView.builder(
              reverse: true,
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[_logs.length - 1 - index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Text(log, style: const TextStyle(fontSize: 12)),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Build a section title row with a Material icon (构建带 Material 图标的分区标题).
  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }

  /// Build one key-value status row (构建单行键值状态).
  Widget _buildKeyValueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  /// Build a reusable command button for the sample page (构建示例页复用命令按钮).
  Widget _buildCommandButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool filled = false,
    bool destructive = false,
  }) {
    final foregroundColor = destructive
        ? Theme.of(context).colorScheme.error
        : null;
    final iconWidget = Icon(icon);
    final labelWidget = Text(label);
    final action = _busy ? null : onPressed;
    if (filled) {
      return FilledButton.icon(
        onPressed: action,
        icon: iconWidget,
        label: labelWidget,
      );
    }
    return OutlinedButton.icon(
      style: foregroundColor == null
          ? null
          : OutlinedButton.styleFrom(foregroundColor: foregroundColor),
      onPressed: action,
      icon: iconWidget,
      label: labelWidget,
    );
  }

  /// Scan nearby WiFi access points through the connected module (通过已连接模块扫描附近 WiFi 热点).
  Future<void> _scanWifi() {
    return _runWifiCommand('scan', ElinkWifi.scan);
  }

  /// Query BLE, WiFi, and module work state (查询 BLE、WiFi 和模块工作状态).
  Future<void> _getCurrentState() {
    return _runWifiCommand('getCurrentState', ElinkWifi.getCurrentState);
  }

  /// Configure selected WiFi access point and ask the module to connect (配置选中的 WiFi 热点并请求模块连接).
  Future<void> _configureAndConnect() async {
    final accessPoint = _selectedAccessPoint;
    if (accessPoint == null) {
      _addLog('[configureAndConnect] select an access point first');
      return;
    }
    final macAddress = _accessPointMacAddress(accessPoint);
    if (macAddress.isEmpty) {
      _addLog('[configureAndConnect] selected access point has no MAC');
      return;
    }
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim());
    final path = _pathController.text.trim();
    if (host.isEmpty) {
      _addLog('[configureAndConnect] host is required');
      return;
    }
    if (port == null || port < 0 || port > 65535) {
      _addLog('[configureAndConnect] port must be 0..65535');
      return;
    }
    await _runWifiCommand(
      'configureAndConnect',
      (remoteId) => ElinkWifi.configureServerAndConnect(
        remoteId,
        host: host,
        port: port,
        path: path,
        macAddress: macAddress,
        password: _passwordController.text,
      ),
    );
  }

  /// Ask the module to connect the configured WiFi (请求模块连接已配置 WiFi).
  Future<void> _connectWifi() {
    return _runWifiCommand('connect', ElinkWifi.connect);
  }

  /// Ask the module to disconnect WiFi (请求模块断开 WiFi).
  Future<void> _disconnectWifi() {
    return _runWifiCommand('disconnect', ElinkWifi.disconnect);
  }

  /// Query the connected WiFi SSID (查询当前连接 WiFi 名称).
  Future<void> _getConnectedSsid() {
    return _runWifiCommand('getConnectedSsid', ElinkWifi.getConnectedSsid);
  }

  /// Query the connected WiFi MAC address (查询当前连接 WiFi MAC).
  Future<void> _getConnectedMac() {
    return _runWifiCommand('getConnectedMac', ElinkWifi.getConnectedMac);
  }

  /// Query the saved WiFi password (查询已保存 WiFi 密码).
  Future<void> _getConnectedPassword() {
    return _runWifiCommand(
      'getConnectedPassword',
      ElinkWifi.getConnectedPassword,
    );
  }

  /// Query WiFi module device serial number (查询 WiFi 模块设备 SN).
  Future<void> _getDeviceSn() {
    return _runWifiCommand('getDeviceSn', ElinkWifi.getDeviceSn);
  }

  /// Query server host, port, and path from the module (查询模块服务端 host、port 和 path).
  Future<void> _getServerInfo() {
    return _runWifiCommand('getServerInfo', ElinkWifi.getServerInfo);
  }

  /// Set server host, port, and path on the module (设置模块服务端 host、port 和 path).
  Future<void> _setServerInfo() async {
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim());
    if (host.isEmpty) {
      _addLog('[setServerInfo] host is required');
      return;
    }
    if (port == null || port < 0 || port > 65535) {
      _addLog('[setServerInfo] port must be 0..65535');
      return;
    }
    await _runWifiCommand(
      'setServerInfo',
      (remoteId) => ElinkWifi.setServerInfo(
        remoteId,
        host: host,
        port: port,
        path: _pathController.text.trim(),
      ),
    );
  }

  /// Restart the WiFi/BLE module (重启 WiFi/BLE 模块).
  Future<void> _restartModule() {
    return _runWifiCommand('restart', ElinkWifi.restart);
  }

  /// Reset the WiFi/BLE module to factory data (将 WiFi/BLE 模块恢复出厂设置).
  Future<void> _resetModule() {
    return _runWifiCommand('reset', ElinkWifi.reset);
  }

  /// Run one WiFi command with remote identifier validation and logging (校验 remote identifier 后执行 WiFi 命令并记录日志).
  Future<void> _runWifiCommand(
    String label,
    Future<void> Function(String remoteId) command,
  ) async {
    final remoteId = _remoteIdController.text.trim();
    if (remoteId.isEmpty) {
      _addLog('[$label] remoteId is required');
      return;
    }
    if (mounted) {
      setState(() => _busy = true);
    }
    try {
      await command(remoteId);
      if (_commandLogsEnabled) {
        _addLog('[call][$label] $remoteId');
      }
    } catch (error) {
      _addLog('[error][$label] $remoteId: $error');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  /// Find one access point by its stable scan key (按稳定扫描 key 查找热点).
  ElinkWifiAccessPoint? _findAccessPointByKey(
    List<ElinkWifiAccessPoint> accessPoints,
    String? key,
  ) {
    if (key == null) {
      return null;
    }
    for (final accessPoint in accessPoints) {
      if (accessPoint.key == key) {
        return accessPoint;
      }
    }
    return null;
  }

  /// Format the title for one access point row (格式化单个热点行标题).
  String _formatAccessPointTitle(ElinkWifiAccessPoint accessPoint) {
    final ssid = accessPoint.ssid.isEmpty ? 'Hidden SSID' : accessPoint.ssid;
    final macAddress = _accessPointMacAddress(accessPoint);
    return macAddress.isEmpty ? ssid : '$ssid  $macAddress';
  }

  /// Format the subtitle for one access point row (格式化单个热点行副标题).
  String _formatAccessPointSubtitle(ElinkWifiAccessPoint accessPoint) {
    return [
      'RSSI ${accessPoint.rssi}',
      accessPoint.securityType.name,
      accessPoint.useState.name,
      'id ${accessPoint.id}',
    ].join('  ');
  }

  /// Format the WiFi MAC address from string or byte fields (从字符串或 byte 字段格式化 WiFi MAC).
  String _accessPointMacAddress(ElinkWifiAccessPoint accessPoint) {
    if (accessPoint.macAddress.isNotEmpty) {
      return accessPoint.macAddress;
    }
    if (accessPoint.macData.isNotEmpty) {
      return ElinkByteUtils.formatMac(accessPoint.macData);
    }
    return '';
  }

  /// Format one generic WiFi event for logs (格式化单条通用 WiFi 事件日志).
  String _formatWifiEvent(ElinkWifiEvent event) {
    final isCommandLog = event.type == 'wifiCommand';
    final parts = <String>[
      isCommandLog
          ? '[tx][wifiCommand] ${event.remoteId}:'
          : '[rx][event] ${event.remoteId}: ${event.type}',
    ];
    if (event.status != null) {
      parts.add('status=${event.status}');
    }
    if (event.command != null) {
      parts.add('command=${_formatCommand(event.command!)}');
    }
    final hex = event.raw['hex'];
    if (hex != null && hex.toString().isNotEmpty) {
      parts.add('data=$hex');
    }
    if (event.value != null) {
      parts.add(isCommandLog ? 'name=${event.value}' : 'value=${event.value}');
    }
    if (event.accessPoint != null) {
      parts.add('ap=${_formatAccessPointTitle(event.accessPoint!)}');
    }
    if (event.accessPoints.isNotEmpty) {
      parts.add('count=${event.accessPoints.length}');
    }
    return parts.join(' ');
  }

  /// Check whether a WiFi event is already logged by a typed stream (判断 WiFi 事件是否已由 typed stream 记录).
  bool _isTypedWifiLogEvent(String type) {
    return switch (type) {
      'wifiScanResult' ||
      'wifiScanFinished' ||
      'wifiStatus' ||
      'wifiResponse' => true,
      _ => false,
    };
  }

  /// Toggle WiFi command debug logs (切换 WiFi 指令调试日志).
  void _setCommandLogsEnabled(bool enabled) {
    ElinkWifi.commandLoggingEnabled = enabled;
    setState(() => _commandLogsEnabled = enabled);
  }

  /// Format a WiFi command code as hexadecimal text (将 WiFi 命令码格式化为十六进制文本).
  String _formatCommand(int command) {
    return '0x${command.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  /// Format one status enum with its raw SDK value (格式化单个状态枚举和 SDK 原始值).
  String _formatStatusValue(Enum status, int rawValue) {
    return '${status.name}($rawValue)';
  }

  /// Format one nullable status enum with its raw SDK value (格式化可空状态枚举和 SDK 原始值).
  String _formatNullableStatusValue(Enum? status, int? rawValue) {
    if (status == null || rawValue == null) {
      return '-';
    }
    return _formatStatusValue(status, rawValue);
  }

  /// Add one line to the bounded log buffer (向有长度限制的日志缓冲区添加一行).
  void _addLog(String message) {
    if (!mounted) return;
    final now = DateTime.now();
    _recentLogTimes.removeWhere(
      (_, time) => now.difference(time) > _duplicateLogWindow,
    );
    final lastTime = _recentLogTimes[message];
    if (lastTime != null && now.difference(lastTime) <= _duplicateLogWindow) {
      return;
    }
    _recentLogTimes[message] = now;
    final timestamp = ExampleTimeUtils.formatTimestamp(now);
    setState(() {
      _logs.add('[$timestamp] $message');
      if (_logs.length > _maxLogCount) {
        _logs.removeAt(0);
      }
    });
  }
}
