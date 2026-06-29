import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_elink_ble_platform_interface.dart';

class MethodChannelFlutterElinkBle extends FlutterElinkBlePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_elink_ble/methods');

  @visibleForTesting
  final eventChannel = const EventChannel('flutter_elink_ble/events');

  Stream<Map<dynamic, dynamic>>? _events;

  @override
  Stream<Map<dynamic, dynamic>> get events {
    return _events ??= eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return event;
      }
      return <String, Object?>{
        'type': 'error',
        'code': 'bad_event',
        'message': 'Unexpected native event: $event',
      };
    });
  }

  @override
  Future<bool> isSupported() async {
    return await methodChannel.invokeMethod<bool>('isSupported') ?? false;
  }

  @override
  Future<Map<dynamic, dynamic>> getAdapterState() async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getAdapterState',
    );
    return result ?? const <String, Object?>{'state': 'unknown'};
  }

  /// 请求 native 拉起系统蓝牙开启入口。
  @override
  Future<void> openBluetooth() {
    return methodChannel.invokeMethod<void>('openBluetooth');
  }

  @override
  Future<void> startScan({
    required int timeoutMs,
    required List<String> withServices,
    int? androidScanMode,
  }) {
    return methodChannel.invokeMethod<void>('startScan', <String, Object?>{
      'timeoutMs': timeoutMs,
      'withServices': withServices,
      'androidScanMode': androidScanMode,
    });
  }

  @override
  Future<void> stopScan() {
    return methodChannel.invokeMethod<void>('stopScan');
  }

  @override
  Future<void> connect({
    required String remoteId,
    required int timeoutMs,
    required bool autoConnect,
  }) {
    return methodChannel.invokeMethod<void>('connect', <String, Object?>{
      'remoteId': remoteId,
      'timeoutMs': timeoutMs,
      'autoConnect': autoConnect,
    });
  }

  @override
  Future<void> disconnect(String remoteId) {
    return methodChannel.invokeMethod<void>('disconnect', <String, Object?>{
      'remoteId': remoteId,
    });
  }

  @override
  Future<void> readRssi(String remoteId) {
    return methodChannel.invokeMethod<void>('readRssi', <String, Object?>{
      'remoteId': remoteId,
    });
  }

  @override
  Future<bool> setAndroidMtu(String remoteId, int mtu) async {
    return await methodChannel.invokeMethod<bool>(
          'setAndroidMtu',
          <String, Object?>{'remoteId': remoteId, 'mtu': mtu},
        ) ??
        false;
  }

  /// 通过 MethodChannel 获取 iOS 最大写入长度。
  /// Get iOS maximum write lengths through MethodChannel.
  @override
  Future<Map<dynamic, dynamic>> getIosMtu(String remoteId) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getIosMtu',
      <String, Object?>{'remoteId': remoteId},
    );
    return result ??
        <String, Object?>{
          'remoteId': remoteId,
          'maxWriteWithoutResponse': 0,
          'maxWriteWithResponse': 0,
        };
  }

  @override
  Future<bool> setAndroidPreferredPhy({
    required String remoteId,
    required int txPhy,
    required int rxPhy,
  }) async {
    return await methodChannel.invokeMethod<bool>(
          'setAndroidPreferredPhy',
          <String, Object?>{
            'remoteId': remoteId,
            'txPhy': txPhy,
            'rxPhy': rxPhy,
          },
        ) ??
        false;
  }

  /// 通过 MethodChannel 设置 Android 指令发送失败重发次数。
  @override
  Future<void> setAndroidCommandResendCount(int resendCount) {
    return methodChannel.invokeMethod<void>(
      'setAndroidCommandResendCount',
      <String, Object?>{'resendCount': resendCount},
    );
  }

  @override
  Future<void> write({
    required String remoteId,
    required Uint8List data,
    required String type,
  }) {
    return methodChannel.invokeMethod<void>('write', <String, Object?>{
      'remoteId': remoteId,
      'data': data,
      'type': type,
    });
  }

  @override
  Future<void> writeA6({required String remoteId, required Uint8List payload}) {
    return methodChannel.invokeMethod<void>('writeA6', <String, Object?>{
      'remoteId': remoteId,
      'payload': payload,
    });
  }

  /// 通过 native SDK 增强版 `0x46` 指令查询 BM 版本。
  @override
  Future<void> getBmVersion(String remoteId) {
    return methodChannel.invokeMethod<void>('getBmVersion', <String, Object?>{
      'remoteId': remoteId,
    });
  }

  @override
  Future<void> writeA7({
    required String remoteId,
    required Uint8List payload,
    int? cid,
  }) {
    return methodChannel.invokeMethod<void>('writeA7', <String, Object?>{
      'remoteId': remoteId,
      'payload': payload,
      'cid': cid,
    });
  }

  @override
  Future<Uint8List?> decryptBroadcast(Uint8List payload) {
    return methodChannel.invokeMethod<Uint8List>('decryptBroadcast', payload);
  }

  @override
  Future<Uint8List?> initHandshake({String? remoteId}) {
    return methodChannel.invokeMethod<Uint8List>('initHandshake', {
      'remoteId': remoteId,
    });
  }

  @override
  Future<Uint8List?> getHandshakeEncryptData(
    Uint8List payload, {
    String? remoteId,
  }) {
    return methodChannel.invokeMethod<Uint8List>('getHandshakeEncryptData', {
      'payload': payload,
      'remoteId': remoteId,
    });
  }

  @override
  Future<bool> checkHandshakeStatus(
    Uint8List payload, {
    String? remoteId,
  }) async {
    return await methodChannel.invokeMethod<bool>('checkHandshakeStatus', {
          'payload': payload,
          'remoteId': remoteId,
        }) ??
        false;
  }

  @override
  Future<Uint8List?> mcuEncrypt({
    required Uint8List cid,
    required Uint8List mac,
    required Uint8List payload,
  }) {
    return methodChannel.invokeMethod<Uint8List>('mcuEncrypt', {
      'cid': cid,
      'mac': mac,
      'payload': payload,
    });
  }

  @override
  Future<Uint8List?> mcuDecrypt({
    required Uint8List mac,
    required Uint8List payload,
  }) {
    return methodChannel.invokeMethod<Uint8List>('mcuDecrypt', {
      'mac': mac,
      'payload': payload,
    });
  }

  @override
  Future<void> dispose() {
    _events = null;
    return methodChannel.invokeMethod<void>('dispose');
  }
}
