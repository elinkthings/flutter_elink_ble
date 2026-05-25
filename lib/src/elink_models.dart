import 'dart:typed_data';

/// 蓝牙适配器状态。
/// Bluetooth adapter state.
enum ElinkAdapterState {
  unknown,
  unavailable,
  unauthorized,
  turningOn,
  on,
  turningOff,
  off;

  /// 将 native 传来的 string state 转成 Dart enum，未知值统一兜底为 unknown。
  /// Convert native string state into a Dart enum and fall back to unknown.
  static ElinkAdapterState fromName(Object? value) {
    return ElinkAdapterState.values.firstWhere(
      (state) => state.name == value,
      orElse: () => ElinkAdapterState.unknown,
    );
  }
}

/// BLE 连接状态。
/// GATT connection state.
enum ElinkConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting;

  /// 是否已经连接，可用于 UI button enable/disable.
  /// Whether the device is connected; useful for UI button enablement.
  bool get isConnected => this == ElinkConnectionState.connected;

  /// 将 native 传来的 string state 转成 Dart enum。
  /// Convert native string state into a Dart enum.
  static ElinkConnectionState fromName(Object? value) {
    return ElinkConnectionState.values.firstWhere(
      (state) => state.name == value,
      orElse: () => ElinkConnectionState.disconnected,
    );
  }
}

/// 写入类型。
/// GATT write type.
enum ElinkWriteType { withResponse, withoutResponse }

/// Android 扫描模式，对应 Android `ScanSettings.SCAN_MODE_*`.
/// Android scan mode mapping to `ScanSettings.SCAN_MODE_*`.
enum ElinkAndroidScanMode {
  opportunistic(-1),
  lowPower(0),
  balanced(1),
  lowLatency(2);

  const ElinkAndroidScanMode(this.value);

  final int value;
}

/// Android BLE PHY 选项，对应 `BluetoothDevice.PHY_LE_*`.
/// Android BLE PHY option mapping to `BluetoothDevice.PHY_LE_*`.
enum ElinkAndroidPhy {
  phy1M(1),
  phy2M(2),
  phyCoded(3);

  const ElinkAndroidPhy(this.value);

  final int value;
}

/// Elink 常用 16-bit UUID wrapper，保持 API 类型明确。
/// Typed wrapper for common Elink 16-bit UUIDs.
class ElinkGuid {
  const ElinkGuid(this.value);

  static const broadcastDevice = ElinkGuid('F0A0');
  static const connectDevice = ElinkGuid('FFE0');
  static const notifyDescriptor = ElinkGuid('2902');
  static const write = ElinkGuid('FFE1');
  static const notify = ElinkGuid('FFE2');
  static const writeAndNotify = ElinkGuid('FFE3');

  final String value;

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    return other is ElinkGuid && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// 一个可连接的 BLE peripheral。
/// A connectable BLE peripheral.
class ElinkDevice {
  const ElinkDevice({
    required this.remoteId,
    this.platformName = '',
    this.connectionState = ElinkConnectionState.disconnected,
  });

  final String remoteId;

  /// 平台侧设备名；Android 可能来自 BluetoothDevice.name，iOS 可能来自 advName.
  /// Platform device name from Android BluetoothDevice.name or iOS advertisement name.
  final String platformName;
  final ElinkConnectionState connectionState;

  ElinkDevice copyWith({
    String? remoteId,
    String? platformName,
    ElinkConnectionState? connectionState,
  }) {
    return ElinkDevice(
      remoteId: remoteId ?? this.remoteId,
      platformName: platformName ?? this.platformName,
      connectionState: connectionState ?? this.connectionState,
    );
  }

  @override
  String toString() => 'ElinkDevice($remoteId, $platformName)';
}

/// BLE advertisement 数据，包含 service UUIDs 与 manufacturer data。
/// BLE advertisement data with service UUIDs and manufacturer data.
class ElinkAdvertisementData {
  const ElinkAdvertisementData({
    this.advName = '',
    this.serviceUuids = const <ElinkGuid>[],
    this.manufacturerData = const <int>[],
    this.raw = const <String, Object?>{},
  });

  final String advName;
  final List<ElinkGuid> serviceUuids;
  final List<int> manufacturerData;
  final Map<String, Object?> raw;

