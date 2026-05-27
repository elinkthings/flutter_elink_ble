import 'dart:async';
import 'dart:typed_data';

import '../flutter_elink_ble_platform_interface.dart';
import 'elink_data_processor.dart';
import 'elink_ble_models.dart';

/// 蓝牙适配器状态回调。
/// Bluetooth adapter state callback.
typedef ElinkAdapterStateCallback = void Function(ElinkAdapterState state);

/// Elink BLE 的 Dart facade，负责把 native EventChannel 事件整理成 streams。
/// Use streams for long-lived UI binding.
///
/// 也可以在业务层使用 [setBluetoothStateCallback] 注册一个简单回调。
/// Use [setBluetoothStateCallback] when the business layer only needs one callback.
class ElinkBle {
  ElinkBle._();

  static FlutterElinkBlePlatform get _platform =>
      FlutterElinkBlePlatform.instance;

  static final StreamController<ElinkAdapterState> _adapterStateController =
      StreamController<ElinkAdapterState>.broadcast();
  static final StreamController<bool> _isScanningController =
      StreamController<bool>.broadcast();
  static final StreamController<List<ElinkScanResult>> _scanResultsController =
      StreamController<List<ElinkScanResult>>.broadcast();
  static final StreamController<ElinkDeviceEvent> _connectionController =
      StreamController<ElinkDeviceEvent>.broadcast();
  static final StreamController<ElinkServiceDiscoveredEvent>
  _serviceDiscoveryController =
      StreamController<ElinkServiceDiscoveredEvent>.broadcast();
  static final StreamController<ElinkProtocolDataPacket>
  _protocolDataController =
      StreamController<ElinkProtocolDataPacket>.broadcast();
  static final StreamController<ElinkPassthroughDataPacket>
  _passthroughDataController =
      StreamController<ElinkPassthroughDataPacket>.broadcast();
  static final StreamController<ElinkCharacteristicEvent>
  _characteristicController =
      StreamController<ElinkCharacteristicEvent>.broadcast();
  static final StreamController<ElinkRssiEvent> _rssiController =
      StreamController<ElinkRssiEvent>.broadcast();
  static final StreamController<ElinkMtuEvent> _mtuController =
      StreamController<ElinkMtuEvent>.broadcast();
  static final StreamController<ElinkHandshakeEvent> _handshakeController =
      StreamController<ElinkHandshakeEvent>.broadcast();
  static final StreamController<ElinkBmVersionEvent> _bmVersionController =
      StreamController<ElinkBmVersionEvent>.broadcast();
  static final StreamController<ElinkBleException> _errorController =
      StreamController<ElinkBleException>.broadcast();

  static final Map<String, ElinkScanResult> _scanResults =
      <String, ElinkScanResult>{};
  static final Map<String, String> _connectionEventKeys = <String, String>{};
  static StreamSubscription<Map<dynamic, dynamic>>? _eventSubscription;
  static StreamSubscription<ElinkAdapterState>? _adapterStateCallbackSub;
  static ElinkAdapterState _adapterStateNow = ElinkAdapterState.unknown;
  static bool _isScanningNow = false;
  static String? _activeScanSignature;

  /// 当前设备是否支持 BLE。
  /// Whether this device supports Bluetooth Low Energy.
  static Future<bool> get isSupported => _platform.isSupported();

  /// 请求打开系统蓝牙。
  /// Request the system to turn on Bluetooth.
  ///
  /// Android 会拉起系统打开蓝牙确认；iOS 不允许 App 直接打开蓝牙，
  /// 只会刷新当前蓝牙状态。最终状态请继续监听 [bluetoothState]。
  /// Android shows the system enable-Bluetooth prompt. iOS cannot turn on
  /// Bluetooth directly, so it only refreshes current state. Continue observing
  /// [bluetoothState] for the final state.
  static Future<void> openBluetooth() {
    _ensureListening();
    return _platform.openBluetooth();
  }

  /// 最近一次收到的 Bluetooth adapter state。
  /// Latest Bluetooth adapter state received from native.
  ///
  /// 调用 getter 会确保 native event stream 已经开始监听。
  /// Reading this getter ensures the native event stream is subscribed.
  static ElinkAdapterState get adapterStateNow {
    _ensureListening();
    return _adapterStateNow;
  }

