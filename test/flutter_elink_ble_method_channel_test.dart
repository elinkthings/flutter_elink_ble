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
            case 'openBluetooth':
              return null;
            case 'getIosMtu':
              return {
                'remoteId': methodCall.arguments['remoteId'],
                'maxWriteWithoutResponse': 244,
                'maxWriteWithResponse': 512,
              };
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

  // 验证统一通道传参及 true/false/异常的原样传播，防止把拒绝伪装成成功。
  test('unified methods preserve channel contracts and outcomes', () async {
    var accepted = true;
    PlatformException? failure;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (failure != null) throw failure;
          return call.method == 'setCommandResendCount' ? null : accepted;
        });
    expect(await platform.setMtu('device-a', 247), isTrue);
    expect(
      await platform.setPreferredPhy(remoteId: 'device-a', txPhy: 2, rxPhy: 1),
      isTrue,
    );
    await platform.setCommandResendCount(3);
    expect(await platform.setConnectPriority('device-b', 1), isTrue);
    expect(
      await platform.sendDataNow(
        remoteId: 'device-b',
        data: Uint8List.fromList([0xA6, 0]),
        type: 'withResponse',
      ),
      isTrue,
    );
    expect(calls.map((call) => call.method), [
      'setMtu',
      'setPreferredPhy',
      'setCommandResendCount',
      'setConnectPriority',
      'sendDataNow',
    ]);
    expect(calls[0].arguments, {'remoteId': 'device-a', 'mtu': 247});
    expect(calls[1].arguments, {
      'remoteId': 'device-a',
      'txPhy': 2,
      'rxPhy': 1,
    });
    expect(calls[2].arguments, {'resendCount': 3});
    expect(calls[3].arguments, {'remoteId': 'device-b', 'priority': 1});
    expect(calls[4].arguments, {
      'remoteId': 'device-b',
      'data': Uint8List.fromList([0xA6, 0]),
      'type': 'withResponse',
    });
    accepted = false;
    expect(await platform.setMtu('device-a', 247), isFalse);
    expect(
      await platform.setPreferredPhy(remoteId: 'device-a', txPhy: 2, rxPhy: 1),
      isFalse,
    );
    expect(await platform.setConnectPriority('device-b', 1), isFalse);
    expect(
      await platform.sendDataNow(
        remoteId: 'device-b',
        data: Uint8List.fromList([1]),
        type: 'withoutResponse',
      ),
      isFalse,
    );
    failure = PlatformException(code: 'permission_denied');
    await expectLater(
      platform.sendDataNow(
        remoteId: 'device-b',
        data: Uint8List.fromList([1]),
        type: 'withoutResponse',
      ),
      throwsA(
        isA<PlatformException>().having(
          (error) => error.code,
          'code',
          'permission_denied',
        ),
      ),
    );
    await expectLater(
      platform.setConnectPriority('device-b', 1),
      throwsA(isA<PlatformException>()),
    );
  });

  test('openBluetooth uses method channel contract', () async {
    await platform.openBluetooth();

    expect(calls.single.method, 'openBluetooth');
    expect(calls.single.arguments, isNull);
  });

  test('cached iOS connect includes identity and its original deadline', () async {
    const remoteId = '00000000-0000-4000-8000-000000000012';
    const identity = {
      'cid': 0x002D,
      'vid': 2,
      'pid': 3,
      'macAddress': '02:11:22:33:44:55',
    };
    await platform.connect(
      remoteId: remoteId,
      timeoutMs: 12000,
      autoConnect: false,
      iosReconnectIdentity: identity,
    );

    expect(calls.single.method, 'connect');
    expect(calls.single.arguments, {
      'remoteId': remoteId,
      'timeoutMs': 12000,
      'autoConnect': false,
      'iosReconnectIdentity': identity,
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
    await platform.readRssi('remote');
    await platform.setAndroidMtu('remote', 247);
    final iosMtu = await platform.getIosMtu('remote');
    await platform.setAndroidPreferredPhy(
      remoteId: 'remote',
      txPhy: ElinkAndroidPhy.phy2M.value,
      rxPhy: ElinkAndroidPhy.phy1M.value,
    );
    await platform.setAndroidCommandResendCount(3);

    expect(calls.map((call) => call.method), [
      'connect',
      'write',
      'disconnect',
      'readRssi',
      'setAndroidMtu',
      'getIosMtu',
      'setAndroidPreferredPhy',
      'setAndroidCommandResendCount',
    ]);
    expect(calls[0].arguments['remoteId'], 'remote');
    expect(calls[1].arguments['data'], Uint8List.fromList([0x01]));
    expect(calls[2].arguments['remoteId'], 'remote');
    expect(calls[3].arguments['remoteId'], 'remote');
    expect(calls[4].arguments['mtu'], 247);
    expect(calls[5].arguments['remoteId'], 'remote');
    expect(iosMtu['maxWriteWithoutResponse'], 244);
    expect(iosMtu['maxWriteWithResponse'], 512);
    expect(calls[6].arguments['txPhy'], ElinkAndroidPhy.phy2M.value);
    expect(calls[6].arguments['rxPhy'], ElinkAndroidPhy.phy1M.value);
    expect(calls[7].arguments['resendCount'], 3);
  });

  // 默认 write 不新增通道参数；自定义 write 完整传递目标且保留原生错误。
  test(
    'write forwards custom UUIDs and preserves legacy channel shape',
    () async {
      await platform.write(
        remoteId: 'device-a',
        data: Uint8List.fromList([1]),
        type: 'withoutResponse',
      );
      expect(calls.single.arguments, {
        'remoteId': 'device-a',
        'data': Uint8List.fromList([1]),
        'type': 'withoutResponse',
      });
      await platform.write(
        remoteId: 'device-b',
        data: Uint8List.fromList([2]),
        type: 'withResponse',
        serviceUuid: 'FFF0',
        characteristicUuid: 'FFF1',
      );
      expect(calls.last.arguments, {
        'remoteId': 'device-b',
        'data': Uint8List.fromList([2]),
        'type': 'withResponse',
        'serviceUuid': 'FFF0',
        'characteristicUuid': 'FFF1',
      });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            throw PlatformException(code: 'characteristic_not_found');
          });
      await expectLater(
        platform.write(
          remoteId: 'device-b',
          data: Uint8List.fromList([2]),
          type: 'withResponse',
          serviceUuid: 'FFF0',
          characteristicUuid: 'FFF1',
        ),
        throwsA(
          isA<PlatformException>().having(
            (error) => error.code,
            'code',
            'characteristic_not_found',
          ),
        ),
      );
    },
  );

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

  test('BM version queries use native method channel contract', () async {
    await platform.getBmVersion('remote');

    expect(calls.map((call) => call.method), ['getBmVersion']);
    expect(calls[0].arguments['remoteId'], 'remote');
  });

  test('handshake methods forward remoteId context', () async {
    await platform.initHandshake(remoteId: 'remote');
    await platform.getHandshakeEncryptData(
      Uint8List.fromList([0xA6]),
      remoteId: 'remote',
    );
    await platform.checkHandshakeStatus(
      Uint8List.fromList([0x24]),
      remoteId: 'remote',
    );

    expect(calls.map((call) => call.method), [
      'initHandshake',
      'getHandshakeEncryptData',
      'checkHandshakeStatus',
    ]);
    expect(calls[0].arguments['remoteId'], 'remote');
    expect(calls[1].arguments['remoteId'], 'remote');
    expect(calls[1].arguments['payload'], Uint8List.fromList([0xA6]));
    expect(calls[2].arguments['remoteId'], 'remote');
    expect(calls[2].arguments['payload'], Uint8List.fromList([0x24]));
  });

  test('data processor validates A6 packets', () {
    final packet = <int>[0xA6, 0x01, 0x23, 0x24, 0x6A];

    expect(MethodChannelFlutterElinkBle, isNotNull);
    expect(packet, hasLength(5));
  });
}