  /// 是否包含 Elink broadcast service UUID `F0A0`.
  /// Whether the advertisement includes Elink broadcast service UUID `F0A0`.
  bool get isBroadcastDevice {
    return serviceUuids.contains(ElinkGuid.broadcastDevice);
  }

  /// 是否包含 Elink connect service UUID `FFE0`.
  /// Whether the advertisement includes Elink connect service UUID `FFE0`.
  bool get isConnectDevice {
    return serviceUuids.contains(ElinkGuid.connectDevice);
  }

  /// 从 native event map 解析广告数据；byte payload 会统一转成 `List<int>`.
  /// Parse advertisement data from native event map and normalize bytes to `List<int>`.
  factory ElinkAdvertisementData.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const ElinkAdvertisementData();
    }
    final serviceUuids = (map['serviceUuids'] as List? ?? const [])
        .map((uuid) => ElinkGuid(uuid.toString().toUpperCase()))
        .toList(growable: false);
    final manufacturerData = _bytesFrom(map['manufacturerData']);
    return ElinkAdvertisementData(
      advName: map['advName']?.toString() ?? '',
      serviceUuids: serviceUuids,
      manufacturerData: manufacturerData,
      raw: Map<String, Object?>.from(map),
    );
  }
}

/// 一条扫描结果。
/// BLE scan result.
class ElinkScanResult {
  ElinkScanResult({
    required this.device,
    required this.advertisementData,
    required this.rssi,
    DateTime? timeStamp,
  }) : timeStamp = timeStamp ?? DateTime.now();

  final ElinkDevice device;
  final ElinkAdvertisementData advertisementData;
  final int rssi;
  final DateTime timeStamp;

  factory ElinkScanResult.fromMap(Map<dynamic, dynamic> map) {
    final remoteId = map['remoteId']?.toString() ?? '';
    return ElinkScanResult(
      device: ElinkDevice(
        remoteId: remoteId,
        platformName:
            map['platformName']?.toString() ?? map['advName']?.toString() ?? '',
      ),
      advertisementData: ElinkAdvertisementData.fromMap(
        map['advertisementData'] as Map?,
      ),
      rssi: (map['rssi'] as num?)?.toInt() ?? 0,
      timeStamp: DateTime.now(),
    );
  }
}

/// 设备连接事件，来自 native GATT/CoreBluetooth callback.
/// Device connection event from native GATT/CoreBluetooth callbacks.
class ElinkDeviceEvent {
  const ElinkDeviceEvent({
    required this.remoteId,
    required this.connectionState,
    this.reason,
  });

  final String remoteId;
  final ElinkConnectionState connectionState;
  final String? reason;

  factory ElinkDeviceEvent.fromMap(Map<dynamic, dynamic> map) {
    return ElinkDeviceEvent(
      remoteId: map['remoteId']?.toString() ?? '',
      connectionState: ElinkConnectionState.fromName(map['state']),
      reason: map['reason']?.toString(),
    );
  }
}

/// 服务发现事件，来自 GATT/CoreBluetooth service discovery callback.
/// Service discovery event from GATT/CoreBluetooth service discovery callbacks.
class ElinkServiceDiscoveredEvent {
  const ElinkServiceDiscoveredEvent({
    required this.remoteId,
    required this.serviceUuid,
    required this.characteristicUuids,
  });

  final String remoteId;
  final ElinkGuid serviceUuid;
  final List<ElinkGuid> characteristicUuids;

  factory ElinkServiceDiscoveredEvent.fromMap(Map<dynamic, dynamic> map) {
    return ElinkServiceDiscoveredEvent(
      remoteId: map['remoteId']?.toString() ?? '',
      serviceUuid: ElinkGuid(
        map['serviceUuid']?.toString().toUpperCase() ?? '',
      ),
      characteristicUuids:
          (map['characteristicUuids'] as List? ?? const <Object?>[])
              .map((uuid) => ElinkGuid(uuid.toString().toUpperCase()))
              .toList(growable: false),
    );
  }
}

/// SDK 协议数据类型。
/// SDK protocol data type.
enum ElinkProtocolDataType {
  a6,
  a7;

  static ElinkProtocolDataType fromName(Object? value) {
    return ElinkProtocolDataType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ElinkProtocolDataType.a7,
    );
  }
}