  /// 蓝牙适配器状态 stream。
  /// Bluetooth adapter state stream: `on`, `off`, `unauthorized`, etc.
  static Stream<ElinkAdapterState> get adapterState {
    _ensureListening();
    return _adapterStateController.stream;
  }

  /// [adapterStateNow] 的语义化别名，便于业务代码按 Bluetooth state 命名。
  /// Semantic alias for [adapterStateNow] when business code uses Bluetooth state naming.
  static ElinkAdapterState get bluetoothStateNow => adapterStateNow;

  /// [adapterState] 的语义化别名，便于业务代码按 Bluetooth state 命名。
  /// Semantic alias for [adapterState] when business code uses Bluetooth state naming.
  static Stream<ElinkAdapterState> get bluetoothState => adapterState;

  /// 注册蓝牙状态回调。
  /// Register Bluetooth state callback.
  ///
  /// 传入 `null` 可取消回调。回调会立即收到当前缓存状态，然后继续收到
  /// native 侧推送的后续变化。
  /// Pass `null` to clear the callback. The callback receives the cached state
  /// immediately and then receives later native updates.
  static void setBluetoothStateCallback(ElinkAdapterStateCallback? callback) {
    _ensureListening();
    _adapterStateCallbackSub?.cancel();
    _adapterStateCallbackSub = null;
    if (callback == null) {
      return;
    }
    callback(_adapterStateNow);
    _adapterStateCallbackSub = adapterState.listen(callback);
  }

  /// 当前 scan 状态，true 表示已调用 startScan 且尚未 stop/timeout.
  /// Current scan state; true after startScan until stop or timeout.
  static bool get isScanningNow {
    _ensureListening();
    return _isScanningNow;
  }

  /// 扫描状态 stream。
  /// Scan running state stream.
  static Stream<bool> get isScanning {
    _ensureListening();
    return _isScanningController.stream;
  }

  /// 扫描结果 stream。同一 remoteId 会被去重并更新为最新 RSSI/广播数据。
  /// Scan results stream, deduplicated by remoteId with latest RSSI/advertisement data.
  static Stream<List<ElinkScanResult>> get scanResults {
    _ensureListening();
    return _scanResultsController.stream;
  }

  /// 连接状态事件 stream。
  /// Connection state event stream.
  static Stream<ElinkDeviceEvent> get connectionEvents {
    _ensureListening();
    return _connectionController.stream;
  }

  /// 服务发现事件，包含 service UUID 和已发现 characteristic UUIDs.
  /// Service discovery events with service UUID and discovered characteristic UUIDs.
  static Stream<ElinkServiceDiscoveredEvent> get serviceDiscoveryEvents {
    _ensureListening();
    return _serviceDiscoveryController.stream;
  }

  /// A6/A7 payload 数据，来自 SDK protocol callbacks.
  /// A6/A7 payload stream from SDK protocol callbacks.
  static Stream<ElinkProtocolDataPacket> get protocolDataPackets {
    _ensureListening();
    return _protocolDataController.stream;
  }

  /// 透传/非协议数据，来自 SDK other/raw data callbacks.
  /// Passthrough or non-protocol data stream from SDK raw callbacks.
  static Stream<ElinkPassthroughDataPacket> get passthroughDataPackets {
    _ensureListening();
    return _passthroughDataController.stream;
  }

  /// 底层 characteristic 操作事件：read/write/descriptorWrite/changed.
  /// Low-level characteristic operation events: read/write/descriptorWrite/changed.
  static Stream<ElinkCharacteristicEvent> get characteristicEvents {
    _ensureListening();
    return _characteristicController.stream;
  }

  /// 已连接设备的 RSSI 读取结果。
  /// RSSI read results for connected devices.
  static Stream<ElinkRssiEvent> get rssiEvents {
    _ensureListening();
    return _rssiController.stream;
  }

  /// Android MTU 设置结果。
  /// Android MTU change result stream.
  static Stream<ElinkMtuEvent> get mtuEvents {
    _ensureListening();
    return _mtuController.stream;
  }

  /// Flutter A6 handshake 结果回调。
  /// Flutter A6 handshake result callbacks.
  static Stream<ElinkHandshakeEvent> get handshakeEvents {
    _ensureListening();
    return _handshakeController.stream;
  }

