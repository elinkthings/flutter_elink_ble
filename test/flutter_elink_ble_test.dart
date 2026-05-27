import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_elink_ble/flutter_elink_ble.dart';
import 'package:flutter_elink_ble/flutter_elink_ble_method_channel.dart';
import 'package:flutter_elink_ble/flutter_elink_ble_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockElinkBlePlatform
    with MockPlatformInterfaceMixin
    implements FlutterElinkBlePlatform {
  final StreamController<Map<dynamic, dynamic>> eventController =
      StreamController<Map<dynamic, dynamic>>.broadcast();

  List<String> lastScanServices = const <String>[];
  int lastScanTimeoutMs = 0;
  int? lastAndroidScanMode;
  int startScanCallCount = 0;
  bool openedBluetooth = false;
  String? lastConnectedRemoteId;
  bool disconnectedCurrent = false;
  String? lastReadRssiRemoteId;
  String? lastSetMtuRemoteId;
  int? lastSetMtu;
  String? lastSetPhyRemoteId;
  int? lastSetTxPhy;
  int? lastSetRxPhy;
  String? lastWriteRemoteId;
  Uint8List lastWriteData = Uint8List(0);
  String? lastWriteType;
  String? lastWriteA6RemoteId;
  Uint8List lastWriteA6Payload = Uint8List(0);
  String? lastWriteA7RemoteId;
  Uint8List lastWriteA7Payload = Uint8List(0);
  int? lastWriteA7Cid;

  @override
  Stream<Map<dynamic, dynamic>> get events => eventController.stream;

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<Map<dynamic, dynamic>> getAdapterState() async => {'state': 'on'};

  @override
  Future<void> openBluetooth() async {
    openedBluetooth = true;
  }

  @override
  Future<void> startScan({
    required int timeoutMs,
    required List<String> withServices,
    int? androidScanMode,
  }) async {
    startScanCallCount += 1;
    lastScanTimeoutMs = timeoutMs;
    lastScanServices = withServices;
    lastAndroidScanMode = androidScanMode;
  }

  @override
  Future<void> stopScan() async {}

  @override
  Future<void> connect({
    required String remoteId,
    required int timeoutMs,
    required bool autoConnect,
  }) async {
    lastConnectedRemoteId = remoteId;
  }

  @override
  Future<void> disconnect(String remoteId) async {}

  @override
  Future<void> disconnectCurrent() async {
    disconnectedCurrent = true;
  }

  @override
  Future<void> readRssi(String remoteId) async {
    lastReadRssiRemoteId = remoteId;
  }

  @override
  Future<bool> setAndroidMtu(String remoteId, int mtu) async {
    lastSetMtuRemoteId = remoteId;
    lastSetMtu = mtu;
    return true;
  }

  @override
  Future<bool> setAndroidPreferredPhy({
    required String remoteId,
    required int txPhy,
    required int rxPhy,
  }) async {
    lastSetPhyRemoteId = remoteId;
    lastSetTxPhy = txPhy;
    lastSetRxPhy = rxPhy;
    return true;
  }

  @override
  Future<void> write({
    required String remoteId,
    required Uint8List data,
    required String type,
  }) async {
    lastWriteRemoteId = remoteId;
    lastWriteData = data;
    lastWriteType = type;
  }

  @override
  Future<void> writeA6({
    required String remoteId,
    required Uint8List payload,
  }) async {
    lastWriteA6RemoteId = remoteId;
    lastWriteA6Payload = payload;
  }

  @override
  Future<void> writeA7({
    required String remoteId,
    required Uint8List payload,
    int? cid,
  }) async {
    lastWriteA7RemoteId = remoteId;
    lastWriteA7Payload = payload;
    lastWriteA7Cid = cid;
  }

  @override
  Future<Uint8List?> decryptBroadcast(Uint8List payload) async => payload;

  @override
  Future<Uint8List?> initHandshake() async => Uint8List.fromList([1, 2]);

  @override
  Future<Uint8List?> getHandshakeEncryptData(Uint8List payload) async =>
      payload;

  @override
  Future<bool> checkHandshakeStatus(Uint8List payload) async => true;

  @override
  Future<Uint8List?> mcuEncrypt({
    required Uint8List cid,
    required Uint8List mac,
    required Uint8List payload,
  }) async {
    return payload;
  }

  @override
  Future<Uint8List?> mcuDecrypt({
    required Uint8List mac,
    required Uint8List payload,
  }) async {
    return payload;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final initialPlatform = FlutterElinkBlePlatform.instance;

  tearDown(() async {
    if (!identical(FlutterElinkBlePlatform.instance, initialPlatform)) {
      await ElinkBle.dispose();
    }
    FlutterElinkBlePlatform.instance = initialPlatform;
  });

  test('$MethodChannelFlutterElinkBle is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterElinkBle>());
  });

  test('openBluetooth forwards to platform', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;

    await ElinkBle.openBluetooth();

    expect(fakePlatform.openedBluetooth, isTrue);
  });

  test('startScan uses default Elink service UUIDs', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;

    await ElinkBle.startScan(timeout: const Duration(seconds: 3));

    expect(fakePlatform.lastScanTimeoutMs, 3000);
    expect(fakePlatform.lastScanServices, ['F0A0', 'FFE0']);
  });

  test('startScan forwards Android scan mode', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;

    await ElinkBle.startScan(
      timeout: const Duration(seconds: 3),
      androidScanMode: ElinkAndroidScanMode.lowPower,
    );

    expect(
      fakePlatform.lastAndroidScanMode,
      ElinkAndroidScanMode.lowPower.value,
    );
  });

  test('startScan reuses active scan with the same configuration', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;

    await ElinkBle.startScan(
      timeout: const Duration(seconds: 3),
      androidScanMode: ElinkAndroidScanMode.lowPower,
    );
    await ElinkBle.startScan(
      timeout: const Duration(seconds: 3),
      androidScanMode: ElinkAndroidScanMode.lowPower,
    );

    expect(fakePlatform.startScanCallCount, 1);
  });

  test('isScanning stream ignores duplicate states', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;
    final states = <bool>[];
    final subscription = ElinkBle.isScanning.listen(states.add);

    await ElinkBle.startScan(timeout: const Duration(seconds: 3));
    fakePlatform.eventController
      ..add({'type': 'scanStopped'})
      ..add({'type': 'scanStopped'});
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(states, [true, false]);
  });

  test('connect and write forward device arguments', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;
    const device = ElinkDevice(remoteId: 'AA:BB:CC:DD:EE:FF');

    await ElinkBle.connect(device);
    await ElinkBle.write(device.remoteId, [0xA6, 0x00, 0x00, 0x6A]);

    expect(fakePlatform.lastConnectedRemoteId, device.remoteId);
    expect(fakePlatform.lastWriteRemoteId, device.remoteId);
    expect(fakePlatform.lastWriteData, [0xA6, 0x00, 0x00, 0x6A]);
    expect(fakePlatform.lastWriteType, 'withoutResponse');
  });

  test('disconnectCurrent forwards to platform', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;

    await ElinkBle.disconnectCurrent();

    expect(fakePlatform.disconnectedCurrent, isTrue);
  });

  test('readRssi forwards to platform', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;

    await ElinkBle.readRssi('remote-1');

    expect(fakePlatform.lastReadRssiRemoteId, 'remote-1');
  });

  test('Android MTU and PHY APIs forward to platform', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;

    final mtuResult = await ElinkBle.setAndroidMtu('remote-1', 247);
    final phyResult = await ElinkBle.setAndroidPreferredPhy(
      'remote-1',
      txPhy: ElinkAndroidPhy.phy2M,
      rxPhy: ElinkAndroidPhy.phy1M,
    );

    expect(mtuResult, isTrue);
    expect(fakePlatform.lastSetMtuRemoteId, 'remote-1');
    expect(fakePlatform.lastSetMtu, 247);
    expect(phyResult, isTrue);
    expect(fakePlatform.lastSetPhyRemoteId, 'remote-1');
    expect(fakePlatform.lastSetTxPhy, ElinkAndroidPhy.phy2M.value);
    expect(fakePlatform.lastSetRxPhy, ElinkAndroidPhy.phy1M.value);
  });

  test('writeA6 and writeA7 forward SDK payload arguments', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;

    await ElinkBle.writeA6('remote-1', [0x01, 0x02]);
    await ElinkBle.writeA7('remote-1', [0x03, 0x04], cid: 0x1234);

    expect(fakePlatform.lastWriteA6RemoteId, 'remote-1');
    expect(fakePlatform.lastWriteA6Payload, [0x01, 0x02]);
    expect(fakePlatform.lastWriteA7RemoteId, 'remote-1');
    expect(fakePlatform.lastWriteA7Payload, [0x03, 0x04]);
    expect(fakePlatform.lastWriteA7Cid, 0x1234);
  });

  test('data processor parses A6 and A7 protocol frames', () {
    final a6Frame = ElinkDataProcessor.wrapA6Frame([0x0E]);
    final parsedA6 = ElinkDataProcessor.parseProtocolFrame(a6Frame);

    expect(a6Frame, [0xA6, 0x01, 0x0E, 0x0F, 0x6A]);
    expect(parsedA6.protocol, ElinkProtocolDataType.a6);
    expect(parsedA6.cid, isNull);
    expect(parsedA6.cidBytes, isEmpty);
    expect(parsedA6.payload, [0x0E]);
    expect(parsedA6.checksum, 0x0F);
    expect(ElinkDataProcessor.parseA6Frame(a6Frame).payload, [0x0E]);
    expect(ElinkDataProcessor.unwrapA6Frame(a6Frame), [0x0E]);

    final a7Frame = <int>[
      0xA7,
      0x00,
      0x8F,
      0x08,
      0x01,
      0x06,
      0x67,
      0xA7,
      0x1F,
      0x0E,
      0x01,
      0x08,
      0xE2,
      0x7A,
    ];

    final parsedA7 = ElinkDataProcessor.parseProtocolFrame(a7Frame);
    final tlvs = ElinkDataProcessor.parseTlvPayload(parsedA7.payload);

    expect(parsedA7.protocol, ElinkProtocolDataType.a7);
    expect(parsedA7.cid, 0x008F);
    expect(parsedA7.cidBytes, [0x00, 0x8F]);
    expect(parsedA7.payload, [0x01, 0x06, 0x67, 0xA7, 0x1F, 0x0E, 0x01, 0x08]);
    expect(parsedA7.checksum, 0xE2);
    expect(ElinkDataProcessor.parseA7Frame(a7Frame).payload, parsedA7.payload);
    expect(tlvs, hasLength(1));
    expect(tlvs.single.type, 0x01);
    expect(tlvs.single.length, 6);
    expect(tlvs.single.data, [0x67, 0xA7, 0x1F, 0x0E, 0x01, 0x08]);
    expect(tlvs.single.readInt(length: 4), 0x67A71F0E);
    expect(tlvs.single.readInt(offset: 4), 0x01);
    expect(tlvs.single.readInt(offset: 5), 0x08);
  });

  test('data processor builds A7 frames from multiple TLVs', () {
    final frame = ElinkDataProcessor.wrapA7TlvFrame(
      cid: 0x008F,
      tlvs: <ElinkPayload>[
        ElinkPayload(type: 0x02),
        ElinkPayload(type: 0x03, data: <int>[0x01, 0x01]),
      ],
    );

    expect(frame, [
      0xA7,
      0x00,
      0x8F,
      0x06,
      0x02,
      0x00,
      0x03,
      0x02,
      0x01,
      0x01,
      0x9E,
      0x7A,
    ]);

    final parsed = ElinkDataProcessor.parseA7Frame(frame);
    final tlvs = ElinkDataProcessor.parseTlvPayload(parsed.payload);
    expect(tlvs.map((tlv) => tlv.type), [0x02, 0x03]);
    expect(tlvs[0].data, isEmpty);
    expect(tlvs[1].data, [0x01, 0x01]);
  });

  test('data processor rejects malformed A6, A7, and TLV data', () {
    expect(
      ElinkDataProcessor.tryParseA6Frame([0xA6, 0x01, 0x0E, 0x00, 0x6A]),
      isNull,
    );
    expect(
      ElinkDataProcessor.tryParseA7Frame([
        0xA7,
        0x00,
        0x8F,
        0x01,
        0x01,
        0x00,
        0x7A,
      ]),
      isNull,
    );
    expect(ElinkDataProcessor.tryParseProtocolFrame([0x00]), isNull);
    expect(
      () => ElinkDataProcessor.parseTlvPayload([0x03, 0x02, 0x01]),
      throwsA(isA<FormatException>()),
    );
    expect(ElinkDataProcessor.tryParseTlvPayload([0x03, 0x02, 0x01]), isNull);
  });

  test('payload integer helpers default to protocol big-endian order', () {
    final tlv = ElinkPayload.fromInt(0x10, 0x1234, length: 2);
    final littleEndianTlv = ElinkPayload.fromInt(
      0x10,
      0x1234,
      length: 2,
      littleEndian: true,
    );

    expect(tlv.bytes, [0x10, 0x12, 0x34]);
    expect(tlv.tlvBytes, [0x10, 0x02, 0x12, 0x34]);
    expect(tlv.readInt(length: 2), 0x1234);
    expect(littleEndianTlv.tlvBytes, [0x10, 0x02, 0x34, 0x12]);
    expect(littleEndianTlv.readInt(length: 2, littleEndian: true), 0x1234);
    expect(ElinkDataProcessor.cidToBytes(0x008F), [0x00, 0x8F]);
    expect(ElinkDataProcessor.cidFromBytes([0x00, 0x8F]), 0x008F);
    expect(ElinkDataProcessor.bytesToInt([0x12, 0x34]), 0x1234);
    expect(
      ElinkDataProcessor.bytesToInt([0x34, 0x12], littleEndian: true),
      0x1234,
    );
  });

  test('data processor parses payload as plain or TLV objects', () {
    final payload = <int>[0x04, 0x01, 0x32];
    final tlvPayload = <int>[0x03, 0x02, 0x01, 0x01];

    final plainPayload = ElinkDataProcessor.parsePlainPayload(payload);
    final parsedPayload = ElinkDataProcessor.parsePayload(payload);
    final parsedTlvs = ElinkDataProcessor.parsePayload(
      tlvPayload,
      parseTlv: true,
    );

    expect(plainPayload.type, 0x04);
    expect(plainPayload.data, [0x01, 0x32]);
    expect(parsedPayload, hasLength(1));
    expect(parsedPayload.single.type, 0x04);
    expect(parsedPayload.single.data, [0x01, 0x32]);
    expect(ElinkDataProcessor.parsePayload(const <int>[]), isEmpty);
    expect(parsedTlvs, hasLength(1));
    expect(parsedTlvs.single.type, 0x03);
    expect(parsedTlvs.single.data, [0x01, 0x01]);
    expect(ElinkDataProcessor.tryParsePlainPayload(const <int>[]), isNull);
    expect(
      ElinkDataProcessor.tryParsePayload([0x03, 0x02, 0x01], parseTlv: true),
      isNull,
    );
  });

  test('getBmVersion sends A6 common command payload', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;

    await ElinkBle.getBmVersion('remote-1');

    expect(fakePlatform.lastWriteA6RemoteId, 'remote-1');
    expect(fakePlatform.lastWriteA6Payload, [0x0E]);
  });

  test('event stream parses scan results', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;
    final nextResult = ElinkBle.scanResults.first;

    fakePlatform.eventController.add({
      'type': 'scanResult',
      'remoteId': 'id-1',
      'platformName': 'Elink',
      'rssi': -45,
      'advertisementData': {
        'advName': 'Elink',
        'serviceUuids': ['F0A0'],
        'manufacturerData': Uint8List.fromList([0x6E, 0x49]),
      },
    });

    final results = await nextResult;
    expect(results.single.device.remoteId, 'id-1');
    expect(results.single.advertisementData.isBroadcastDevice, isTrue);
  });

  test(
    'bluetooth state callback receives immediate and native states',
    () async {
      final fakePlatform = MockElinkBlePlatform();
      FlutterElinkBlePlatform.instance = fakePlatform;
      final states = <ElinkAdapterState>[];

      ElinkBle.setBluetoothStateCallback(states.add);
      fakePlatform.eventController.add({'type': 'adapterState', 'state': 'on'});
      await Future<void>.delayed(Duration.zero);

      expect(states.first, ElinkAdapterState.unknown);
      expect(states.last, ElinkAdapterState.on);

      ElinkBle.setBluetoothStateCallback(null);
      fakePlatform.eventController.add({
        'type': 'adapterState',
        'state': 'off',
      });
      await Future<void>.delayed(Duration.zero);

      expect(states.last, ElinkAdapterState.on);
    },
  );

  test('adapter state stream ignores duplicate states', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;
    final states = <ElinkAdapterState>[];
    final subscription = ElinkBle.adapterState.listen(states.add);

    fakePlatform.eventController
      ..add({'type': 'adapterState', 'state': 'on'})
      ..add({'type': 'adapterState', 'state': 'on'});
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(states, [ElinkAdapterState.on]);
  });

  test('connection stream ignores duplicate consecutive states', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;
    final events = <ElinkDeviceEvent>[];
    final subscription = ElinkBle.connectionEvents.listen(events.add);

    fakePlatform.eventController
      ..add({
        'type': 'connectionState',
        'remoteId': 'remote-1',
        'state': 'connecting',
      })
      ..add({
        'type': 'connectionState',
        'remoteId': 'remote-1',
        'state': 'connecting',
      })
      ..add({
        'type': 'connectionState',
        'remoteId': 'remote-1',
        'state': 'connected',
      });
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(events.map((event) => event.connectionState), [
      ElinkConnectionState.connecting,
      ElinkConnectionState.connected,
    ]);
  });

  test(
    'event stream parses protocol, passthrough, and characteristic events',
    () async {
      final fakePlatform = MockElinkBlePlatform();
      FlutterElinkBlePlatform.instance = fakePlatform;
      final nextProtocol = ElinkBle.protocolDataPackets.first;
      final nextPassthrough = ElinkBle.passthroughDataPackets.first;
      final nextCharacteristic = ElinkBle.characteristicEvents.first;

      fakePlatform.eventController
        ..add({
          'type': 'protocolData',
          'remoteId': 'remote-1',
          'protocol': 'a7',
          'characteristicUuid': 'FFE2',
          'deviceType': 0x1234,
          'data': Uint8List.fromList([0x01]),
        })
        ..add({
          'type': 'passthroughData',
          'remoteId': 'remote-1',
          'characteristicUuid': 'FFE2',
          'data': Uint8List.fromList([0x02]),
        })
        ..add({
          'type': 'characteristicEvent',
          'remoteId': 'remote-1',
          'operation': 'write',
          'serviceUuid': 'FFE0',
          'characteristicUuid': 'FFE1',
          'descriptorUuid': '',
          'data': Uint8List.fromList([0x03]),
        });

      final protocol = await nextProtocol;
      final passthrough = await nextPassthrough;
      final characteristic = await nextCharacteristic;

      expect(protocol.protocol, ElinkProtocolDataType.a7);
      expect(protocol.deviceType, 0x1234);
      expect(protocol.data, [0x01]);
      expect(passthrough.data, [0x02]);
      expect(characteristic.operation, ElinkCharacteristicOperation.write);
      expect(characteristic.characteristicUuid, 'FFE1');
    },
  );

  test('event stream parses service discovery events', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;
    final nextService = ElinkBle.serviceDiscoveryEvents.first;

    fakePlatform.eventController.add({
      'type': 'servicesDiscovered',
      'remoteId': 'remote-1',
      'serviceUuid': 'FFE0',
      'characteristicUuids': ['FFE1', 'FFE2', 'FFE3'],
    });

    final event = await nextService;
    expect(event.remoteId, 'remote-1');
    expect(event.serviceUuid, ElinkGuid.connectDevice);
    expect(event.characteristicUuids, [
      ElinkGuid.write,
      ElinkGuid.notify,
      ElinkGuid.writeAndNotify,
    ]);
  });

  test('event stream parses rssi events', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;
    final nextRssi = ElinkBle.rssiEvents.first;

    fakePlatform.eventController.add({
      'type': 'rssi',
      'remoteId': 'remote-1',
      'rssi': -62,
    });

    final event = await nextRssi;
    expect(event.remoteId, 'remote-1');
    expect(event.rssi, -62);
  });

  test('event stream parses mtu events', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;
    final nextMtu = ElinkBle.mtuEvents.first;

    fakePlatform.eventController.add({
      'type': 'mtu',
      'remoteId': 'remote-1',
      'mtu': 247,
      'availableMtu': 244,
    });

    final event = await nextMtu;
    expect(event.remoteId, 'remote-1');
    expect(event.mtu, 247);
    expect(event.availableMtu, 244);
  });

  test('event stream parses BM version from A6 payload', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;
    final nextBmVersion = ElinkBle.bmVersionEvents.first;

    fakePlatform.eventController.add({
      'type': 'protocolData',
      'remoteId': 'remote-1',
      'protocol': 'a6',
      'data': Uint8List.fromList([
        0x0E,
        0x42,
        0x4D,
        0x03,
        0x04,
        0x15,
        0x06,
        0x18,
        0x05,
        0x17,
      ]),
    });

    final event = await nextBmVersion;
    expect(event.remoteId, 'remote-1');
    expect(event.version, 'BM03H4S2.1.6_20240523');
    expect(event.rawPayload, [
      0x0E,
      0x42,
      0x4D,
      0x03,
      0x04,
      0x15,
      0x06,
      0x18,
      0x05,
      0x17,
    ]);
  });

  test('event stream normalizes double-headed iOS A6 packets', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;
    final nextProtocol = ElinkBle.protocolDataPackets.first;

    fakePlatform.eventController.add({
      'type': 'protocolData',
      'remoteId': 'remote-1',
      'protocol': 'a6',
      'data': Uint8List.fromList([
        0xA6,
        0xA6,
        0x0A,
        0x0E,
        0x42,
        0x58,
        0x02,
        0x01,
        0x0D,
        0x00,
        0x1A,
        0x04,
        0x19,
        0xF9,
        0x6A,
      ]),
    });

    final packet = await nextProtocol;
    expect(packet.data, [
      0x0E,
      0x42,
      0x58,
      0x02,
      0x01,
      0x0D,
      0x00,
      0x1A,
      0x04,
      0x19,
    ]);
  });

  test('A6 handshake fallback replies and emits status', () async {
    final fakePlatform = MockElinkBlePlatform();
    FlutterElinkBlePlatform.instance = fakePlatform;
    final nextHandshake = ElinkBle.handshakeEvents.first;
    final setPacket = ElinkDataProcessor.wrapA6Frame([
      ElinkDataProcessor.setHandshake,
      ...List<int>.filled(16, 0x01),
    ]);
    final getPacket = ElinkDataProcessor.wrapA6Frame([
      ElinkDataProcessor.getHandshake,
      ...List<int>.filled(16, 0x02),
    ]);

    fakePlatform.eventController.add({
      'type': 'protocolData',
      'remoteId': 'remote-1',
      'protocol': 'a6',
      'data': Uint8List.fromList(setPacket),
    });
    await Future<void>.delayed(Duration.zero);

    expect(fakePlatform.lastWriteRemoteId, 'remote-1');
    expect(fakePlatform.lastWriteData, setPacket);
    expect(fakePlatform.lastWriteType, ElinkWriteType.withoutResponse.name);

    fakePlatform.eventController.add({
      'type': 'protocolData',
      'remoteId': 'remote-1',
      'protocol': 'a6',
      'data': Uint8List.fromList(getPacket),
    });

    final event = await nextHandshake;
    expect(event.remoteId, 'remote-1');
    expect(event.success, isTrue);
  });
}
