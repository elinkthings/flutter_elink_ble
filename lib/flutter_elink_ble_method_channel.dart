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
  Future<void> disconnectCurrent() {
    return methodChannel.invokeMethod<void>('disconnectCurrent');
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
  Future<Uint8List?> initHandshake() {
    return methodChannel.invokeMethod<Uint8List>('initHandshake');
  }

  @override
  Future<Uint8List?> getHandshakeEncryptData(Uint8List payload) {
    return methodChannel.invokeMethod<Uint8List>(
      'getHandshakeEncryptData',
      payload,
    );
  }

  @override
  Future<bool> checkHandshakeStatus(Uint8List payload) async {
    return await methodChannel.invokeMethod<bool>(
          'checkHandshakeStatus',
          payload,
        ) ??
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