  /// BM 模块版本回调 stream，由 A6 `0x0E` 回包解析得到。
  /// BM module version stream parsed from A6 `0x0E` responses.
  static Stream<ElinkBmVersionEvent> get bmVersionEvents {
    _ensureListening();
    return _bmVersionController.stream;
  }

  /// Native 或 Dart bridge 产生的错误事件。
  /// Error events produced by native code or the Dart bridge.
  static Stream<ElinkBleException> get errors {
    _ensureListening();
    return _errorController.stream;
  }

  /// 开始 BLE scan。默认扫描 Elink 广播设备 `F0A0` 与连接设备 `FFE0`。
  /// Start BLE scan. Defaults to Elink broadcast service `F0A0` and connect service `FFE0`.
  static Future<void> startScan({
    Duration timeout = const Duration(seconds: 10),
    List<ElinkGuid> withServices = const <ElinkGuid>[
      ElinkGuid.broadcastDevice,
      ElinkGuid.connectDevice,
    ],
    ElinkAndroidScanMode? androidScanMode,
  }) async {
    _ensureListening();
    final scanSignature = _scanSignature(withServices, androidScanMode);
    if (_isScanningNow && _activeScanSignature == scanSignature) {
      return;
    }
    _scanResults.clear();
    _scanResultsController.add(const <ElinkScanResult>[]);
    _setScanning(true);
    _activeScanSignature = scanSignature;
    try {
      await _platform.startScan(
        timeoutMs: timeout.inMilliseconds,
        withServices: withServices.map((guid) => guid.value).toList(),
        androidScanMode: androidScanMode?.value,
      );
    } catch (_) {
      _setScanning(false);
      rethrow;
    }
  }

  /// 停止 BLE scan，并同步更新 [isScanning] 状态。
  /// Stop BLE scan and update [isScanning] state.
  static Future<void> stopScan() async {
    _ensureListening();
    await _platform.stopScan();
    _setScanning(false);
  }

  /// 连接一个扫描到的设备。
  /// Connect a scanned BLE peripheral.
  static Future<void> connect(
    ElinkDevice device, {
    Duration timeout = const Duration(seconds: 15),
    bool autoConnect = false,
  }) {
    _ensureListening();
    return _platform.connect(
      remoteId: device.remoteId,
      timeoutMs: timeout.inMilliseconds,
      autoConnect: autoConnect,
    );
  }

  /// 断开指定 remoteId 的 BLE 连接。
  /// Disconnect the BLE connection for a remoteId.
  static Future<void> disconnect(String remoteId) {
    _ensureListening();
    return _platform.disconnect(remoteId);
  }

  /// 断开当前连接设备。
  /// Disconnect the current connected device.
  static Future<void> disconnectCurrent() {
    _ensureListening();
    return _platform.disconnectCurrent();
  }

  /// 主动读取已连接设备 RSSI，结果从 [rssiEvents] 返回。
  /// Read RSSI for a connected device; result is emitted through [rssiEvents].
  static Future<void> readRssi(String remoteId) {
    _ensureListening();
    return _platform.readRssi(remoteId);
  }

  /// Android only: request GATT MTU. iOS 不支持主动设置 MTU。
  /// Android only: request GATT MTU. iOS does not support active MTU requests.
  static Future<bool> setAndroidMtu(String remoteId, int mtu) {
    _ensureListening();
    return _platform.setAndroidMtu(remoteId, mtu);
  }

  /// Android only: set preferred PHY. Requires Android 8.0+.
  /// Android only: set preferred PHY. Requires Android 8.0+.
  static Future<bool> setAndroidPreferredPhy(
    String remoteId, {
    required ElinkAndroidPhy txPhy,
    required ElinkAndroidPhy rxPhy,
  }) {
    _ensureListening();
    return _platform.setAndroidPreferredPhy(
      remoteId: remoteId,
      txPhy: txPhy.value,
      rxPhy: rxPhy.value,
    );
  }

  /// 写入 Elink packet 到设备 characteristic。
  /// Write a full Elink packet to the device characteristic.
  static Future<void> write(
    String remoteId,
    List<int> data, {
    ElinkWriteType type = ElinkWriteType.withoutResponse,
  }) {
    _ensureListening();
    return _platform.write(
      remoteId: remoteId,
      data: Uint8List.fromList(data),
      type: type.name,
    );
  }

