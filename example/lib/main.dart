import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_elink_ble/flutter_elink_ble.dart';

import 'bluetooth_connection_page.dart';
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
  final List<String> _logs = <String>[];
  final Set<String> _handshakeStartedRemoteIds = <String>{};
  final Set<String> _handshakeReadyRemoteIds = <String>{};
  final Map<String, ElinkServiceDiscoveredEvent> _handshakeServiceEvents =
      <String, ElinkServiceDiscoveredEvent>{};
  List<ElinkScanResult> _scanResults = const <ElinkScanResult>[];
  ElinkAdapterState _adapterState = ElinkBle.adapterStateNow;
  bool _isScanning = false;
  bool _enableTlvParse = false;
  String? _connectedRemoteId;
  String? _connectedMacAddress;
  String? _bmVersion;

  @override
  void initState() {
    super.initState();
    _subscriptions
      ..add(
        ElinkBle.adapterState.listen((state) {
          setState(() => _adapterState = state);
          _addLog('[adapterState] ${state.name}');
        }),
      )
      ..add(
        ElinkBle.isScanning.listen((isScanning) {
          if (_isScanning == isScanning) {
            return;
          }
          setState(() => _isScanning = isScanning);
          _addLog('[isScanning] $isScanning');
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
            if (event.connectionState.isConnected) {
              _connectedRemoteId = event.remoteId;
              _connectedMacAddress = _scanResults
                  .where((result) => result.device.remoteId == event.remoteId)
                  .map((result) => result.device.macAddress)
                  .firstWhere(
                    (macAddress) => macAddress.isNotEmpty,
                    orElse: () => '',
                  );
            } else {
              _connectedRemoteId = null;
              _connectedMacAddress = null;
              _handshakeStartedRemoteIds.remove(event.remoteId);
              _handshakeReadyRemoteIds.remove(event.remoteId);
              _handshakeServiceEvents.remove(event.remoteId);
              _bmVersion = null;
            }
          });
          _addLog(
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
          _addLog(
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
          _addLog(
            '[protocolDataPackets] ${packet.remoteId}: '
            '${packet.protocol.name.toUpperCase()} '
            'payload=${ElinkDataProcessor.formatHex(packet.data)}',
          );
          _addProtocolPacketParseLogs(packet);
        }),
      )
      ..add(
        ElinkBle.passthroughDataPackets.listen((packet) {
          _addLog(
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
          _addLog(
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
          _addLog('[rssiEvents] ${event.remoteId}: ${event.rssi}');
        }),
      )
      ..add(
        ElinkBle.mtuEvents.listen((event) {
          _addLog(
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
          _addLog('[handshakeEvents] ${event.remoteId}: ${event.success}');
        }),
      )
      ..add(
        ElinkBle.bmVersionEvents.listen((event) {
          if (event.remoteId == _connectedRemoteId) {
            setState(() => _bmVersion = event.version);
          }
          _addLog('[bmVersionEvents] ${event.remoteId}: ${event.version}');
        }),
      )
      ..add(
        ElinkBle.errors.listen((error) {
          _addLog('[errors] $error');
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

  /// Build the current example page from BLE connection state (根据 BLE 连接状态构建当前示例页面).
  Widget _buildCurrentPage() {
    if (_connectedRemoteId == null) {
      return ScanPage(
        adapterState: _adapterState,
        isScanning: _isScanning,
        scanResults: _scanResults,
        onOpenBluetooth: () => unawaited(_openBluetooth()),
        onStartScan: () => unawaited(_startScan()),
        onStopScan: () => unawaited(_stopScan()),
        onConnect: (device) => unawaited(_connect(device)),
      );
    }
    return BluetoothConnectionPage(
      connectedRemoteId: _connectedRemoteId,
      connectedMacAddress: _connectedMacAddress,
      bmVersion: _bmVersion,
      enableTlvParse: _enableTlvParse,
      logs: _logs,
      onDisconnect: () => unawaited(_disconnectCurrent()),
      onGetBmVersion: () => unawaited(_getBmVersion()),
      mtuActionLabel: Platform.isIOS
          ? 'Get iOS MTU'
          : Platform.isAndroid
          ? 'Set MTU 517'
          : 'MTU',
      onMtuAction: () => unawaited(_handleMtu()),
      onOpenWifiProvisioning: _openWifiProvisioning,
      onEnableTlvParseChanged: (value) {
        setState(() => _enableTlvParse = value);
        _addLog('[parseConfig] tlv=$value');
      },
    );
  }

  /// Connect one scanned BLE device and log failures (连接单个已扫描 BLE 设备并记录失败).
  Future<void> _connect(ElinkDevice device) async {
    try {
      _connectedMacAddress = device.macAddress.isEmpty
          ? null
          : device.macAddress;
      await ElinkBle.connect(device);
    } catch (error) {
      _addLog('[connect] ${device.remoteId}: $error');
    }
  }

  /// 根据当前平台处理 MTU：Android 请求 517，iOS 查询最大写入长度。
  Future<void> _handleMtu({int androidMtu = _defaultAndroidMtu}) async {
    final remoteId = _connectedRemoteId;
    if (remoteId == null) {
      return;
    }
    try {
      if (Platform.isIOS) {
        final mtu = await ElinkBle.getIosMtu(remoteId);
        _addLog(
          '[getIosMtu] $remoteId: '
          'withoutResponse=${mtu.maxWriteWithoutResponse} '
          'withResponse=${mtu.maxWriteWithResponse}',
        );
        return;
      }
      if (!Platform.isAndroid) {
        _addLog('[mtu] $remoteId: unsupported platform');
        return;
      }
      final requested = await ElinkBle.setAndroidMtu(remoteId, androidMtu);
      _addLog(
        '[setAndroidMtu] $remoteId: '
        'mtu=$androidMtu requested=$requested',
      );
    } catch (error) {
      _addLog('[mtu] $remoteId: $error');
    }
  }

  /// Disconnect the current BLE device and log failures (断开当前 BLE 设备并记录失败).
  Future<void> _disconnectCurrent() async {
    try {
      await ElinkBle.disconnectCurrent();
    } catch (error) {
      _addLog('[disconnectCurrent] $error');
    }
  }

  Future<void> _startScan() async {
    try {
      await ElinkBle.startScan(timeout: const Duration(seconds: 10));
    } catch (error) {
      _addLog(error.toString());
    }
  }

  Future<void> _stopScan() async {
    try {
      await ElinkBle.stopScan();
    } catch (error) {
      _addLog(error.toString());
    }
  }

  /// 请求系统打开蓝牙，并立即刷新一次缓存状态。
  Future<void> _openBluetooth() async {
    try {
      await ElinkBle.openBluetooth();
      await ElinkBle.refreshAdapterState();
    } catch (error) {
      _addLog(error.toString());
    }
  }

  Future<void> _getBmVersion() async {
    final remoteId = _connectedRemoteId;
    if (remoteId == null) {
      return;
    }
    try {
      await ElinkBle.getBmVersion(remoteId);
      _addLog(
        '[tx][getBmVersion] $remoteId: '
        '${ElinkDataProcessor.formatHex(ElinkDataProcessor.getBmVersionPacket())}',
      );
    } catch (error) {
      _addLog('[getBmVersion] $remoteId: $error');
    }
  }

  /// Open the WiFi provisioning page with the connected BLE remoteId (使用当前已连接 BLE remoteId 打开 WiFi 配网页面).
  void _openWifiProvisioning() {
    final remoteId = _connectedRemoteId;
    if (remoteId == null) {
      return;
    }
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
        _connectedRemoteId != remoteId ||
        !_handshakeStartedRemoteIds.add(remoteId)) {
      return;
    }
    try {
      final packet = await ElinkDataProcessor.initHandshake();
      if (packet == null || packet.isEmpty) {
        _addLog('[handshake] $remoteId: init packet is empty');
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
      _addLog('[handshake] $remoteId: $error');
    }
  }

  Future<void> _writeData(
    String remoteId,
    Iterable<int> data, {
    required String source,
  }) async {
    final bytes = List<int>.unmodifiable(data);
    await ElinkBle.write(remoteId, bytes);
    _addLog('[tx][$source] $remoteId: ${ElinkDataProcessor.formatHex(bytes)}');
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
      _addLog('[a7Decrypt] ${event.remoteId}: missing MAC');
      return;
    }
    try {
      final decrypted = await ElinkDataProcessor.decryptA7Packet(
        mac: mac,
        packet: frame.rawData,
      );
      if (decrypted == null) {
        _addLog('[a7Decrypt] ${event.remoteId}: decrypt result is null');
        return;
      }
      final cidText = frame.cid == null
          ? '-'
          : '0x${frame.cid!.toRadixString(16).padLeft(4, '0').toUpperCase()}';
      _addLog(
        '[a7Decrypt][characteristicEvents] ${event.remoteId}: '
        'cid=$cidText payload=${ElinkDataProcessor.formatHex(decrypted)}',
      );
      _addPayloadParseLog(
        source: 'a7Decrypt:characteristicEvents',
        remoteId: event.remoteId,
        payload: decrypted,
      );
    } catch (error) {
      _addLog('[a7Decrypt] ${event.remoteId}: $error');
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
    _addLog(
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
    _addLog(
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

  void _addLog(String message) {
    if (!mounted) return;
    final timestamp = ExampleTimeUtils.formatTimestamp(DateTime.now());
    setState(() {
      _logs.add('[$timestamp] $message');
      if (_logs.length > _maxLogCount) {
        _logs.removeAt(0);
      }
    });
  }
}
