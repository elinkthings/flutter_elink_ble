import 'dart:async';
import 'dart:convert';

import '../flutter_elink_ble_platform_interface.dart';
import 'elink_byte_utils.dart';
import 'elink_ble_models.dart';
import 'elink_data_processor.dart';
import 'elink_wifi_commands.dart';
import 'elink_wifi_models.dart';

/// Elink WiFi provisioning facade for WiFi commands and native event parsing (Elink WiFi 配网 facade，负责 WiFi 命令调用和 WiFi native 事件整理).
class ElinkWifi {
  /// Prevent instantiating this facade (禁止实例化工具 facade).
  ElinkWifi._();

  /// Current platform implementation (当前平台实现).
  static FlutterElinkBlePlatform get _platform {
    return FlutterElinkBlePlatform.instance;
  }

  static final StreamController<ElinkWifiEvent> _eventController =
      StreamController<ElinkWifiEvent>.broadcast();
  static final StreamController<List<ElinkWifiAccessPoint>>
  _scanResultsController =
      StreamController<List<ElinkWifiAccessPoint>>.broadcast();
  static final StreamController<ElinkWifiStatusEvent> _statusController =
      StreamController<ElinkWifiStatusEvent>.broadcast();
  static final StreamController<ElinkWifiResponseEvent> _responseController =
      StreamController<ElinkWifiResponseEvent>.broadcast();

  static final Map<String, ElinkWifiAccessPoint> _scanResults =
      <String, ElinkWifiAccessPoint>{};
  static final Map<String, String> _scanSsidByNumber = <String, String>{};
  static final Map<String, Map<String, Object?>> _scanInfoByNumber =
      <String, Map<String, Object?>>{};
  static final Map<String, ElinkWifiStatusEvent> _latestStatusByRemoteId =
      <String, ElinkWifiStatusEvent>{};
  static StreamSubscription<Map<dynamic, dynamic>>? _eventSubscription;
  static final Map<String, DateTime> _recentNativeEventTimes =
      <String, DateTime>{};
  static final Map<String, DateTime> _recentEmittedEventTimes =
      <String, DateTime>{};
  static final Map<String, DateTime> _recentStatusEventTimes =
      <String, DateTime>{};
  static final Map<String, String> _serverHostParts = <String, String>{};
  static const Duration _nativeEventDuplicateWindow = Duration(
    milliseconds: 300,
  );
  static const Duration _commandAckTimeout = Duration(seconds: 6);

  /// Whether Dart should emit WiFi command debug logs; disabled by default (是否输出 WiFi 指令调试日志，默认关闭).
  static bool commandLoggingEnabled = false;

  /// Generic WiFi provisioning event stream (WiFi 配网相关原始事件 stream).
  static Stream<ElinkWifiEvent> get events {
    _ensureListening();
    return _eventController.stream;
  }

  /// WiFi scan result stream, deduplicated by MAC or scan id (WiFi 扫描结果 stream，同一 MAC/编号会被去重更新).
  static Stream<List<ElinkWifiAccessPoint>> get scanResults {
    _ensureListening();
    return _scanResultsController.stream;
  }

  /// BLE, WiFi, and module work status event stream (BLE/WiFi/模块工作状态事件 stream).
  static Stream<ElinkWifiStatusEvent> get statusEvents {
    _ensureListening();
    return _statusController.stream;
  }

  /// WiFi setting command response event stream (WiFi 设置命令响应事件 stream).
  static Stream<ElinkWifiResponseEvent> get responseEvents {
    _ensureListening();
    return _responseController.stream;
  }

