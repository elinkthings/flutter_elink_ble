import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_elink_ble/flutter_elink_ble.dart';

void main() {
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
  final List<StreamSubscription<Object?>> _subscriptions = [];
  final List<String> _logs = <String>[];
  final Set<String> _handshakeStartedRemoteIds = <String>{};
  final Set<String> _handshakeReadyRemoteIds = <String>{};
  final Map<String, ElinkServiceDiscoveredEvent> _handshakeServiceEvents =
      <String, ElinkServiceDiscoveredEvent>{};
  List<ElinkScanResult> _scanResults = const <ElinkScanResult>[];
  ElinkAdapterState _adapterState = ElinkBle.adapterStateNow;
  bool _isScanning = false;
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
            '${packet.protocol.name.toUpperCase()} '
            '${_hex(packet.data)}',
          );
        }),
      )
      ..add(
        ElinkBle.passthroughDataPackets.listen((packet) {
          _addLog(
            '[passthroughDataPackets] ${packet.remoteId}: '
            '${_hex(packet.data)}',
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

  void _addLog(String message) {
    if (!mounted) return;
    final timestamp = _formatTimestamp(DateTime.now());
    setState(() {
      _logs.add('[$timestamp] $message');
      if (_logs.length > 80) {
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
        .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }
}
