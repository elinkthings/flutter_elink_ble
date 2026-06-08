import 'elink_byte_utils.dart';

/// WiFi access point security type (WiFi 热点安全类型).
enum ElinkWifiSecurityType {
  /// 开放网络，无需密码。
  /// Open network without a password.
  open(0),

  /// WEP 加密网络。
  /// WEP secured network.
  wep(1),

  /// WPA-PSK 加密网络。
  /// WPA-PSK secured network.
  wpaPsk(2),

  /// WPA2-PSK 加密网络。
  /// WPA2-PSK secured network.
  wpa2Psk(3),

  /// WPA/WPA2-PSK 混合加密网络。
  /// WPA/WPA2-PSK mixed secured network.
  wpaWpa2Psk(4),

  /// WPA2 企业级加密网络。
  /// WPA2 Enterprise secured network.
  wpa2Enterprise(5),

  /// 未知安全类型。
  /// Unknown security type.
  unknown(-1);

  /// Create a WiFi security type with the native numeric value (使用 native 数值创建 WiFi 安全类型).
  const ElinkWifiSecurityType(this.value);

  /// Native numeric value returned by the SDK (SDK 返回的 native 数值).
  final int value;

  /// Convert a native numeric value to an enum value (将 native 数值转为枚举值).
  static ElinkWifiSecurityType fromValue(Object? value) {
    final intValue = (value as num?)?.toInt();
    return ElinkWifiSecurityType.values.firstWhere(
      (type) => type.value == intValue,
      orElse: () => ElinkWifiSecurityType.unknown,
    );
  }
}

/// WiFi access point saved or connected state (WiFi 热点保存或连接状态).
enum ElinkWifiUseState {
  /// 未知热点使用状态。
  /// Unknown access point use state.
  unknown(0),

  /// 热点配置已保存。
  /// Access point configuration is saved.
  saved(1),

  /// 热点当前已连接。
  /// Access point is currently connected.
  connected(2);

  /// Create a WiFi use state with the native numeric value (使用 native 数值创建 WiFi 使用状态).
  const ElinkWifiUseState(this.value);

  /// Native numeric value returned by the SDK (SDK 返回的 native 数值).
  final int value;

  /// Convert a native numeric value to an enum value (将 native 数值转为枚举值).
  static ElinkWifiUseState fromValue(Object? value) {
    final intValue = (value as num?)?.toInt();
    return ElinkWifiUseState.values.firstWhere(
      (state) => state.value == intValue,
      orElse: () => ElinkWifiUseState.unknown,
    );
  }
}

/// WiFi setting or scan command result status (WiFi 设置或扫描命令结果状态).
enum ElinkWifiCommandStatus {
  /// 命令执行成功。
  /// Command succeeded.
  success(0),

  /// 命令执行失败。
  /// Command failed.
  failure(1),

  /// 当前模块不支持该命令。
  /// Command is not supported by the module.
  notSupported(2),

  /// 未知命令结果状态。
  /// Unknown command result status.
  unknown(-1);

  /// Create a WiFi command status with the native numeric value (使用 native 数值创建 WiFi 命令状态).
  const ElinkWifiCommandStatus(this.value);

  /// Native numeric value returned by the SDK (SDK 返回的 native 数值).
  final int value;

  /// Convert a native numeric value to an enum value (将 native 数值转为枚举值).
  static ElinkWifiCommandStatus fromValue(Object? value) {
    final intValue = (value as num?)?.toInt();
    return ElinkWifiCommandStatus.values.firstWhere(
      (status) => status.value == intValue,
      orElse: () => ElinkWifiCommandStatus.unknown,
    );
  }
}

/// BLE pairing status reported with WiFi module state (WiFi 模块状态中携带的 BLE 配对状态).
enum ElinkWifiBleStatus {
  /// BLE 未连接。
  /// BLE is not connected.
  noConnection(0),

  /// BLE 已连接。
  /// BLE is connected.
  connected(1),

  /// BLE 已配对。
  /// BLE is paired.
  paired(2),

  /// 未知 BLE 状态。
  /// Unknown BLE status.
  unknown(-1);

  /// Create a BLE status with the native numeric value (使用 native 数值创建 BLE 状态).
  const ElinkWifiBleStatus(this.value);

  /// Native numeric value returned by the SDK (SDK 返回的 native 数值).
  final int value;

  /// Convert a native numeric value to an enum value (将 native 数值转为枚举值).
  static ElinkWifiBleStatus fromValue(Object? value) {
    final intValue = (value as num?)?.toInt();
    return ElinkWifiBleStatus.values.firstWhere(
      (status) => status.value == intValue,
      orElse: () => ElinkWifiBleStatus.unknown,
    );
  }
}

