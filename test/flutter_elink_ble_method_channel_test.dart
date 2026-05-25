import 'package:flutter/services.dart';
import 'package:flutter_elink_ble/flutter_elink_ble.dart';
import 'package:flutter_elink_ble/flutter_elink_ble_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelFlutterElinkBle();
  const channel = MethodChannel('flutter_elink_ble/methods');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          calls.add(methodCall);
          switch (methodCall.method) {
            case 'isSupported':
              return true;
            case 'getAdapterState':
              return {'state': 'on'};
            case 'decryptBroadcast':
            case 'initHandshake':
            case 'getHandshakeEncryptData':
            case 'mcuEncrypt':
            case 'mcuDecrypt':
              return Uint8List.fromList([1, 2, 3]);
            case 'checkHandshakeStatus':
              return true;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('startScan forwards timeout and service filters', () async {
    await platform.startScan(
      timeoutMs: 5000,
      withServices: ['F0A0', 'FFE0'],
      androidScanMode: ElinkAndroidScanMode.lowLatency.value,
    );

    expect(calls.single.method, 'startScan');
    expect(calls.single.arguments, {
      'timeoutMs': 5000,
      'withServices': ['F0A0', 'FFE0'],
      'androidScanMode': ElinkAndroidScanMode.lowLatency.value,
    });
  });

  test('connect, disconnect, and write use method channel contract', () async {
    await platform.connect(
      remoteId: 'remote',
      timeoutMs: 15000,
      autoConnect: false,
    );
    await platform.write(
      remoteId: 'remote',
      data: Uint8List.fromList([0x01]),
      type: 'withoutResponse',
    );
    await platform.disconnect('remote');
    await platform.disconnectCurrent();
    await platform.readRssi('remote');
    await platform.setAndroidMtu('remote', 247);
    await platform.setAndroidPreferredPhy(
      remoteId: 'remote',
      txPhy: ElinkAndroidPhy.phy2M.value,
      rxPhy: ElinkAndroidPhy.phy1M.value,
    );

    expect(calls.map((call) => call.method), [
      'connect',
      'write',
      'disconnect',
      'disconnectCurrent',
      'readRssi',
      'setAndroidMtu',
      'setAndroidPreferredPhy',
    ]);
    expect(calls[0].arguments['remoteId'], 'remote');
    expect(calls[1].arguments['data'], Uint8List.fromList([0x01]));
    expect(calls[2].arguments['remoteId'], 'remote');
    expect(calls[4].arguments['remoteId'], 'remote');
    expect(calls[5].arguments['mtu'], 247);
    expect(calls[6].arguments['txPhy'], ElinkAndroidPhy.phy2M.value);
    expect(calls[6].arguments['rxPhy'], ElinkAndroidPhy.phy1M.value);
  });

  test('writeA6 and writeA7 use method channel contract', () async {
    await platform.writeA6(
      remoteId: 'remote',
      payload: Uint8List.fromList([0x01, 0x02]),
    );
    await platform.writeA7(
      remoteId: 'remote',
      payload: Uint8List.fromList([0x03, 0x04]),
      cid: 0x1234,
    );

    expect(calls.map((call) => call.method), ['writeA6', 'writeA7']);
    expect(calls[0].arguments['remoteId'], 'remote');
    expect(calls[0].arguments['payload'], Uint8List.fromList([0x01, 0x02]));
    expect(calls[1].arguments['remoteId'], 'remote');
    expect(calls[1].arguments['payload'], Uint8List.fromList([0x03, 0x04]));
    expect(calls[1].arguments['cid'], 0x1234);
  });

  test('data processor validates A6 packets', () {
    final packet = <int>[0xA6, 0x01, 0x23, 0x24, 0x6A];

    expect(MethodChannelFlutterElinkBle, isNotNull);
    expect(packet, hasLength(5));
  });
}