/// A6/A7 数据回调。
/// A6/A7 data callback.
///
/// 对应 Android `OnBleDeviceDataListener` 和 iOS SDK A6/A7 delegate.
/// Maps Android `OnBleDeviceDataListener` and iOS SDK A6/A7 delegates.
class ElinkProtocolDataPacket {
  const ElinkProtocolDataPacket({
    required this.remoteId,
    required this.protocol,
    required this.data,
    this.characteristicUuid = '',
    this.deviceType,
  });

  final String remoteId;
  final ElinkProtocolDataType protocol;

  /// Payload 数据。SDK 已去掉 A6/A7 包头、包尾、校验和。
  /// Payload data after the SDK removes A6/A7 header, tail, and checksum.
  final Uint8List data;
  final String characteristicUuid;

  /// A7 的设备类型 CID；A6 或平台未提供时为 null。
  /// A7 device type CID; null for A6 or when the platform does not provide it.
  final int? deviceType;

  factory ElinkProtocolDataPacket.fromMap(Map<dynamic, dynamic> map) {
    return ElinkProtocolDataPacket(
      remoteId: map['remoteId']?.toString() ?? '',
      protocol: ElinkProtocolDataType.fromName(map['protocol']),
      data: Uint8List.fromList(_bytesFrom(map['data'])),
      characteristicUuid: map['characteristicUuid']?.toString() ?? '',
      deviceType: (map['deviceType'] as num?)?.toInt(),
    );
  }
}

/// 透传/非协议数据。
/// Passthrough or non-protocol data.
///
/// 对应 Android `OnBleOtherDataListener` 和 iOS raw data callback.
/// Maps Android `OnBleOtherDataListener` and iOS raw data callbacks.
class ElinkPassthroughDataPacket {
  const ElinkPassthroughDataPacket({
    required this.remoteId,
    required this.data,
    this.characteristicUuid = '',
  });

  final String remoteId;
  final Uint8List data;
  final String characteristicUuid;

  factory ElinkPassthroughDataPacket.fromMap(Map<dynamic, dynamic> map) {
    return ElinkPassthroughDataPacket(
      remoteId: map['remoteId']?.toString() ?? '',
      data: Uint8List.fromList(_bytesFrom(map['data'])),
      characteristicUuid: map['characteristicUuid']?.toString() ?? '',
    );
  }
}

/// 底层特征值操作回调类型。
/// Characteristic low-level callback type.
enum ElinkCharacteristicOperation {
  read,
  write,
  descriptorWrite,
  changed,
  notificationStateChanged;

  static ElinkCharacteristicOperation fromName(Object? value) {
    return ElinkCharacteristicOperation.values.firstWhere(
      (operation) => operation.name == value,
      orElse: () => ElinkCharacteristicOperation.changed,
    );
  }
}

/// 底层 characteristic/descriptor 操作事件。
/// Low-level characteristic/descriptor operation event.
class ElinkCharacteristicEvent {
  const ElinkCharacteristicEvent({
    required this.remoteId,
    required this.operation,
    required this.characteristicUuid,
    required this.data,
    this.serviceUuid = '',
    this.descriptorUuid = '',
  });

  final String remoteId;
  final ElinkCharacteristicOperation operation;
  final String serviceUuid;
  final String characteristicUuid;
  final String descriptorUuid;
  final Uint8List data;

  factory ElinkCharacteristicEvent.fromMap(Map<dynamic, dynamic> map) {
    return ElinkCharacteristicEvent(
      remoteId: map['remoteId']?.toString() ?? '',
      operation: ElinkCharacteristicOperation.fromName(map['operation']),
      serviceUuid: map['serviceUuid']?.toString() ?? '',
      characteristicUuid: map['characteristicUuid']?.toString() ?? '',
      descriptorUuid: map['descriptorUuid']?.toString() ?? '',
      data: Uint8List.fromList(_bytesFrom(map['data'])),
    );
  }
}

/// 已连接设备的 RSSI 读取结果。
/// RSSI read result for a connected device.
class ElinkRssiEvent {
  const ElinkRssiEvent({required this.remoteId, required this.rssi});

  final String remoteId;
  final int rssi;