/// WiFi connection status reported by the WiFi module (WiFi 模块返回的 WiFi 连接状态).
enum ElinkWifiConnectionStatus {
  /// 尚未设置目标 WiFi 热点。
  /// Target WiFi access point is not set.
  notSetAp(0),

  /// 连接 WiFi 热点失败。
  /// Failed to connect to the WiFi access point.
  connectApFail(1),

  /// 连接服务器失败。
  /// Failed to connect to the server.
  connectServerFail(2),

  /// 已连接 WiFi 热点。
  /// Connected to the WiFi access point.
  connectedAp(3),

  /// 正在连接 WiFi 热点。
  /// Connecting to the WiFi access point.
  connectingAp(4),

  /// WiFi 热点信号较差。
  /// WiFi access point signal is poor.
  poorApSignal(5),

  /// WiFi 密码错误。
  /// WiFi password is wrong.
  passwordWrong(6),

  /// 无法获取 IP 地址。
  /// Failed to obtain an IP address.
  cantGetIp(7),

  /// 未知 WiFi 连接状态。
  /// Unknown WiFi connection status.
  unknown(-1);

  /// Create a WiFi connection status with the native numeric value (使用 native 数值创建 WiFi 连接状态).
  const ElinkWifiConnectionStatus(this.value);

  /// Native numeric value returned by the SDK (SDK 返回的 native 数值).
  final int value;

  /// Convert a native numeric value to an enum value (将 native 数值转为枚举值).
  static ElinkWifiConnectionStatus fromValue(Object? value) {
    final intValue = (value as num?)?.toInt();
    return ElinkWifiConnectionStatus.values.firstWhere(
      (status) => status.value == intValue,
      orElse: () => ElinkWifiConnectionStatus.unknown,
    );
  }
}

/// WiFi module work status (WiFi 模块工作状态).
enum ElinkWifiWorkStatus {
  /// 模块处于唤醒状态。
  /// Module is awake.
  wakeup(0),

  /// 模块处于休眠状态。
  /// Module is sleeping.
  sleep(1),

  /// 模块已就绪。
  /// Module is ready.
  ready(2),

  /// 未知模块工作状态。
  /// Unknown module work status.
  unknown(-1);

  /// Create a module work status with the native numeric value (使用 native 数值创建模块工作状态).
  const ElinkWifiWorkStatus(this.value);

  /// Native numeric value returned by the SDK (SDK 返回的 native 数值).
  final int value;

  /// Convert a native numeric value to an enum value (将 native 数值转为枚举值).
  static ElinkWifiWorkStatus fromValue(Object? value) {
    final intValue = (value as num?)?.toInt();
    return ElinkWifiWorkStatus.values.firstWhere(
      (status) => status.value == intValue,
      orElse: () => ElinkWifiWorkStatus.unknown,
    );
  }
}

/// WiFi connection failure reason reported by the WiFi module (WiFi 模块返回的 WiFi 连接失败原因).
enum ElinkWifiConnectFailCode {
  /// 未知失败原因。
  /// Unknown failure reason.
  unknownReason(0),

  /// 热点信号较差。
  /// Access point signal is poor.
  apSignalBad(1),

  /// WiFi 密码错误。
  /// WiFi password is wrong.
  wrongPassword(2),

  /// 无法获取 IP 地址。
  /// Failed to obtain an IP address.
  noIp(3),

  /// 未知失败码。
  /// Unknown failure code.
  unknown(-1);

  /// Create a WiFi failure reason with the native numeric value (使用 native 数值创建 WiFi 失败原因).
  const ElinkWifiConnectFailCode(this.value);

  /// Native numeric value returned by the SDK (SDK 返回的 native 数值).
  final int value;

  /// Convert a native numeric value to an enum value (将 native 数值转为枚举值).
  static ElinkWifiConnectFailCode fromValue(Object? value) {
    final intValue = (value as num?)?.toInt();
    if (intValue == null) {
      return ElinkWifiConnectFailCode.unknown;
    }
    return ElinkWifiConnectFailCode.values.firstWhere(
      (code) => code.value == intValue,
      orElse: () => ElinkWifiConnectFailCode.unknown,
    );
  }
}

/// WiFi access point returned by the module scan (模块扫描返回的 WiFi 热点信息).
class ElinkWifiAccessPoint {
  /// Create a WiFi access point model (创建 WiFi 热点模型).
  const ElinkWifiAccessPoint({
    this.remoteId = '',
    this.id = 0,
    this.ssid = '',
    this.macAddress = '',
    this.macData = const <int>[],
    this.rssi = 0,
    this.securityType = ElinkWifiSecurityType.unknown,
    this.useState = ElinkWifiUseState.unknown,
    this.raw = const <String, Object?>{},
  });

