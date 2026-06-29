import 'dart:async';
import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_elink_ble_method_channel.dart';

abstract class FlutterElinkBlePlatform extends PlatformInterface {
  FlutterElinkBlePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterElinkBlePlatform _instance = MethodChannelFlutterElinkBle();

  static FlutterElinkBlePlatform get instance => _instance;

  static set instance(FlutterElinkBlePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<Map<dynamic, dynamic>> get events {
    throw UnimplementedError('events has not been implemented.');
  }

  Future<bool> isSupported() {
    throw UnimplementedError('isSupported() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>> getAdapterState() {
    throw UnimplementedError('getAdapterState() has not been implemented.');
  }

  /// 请求系统打开蓝牙，最终状态通过 adapter state 事件返回。
  Future<void> openBluetooth() {
    throw UnimplementedError('openBluetooth() has not been implemented.');
  }

  Future<void> startScan({
    required int timeoutMs,
    required List<String> withServices,
    int? androidScanMode,
  }) {
    throw UnimplementedError('startScan() has not been implemented.');
  }

  Future<void> stopScan() {
    throw UnimplementedError('stopScan() has not been implemented.');
  }

  Future<void> connect({
    required String remoteId,
    required int timeoutMs,
    required bool autoConnect,
  }) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  Future<void> disconnect(String remoteId) {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  Future<void> readRssi(String remoteId) {
    throw UnimplementedError('readRssi() has not been implemented.');
  }

  Future<bool> setAndroidMtu(String remoteId, int mtu) {
    throw UnimplementedError('setAndroidMtu() has not been implemented.');
  }

  /// iOS only: 获取当前连接设备的最大写入长度。
  /// iOS only: get maximum write lengths for the connected peripheral.
  Future<Map<dynamic, dynamic>> getIosMtu(String remoteId) {
    throw UnimplementedError('getIosMtu() has not been implemented.');
  }

  Future<bool> setAndroidPreferredPhy({
    required String remoteId,
    required int txPhy,
    required int rxPhy,
  }) {
    throw UnimplementedError(
      'setAndroidPreferredPhy() has not been implemented.',
    );
  }

  /// Android only: 设置指令发送失败重发次数，0 关闭，负数由 native 忽略。
  Future<void> setAndroidCommandResendCount(int resendCount) {
    throw UnimplementedError(
      'setAndroidCommandResendCount() has not been implemented.',
    );
  }

  Future<void> write({
    required String remoteId,
    required Uint8List data,
    required String type,
  }) {
    throw UnimplementedError('write() has not been implemented.');
  }

  Future<void> writeA6({required String remoteId, required Uint8List payload}) {
    throw UnimplementedError('writeA6() has not been implemented.');
  }

  /// 通过 native SDK 增强版 `0x46` 指令查询 BM 版本。
  Future<void> getBmVersion(String remoteId) {
    throw UnimplementedError('getBmVersion() has not been implemented.');
  }

  Future<void> writeA7({
    required String remoteId,
    required Uint8List payload,
    int? cid,
  }) {
    throw UnimplementedError('writeA7() has not been implemented.');
  }

  Future<Uint8List?> decryptBroadcast(Uint8List payload) {
    throw UnimplementedError('decryptBroadcast() has not been implemented.');
  }

  Future<Uint8List?> initHandshake({String? remoteId}) {
    throw UnimplementedError('initHandshake() has not been implemented.');
  }

  Future<Uint8List?> getHandshakeEncryptData(
    Uint8List payload, {
    String? remoteId,
  }) {
    throw UnimplementedError(
      'getHandshakeEncryptData() has not been implemented.',
    );
  }

  Future<bool> checkHandshakeStatus(Uint8List payload, {String? remoteId}) {
    throw UnimplementedError(
      'checkHandshakeStatus() has not been implemented.',
    );
  }

  Future<Uint8List?> mcuEncrypt({
    required Uint8List cid,
    required Uint8List mac,
    required Uint8List payload,
  }) {
    throw UnimplementedError('mcuEncrypt() has not been implemented.');
  }

  Future<Uint8List?> mcuDecrypt({
    required Uint8List mac,
    required Uint8List payload,
  }) {
    throw UnimplementedError('mcuDecrypt() has not been implemented.');
  }

  Future<void> dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }
}
