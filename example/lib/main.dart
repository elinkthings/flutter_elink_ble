import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_elink_ble/flutter_elink_ble.dart';

void main() {
  print("Flutter main started");
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
            _connectedRemoteId = event.connectionState.isConnected
                ? event.remoteId
                : null;
            if (!event.connectionState.isConnected) {
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
            '${packet.protocol.name.toUpperCase()} payload=${_hex(packet.data)}',
          );
          _addProtocolPacketParseLogs(packet);
        }),
      )
      ..add(
        ElinkBle.passthroughDataPackets.listen((packet) {
          _addLog(
            '[passthroughDataPackets] ${packet.remoteId}: '
            '${_hex(packet.data)}',
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
            '${_hex(event.data)}',
          );
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Open Bluetooth',
                      onPressed: _adapterState == ElinkAdapterState.on
                          ? null
                          : _openBluetooth,
                      icon: const Icon(Icons.bluetooth),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _isScanning ? null : _startScan,
                      icon: const Icon(Icons.bluetooth_searching),
                      label: const Text('Scan'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _isScanning ? _stopScan : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                    ),
                    const Spacer(),
                    if (_connectedRemoteId != null)
                      IconButton(
                        tooltip: 'Disconnect',
                        onPressed: ElinkBle.disconnectCurrent,
                        icon: const Icon(Icons.bluetooth_disabled),
                      ),
                  ],
                ),
                if (_connectedRemoteId != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'BM Version: ${_bmVersion ?? "--"}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _getBmVersion,
                        icon: const Icon(Icons.info_outline),
                        label: const Text('GetBmVersion'),
                      ),
                    ],
                  ),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Parse payload as TLV'),
                  subtitle: const Text('Off: type + data, On: TLV entries'),
                  value: _enableTlvParse,
                  onChanged: (value) {
                    setState(() => _enableTlvParse = value);
                    _addLog('[parseConfig] tlv=$value');
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _scanResults.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final result = _scanResults[index];
                final data = ElinkDataProcessor.parseAdvertisement(
                  result.advertisementData.manufacturerData,
                  isBroadcastDevice: result.advertisementData.isBroadcastDevice,
                );
                return ListTile(
                  title: Text(
                    result.device.platformName.isEmpty
                        ? 'Unknown'
                        : result.device.platformName,
                  ),
                  subtitle: Text(
                    [
                      result.device.remoteId,
                      'RSSI ${result.rssi}',
                      'CID ${data.cidValue}',
                      'VID ${data.vidValue}',
                      'PID ${data.pidValue}',
                      data.macAddress,
                    ].join('  '),
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: () => ElinkBle.connect(result.device),
                    child: const Text('Connect'),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 180,
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
        ],
      ),
    );
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
        '${_hex(ElinkDataProcessor.getBmVersionPacket())}',
      );
    } catch (error) {
      _addLog('[getBmVersion] $remoteId: $error');
    }
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
    _addLog('[tx][$source] $remoteId: ${_hex(bytes)}');
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
      'payload=${_hex(frame.payload)}',
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
    final data = payload.data.isEmpty ? 'empty' : _hex(payload.data);
    final length = parseTlv ? ', length: ${payload.length}' : '';
    return '{type: 0x${payload.type.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '$length, data: $data}';
  }

  void _addLog(String message) {
    if (!mounted) return;
    final timestamp = _formatTimestamp(DateTime.now());
    setState(() {
      _logs.add('[$timestamp] $message');
      if (_logs.length > _maxLogCount) {
        _logs.removeAt(0);
      }
    });
  }

  String _formatTimestamp(DateTime time) {
    return '${_twoDigits(time.hour)}:'
        '${_twoDigits(time.minute)}:'
        '${_twoDigits(time.second)}';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _hex(Iterable<int> data) {
    return data
        .map(
          (byte) =>
              (byte & 0xff).toRadixString(16).padLeft(2, '0').toUpperCase(),
        )
        .join(' ');
  }
}