  /// BLE device remote identifier for this event (此事件所属 BLE 设备的 remote identifier).
  final String remoteId;

  /// Native scan result identifier (native 扫描结果编号).
  final int id;

  /// WiFi SSID reported by the module (模块返回的 WiFi SSID).
  final String ssid;

  /// WiFi BSSID/MAC string reported by the module (模块返回的 WiFi BSSID/MAC 字符串).
  final String macAddress;

  /// WiFi BSSID/MAC bytes reported by the module (模块返回的 WiFi BSSID/MAC 字节).
  final List<int> macData;

  /// WiFi signal strength RSSI (WiFi 信号强度 RSSI).
  final int rssi;

  /// WiFi security type (WiFi 安全类型).
  final ElinkWifiSecurityType securityType;

  /// WiFi saved or connected state (WiFi 保存或连接状态).
  final ElinkWifiUseState useState;

  /// Raw native event map used to build this model (创建此模型的 native 原始 event map).
  final Map<String, Object?> raw;

  /// Parse a WiFi access point from a native event map (从 native event map 解析 WiFi 热点).
  factory ElinkWifiAccessPoint.fromMap(Map<dynamic, dynamic> map) {
    return ElinkWifiAccessPoint(
      remoteId: map['remoteId']?.toString() ?? '',
      id: (map['id'] as num?)?.toInt() ?? 0,
      ssid: map['ssid']?.toString() ?? '',
      macAddress: map['macAddress']?.toString() ?? '',
      macData: ElinkByteUtils.bytesFrom(map['macData']),
      rssi: (map['rssi'] as num?)?.toInt() ?? 0,
      securityType: ElinkWifiSecurityType.fromValue(map['securityType']),
      useState: ElinkWifiUseState.fromValue(map['useState']),
      raw: Map<String, Object?>.from(map),
    );
  }

  /// Stable key used to deduplicate scan results (用于扫描结果去重的稳定 key).
  String get key {
    if (macAddress.isNotEmpty) return macAddress;
    if (macData.isNotEmpty) return ElinkByteUtils.formatMac(macData);
    if (id != 0) return '$remoteId#$id';
    return '$remoteId#$ssid';
  }
}

/// BLE, WiFi, and module work status event (BLE、WiFi 和模块工作状态事件).
class ElinkWifiStatusEvent {
  /// Create a WiFi status event model (创建 WiFi 状态事件模型).
  ElinkWifiStatusEvent({
    required this.remoteId,
    required this.bleStatus,
    required this.wifiStatus,
    required this.workStatus,
    this.failStatus,
    int? rawBleStatus,
    int? rawWifiStatus,
    int? rawWorkStatus,
    int? rawFailStatus,
  }) : _rawBleStatus = rawBleStatus ?? bleStatus.value,
       _rawWifiStatus = rawWifiStatus ?? wifiStatus.value,
       _rawWorkStatus = rawWorkStatus ?? workStatus.value,
       _rawFailStatus = rawFailStatus ?? failStatus?.value;

  /// BLE device remote identifier for this event (此事件所属 BLE 设备的 remote identifier).
  final String remoteId;

  /// BLE pairing status reported with WiFi module state (WiFi 模块状态中携带的 BLE 配对状态).
  final ElinkWifiBleStatus bleStatus;

  /// WiFi connection status using values defined by the AILink SDK (WiFi 连接状态，具体值沿用 AILink SDK 文档定义).
  final ElinkWifiConnectionStatus wifiStatus;

  /// WiFi module work status (WiFi 模块工作状态).
  final ElinkWifiWorkStatus workStatus;

  /// WiFi failure reason, which is not returned by every device (WiFi 连接失败原因，部分设备不会返回).
  final ElinkWifiConnectFailCode? failStatus;

  final int _rawBleStatus;
  final int _rawWifiStatus;
  final int _rawWorkStatus;
  final int? _rawFailStatus;

  /// Raw BLE status value returned by the SDK (SDK 返回的原始 BLE 状态值).
  int get rawBleStatus => _rawBleStatus;

  /// Raw WiFi status value returned by the SDK (SDK 返回的原始 WiFi 状态值).
  int get rawWifiStatus => _rawWifiStatus;

  /// Raw module work status value returned by the SDK (SDK 返回的原始模块工作状态值).
  int get rawWorkStatus => _rawWorkStatus;

  /// Raw WiFi failure reason value returned by the SDK (SDK 返回的原始 WiFi 失败原因值).
  int? get rawFailStatus => _rawFailStatus;