  factory ElinkRssiEvent.fromMap(Map<dynamic, dynamic> map) {
    return ElinkRssiEvent(
      remoteId: map['remoteId']?.toString() ?? '',
      rssi: (map['rssi'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Android MTU 设置结果。
/// Android MTU change result.
class ElinkMtuEvent {
  const ElinkMtuEvent({required this.remoteId, this.mtu, this.availableMtu});

  final String remoteId;

  /// GATT MTU size reported by Android SDK.
  /// Android SDK 回调的 GATT MTU。
  final int? mtu;

  /// 可用 payload 长度，SDK 已处理 ATT header。
  /// Available payload length after SDK accounts for ATT header.
  final int? availableMtu;

  factory ElinkMtuEvent.fromMap(Map<dynamic, dynamic> map) {
    return ElinkMtuEvent(
      remoteId: map['remoteId']?.toString() ?? '',
      mtu: (map['mtu'] as num?)?.toInt(),
      availableMtu: (map['availableMtu'] as num?)?.toInt(),
    );
  }
}

/// Flutter A6 handshake 回调事件。
/// Flutter A6 handshake callback event.
class ElinkHandshakeEvent {
  const ElinkHandshakeEvent({required this.remoteId, required this.success});

  final String remoteId;

  /// `true` 表示 handshake 成功。
  /// `true` means the handshake succeeded.
  final bool success;

  factory ElinkHandshakeEvent.fromMap(Map<dynamic, dynamic> map) {
    return ElinkHandshakeEvent(
      remoteId: map['remoteId']?.toString() ?? '',
      success: map['success'] == true,
    );
  }
}

/// BM 模块版本回调事件。
/// BM module version callback event.
class ElinkBmVersionEvent {
  const ElinkBmVersionEvent({
    required this.remoteId,
    required this.version,
    required this.rawPayload,
  });

  final String remoteId;

  /// 按 AiLinkSecretFlutter common parser 格式化后的 BM version。
  /// BM version formatted with the AiLinkSecretFlutter common parser rules.
  final String version;

  /// 原始 A6 payload，首字节为 `0x0E`.
  /// Raw A6 payload whose first byte is `0x0E`.
  final Uint8List rawPayload;
}

/// 插件统一错误类型，承载 native error code/message/details.
/// Unified plugin error type carrying native error code, message, and details.
class ElinkBleException implements Exception {
  const ElinkBleException({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;
  final Object? details;

  factory ElinkBleException.fromMap(Map<dynamic, dynamic> map) {
    return ElinkBleException(
      code: map['code']?.toString() ?? 'unknown',
      message: map['message']?.toString() ?? 'Unknown Elink BLE error',
      details: map['details'],
    );
  }

  @override
  String toString() => 'ElinkBleException($code, $message, $details)';
}

/// 从 Elink 广播数据中解析出的设备标识字段。
/// Device identity fields parsed from Elink advertisement data.
class ElinkBleData {
  const ElinkBleData({
    required this.cid,
    required this.vid,
    required this.pid,
    required this.mac,
  });

  final List<int> cid;
  final List<int> vid;
  final List<int> pid;
  final List<int> mac;

  /// 2-byte CID value，按 Elink payload 顺序转为 int.
  /// 2-byte CID value converted to int using Elink payload order.
  int get cidValue => _twoByteValue(cid);
  int get vidValue => _twoByteValue(vid);
  int get pidValue => _twoByteValue(pid);

  /// 广播中的 MAC 为 little-endian，这里转换为常见显示格式。
  /// Advertisement MAC is little-endian and converted to common display format.
  String get macAddress => _littleEndianMac(mac);

  /// 所有字段为 0 时认为没有解析到有效 Elink data.
  /// Treat the parsed data as empty when every field is zero.
  bool get isEmpty {
    return cid.every((byte) => byte == 0) &&
        vid.every((byte) => byte == 0) &&
        pid.every((byte) => byte == 0) &&
        mac.every((byte) => byte == 0);
  }

  static int _twoByteValue(List<int> bytes) {
    if (bytes.length != 2) {
      return 0;
    }
    return ((bytes[0] & 0xff) << 8) | (bytes[1] & 0xff);
  }

  static String _littleEndianMac(List<int> bytes) {
    return bytes.reversed
        .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
  }
}

List<int> _bytesFrom(Object? value) {
  if (value == null) {
    return const <int>[];
  }
  if (value is Uint8List) {
    return value.toList(growable: false);
  }
  if (value is List) {
    return value.map((byte) => (byte as num).toInt() & 0xff).toList();
  }
  return const <int>[];
}