  /// 发送 A6 payload。
  /// The native SDK adds the A6 header, tail, and checksum.
  static Future<void> writeA6(String remoteId, List<int> payload) {
    _ensureListening();
    return _platform.writeA6(
      remoteId: remoteId,
      payload: Uint8List.fromList(payload),
    );
  }

  /// 通过 A6 `0x0E` 查询 BM 模块版本。
  /// Query the BM module version with A6 command `0x0E`.
  ///
  /// 回包会从 [bmVersionEvents] 返回。
  /// The response is emitted through [bmVersionEvents].
  static Future<void> getBmVersion(String remoteId) {
    _ensureListening();
    return _platform.writeA6(
      remoteId: remoteId,
      payload: Uint8List.fromList(ElinkDataProcessor.getBmVersionPayload()),
    );
  }

  /// 发送 A7 payload。
  /// The native SDK adds the A7 header, tail, and checksum.
  ///
  /// Android 侧 `SendMcuBean` 需要 CID；未传时 native 会尝试使用已连接设备的 CID。
  /// iOS 侧 `ELAILinkBleManager.sendA7Payload` 使用当前连接设备上下文。
  ///
  /// Android `SendMcuBean` needs CID; native falls back to the connected device CID.
  /// iOS `ELAILinkBleManager.sendA7Payload` uses the current connected device context.
  static Future<void> writeA7(String remoteId, List<int> payload, {int? cid}) {
    _ensureListening();
    return _platform.writeA7(
      remoteId: remoteId,
      payload: Uint8List.fromList(payload),
      cid: cid,
    );
  }

  /// 主动查询一次 native adapter state，并触发 Dart stream/callback。
  /// Query native adapter state once and publish it through Dart stream/callback.
  static Future<void> refreshAdapterState() async {
    _ensureListening();
    final result = await _platform.getAdapterState();
    _setAdapterState(ElinkAdapterState.fromName(result['state']));
  }

  /// 释放 event subscription 和 native 连接资源。
  /// Release event subscription and native connection resources.
  static Future<void> dispose() async {
    await _adapterStateCallbackSub?.cancel();
    _adapterStateCallbackSub = null;
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    _scanResults.clear();
    _connectionEventKeys.clear();
    _activeScanSignature = null;
    _adapterStateNow = ElinkAdapterState.unknown;
    _setScanning(false);
    await _platform.dispose();
  }

  static void _ensureListening() {
    _eventSubscription ??= _platform.events.listen(
      _handleEvent,
      onError: (Object error) {
        _errorController.add(
          ElinkBleException(code: 'event_stream', message: error.toString()),
        );
      },
    );
  }

  static void _handleEvent(Map<dynamic, dynamic> event) {
    switch (event['type']) {
      case 'adapterState':
        _setAdapterState(ElinkAdapterState.fromName(event['state']));
        break;
      case 'scanResult':
        final result = ElinkScanResult.fromMap(event);
        if (result.device.remoteId.isNotEmpty) {
          _scanResults[result.device.remoteId] = result;
          _scanResultsController.add(
            List<ElinkScanResult>.unmodifiable(_scanResults.values),
          );
        }
        break;
      case 'scanStopped':
        _setScanning(false);
        break;
      case 'connectionState':
        _emitConnectionEvent(ElinkDeviceEvent.fromMap(event));
        break;
      case 'servicesDiscovered':
        _serviceDiscoveryController.add(
          ElinkServiceDiscoveredEvent.fromMap(event),
        );
        break;
      case 'protocolData':
        final packet = _normalizeProtocolPacket(
          ElinkProtocolDataPacket.fromMap(event),
        );
        _protocolDataController.add(packet);
        _handleCommonA6Packet(packet);
        unawaited(_handleFlutterHandshakePacket(packet));
        break;
      case 'passthroughData':
        _passthroughDataController.add(
          ElinkPassthroughDataPacket.fromMap(event),
        );
        break;
      case 'characteristicEvent':
        _characteristicController.add(ElinkCharacteristicEvent.fromMap(event));
        break;
      case 'rssi':
        _rssiController.add(ElinkRssiEvent.fromMap(event));
        break;
      case 'mtu':
        _mtuController.add(ElinkMtuEvent.fromMap(event));
        break;
      case 'error':
        _errorController.add(ElinkBleException.fromMap(event));
        break;
      default:
        _errorController.add(
          ElinkBleException(
            code: 'unknown_event',
            message: 'Unknown Elink BLE event type: ${event['type']}',
            details: event,
          ),
        );
    }
  }