  /// Parse a WiFi status event from a native event map (从 native event map 解析 WiFi 状态事件).
  factory ElinkWifiStatusEvent.fromMap(Map<dynamic, dynamic> map) {
    final bleStatus = (map['bleStatus'] as num?)?.toInt();
    final wifiStatus = (map['wifiStatus'] as num?)?.toInt();
    final workStatus = (map['workStatus'] as num?)?.toInt();
    final failStatus = (map['failStatus'] as num?)?.toInt();
    return ElinkWifiStatusEvent(
      remoteId: map['remoteId']?.toString() ?? '',
      bleStatus: ElinkWifiBleStatus.fromValue(bleStatus),
      wifiStatus: ElinkWifiConnectionStatus.fromValue(wifiStatus),
      workStatus: ElinkWifiWorkStatus.fromValue(workStatus),
      failStatus: failStatus == null
          ? null
          : ElinkWifiConnectFailCode.fromValue(failStatus),
      rawBleStatus: bleStatus,
      rawWifiStatus: wifiStatus,
      rawWorkStatus: workStatus,
      rawFailStatus: failStatus,
    );
  }
}

/// WiFi setting command response event (WiFi 设置命令响应事件).
class ElinkWifiResponseEvent {
  /// Create a WiFi response event model (创建 WiFi 响应事件模型).
  const ElinkWifiResponseEvent({
    required this.remoteId,
    required this.command,
    required this.status,
  });

  /// BLE device remote identifier for this event (此事件所属 BLE 设备的 remote identifier).
  final String remoteId;

  /// A6 WiFi command, for example `0x84`, `0x86`, or `0x88` (A6 WiFi 命令号，例如 `0x84`、`0x86`、`0x88`).
  final int command;

  /// Command result status (命令执行结果).
  final ElinkWifiCommandStatus status;

  /// Parse a WiFi response event from a native event map (从 native event map 解析 WiFi 响应事件).
  factory ElinkWifiResponseEvent.fromMap(Map<dynamic, dynamic> map) {
    return ElinkWifiResponseEvent(
      remoteId: map['remoteId']?.toString() ?? '',
      command: (map['command'] as num?)?.toInt() ?? 0,
      status: ElinkWifiCommandStatus.fromValue(map['status']),
    );
  }
}

/// Generic WiFi event parsed from native callbacks (从 native callback 解析出的通用 WiFi 事件).
class ElinkWifiEvent {
  /// Create a generic WiFi event model (创建通用 WiFi 事件模型).
  const ElinkWifiEvent({
    required this.type,
    this.remoteId = '',
    this.status,
    this.command,
    this.value,
    this.accessPoint,
    this.accessPoints = const <ElinkWifiAccessPoint>[],
    this.raw = const <String, Object?>{},
  });

  /// Native event type name (native event type 名称).
  final String type;

  /// BLE device remote identifier for this event (此事件所属 BLE 设备的 remote identifier).
  final String remoteId;

  /// Optional native status value (可选 native 状态值).
  final int? status;

  /// Optional WiFi command code (可选 WiFi 命令码).
  final int? command;

  /// Optional event value such as SSID, MAC, password, or server field (可选事件值，如 SSID、MAC、密码或服务器字段).
  final Object? value;

  /// Optional single WiFi access point payload (可选单个 WiFi 热点 payload).
  final ElinkWifiAccessPoint? accessPoint;

  /// Optional WiFi access point list payload (可选 WiFi 热点列表 payload).
  final List<ElinkWifiAccessPoint> accessPoints;

  /// Raw native event map used to build this model (创建此模型的 native 原始 event map).
  final Map<String, Object?> raw;

  /// Parse a generic WiFi event from a native event map (从 native event map 解析通用 WiFi 事件).
  factory ElinkWifiEvent.fromMap(Map<dynamic, dynamic> map) {
    final accessPointMap = map['accessPoint'];
    final accessPoints = (map['accessPoints'] as List? ?? const <Object?>[])
        .whereType<Map>()
        .map(ElinkWifiAccessPoint.fromMap)
        .toList(growable: false);
    return ElinkWifiEvent(
      type: map['type']?.toString() ?? '',
      remoteId: map['remoteId']?.toString() ?? '',
      status: (map['status'] as num?)?.toInt(),
      command: (map['command'] as num?)?.toInt(),
      value: map['value'],
      accessPoint: accessPointMap is Map
          ? ElinkWifiAccessPoint.fromMap(accessPointMap)
          : null,
      accessPoints: accessPoints,
      raw: Map<String, Object?>.from(map),
    );
  }
}