  /// Scan nearby WiFi access points; results are emitted through [scanResults] and [events] (扫描设备附近 WiFi 热点，结果从 [scanResults] 和 [events] 返回).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  static Future<void> scan(String remoteId) {
    _ensureListening();
    _scanResults.clear();
    _scanSsidByNumber.clear();
    _scanInfoByNumber.clear();
    _scanResultsController.add(const <ElinkWifiAccessPoint>[]);
    return _writeWifiCommands(remoteId, ElinkWifiCommandBuilder.scan());
  }

  /// Query BLE, WiFi, and module work status; results are emitted through [statusEvents] (查询 BLE/WiFi/模块工作状态，结果从 [statusEvents] 返回).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  static Future<void> getCurrentState(String remoteId) {
    _ensureListening();
    return _writeWifiCommands(
      remoteId,
      ElinkWifiCommandBuilder.getCurrentState(),
    );
  }

  /// Configure target WiFi MAC and password, then ask the module to connect (设置目标 WiFi MAC 和密码，并请求模块连接).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  ///
  /// [macAddress] is the WiFi BSSID/MAC from scan results; prefer [ElinkWifiAccessPoint.macAddress] (扫描结果中的 WiFi BSSID/MAC，建议使用 [ElinkWifiAccessPoint.macAddress]).
  ///
  /// [password] is the target WiFi password; pass an empty string for open networks (目标 WiFi 密码；开放网络可传空字符串).
  static Future<void> configureAndConnect(
    String remoteId, {
    required String macAddress,
    required String password,
  }) async {
    _ensureListening();
    await _writeWifiCommandGroup(
      remoteId,
      command: 0x84,
      commands: <ElinkWifiCommandPacket>[
        ElinkWifiCommandBuilder.setConnectWifiMac(macAddress),
      ],
    );
    await _writeWifiCommandGroup(
      remoteId,
      command: 0x86,
      commands: ElinkWifiCommandBuilder.setPassword(password),
    );
    await _writeWifiCommandGroup(
      remoteId,
      command: 0x88,
      commands: ElinkWifiCommandBuilder.connect(),
    );
  }

  /// 先设置 WiFi 模块服务端信息，再配置目标 WiFi 并请求连接。
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  ///
  /// [host] is the server domain, IP, or URL host (服务端域名、IP 或 URL host).
  ///
  /// [port] is the server port (服务端端口号).
  ///
  /// [path] is the server path; leave it empty when unused (服务端路径；无路径时可留空).
  ///
  /// [macAddress] is the WiFi BSSID/MAC from scan results (扫描结果中的 WiFi BSSID/MAC).
  ///
  /// [password] is the target WiFi password; pass an empty string for open networks (目标 WiFi 密码；开放网络可传空字符串).
  static Future<void> configureServerAndConnect(
    String remoteId, {
    required String host,
    required int port,
    String path = '',
    required String macAddress,
    required String password,
  }) async {
    _ensureListening();
    await setServerInfo(remoteId, host: host, port: port, path: path);
    await configureAndConnect(
      remoteId,
      macAddress: macAddress,
      password: password,
    );
  }

  /// Set WiFi password (设置 WiFi 密码).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  ///
  /// [password] is the target WiFi password; pass an empty string for open networks (目标 WiFi 密码；开放网络可传空字符串).
  static Future<void> setPassword(String remoteId, {required String password}) {
    _ensureListening();
    return _writeWifiCommands(
      remoteId,
      ElinkWifiCommandBuilder.setPassword(password),
    );
  }

  /// Ask the module to connect the configured WiFi (请求模块连接已配置的 WiFi).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  static Future<void> connect(String remoteId) {
    _ensureListening();
    return _writeWifiCommands(remoteId, ElinkWifiCommandBuilder.connect());
  }

  /// Ask the module to disconnect the current WiFi (请求模块断开当前 WiFi).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  static Future<void> disconnect(String remoteId) {
    _ensureListening();
    return _writeWifiCommands(remoteId, ElinkWifiCommandBuilder.disconnect());
  }

  /// Query connected WiFi SSID; result is emitted through [events] (查询当前连接的 WiFi 名称，结果从 [events] 返回).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  static Future<void> getConnectedSsid(String remoteId) {
    _ensureListening();
    return _writeWifiCommands(
      remoteId,
      ElinkWifiCommandBuilder.getConnectedSsid(),
    );
  }

  /// Query saved WiFi password; result is emitted through [events] (查询当前保存的 WiFi 密码，结果从 [events] 返回).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  static Future<void> getConnectedPassword(String remoteId) {
    _ensureListening();
    return _writeWifiCommands(
      remoteId,
      ElinkWifiCommandBuilder.getConnectedPassword(),
    );
  }

  /// Query connected WiFi MAC; result is emitted through [events] (查询当前连接的 WiFi MAC，结果从 [events] 返回).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  static Future<void> getConnectedMac(String remoteId) {
    _ensureListening();
    return _writeWifiCommands(
      remoteId,
      ElinkWifiCommandBuilder.getConnectedMac(),
    );
  }

  /// Query WiFi module deviceId/SN; result is emitted through [events] (查询 WiFi 模块 deviceId/SN，结果从 [events] 返回).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  static Future<void> getDeviceSn(String remoteId) {
    _ensureListening();
    return _writeWifiCommands(remoteId, ElinkWifiCommandBuilder.getDeviceSn());
  }

  /// Query server host, port, and path; results are emitted through [events] (查询服务端 host、port、path，结果从 [events] 返回).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  static Future<void> getServerInfo(String remoteId) {
    _ensureListening();
    return _writeWifiCommands(
      remoteId,
      ElinkWifiCommandBuilder.getServerInfo(),
    );
  }

  /// Query server host or URL (查询服务端 host 或 URL).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  static Future<void> getServerHost(String remoteId) {
    _ensureListening();
    return _writeWifiCommands(
      remoteId,
      ElinkWifiCommandBuilder.getServerHost(),
    );
  }

  /// Query server port (查询服务端端口号).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  static Future<void> getServerPort(String remoteId) {
    _ensureListening();
    return _writeWifiCommands(
      remoteId,
      ElinkWifiCommandBuilder.getServerPort(),
    );
  }

  /// Query server path (查询服务端 path).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  static Future<void> getServerPath(String remoteId) {
    _ensureListening();
    return _writeWifiCommands(
      remoteId,
      ElinkWifiCommandBuilder.getServerPath(),
    );
  }

  /// Set server host, port, and path for the WiFi module (设置 WiFi 模块访问的服务端 host、port、path).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  ///
  /// [host] is the server domain, IP, or URL host (服务端域名、IP 或 URL host).
  ///
  /// [port] is the server port (服务端端口号).
  ///
  /// [path] is the server path; leave it empty when unused (服务端路径；无路径时可留空).
  static Future<void> setServerInfo(
    String remoteId, {
    required String host,
    required int port,
    String path = '',
  }) async {
    _ensureListening();
    await _writeWifiCommandGroup(
      remoteId,
      command: 0x8B,
      commands: ElinkWifiCommandBuilder.setServerHost(host),
    );
    await _writeWifiCommandGroup(
      remoteId,
      command: 0x8D,
      commands: <ElinkWifiCommandPacket>[
        ElinkWifiCommandBuilder.setServerPort(port),
      ],
    );
    await _writeWifiCommandGroup(
      remoteId,
      command: 0x96,
      commands: ElinkWifiCommandBuilder.setServerPath(path),
    );
  }

  /// Ask the WiFi/BLE module to restart (请求 WiFi/BLE 模块重启).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  static Future<void> restart(String remoteId) {
    _ensureListening();
    return _writeWifiCommands(remoteId, ElinkWifiCommandBuilder.restart());
  }

  /// Ask the WiFi/BLE module to reset to factory data (请求 WiFi/BLE 模块恢复出厂设置).
  ///
  /// [remoteId] is the native remote identifier of the connected BLE device (已连接 BLE 设备的 native remote identifier).
  static Future<void> reset(String remoteId) {
    _ensureListening();
    return _writeWifiCommands(remoteId, ElinkWifiCommandBuilder.reset());
  }

  /// Release the WiFi event subscription and clear cached data (释放 WiFi event subscription 并清空缓存).
  static Future<void> dispose() async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    _scanResults.clear();
    _scanSsidByNumber.clear();
    _scanInfoByNumber.clear();
    _latestStatusByRemoteId.clear();
    _recentNativeEventTimes.clear();
    _recentEmittedEventTimes.clear();
    _recentStatusEventTimes.clear();
    _serverHostParts.clear();
    commandLoggingEnabled = false;
  }

  /// Start listening to the native event stream (开始监听 native event stream).
  static void _ensureListening() {
    _eventSubscription ??= _platform.events.listen(_handleNativeEvent);
  }

  /// Dispatch WiFi events by native event type (按 native event type 分发 WiFi 事件).
  ///
  /// [event] is the event map forwarded from the native EventChannel (native EventChannel 透传的事件 map).
  static void _handleNativeEvent(Map<dynamic, dynamic> event) {
    if (_isDuplicateNativeEvent(event)) {
      return;
    }
    switch (event['type']) {
      case 'wifiScanResult':
        _handleScanResult(event);
        break;
      case 'wifiScanFinished':
        _handleScanFinished(event);
        break;
      case 'wifiStatus':
        _handleStatusEvent(event);
        break;
      case 'wifiResponse':
        _handleResponseEvent(event);
        break;
      case 'protocolData':
        _handleProtocolDataEvent(event);
        break;
      case 'wifiScanStatus':
      case 'wifiScanCount':
      case 'wifiConnecting':
      case 'wifiCommand':
      case 'wifiConnectedSsid':
      case 'wifiConnectedMac':
      case 'wifiConnectedPassword':
      case 'wifiDeviceSn':
      case 'wifiDtimInterval':
      case 'wifiServerHost':
      case 'wifiServerPort':
      case 'wifiServerPath':
      case 'wifiServerSetting':
        _emitEvent(event);
        break;
    }
  }

  /// 判断 WiFi 事件是否为短时间内重复回调。
  ///
  /// [event] is the native event map to check (待检查的 native event map).
  static bool _isDuplicateNativeEvent(Map<dynamic, dynamic> event) {
    final key = _stableEventKey(event);
    final now = DateTime.now();
    _recentNativeEventTimes.removeWhere(
      (_, time) => now.difference(time) > _nativeEventDuplicateWindow,
    );
    final lastTime = _recentNativeEventTimes[key];
    if (lastTime != null &&
        now.difference(lastTime) <= _nativeEventDuplicateWindow) {
      return true;
    }
    _recentNativeEventTimes[key] = now;
    return false;
  }

  /// 生成稳定的事件去重 key，避免 Map 顺序影响判断。
  ///
  /// [value] is the native event value to serialize (待序列化的 native event 值).
  static String _stableEventKey(Object? value) {
    if (value is Map) {
      final entries = value.entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
      return entries
          .map((entry) {
            return '${entry.key}:${_stableEventKey(entry.value)}';
          })
          .join('|');
    }
    if (value is Iterable) {
      return value.map(_stableEventKey).join(',');
    }
    return value.toString();
  }

  /// Handle WiFi A6 status payloads carried by native protocolData events (处理 native protocolData 中夹带的 WiFi A6 状态 payload).
  ///
  /// [event] is the native protocolData event map (native protocolData event map).
  static void _handleProtocolDataEvent(Map<dynamic, dynamic> event) {
    final packet = ElinkProtocolDataPacket.fromMap(event);
    if (packet.protocol != ElinkProtocolDataType.a6) {
      return;
    }
    _handleWifiPayload(packet.remoteId, packet.data);
  }

  /// 顺序下发 Dart 侧构造的 WiFi A6 指令，并输出统一 tx 日志。
  ///
  /// [remoteId] is the native remote identifier for the target device (目标设备的 native remote identifier).
  ///
  /// [commands] is the WiFi A6 command sequence to send (待下发的 WiFi A6 指令序列).
  static Future<void> _writeWifiCommands(
    String remoteId,
    List<ElinkWifiCommandPacket> commands,
  ) async {
    for (final command in commands) {
      _emitWifiCommand(remoteId, command);
      await _platform.writeA6(remoteId: remoteId, payload: command.payload);
    }
  }

  /// 按命令类型下发 WiFi 指令组，并等待设备成功回包后再返回。
  ///
  /// [remoteId] is the native remote identifier for the target device (目标设备的 native remote identifier).
  ///
  /// [command] is the WiFi command byte expected in the response (等待回包的 WiFi 命令字节).
  ///
  /// [commands] is the payload sequence for the same command type (同一命令类型的 payload 序列).
  static Future<void> _writeWifiCommandGroup(
    String remoteId, {
    required int command,
    required List<ElinkWifiCommandPacket> commands,
  }) async {
    final ackFuture = responseEvents
        .firstWhere((event) {
          return _isRemoteIdMatch(event.remoteId, remoteId) &&
              event.command == command;
        })
        .timeout(_commandAckTimeout);
    try {
      for (final packet in commands) {
        _emitWifiCommand(remoteId, packet);
        await _platform.writeA6(remoteId: remoteId, payload: packet.payload);
      }
      final ack = await ackFuture;
      if (ack.status != ElinkWifiCommandStatus.success) {
        throw StateError(
          'WiFi command 0x${command.toRadixString(16)} failed: '
          '${ack.status.name}',
        );
      }
    } catch (_) {
      unawaited(ackFuture.then<void>((_) {}, onError: (_) {}));
      rethrow;
    }
  }

  /// 判断 WiFi 回包 remoteId 是否属于当前目标设备。
  ///
  /// [eventRemoteId] is the remoteId carried by the response event (回包携带的 remoteId).
  ///
  /// [targetRemoteId] is the remoteId of the command target (命令目标 remoteId).
  static bool _isRemoteIdMatch(String eventRemoteId, String targetRemoteId) {
    return eventRemoteId.isEmpty || eventRemoteId == targetRemoteId;
  }

  /// 发送 WiFi 指令日志事件。
  ///
  /// [remoteId] is the native remote identifier for the target device (目标设备的 native remote identifier).
  ///
  /// [command] is the WiFi command packet being sent (正在下发的 WiFi 指令包).
  static void _emitWifiCommand(
    String remoteId,
    ElinkWifiCommandPacket command,
  ) {
    if (!commandLoggingEnabled) {
      return;
    }
    _emitEvent(<String, Object?>{
      'type': 'wifiCommand',
      'remoteId': remoteId,
      'command': command.payload.isEmpty ? -1 : command.payload.first,
      'value': command.name,
      'hex': ElinkByteUtils.formatHex(command.payload),
      'data': command.payload,
    });
  }

  /// Handle one WiFi scan result and update the cached list (处理单个 WiFi 扫描结果并更新缓存列表).
  ///
  /// [event] is one WiFi scan result event map (单个 WiFi 扫描结果 event map).
  static void _handleScanResult(Map<dynamic, dynamic> event) {
    final result = ElinkWifiAccessPoint.fromMap(event);
    _scanResults[result.key] = result;
    _scanResultsController.add(
      List<ElinkWifiAccessPoint>.unmodifiable(_scanResults.values),
    );
    _emitEvent({...event, 'accessPoint': event});
  }

  /// Handle WiFi scan-finished events and replace the cached list (处理 WiFi 扫描完成事件并替换缓存列表).
  ///
  /// [event] is the WiFi scan-finished event map (WiFi 扫描完成 event map).
  static void _handleScanFinished(Map<dynamic, dynamic> event) {
    final accessPoints = (event['accessPoints'] as List? ?? const <Object?>[])
        .whereType<Map>()
        .map(ElinkWifiAccessPoint.fromMap)
        .toList(growable: false);
    _scanResults
      ..clear()
      ..addEntries(accessPoints.map((item) => MapEntry(item.key, item)));
    _scanResultsController.add(
      List<ElinkWifiAccessPoint>.unmodifiable(_scanResults.values),
    );
    _emitEvent(event);
  }

  /// Handle BLE, WiFi, and module work status events (处理 BLE/WiFi/模块工作状态事件).
  ///
  /// [event] is the WiFi status event map (WiFi 状态 event map).
  static void _handleStatusEvent(Map<dynamic, dynamic> event) {
    final status = ElinkWifiStatusEvent.fromMap(event);
    if (_isDuplicateStatusEvent(status)) {
      return;
    }
    _latestStatusByRemoteId[status.remoteId] = status;
    _statusController.add(status);
    _emitEvent(_statusEventMap(status));
  }

  /// 将 WiFi 状态模型还原为通用事件 map。
  ///
  /// [status] is the normalized WiFi status event (规整后的 WiFi 状态事件).
  static Map<String, Object?> _statusEventMap(ElinkWifiStatusEvent status) {
    return <String, Object?>{
      'type': 'wifiStatus',
      'remoteId': status.remoteId,
      'bleStatus': status.rawBleStatus,
      'wifiStatus': status.rawWifiStatus,
      'workStatus': status.rawWorkStatus,
      if (status.rawFailStatus != null) 'failStatus': status.rawFailStatus,
    };
  }

  /// 判断 WiFi 状态事件是否为短时间内重复回调。
  ///
  /// [event] is the normalized WiFi status event (规整后的 WiFi 状态事件).
  static bool _isDuplicateStatusEvent(ElinkWifiStatusEvent event) {
    final key = [
      event.remoteId,
      event.rawBleStatus,
      event.wifiStatus.value,
      event.rawWorkStatus,
      event.rawFailStatus,
    ].join('|');
    final now = DateTime.now();
    _recentStatusEventTimes.removeWhere(
      (_, time) => now.difference(time) > _nativeEventDuplicateWindow,
    );
    final lastTime = _recentStatusEventTimes[key];
    if (lastTime != null &&
        now.difference(lastTime) <= _nativeEventDuplicateWindow) {
      return true;
    }
    _recentStatusEventTimes[key] = now;
    return false;
  }

  /// Handle WiFi setting command response events (处理 WiFi 设置命令响应事件).
  ///
  /// [event] is the WiFi setting command response event map (WiFi 设置命令响应 event map).
  static void _handleResponseEvent(Map<dynamic, dynamic> event) {
    _responseController.add(ElinkWifiResponseEvent.fromMap(event));
    _emitEvent(event);
  }

  /// Parse WiFi A6 payloads carried by protocolData events (解析 protocolData 中夹带的 WiFi A6 payload).
  ///
  /// [remoteId] is the native remote identifier for the event device (事件所属设备的 native remote identifier).
  ///
  /// [data] is an A6 payload or a full A6 packet (A6 payload 或完整 A6 packet).
  static void _handleWifiPayload(String remoteId, List<int> data) {
    final payload = ElinkDataProcessor.normalizeA6Payload(data);
    if (payload.isEmpty) {
      return;
    }
    switch (payload[0]) {
      case 0x26:
        _handlePackedStatusPayload(remoteId, payload);
        break;
      case 0x80:
        _handleScanStatusPayload(remoteId, payload);
        break;
      case 0x81:
        _handleScanNamePayload(remoteId, payload);
        break;
      case 0x82:
        _handleScanInfoPayload(remoteId, payload);
        break;
      case 0x83:
        _handleScanFinishedPayload(remoteId, payload);
        break;
      case 0x84:
      case 0x86:
      case 0x88:
        _handleCommandResponsePayload(remoteId, payload);
        break;
      case 0x85:
        _handleConnectedMacPayload(remoteId, payload);
        break;
      case 0x87:
        _handleTextPayload(remoteId, payload, 'wifiConnectedPassword');
        break;
      case 0x8B:
      case 0x8D:
      case 0x96:
        _handleCommandResponsePayload(remoteId, payload);
        _handleServerSettingPayload(remoteId, payload);
        break;
      case 0x8C:
        _handleServerHostPayload(remoteId, payload);
        break;
      case 0x8E:
        _handleServerPortPayload(remoteId, payload);
        break;
      case 0x93:
        _handleDeviceSnPayload(remoteId, payload);
        break;
      case 0x94:
        _handleTextPayload(remoteId, payload, 'wifiConnectedSsid');
        break;
      case 0x97:
        _handleTextPayload(remoteId, payload, 'wifiServerPath');
        break;
      case 0xAB:
        _handleConnectFailPayload(remoteId, payload);
        break;
    }
  }

  /// 按 Android SDK 规则解析 `0x26` WiFi 状态回包。
  ///
  /// [remoteId] is the native remote identifier for the event device (事件所属设备的 native remote identifier).
  ///
  /// [payload] is a `0x26` WiFi status payload (0x26 WiFi 状态 payload).
  static void _handlePackedStatusPayload(String remoteId, List<int> payload) {
    if (payload.length < 3) {
      return;
    }
    final packedStatus = payload[1] & 0xff;
    _handleStatusEvent(<String, Object?>{
      'type': 'wifiStatus',
      'remoteId': remoteId,
      'bleStatus': packedStatus & 0x0f,
      'wifiStatus': (packedStatus & 0xf0) >> 4,
      'workStatus': payload[2] & 0xff,
    });
  }

  /// 解析 `0xAB` WiFi 连接 AP 失败原因回包。
  ///
  /// [remoteId] is the native remote identifier for the event device (事件所属设备的 native remote identifier).
  ///
  /// [payload] is a `0xAB` WiFi connection failure payload (0xAB WiFi 连接失败原因 payload).
  static void _handleConnectFailPayload(String remoteId, List<int> payload) {
    if (payload.length < 2) {
      return;
    }
    final latestStatus = _latestStatusByRemoteId[remoteId];
    _handleStatusEvent(<String, Object?>{
      'type': 'wifiStatus',
      'remoteId': remoteId,
      'bleStatus': latestStatus?.rawBleStatus,
      'wifiStatus': ElinkWifiConnectionStatus.connectApFail.value,
      'workStatus': latestStatus?.rawWorkStatus,
      'failStatus': payload[1] & 0xff,
    });
  }

  /// 解析 WiFi 扫描状态回包。
  ///
  /// [remoteId] is the native remote identifier for the event device (事件所属设备的 native remote identifier).
  ///
  /// [payload] is a `0x80` WiFi scan status payload (0x80 WiFi 扫描状态 payload).
  static void _handleScanStatusPayload(String remoteId, List<int> payload) {
    if (payload.length < 2) {
      return;
    }
    _emitEvent(<String, Object?>{
      'type': 'wifiScanStatus',
      'remoteId': remoteId,
      'status': payload[1] & 0x0f,
    });
  }

  /// 解析 WiFi 扫描 SSID 分包。
  ///
  /// [remoteId] is the native remote identifier for the event device (事件所属设备的 native remote identifier).
  ///
  /// [payload] is a `0x81` WiFi scan SSID payload (0x81 WiFi 扫描 SSID payload).
  static void _handleScanNamePayload(String remoteId, List<int> payload) {
    if (payload.length < 2) {
      return;
    }
    final id = payload[1] & 0xff;
    final key = _scanNumberKey(remoteId, id);
    final ssid = _decodePayloadText(payload, start: 2);
    _scanSsidByNumber[key] = ssid;
    final info = _scanInfoByNumber[key];
    if (info != null) {
      final updatedInfo = <String, Object?>{...info, 'ssid': ssid};
      _scanInfoByNumber[key] = updatedInfo;
      _handleScanResult(updatedInfo);
    }
  }

  /// 解析 WiFi 扫描热点详情分包。
  ///
  /// [remoteId] is the native remote identifier for the event device (事件所属设备的 native remote identifier).
  ///
  /// [payload] is a `0x82` WiFi scan detail payload (0x82 WiFi 扫描详情 payload).
  static void _handleScanInfoPayload(String remoteId, List<int> payload) {
    if (payload.length < 11) {
      return;
    }
    final id = payload[1] & 0xff;
    final key = _scanNumberKey(remoteId, id);
    final macData = payload.sublist(2, 8);
    final rawRssi = payload[8] & 0xff;
    final event = <String, Object?>{
      'type': 'wifiScanResult',
      'remoteId': remoteId,
      'id': id,
      'ssid': _scanSsidByNumber[key] ?? '',
      'macAddress': ElinkByteUtils.formatMac(macData, littleEndian: true),
      'macData': macData,
      'rssi': rawRssi > 127 ? rawRssi - 256 : rawRssi,
      'securityType': payload[9] & 0xff,
      'useState': payload[10] & 0xff,
    };
    _scanInfoByNumber[key] = event;
    _handleScanResult(event);
  }

  /// 解析 WiFi 扫描完成回包。
  ///
  /// [remoteId] is the native remote identifier for the event device (事件所属设备的 native remote identifier).
  ///
  /// [payload] is a `0x83` WiFi scan finish payload (0x83 WiFi 扫描完成 payload).
  static void _handleScanFinishedPayload(String remoteId, List<int> payload) {
    final count = payload.length > 1 ? payload[1] & 0xff : _scanResults.length;
    final accessPoints = _scanResults.values
        .where((item) => item.remoteId == remoteId)
        .map(_accessPointEventMap)
        .toList(growable: false);
    _handleScanFinished(<String, Object?>{
      'type': 'wifiScanFinished',
      'remoteId': remoteId,
      'status': count,
      'value': count,
      'accessPoints': accessPoints,
    });
  }

  /// 解析 WiFi 设置类命令响应。
  ///
  /// [remoteId] is the native remote identifier for the event device (事件所属设备的 native remote identifier).
  ///
  /// [payload] is a WiFi setting response payload (WiFi 设置响应 payload).
  static void _handleCommandResponsePayload(
    String remoteId,
    List<int> payload,
  ) {
    if (payload.length < 2) {
      return;
    }
    _handleResponseEvent(<String, Object?>{
      'type': 'wifiResponse',
      'remoteId': remoteId,
      'command': payload[0] & 0xff,
      'status': payload[1] & 0xff,
    });
  }

  /// 解析服务端设置类命令响应。
  ///
  /// [remoteId] is the native remote identifier for the event device (事件所属设备的 native remote identifier).
  ///
  /// [payload] is a server setting response payload (服务端设置响应 payload).
  static void _handleServerSettingPayload(String remoteId, List<int> payload) {
    if (payload.length < 2) {
      return;
    }
    final status = payload[1] & 0xff;
    _emitEvent(<String, Object?>{
      'type': 'wifiServerSetting',
      'remoteId': remoteId,
      'command': payload[0] & 0xff,
      'status': status,
      'value': status == 0,
    });
  }

  /// 解析当前连接 WiFi MAC 回包。
  ///
  /// [remoteId] is the native remote identifier for the event device (事件所属设备的 native remote identifier).
  ///
  /// [payload] is a `0x85` WiFi MAC payload (0x85 WiFi MAC payload).
  static void _handleConnectedMacPayload(String remoteId, List<int> payload) {
    if (payload.length < 7) {
      return;
    }
    final macData = payload.sublist(1, 7);
    _emitEvent(<String, Object?>{
      'type': 'wifiConnectedMac',
      'remoteId': remoteId,
      'value': ElinkByteUtils.formatMac(macData, littleEndian: true),
      'macData': macData,
    });
  }

  /// 解析 UTF-8 文本类 WiFi 回包。
  ///
  /// [remoteId] is the native remote identifier for the event device (事件所属设备的 native remote identifier).
  ///
  /// [payload] is the WiFi text payload whose first byte is command (首字节为 command 的 WiFi 文本 payload).
  ///
  /// [type] is the event type to emit (需要输出的 event type).
  static void _handleTextPayload(
    String remoteId,
    List<int> payload,
    String type,
  ) {
    final value = _decodePayloadText(payload, start: 1);
    _emitEvent(<String, Object?>{
      'type': type,
      'remoteId': remoteId,
      'value': value,
    });
  }

  /// 聚合 WiFi server host 的 A6 分包，只在最后一包输出完整 host。
  ///
  /// [remoteId] is the native remote identifier for the event device (事件所属设备的 native remote identifier).
  ///
  /// [payload] is a `0x8C` WiFi server host payload (0x8C WiFi server host payload).
  static void _handleServerHostPayload(String remoteId, List<int> payload) {
    if (payload.length < 2) {
      return;
    }
    final end = payload[1] == 0;
    final part = _decodePayloadText(payload, start: 2);
    final host = (_serverHostParts[remoteId] ?? '') + part;
    if (!end) {
      _serverHostParts[remoteId] = host;
      return;
    }
    _serverHostParts.remove(remoteId);
    _emitEvent(<String, Object?>{
      'type': 'wifiServerHost',
      'remoteId': remoteId,
      'value': host,
    });
  }

  /// 解析服务端端口回包。
  ///
  /// [remoteId] is the native remote identifier for the event device (事件所属设备的 native remote identifier).
  ///
  /// [payload] is a `0x8E` server port payload (0x8E 服务端端口 payload).
  static void _handleServerPortPayload(String remoteId, List<int> payload) {
    if (payload.length < 3) {
      return;
    }
    _emitEvent(<String, Object?>{
      'type': 'wifiServerPort',
      'remoteId': remoteId,
      'value': ((payload[1] & 0xff) << 8) | (payload[2] & 0xff),
    });
  }

  /// 解析 WiFi 模块 SN 回包。
  ///
  /// [remoteId] is the native remote identifier for the event device (事件所属设备的 native remote identifier).
  ///
  /// [payload] is a `0x93` WiFi SN payload (0x93 WiFi SN payload).
  static void _handleDeviceSnPayload(String remoteId, List<int> payload) {
    if (payload.length < 5) {
      return;
    }
    _emitEvent(<String, Object?>{
      'type': 'wifiDeviceSn',
      'remoteId': remoteId,
      'value':
          ((payload[1] & 0xff) << 24) |
          ((payload[2] & 0xff) << 16) |
          ((payload[3] & 0xff) << 8) |
          (payload[4] & 0xff),
    });
  }

  /// 生成扫描编号缓存 key。
  ///
  /// [remoteId] is the native remote identifier for the event device (事件所属设备的 native remote identifier).
  ///
  /// [id] is the scan result number from the WiFi module (WiFi 模块返回的扫描编号).
  static String _scanNumberKey(String remoteId, int id) {
    return '$remoteId|$id';
  }

  /// 将 WiFi 热点模型还原为 event map。
  ///
  /// [accessPoint] is the access point model to serialize (待序列化的 WiFi 热点模型).
  static Map<String, Object?> _accessPointEventMap(
    ElinkWifiAccessPoint accessPoint,
  ) {
    return <String, Object?>{
      'remoteId': accessPoint.remoteId,
      'id': accessPoint.id,
      'ssid': accessPoint.ssid,
      'macAddress': accessPoint.macAddress,
      'macData': accessPoint.macData,
      'rssi': accessPoint.rssi,
      'securityType': accessPoint.securityType.value,
      'useState': accessPoint.useState.value,
    };
  }

  /// 解码 WiFi payload 中的 UTF-8 文本并移除首尾空白。
  ///
  /// [payload] is the complete WiFi payload (完整 WiFi payload).
  ///
  /// [start] is the first byte index for text data (文本数据开始 byte index).
  static String _decodePayloadText(List<int> payload, {required int start}) {
    if (payload.length <= start) {
      return '';
    }
    final textBytes = payload
        .sublist(start)
        .where((byte) => byte != 0)
        .toList();
    return utf8.decode(textBytes, allowMalformed: true).trim();
  }

  /// Emit a generic WiFi event (发送通用 WiFi 事件).
  ///
  /// [event] is the WiFi event map emitted to [events] (待发送到 [events] 的 WiFi event map).
  static void _emitEvent(Map<dynamic, dynamic> event) {
    if (event['type'] == 'wifiCommand') {
      if (!commandLoggingEnabled) {
        return;
      }
      _eventController.add(ElinkWifiEvent.fromMap(event));
      return;
    }
    final key = _stableEventKey(event);
    final now = DateTime.now();
    _recentEmittedEventTimes.removeWhere(
      (_, time) => now.difference(time) > _nativeEventDuplicateWindow,
    );
    final lastTime = _recentEmittedEventTimes[key];
    if (lastTime != null &&
        now.difference(lastTime) <= _nativeEventDuplicateWindow) {
      return;
    }
    _recentEmittedEventTimes[key] = now;
    _eventController.add(ElinkWifiEvent.fromMap(event));
  }
}
