import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_elink_ble/flutter_elink_ble.dart';

import 'bluetooth_connection_page.dart';
import 'connected_device_info.dart';
import 'example_time_utils.dart';
import 'scan_page.dart';
import 'wifi_provisioning_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ElinkExampleApp());
}

class ElinkExampleApp extends StatelessWidget {
  const ElinkExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ElinkHomePage(),
    );
  }
}

class ElinkHomePage extends StatefulWidget {
  const ElinkHomePage({super.key});

  @override
  State<ElinkHomePage> createState() => _ElinkHomePageState();
}

class _ElinkHomePageState extends State<ElinkHomePage> {
  static const int _maxLogCount = 160;

  /// Android 示例默认请求的 GATT MTU。
  static const int _defaultAndroidMtu = 517;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  final Map<String, List<String>> _deviceLogs = <String, List<String>>{};
  final Set<String> _handshakeStartedRemoteIds = <String>{};
  final Set<String> _handshakeReadyRemoteIds = <String>{};
  final Map<String, ElinkServiceDiscoveredEvent> _handshakeServiceEvents =
      <String, ElinkServiceDiscoveredEvent>{};
  List<ElinkScanResult> _scanResults = const <ElinkScanResult>[];
  ElinkAdapterState _adapterState = ElinkBle.adapterStateNow;
  bool _isScanning = false;
  bool _enableTlvParse = false;
  int _androidCommandResendCount = 0;
  final Set<String> _connectedRemoteIds = <String>{};
  final Map<String, String> _connectedMacAddresses = <String, String>{};
  final Map<String, String> _bmVersions = <String, String>{};
  String? _selectedRemoteId;