  /// 发送连接状态事件，并过滤同一设备连续重复的状态。
  /// Emit connection events and ignore consecutive duplicates per device.
  static void _emitConnectionEvent(ElinkDeviceEvent event) {
    final eventKey = '${event.connectionState.name}|${event.reason ?? ''}';
    if (_connectionEventKeys[event.remoteId] == eventKey) {
      return;
    }
    _connectionEventKeys[event.remoteId] = eventKey;
    _connectionController.add(event);
  }

  static void _setAdapterState(ElinkAdapterState state) {
    if (_adapterStateNow == state) {
      return;
    }
    _adapterStateNow = state;
    _adapterStateController.add(state);
  }

  static void _setScanning(bool value) {
    if (_isScanningNow == value) {
      return;
    }
    _isScanningNow = value;
    if (!value) {
      _activeScanSignature = null;
    }
    _isScanningController.add(value);
  }

  static String _scanSignature(
    List<ElinkGuid> withServices,
    ElinkAndroidScanMode? androidScanMode,
  ) {
    final services =
        withServices.map((guid) => guid.value.toUpperCase()).toList()..sort();
    return '${androidScanMode?.value ?? "default"}:${services.join(",")}';
  }

  static Future<void> _handleFlutterHandshakePacket(
    ElinkProtocolDataPacket packet,
  ) async {
    if (packet.protocol != ElinkProtocolDataType.a6) {
      return;
    }
    final a6Packet = _normalizeA6Packet(packet.data);
    try {
      if (ElinkDataProcessor.isSetHandshakeCommand(a6Packet)) {
        final response = await ElinkDataProcessor.getHandshakeEncryptData(
          a6Packet,
        );
        if (response == null || response.isEmpty) return;
        await _platform.write(
          remoteId: packet.remoteId,
          data: response,
          type: ElinkWriteType.withoutResponse.name,
        );
      } else if (ElinkDataProcessor.isGetHandshakeCommand(a6Packet)) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        final ready = await ElinkDataProcessor.checkHandshakeStatus(a6Packet);
        _handshakeController.add(
          ElinkHandshakeEvent(remoteId: packet.remoteId, success: ready),
        );
      }
    } catch (error) {
      _errorController.add(
        ElinkBleException(
          code: 'handshake_error',
          message: error.toString(),
          details: packet,
        ),
      );
    }
  }

  static ElinkProtocolDataPacket _normalizeProtocolPacket(
    ElinkProtocolDataPacket packet,
  ) {
    if (packet.protocol != ElinkProtocolDataType.a6) {
      return packet;
    }
    return ElinkProtocolDataPacket(
      remoteId: packet.remoteId,
      protocol: packet.protocol,
      data: Uint8List.fromList(
        ElinkDataProcessor.normalizeA6Payload(packet.data),
      ),
      characteristicUuid: packet.characteristicUuid,
      deviceType: packet.deviceType,
    );
  }

  static void _handleCommonA6Packet(ElinkProtocolDataPacket packet) {
    if (packet.protocol != ElinkProtocolDataType.a6) {
      return;
    }
    final version = ElinkDataProcessor.parseBmVersion(packet.data);
    if (version == null) {
      return;
    }
    _bmVersionController.add(
      ElinkBmVersionEvent(
        remoteId: packet.remoteId,
        version: version,
        rawPayload: Uint8List.fromList(
          ElinkDataProcessor.normalizeA6Payload(packet.data),
        ),
      ),
    );
  }

  static List<int> _normalizeA6Packet(List<int> data) {
    if (ElinkDataProcessor.isA6Packet(data)) {
      return data;
    }
    final payload = ElinkDataProcessor.normalizeA6Payload(data);
    if (payload.isNotEmpty &&
        (payload.first == ElinkDataProcessor.setHandshake ||
            payload.first == ElinkDataProcessor.getHandshake)) {
      return ElinkDataProcessor.wrapA6Frame(payload);
    }
    return data;
  }
}