  @override
  void initState() {
    super.initState();
    _subscriptions
      ..add(
        ElinkBle.adapterState.listen((state) {
          setState(() => _adapterState = state);
        }),
      )
      ..add(
        ElinkBle.isScanning.listen((isScanning) {
          if (_isScanning == isScanning) {
            return;
          }
          setState(() => _isScanning = isScanning);
        }),
      )
      ..add(
        ElinkBle.scanResults.listen((results) {
          setState(() => _scanResults = results);
        }),
      )
      ..add(
        ElinkBle.connectionEvents.listen((event) {
          setState(() {
            switch (event.connectionState) {
              case ElinkConnectionState.connected:
                _connectedRemoteIds.add(event.remoteId);
                _selectedRemoteId = event.remoteId;
                _connectedMacAddresses[event.remoteId] = _macAddressFor(
                  event.remoteId,
                );
                break;
              case ElinkConnectionState.disconnected:
                _connectedRemoteIds.remove(event.remoteId);
                _connectedMacAddresses.remove(event.remoteId);
                _bmVersions.remove(event.remoteId);
                _handshakeStartedRemoteIds.remove(event.remoteId);
                _handshakeReadyRemoteIds.remove(event.remoteId);
                _handshakeServiceEvents.remove(event.remoteId);
                if (_selectedRemoteId == event.remoteId) {
                  _selectedRemoteId = _connectedRemoteIds.isEmpty
                      ? null
                      : _connectedRemoteIds.first;
                }
                break;
              case ElinkConnectionState.connecting:
              case ElinkConnectionState.disconnecting:
                _selectedRemoteId ??= event.remoteId;
                break;
            }
          });
          _addDeviceLog(
            event.remoteId,
            '[connectionEvents] ${event.remoteId}: '
            '${event.connectionState.name}',
          );
          if (event.connectionState.isConnected) {
            unawaited(_startHandshakeIfReady(event.remoteId));
          }
        }),
      )
      ..add(
        ElinkBle.serviceDiscoveryEvents.listen((event) {
          _addDeviceLog(
            event.remoteId,
            '[serviceDiscoveryEvents] ${event.remoteId}: '
            '${event.serviceUuid} '
            '${event.characteristicUuids.map((uuid) => uuid.value).join(",")}',
          );
          if (_hasWriteCharacteristic(event)) {
            _handshakeServiceEvents[event.remoteId] = event;
            unawaited(_startHandshakeIfReady(event.remoteId));
          }
        }),
      )
      ..add(
        ElinkBle.protocolDataPackets.listen((packet) {
          _addDeviceLog(
            packet.remoteId,
            '[protocolDataPackets] ${packet.remoteId}: '
            '${packet.protocol.name.toUpperCase()} '
            'payload=${ElinkDataProcessor.formatHex(packet.data)}',
          );
          _addProtocolPacketParseLogs(packet);
        }),
      )
      ..add(
        ElinkBle.passthroughDataPackets.listen((packet) {
          _addDeviceLog(
            packet.remoteId,
            '[passthroughDataPackets] ${packet.remoteId}: '
            '${ElinkDataProcessor.formatHex(packet.data)}',
          );
          _addRawFrameParseLogs(
            source: 'passthroughDataPackets',
            remoteId: packet.remoteId,
            data: packet.data,
          );
        }),
      )
      ..add(
        ElinkBle.characteristicEvents.listen((event) {
          _addDeviceLog(
            event.remoteId,
            '[characteristicEvents] ${event.remoteId}: '
            '${event.operation.name} ${event.characteristicUuid} '
            '${ElinkDataProcessor.formatHex(event.data)}',
          );
          unawaited(_handleA7CharacteristicChanged(event));
          _addRawFrameParseLogs(
            source: 'characteristicEvents',
            remoteId: event.remoteId,
            data: event.data,
          );
        }),
      )
      ..add(
        ElinkBle.rssiEvents.listen((event) {
          _addDeviceLog(
            event.remoteId,
            '[rssiEvents] ${event.remoteId}: ${event.rssi}',
          );
        }),
      )
      ..add(
        ElinkBle.mtuEvents.listen((event) {
          _addDeviceLog(
            event.remoteId,
            '[mtuEvents] ${event.remoteId}: '
            'mtu=${event.mtu} available=${event.availableMtu}',
          );
        }),
      )
      ..add(
        ElinkBle.handshakeEvents.listen((event) {
          if (event.success) {
            _handshakeReadyRemoteIds.add(event.remoteId);
          }
          _addDeviceLog(
            event.remoteId,
            '[handshakeEvents] ${event.remoteId}: ${event.success}',
          );
        }),
      )
      ..add(
        ElinkBle.bmVersionEvents.listen((event) {
          if (_connectedRemoteIds.contains(event.remoteId)) {
            setState(() => _bmVersions[event.remoteId] = event.version);
          }
          _addDeviceLog(
            event.remoteId,
            '[bmVersionEvents] ${event.remoteId}: ${event.version}',
          );
        }),
      )
      ..add(
        ElinkBle.errors.listen((error) {
          final remoteId = _remoteIdFromError(error);
          if (remoteId != null) {
            _addDeviceLog(remoteId, '[errors] $error');
          }
        }),
      );
    unawaited(ElinkBle.refreshAdapterState());
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    unawaited(ElinkBle.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elink BLE'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: Text(_adapterState.name)),
          ),
        ],
      ),
      body: _buildCurrentPage(),
    );
  }

  /// Build the current example page from scan and connection state (根据扫描和连接状态构建当前示例页面).
  Widget _buildCurrentPage() {
    final connectedDevices = _connectedDevices();
    return DefaultTabController(
      key: ValueKey<String>(
        'tabs:${connectedDevices.length}:${_selectedRemoteId ?? ""}',
      ),
      length: connectedDevices.length + 1,
      initialIndex: _initialTabIndex(connectedDevices),
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [
              const Tab(icon: Icon(Icons.bluetooth_searching), text: 'Scan'),
              ...connectedDevices.map(_buildDeviceTab),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ScanPage(
                  adapterState: _adapterState,
                  isScanning: _isScanning,
                  scanResults: _scanResults,
                  connectedRemoteIds: _connectedRemoteIds,
                  onOpenBluetooth: () => unawaited(_openBluetooth()),
                  onStartScan: () => unawaited(_startScan()),
                  onStopScan: () => unawaited(_stopScan()),
                  onConnect: (device) => unawaited(_connect(device)),
                  showAndroidCommandResendSetting: Platform.isAndroid,
                  androidCommandResendCount: _androidCommandResendCount,
                  onAndroidCommandResendCountChanged: (resendCount) {
                    unawaited(_setAndroidCommandResendCount(resendCount));
                  },
                ),
                ...connectedDevices.map(_buildDevicePage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 计算动态 tab 初始索引，连接成功后自动切到对应设备。
  int _initialTabIndex(List<ConnectedDeviceInfo> connectedDevices) {
    final selectedRemoteId = _selectedRemoteId;
    if (selectedRemoteId == null) {
      return 0;
    }
    final deviceIndex = connectedDevices.indexWhere(
      (device) => device.remoteId == selectedRemoteId,
    );
    return deviceIndex < 0 ? 0 : deviceIndex + 1;
  }

  /// 构建单个已连接设备的 tab。
  Tab _buildDeviceTab(ConnectedDeviceInfo device) {
    return Tab(
      icon: const Icon(Icons.bluetooth_connected),
      text: _deviceTabLabel(device),
    );
  }

  /// 构建单个已连接设备的操作页。
  Widget _buildDevicePage(ConnectedDeviceInfo device) {
    final remoteId = device.remoteId;
    return BluetoothConnectionPage(
      connectedDevice: device,
      enableTlvParse: _enableTlvParse,
      logs: _logsForDevice(remoteId),
      onClearLogs: () => _clearDeviceLogs(remoteId),
      onDisconnect: () => unawaited(_disconnectDevice(remoteId)),
      onGetBmVersion: () => unawaited(_getBmVersion(remoteId)),
      mtuActionLabel: Platform.isIOS
          ? 'Get iOS MTU'
          : Platform.isAndroid
          ? 'Set MTU 517'
          : 'MTU',
      onMtuAction: () => unawaited(_handleMtu(remoteId)),
      onOpenWifiProvisioning: () => _openWifiProvisioning(remoteId),
      onEnableTlvParseChanged: (value) {
        setState(() => _enableTlvParse = value);
        _addDeviceLog(remoteId, '[parseConfig] tlv=$value');
      },
      showAndroidCommandResendSetting: Platform.isAndroid,
      androidCommandResendCount: _androidCommandResendCount,
      onAndroidCommandResendCountChanged: (resendCount) {
        unawaited(
          _setAndroidCommandResendCount(resendCount, logRemoteId: remoteId),
        );
      },
    );
  }

  /// 格式化设备 tab 文案。
  String _deviceTabLabel(ConnectedDeviceInfo device) {
    final id = device.remoteId;
    final shortId = id.length <= 8 ? id : id.substring(id.length - 8);
    return device.handshakeReady ? 'Ready $shortId' : shortId;
  }

  /// Build connected device view models for the device tab (构建设备页使用的已连接设备信息).
  List<ConnectedDeviceInfo> _connectedDevices() {
    return _connectedRemoteIds
        .map((remoteId) {
          final cachedMacAddress = _connectedMacAddresses[remoteId];
          return ConnectedDeviceInfo(
            remoteId: remoteId,
            macAddress: cachedMacAddress == null || cachedMacAddress.isEmpty
                ? _macAddressFor(remoteId)
                : cachedMacAddress,
            bmVersion: _bmVersions[remoteId],
            handshakeReady: _handshakeReadyRemoteIds.contains(remoteId),
          );
        })
        .toList(growable: false);
  }

  /// 获取指定设备 tab 当前展示的日志列表。
  List<String> _logsForDevice(String remoteId) {
    return _deviceLogs[remoteId] ?? const <String>[];
  }

  /// 清空指定设备 tab 的日志，不影响其它设备页面。
  void _clearDeviceLogs(String remoteId) {
    setState(() => _deviceLogs.remove(remoteId));
  }

  /// Resolve one device MAC from scan cache or connected cache (从扫描缓存或连接缓存解析设备 MAC).
  String _macAddressFor(String remoteId) {
    for (final result in _scanResults) {
      if (result.device.remoteId != remoteId) {
        continue;
      }
      if (result.device.macAddress.isNotEmpty) {
        return result.device.macAddress;
      }
      final macAddress = result.advertisementData.identity.macAddress;
      if (macAddress.isNotEmpty) {
        return macAddress;
      }
    }
    return _connectedMacAddresses[remoteId] ?? '';
  }

  /// Connect one BLE device after stopping this example scan, and log failures (停止示例页扫描后连接一个 BLE 设备，并记录失败).
  Future<void> _connect(ElinkDevice device) async {
    if (_connectedRemoteIds.contains(device.remoteId)) {
      setState(() => _selectedRemoteId = device.remoteId);
      return;
    }
    try {
      setState(() {
        _selectedRemoteId ??= device.remoteId;
        _connectedMacAddresses[device.remoteId] = device.macAddress;
      });
      if (_isScanning) {
        await ElinkBle.stopScan();
      }
      await ElinkBle.connect(device);
    } catch (error) {
      _addDeviceLog(device.remoteId, '[connect] ${device.remoteId}: $error');
    }
  }

  /// 根据当前平台处理 MTU：Android 请求 517，iOS 查询最大写入长度。
  Future<void> _handleMtu(
    String remoteId, {
    int androidMtu = _defaultAndroidMtu,
  }) async {
    try {
      if (Platform.isIOS) {
        final mtu = await ElinkBle.getIosMtu(remoteId);
        _addDeviceLog(
          remoteId,
          '[getIosMtu] $remoteId: '
          'withoutResponse=${mtu.maxWriteWithoutResponse} '
          'withResponse=${mtu.maxWriteWithResponse}',
        );
        return;
      }
      if (!Platform.isAndroid) {
        _addDeviceLog(remoteId, '[mtu] $remoteId: unsupported platform');
        return;
      }
      final requested = await ElinkBle.setAndroidMtu(remoteId, androidMtu);
      _addDeviceLog(
        remoteId,
        '[setAndroidMtu] $remoteId: '
        'mtu=$androidMtu requested=$requested',
      );
    } catch (error) {
      _addDeviceLog(remoteId, '[mtu] $remoteId: $error');
    }
  }

  /// 更新 Android 指令发送失败重发次数，0 表示关闭。
  Future<void> _setAndroidCommandResendCount(
    int resendCount, {
    String? logRemoteId,
  }) async {
    if (resendCount < 0 || resendCount == _androidCommandResendCount) {
      return;
    }
    final previousCount = _androidCommandResendCount;
    setState(() => _androidCommandResendCount = resendCount);
    try {
      await ElinkBle.setAndroidCommandResendCount(resendCount: resendCount);
      if (logRemoteId != null) {
        _addDeviceLog(logRemoteId, '[androidResend] resendCount=$resendCount');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _androidCommandResendCount = previousCount);
      }
      if (logRemoteId != null) {
        _addDeviceLog(
          logRemoteId,
          '[androidResend] resendCount=$resendCount: $error',
        );
      }
    }
  }

  /// Disconnect the selected BLE device by remoteId and log failures (按 remoteId 断开选中 BLE 设备，并记录失败).
  Future<void> _disconnectDevice(String remoteId) async {
    try {
      await ElinkBle.disconnect(remoteId);
    } catch (error) {
      _addDeviceLog(remoteId, '[disconnect] $remoteId: $error');
    }
  }

  Future<void> _startScan() async {
    try {
      await ElinkBle.startScan(timeout: const Duration(seconds: 10));
    } catch (error) {
      debugPrint('[startScan] $error');
    }
  }

  Future<void> _stopScan() async {
    try {
      await ElinkBle.stopScan();
    } catch (error) {
      debugPrint('[stopScan] $error');
    }
  }

  /// 请求系统打开蓝牙，并立即刷新一次缓存状态。
  Future<void> _openBluetooth() async {
    try {
      await ElinkBle.openBluetooth();
      await ElinkBle.refreshAdapterState();
    } catch (error) {
      debugPrint('[openBluetooth] $error');
    }
  }

  Future<void> _getBmVersion(String remoteId) async {
    try {
      await ElinkBle.getBmVersion(remoteId);
      _addDeviceLog(
        remoteId,
        '[tx][getBmVersion] $remoteId: '
        '${ElinkDataProcessor.formatHex(ElinkDataProcessor.getBmVersionPacket())}',
      );
    } catch (error) {
      _addDeviceLog(remoteId, '[getBmVersion] $remoteId: $error');
    }
  }

  /// Open the WiFi provisioning page with the connected BLE remoteId (使用当前已连接 BLE remoteId 打开 WiFi 配网页面).
  void _openWifiProvisioning(String remoteId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => WifiProvisioningPage(initialRemoteId: remoteId),
      ),
    );
  }

  bool _hasWriteCharacteristic(ElinkServiceDiscoveredEvent event) {
    return event.characteristicUuids.any((uuid) {
      return uuid == ElinkGuid.write ||
          uuid == ElinkGuid.writeAndNotify ||
          uuid.value == 'FFE1' ||
          uuid.value == 'FFE3';
    });
  }

  Future<void> _startHandshakeIfReady(String remoteId) async {
    final event = _handshakeServiceEvents[remoteId];
    if (event == null ||
        !_connectedRemoteIds.contains(remoteId) ||
        !_handshakeStartedRemoteIds.add(remoteId)) {
      return;
    }
    try {
      final packet = await ElinkDataProcessor.initHandshake(remoteId: remoteId);
      if (packet == null || packet.isEmpty) {
        _addDeviceLog(remoteId, '[handshake] $remoteId: init packet is empty');
        return;
      }
      await _writeData(remoteId, packet, source: 'handshake');
      _addRawFrameParseLogs(
        source: 'tx:handshake',
        remoteId: remoteId,
        data: packet,
      );
    } catch (error) {
      _handshakeStartedRemoteIds.remove(remoteId);
      _addDeviceLog(remoteId, '[handshake] $remoteId: $error');
    }
  }

  Future<void> _writeData(
    String remoteId,
    Iterable<int> data, {
    required String source,
  }) async {
    final bytes = List<int>.unmodifiable(data);
    await ElinkBle.write(remoteId, bytes);
    _addDeviceLog(
      remoteId,
      '[tx][$source] $remoteId: ${ElinkDataProcessor.formatHex(bytes)}',
    );
  }

  /// 在 sample 的 characteristic changed 回调中处理完整 A7 原始 frame。
  Future<void> _handleA7CharacteristicChanged(
    ElinkCharacteristicEvent event,
  ) async {
    if (event.operation != ElinkCharacteristicOperation.changed) {
      return;
    }
    final frame = ElinkDataProcessor.tryParseA7Frame(event.data);
    if (frame == null) {
      return;
    }
    final mac = _a7DecryptMac(event.remoteId);
    if (mac == null || mac.isEmpty) {
      _addDeviceLog(
        event.remoteId,
        '[a7Decrypt] ${event.remoteId}: missing MAC',
      );
      return;
    }
    try {
      final decrypted = await ElinkDataProcessor.decryptA7Packet(
        mac: mac,
        packet: frame.rawData,
      );
      if (decrypted == null) {
        _addDeviceLog(
          event.remoteId,
          '[a7Decrypt] ${event.remoteId}: decrypt result is null',
        );
        return;
      }
      final cidText = frame.cid == null
          ? '-'
          : '0x${frame.cid!.toRadixString(16).padLeft(4, '0').toUpperCase()}';
      _addDeviceLog(
        event.remoteId,
        '[a7Decrypt][characteristicEvents] ${event.remoteId}: '
        'cid=$cidText payload=${ElinkDataProcessor.formatHex(decrypted)}',
      );
      _addPayloadParseLog(
        source: 'a7Decrypt:characteristicEvents',
        remoteId: event.remoteId,
        payload: decrypted,
      );
    } catch (error) {
      _addDeviceLog(event.remoteId, '[a7Decrypt] ${event.remoteId}: $error');
    }
  }

  /// 获取 A7 解密需要的 little-endian MAC，优先使用扫描广播数据。
  List<int>? _a7DecryptMac(String remoteId) {
    for (final result in _scanResults) {
      if (result.device.remoteId != remoteId) {
        continue;
      }
      final bleData = result.advertisementData.identity;
      if (!bleData.isEmpty && bleData.mac.any((byte) => byte != 0)) {
        return bleData.mac;
      }
    }
    return _littleEndianMacFromRemoteId(remoteId);
  }

  /// 将 Android 常见 MAC remoteId 转为 SDK 解密所需的 little-endian byte 顺序。
  List<int>? _littleEndianMacFromRemoteId(String remoteId) {
    final hex = remoteId.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
    if (hex.length != 12) {
      return null;
    }
    final bytes = <int>[];
    for (var index = 0; index < hex.length; index += 2) {
      final byte = int.tryParse(hex.substring(index, index + 2), radix: 16);
      if (byte == null) {
        return null;
      }
      bytes.add(byte);
    }
    return bytes.reversed.toList(growable: false);
  }

  void _addProtocolPacketParseLogs(ElinkProtocolDataPacket packet) {
    switch (packet.protocol) {
      case ElinkProtocolDataType.a6:
        final frame = ElinkDataProcessor.parseA6Frame(
          ElinkDataProcessor.wrapA6Frame(packet.data),
        );
        _addFrameParseLog(
          source: 'protocolDataPackets',
          remoteId: packet.remoteId,
          frame: frame,
        );
        _addPayloadParseLog(
          source: 'protocolDataPackets',
          remoteId: packet.remoteId,
          payload: frame.payload,
        );
        break;
      case ElinkProtocolDataType.a7:
        final cid = packet.deviceType;
        if (cid == null) {
          _addPayloadParseLog(
            source: 'protocolDataPackets',
            remoteId: packet.remoteId,
            payload: packet.data,
            prefix: 'A7 cid is missing, ',
          );
          return;
        }
        final frame = ElinkDataProcessor.parseA7Frame(
          ElinkDataProcessor.wrapA7Frame(cid: cid, payload: packet.data),
        );
        _addFrameParseLog(
          source: 'protocolDataPackets',
          remoteId: packet.remoteId,
          frame: frame,
        );
        _addPayloadParseLog(
          source: 'protocolDataPackets',
          remoteId: packet.remoteId,
          payload: frame.payload,
        );
        break;
    }
  }

  void _addRawFrameParseLogs({
    required String source,
    required String remoteId,
    required Iterable<int> data,
  }) {
    final frame = ElinkDataProcessor.tryParseProtocolFrame(data.toList());
    if (frame == null) {
      return;
    }
    _addFrameParseLog(source: source, remoteId: remoteId, frame: frame);
    _addPayloadParseLog(
      source: source,
      remoteId: remoteId,
      payload: frame.payload,
    );
  }

  void _addFrameParseLog({
    required String source,
    required String remoteId,
    required ElinkProtocolFrame frame,
  }) {
    final cidText = frame.cid == null
        ? '-'
        : '0x${frame.cid!.toRadixString(16).padLeft(4, '0').toUpperCase()}';
    _addDeviceLog(
      remoteId,
      '[parse][$source] $remoteId: '
      'protocol=${frame.protocol.name.toUpperCase()} '
      'cid=$cidText len=${frame.payloadLength} '
      'checksum=0x${frame.checksum.toRadixString(16).padLeft(2, '0').toUpperCase()} '
      'payload=${ElinkDataProcessor.formatHex(frame.payload)}',
    );
  }

  void _addPayloadParseLog({
    required String source,
    required String remoteId,
    required Iterable<int> payload,
    String prefix = '',
  }) {
    final payloads = ElinkDataProcessor.tryParsePayload(
      payload.toList(growable: false),
      parseTlv: _enableTlvParse,
    );
    _addDeviceLog(
      remoteId,
      '[parse][$source] $remoteId: '
      '$prefix${_enableTlvParse ? 'tlv=' : 'payload='}'
      '${_formatPayloads(payloads, parseTlv: _enableTlvParse)}',
    );
  }

  String _formatPayloads(
    List<ElinkPayload>? payloads, {
    required bool parseTlv,
  }) {
    if (payloads == null) {
      return 'invalid';
    }
    if (payloads.isEmpty) {
      return 'empty';
    }
    return payloads
        .map((payload) => _formatPayload(payload, parseTlv))
        .join(' | ');
  }

  String _formatPayload(ElinkPayload payload, bool parseTlv) {
    final data = payload.data.isEmpty
        ? 'empty'
        : ElinkDataProcessor.formatHex(payload.data);
    final length = parseTlv ? ', length: ${payload.length}' : '';
    return '{type: 0x${payload.type.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '$length, data: $data}';
  }

  /// 记录指定设备 tab 的日志，并限制单设备日志数量。
  void _addDeviceLog(String remoteId, String message) {
    if (!mounted) return;
    if (remoteId.isEmpty) return;
    final timestamp = ExampleTimeUtils.formatTimestamp(DateTime.now());
    setState(() {
      final logs = _deviceLogs.putIfAbsent(remoteId, () => <String>[]);
      logs.add('[$timestamp] $message');
      if (logs.length > _maxLogCount) {
        logs.removeRange(0, logs.length - _maxLogCount);
      }
    });
  }

  /// 从错误 details 中提取 remoteId，用于把错误日志归属到对应设备 tab。
  String? _remoteIdFromError(ElinkBleException error) {
    final details = error.details;
    if (details is ElinkDeviceEvent) {
      return details.remoteId;
    }
    if (details is ElinkServiceDiscoveredEvent) {
      return details.remoteId;
    }
    if (details is ElinkProtocolDataPacket) {
      return details.remoteId;
    }
    if (details is ElinkPassthroughDataPacket) {
      return details.remoteId;
    }
    if (details is ElinkCharacteristicEvent) {
      return details.remoteId;
    }
    if (details is ElinkRssiEvent) {
      return details.remoteId;
    }
    if (details is ElinkMtuEvent) {
      return details.remoteId;
    }
    if (details is ElinkHandshakeEvent) {
      return details.remoteId;
    }
    if (details is ElinkBmVersionEvent) {
      return details.remoteId;
    }
    if (details is Map) {
      final remoteId = details['remoteId']?.toString();
      if (remoteId != null && remoteId.isNotEmpty) {
        return remoteId;
      }
    }
    return null;
  }
}
