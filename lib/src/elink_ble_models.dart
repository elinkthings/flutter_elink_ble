import 'dart:typed_data';

import 'elink_byte_utils.dart';

/// 蓝牙适配器状态。
/// Bluetooth adapter state.
enum ElinkAdapterState {
  /// 未知蓝牙适配器状态。
  /// Unknown Bluetooth adapter state.
  unknown,

  /// 当前设备不支持或无法使用 BLE。
  /// BLE is unavailable on the current device.
  unavailable,

  /// App 没有蓝牙权限。
  /// The app is not authorized to use Bluetooth.
  unauthorized,

  /// 蓝牙正在打开。
  /// Bluetooth is turning on.
  turningOn,

  /// 蓝牙已打开。
  /// Bluetooth is on.
  on,

  /// 蓝牙正在关闭。
  /// Bluetooth is turning off.
  turningOff,

  /// 蓝牙已关闭。
  /// Bluetooth is off.
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
  /// BLE 设备已断开连接。
  /// The BLE device is disconnected.
  disconnected,

  /// BLE 设备正在连接。
  /// The BLE device is connecting.
  connecting,

  /// BLE 设备已连接。
  /// The BLE device is connected.
  connected,

  /// BLE 设备正在断开连接。
  /// The BLE device is disconnecting.
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

/// Native 插件日志等级，用于区分调试、信息、警告和错误。
/// Native plugin log level.
enum ElinkNativeLogLevel {
  /// Debug 日志。
  /// Debug log.
  debug,

  /// Info 日志。
  /// Info log.
  info,

  /// Warning 日志。
  /// Warning log.
  warning,

  /// Error 日志。
  /// Error log.
  error;

  /// 将 native 传来的等级文本转成 Dart enum。
  /// Convert native log level text into Dart enum.
  static ElinkNativeLogLevel fromName(Object? value) {
    switch (value?.toString().toUpperCase()) {
      case 'D':
      case 'DEBUG':
        return ElinkNativeLogLevel.debug;
      case 'W':
      case 'WARN':
      case 'WARNING':
        return ElinkNativeLogLevel.warning;
      case 'E':
      case 'ERROR':
        return ElinkNativeLogLevel.error;
      case 'I':
      case 'INFO':
      default:
        return ElinkNativeLogLevel.info;
    }
  }

  /// 原生日志短等级，保持和 iOS/Android 常见 D/I/W/E 一致。
  /// Short level name matching common iOS/Android D/I/W/E logs.
  String get shortName {
    return switch (this) {
      ElinkNativeLogLevel.debug => 'D',
      ElinkNativeLogLevel.info => 'I',
      ElinkNativeLogLevel.warning => 'W',
      ElinkNativeLogLevel.error => 'E',
    };
  }
}

/// Native 插件日志事件，由 iOS/Android 通过 EventChannel 上报。
/// Native plugin log event emitted through EventChannel.
class ElinkNativeLogEvent {
  /// 创建 native 插件日志事件。
  /// Create a native plugin log event.
  const ElinkNativeLogEvent({
    required this.platform,
    required this.level,
    required this.message,
    required this.time,
    this.remoteId,
  });

  final String platform;
  final ElinkNativeLogLevel level;
  final String message;
  final DateTime time;

  /// 日志关联的 BLE remoteId；native 未提供结构化字段时为 null。
  /// BLE remoteId associated with this log; null when native does not provide it.
  final String? remoteId;

  /// 从 native event map 解析日志事件。
  /// Parse a native log event from native event map.
  factory ElinkNativeLogEvent.fromMap(Map<dynamic, dynamic> map) {
    final timestampMs = (map['timestampMs'] as num?)?.toInt();
    return ElinkNativeLogEvent(
      platform: map['platform']?.toString() ?? '',
      level: ElinkNativeLogLevel.fromName(map['level']),
      message: map['message']?.toString() ?? '',
      remoteId: _blankToNull(map['remoteId']?.toString()),
      time: timestampMs == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(timestampMs),
    );
  }

  /// 转成 Flutter 侧统一输出的日志文本。
  /// Convert to a unified Flutter-side log line.
  String toFlutterLogLine() {
    final platformName = platform.isEmpty ? 'native' : platform;
    return '[FlutterElinkBle][$platformName][${level.shortName}] $message';
  }
}

String? _blankToNull(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

/// 写入类型。
/// GATT write type.
enum ElinkWriteType {
  /// 写入后等待 GATT response。
  /// Write with a GATT response.
  withResponse,

  /// 写入后不等待 GATT response。
  /// Write without a GATT response.
  withoutResponse,
}

/// Android 扫描模式，对应 Android `ScanSettings.SCAN_MODE_*`.
/// Android scan mode mapping to `ScanSettings.SCAN_MODE_*`.
enum ElinkAndroidScanMode {
  /// 机会扫描模式，仅返回其它客户端扫描到的结果。
  /// Opportunistic scan mode that only receives results from other scans.
  opportunistic(-1),

  /// 低功耗扫描模式。
  /// Low power scan mode.
  lowPower(0),

  /// 平衡功耗和延迟的扫描模式。
  /// Balanced scan mode.
  balanced(1),

  /// 低延迟高频扫描模式。
  /// Low latency scan mode.
  lowLatency(2);

  const ElinkAndroidScanMode(this.value);

  final int value;
}

/// Android BLE PHY 选项，对应 `BluetoothDevice.PHY_LE_*`.
/// Android BLE PHY option mapping to `BluetoothDevice.PHY_LE_*`.
enum ElinkAndroidPhy {
  /// LE 1M PHY。
  phy1M(1),

  /// LE 2M PHY。
  phy2M(2),

  /// LE Coded PHY。
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
    this.macAddress = '',
  });

  final String remoteId;

  /// 平台侧设备名；Android 可能来自 BluetoothDevice.name，iOS 可能来自 advName.
  /// Platform device name from Android BluetoothDevice.name or iOS advertisement name.
  final String platformName;
  final ElinkConnectionState connectionState;

  /// 从 manufacturerData 广播内容中解析出的设备 MAC 地址。
  /// Device MAC address parsed from manufacturerData advertisement content.
  final String macAddress;

  ElinkDevice copyWith({
    String? remoteId,
    String? platformName,
    ElinkConnectionState? connectionState,
    String? macAddress,
  }) {
    return ElinkDevice(
      remoteId: remoteId ?? this.remoteId,
      platformName: platformName ?? this.platformName,
      connectionState: connectionState ?? this.connectionState,
      macAddress: macAddress ?? this.macAddress,
    );
  }

  @override
  String toString() => 'ElinkDevice($remoteId, $platformName, $macAddress)';
}

/// BLE advertisement 数据，包含 service UUIDs 与 manufacturer data。
/// BLE advertisement data with service UUIDs and manufacturer data.
class ElinkAdvertisementData {
  const ElinkAdvertisementData({
    this.advName = '',
    this.serviceUuids = const <ElinkGuid>[],
    this.manufacturerData = const <int>[],
    this.identity = const ElinkBleData.empty(),
    this.raw = const <String, Object?>{},
  });

  final String advName;
  final List<ElinkGuid> serviceUuids;
  final List<int> manufacturerData;
  final ElinkBleData identity;
  final Map<String, Object?> raw;

  /// 从 manufacturerData 中解析出的 MAC 地址；无有效广播内容时为空字符串。
  /// MAC address parsed from manufacturerData; empty when no valid identity exists.
  String get macAddress {
    return identity.isEmpty ? '' : identity.macAddress;
  }

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
    final manufacturerData = ElinkByteUtils.bytesFrom(map['manufacturerData']);
    final isBroadcastDevice = serviceUuids.contains(ElinkGuid.broadcastDevice);
    final isConnectDevice = serviceUuids.contains(ElinkGuid.connectDevice);
    final identity = ElinkBleData.fromManufacturerData(
      manufacturerData,
      isBroadcastDevice: isBroadcastDevice && !isConnectDevice,
    );
    return ElinkAdvertisementData(
      advName: map['advName']?.toString() ?? '',
      serviceUuids: serviceUuids,
      manufacturerData: manufacturerData,
      identity: identity,
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
    final advertisementData = ElinkAdvertisementData.fromMap(
      map['advertisementData'] as Map?,
    );
    final nativeMacAddress = map['macAddress']?.toString() ?? '';
    final macAddress = advertisementData.macAddress.isNotEmpty
        ? advertisementData.macAddress
        : nativeMacAddress;
    return ElinkScanResult(
      device: ElinkDevice(
        remoteId: remoteId,
        platformName:
            map['platformName']?.toString() ?? map['advName']?.toString() ?? '',
        macAddress: macAddress,
      ),
      advertisementData: advertisementData,
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
  /// A6 协议数据。
  /// A6 protocol data.
  a6,

  /// A7 协议数据。
  /// A7 protocol data.
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
      data: Uint8List.fromList(ElinkByteUtils.bytesFrom(map['data'])),
      characteristicUuid: map['characteristicUuid']?.toString() ?? '',
      deviceType: (map['deviceType'] as num?)?.toInt(),
    );
  }
}

/// A6/A7 协议完整 frame 解析结果。
/// Parsed full A6/A7 protocol frame.
class ElinkProtocolFrame {
  ElinkProtocolFrame({
    required this.protocol,
    required List<int> payload,
    required this.checksum,
    required List<int> rawData,
    this.cid,
    List<int> cidBytes = const <int>[],
  }) : cidBytes = Uint8List.fromList(
         ElinkByteUtils.checkedBytes(cidBytes, 'cidBytes'),
       ),
       payload = Uint8List.fromList(
         ElinkByteUtils.checkedBytes(payload, 'payload'),
       ),
       rawData = Uint8List.fromList(
         ElinkByteUtils.checkedBytes(rawData, 'rawData'),
       ) {
    if (protocol == ElinkProtocolDataType.a7) {
      final value = cid;
      if (value == null) {
        throw ArgumentError.notNull('cid');
      }
      if (value < 0 || value > 0xffff) {
        throw RangeError.range(value, 0, 0xffff, 'cid');
      }
      if (this.cidBytes.length != 2) {
        throw ArgumentError.value(cidBytes, 'cidBytes', 'CID must be 2 bytes');
      }
    } else if (cid != null || this.cidBytes.isNotEmpty) {
      throw ArgumentError.value(cid, 'cid', 'A6 frame does not contain CID');
    }
    if (checksum < 0 || checksum > 0xff) {
      throw RangeError.range(checksum, 0, 0xff, 'checksum');
    }
  }

  /// 协议类型：A6 或 A7。
  /// Protocol type: A6 or A7.
  final ElinkProtocolDataType protocol;

  /// 产品类型 CID，按协议默认大端序解析。
  ///
  /// A6 frame 不包含 CID，因此为 null。
  /// Product CID parsed as big-endian.
  ///
  /// A6 frames do not contain CID, so this is null.
  final int? cid;

  /// CID 原始 2 字节。
  ///
  /// A6 frame 不包含 CID，因此为空。
  /// Raw 2-byte CID.
  ///
  /// A6 frames do not contain CID, so this is empty.
  final Uint8List cidBytes;

  /// A6/A7 payload 内容。
  /// A6/A7 payload content.
  final Uint8List payload;

  /// Frame 中携带的 checksum。
  /// Checksum byte carried by the frame.
  final int checksum;

  /// 原始完整 frame。
  /// Raw full frame.
  final Uint8List rawData;

  int get payloadLength => payload.length;

  @override
  String toString() {
    final cidText = cid == null
        ? 'null'
        : '0x${cid!.toRadixString(16).padLeft(4, '0')}';
    return 'ElinkProtocolFrame(protocol: ${protocol.name}, cid: $cidText, '
        'payloadLength: $payloadLength)';
  }
}

/// 通用 payload 数据。
/// Generic payload data.
///
/// 普通 payload 中 [type] 表示首字节类型，[data] 表示其余内容。
/// TLV payload 中 [type] 表示 T，[data] 表示 V。
///
/// In a plain payload, [type] is the first-byte type and [data] is the
/// remaining content. In a TLV payload, [type] is T and [data] is V.
class ElinkPayload {
  ElinkPayload({required int type, List<int> data = const <int>[]})
    : type = ElinkByteUtils.checkedByte(type, 'type'),
      data = Uint8List.fromList(
        ElinkByteUtils.checkedBytes(data, 'data', maxLength: 0xff),
      );

  /// 使用整数值构造 payload data，默认大端序匹配 ShowDoc 通信协议。
  /// Build payload data from an integer value. Big-endian by default.
  factory ElinkPayload.fromInt(
    int type,
    int data, {
    int length = 1,
    bool littleEndian = false,
  }) {
    return ElinkPayload(
      type: type,
      data: ElinkByteUtils.intToBytes(
        data,
        length: length,
        littleEndian: littleEndian,
      ),
    );
  }

  /// 普通 payload type 或 TLV T 字段，1 byte。
  /// Plain payload type or TLV T field, one byte.
  final int type;

  /// 普通 payload data 或 TLV V 字段。
  /// Plain payload data or TLV V field.
  final Uint8List data;

  /// data 长度；在 TLV 模式中等同于 L 字段。
  /// Data length; equal to the L field in TLV mode.
  int get length => data.length;

  /// 普通 payload 原始字节：type + data。
  /// Raw normal payload bytes: type + data.
  List<int> get bytes => <int>[type, ...data];

  /// TLV 原始字节：T + L + V。
  /// Raw TLV bytes: T + L + V.
  List<int> get tlvBytes => <int>[type, length, ...data];

  /// 从 data 字段读取无符号整数，默认大端序。
  /// Read an unsigned integer from data. Big-endian by default.
  int readInt({int offset = 0, int length = 1, bool littleEndian = false}) {
    if (length < 1 || length > 8) {
      throw RangeError.range(length, 1, 8, 'length');
    }
    final end = offset + length;
    if (offset < 0 || end > data.length) {
      throw RangeError(
        'offset $offset with length $length is outside payload data length '
        '${data.length}',
      );
    }
    return ElinkByteUtils.bytesToInt(
      data.sublist(offset, end),
      littleEndian: littleEndian,
    );
  }

  @override
  String toString() {
    return 'ElinkPayload(type: 0x${type.toRadixString(16).padLeft(2, '0')}, '
        'length: $length)';
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
      data: Uint8List.fromList(ElinkByteUtils.bytesFrom(map['data'])),
      characteristicUuid: map['characteristicUuid']?.toString() ?? '',
    );
  }
}

/// 底层特征值操作回调类型。
/// Characteristic low-level callback type.
enum ElinkCharacteristicOperation {
  /// 读取 characteristic 回调。
  /// Characteristic read callback.
  read,

  /// 写入 characteristic 回调。
  /// Characteristic write callback.
  write,

  /// 写入 descriptor 回调。
  /// Descriptor write callback.
  descriptorWrite,

  /// characteristic value changed 回调。
  /// Characteristic value changed callback.
  changed,

  /// notification 订阅状态变更回调。
  /// Notification state changed callback.
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
      data: Uint8List.fromList(ElinkByteUtils.bytesFrom(map['data'])),
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

/// iOS 当前连接设备的最大写入长度。
/// Current iOS maximum write lengths for a connected peripheral.
class ElinkIosMtu {
  /// 创建 iOS 最大写入长度结果。
  /// Create an iOS maximum write length result.
  const ElinkIosMtu({
    required this.remoteId,
    required this.maxWriteWithoutResponse,
    required this.maxWriteWithResponse,
  });

  final String remoteId;

  /// `.withoutResponse` 单次可写入的最大 payload 长度。
  /// Maximum payload length for one `.withoutResponse` write.
  final int maxWriteWithoutResponse;

  /// `.withResponse` 单次可写入的最大 payload 长度。
  /// Maximum payload length for one `.withResponse` write.
  final int maxWriteWithResponse;

  /// 从 native map 解析 iOS 最大写入长度。
  /// Parse iOS maximum write lengths from a native map.
  factory ElinkIosMtu.fromMap(Map<dynamic, dynamic> map) {
    return ElinkIosMtu(
      remoteId: map['remoteId']?.toString() ?? '',
      maxWriteWithoutResponse:
          (map['maxWriteWithoutResponse'] as num?)?.toInt() ?? 0,
      maxWriteWithResponse: (map['maxWriteWithResponse'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 原生 SDK handshake 回调事件。
/// Native SDK handshake callback event.
class ElinkHandshakeEvent {
  const ElinkHandshakeEvent({required this.remoteId, required this.success});

  final String remoteId;

  /// `true` 表示 handshake 成功。
  /// `true` means the handshake succeeded.
  final bool success;

  /// 从 native 事件 map 构建握手事件。
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
    required this.command,
    required this.rawPayload,
  });

  final String remoteId;

  /// native SDK 已解析出的 BM version。
  /// BM version parsed by the native SDK.
  final String version;

  /// BM 版本命令字，`0x0E` 表示旧版，`0x46` 表示新版。
  /// BM version command byte; `0x0E` means legacy and `0x46` means enhanced.
  final int command;

  /// 根据命令字判断是否为旧版 BM 版本回包。
  bool get isLegacyCommand => command == 0x0E;

  /// 根据命令字判断是否为新版 BM 版本回包。
  bool get isEnhancedCommand => command == 0x46;

  /// 根据命令字返回日志展示使用的新旧类型。
  String get versionKind {
    if (isLegacyCommand) return 'old';
    if (isEnhancedCommand) return 'new';
    return 'unknown';
  }

  /// 原始 A6 payload；native 仅回传版本字符串时只包含命令字节。
  /// Raw A6 payload; contains only the command byte when native only returns the parsed version.
  final Uint8List rawPayload;

  /// 从 native 事件 map 构建 BM 版本事件。
  factory ElinkBmVersionEvent.fromMap(Map<dynamic, dynamic> map) {
    final payload = map['rawPayload'];
    final rawPayload = payload is Uint8List
        ? payload
        : payload is List
        ? Uint8List.fromList(
            payload
                .whereType<num>()
                .map((value) => value.toInt() & 0xff)
                .toList(growable: false),
          )
        : null;
    final command =
        (map['command'] is num
            ? (map['command'] as num).toInt()
            : rawPayload == null || rawPayload.isEmpty
            ? 0x46
            : rawPayload.first) &
        0xff;
    return ElinkBmVersionEvent(
      remoteId: map['remoteId']?.toString() ?? '',
      version: map['version']?.toString() ?? '',
      command: command,
      rawPayload: rawPayload ?? Uint8List.fromList(<int>[command]),
    );
  }
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

  /// 创建空的广播设备标识。
  /// Create an empty advertisement identity.
  const ElinkBleData.empty()
    : cid = const <int>[0, 0],
      vid = const <int>[0, 0],
      pid = const <int>[0, 0],
      mac = const <int>[0, 0, 0, 0, 0, 0];

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

  /// 按 showdoc manufacturerData 规则解析 CID/VID/PID/MAC。
  ///
  /// [manufacturerData] is the BLE manufacturer data bytes (BLE 厂商自定义广播数据).
  ///
  /// [isBroadcastDevice] selects the legacy broadcast layout when company ID is absent (无 Company ID 时使用旧广播布局).
  static ElinkBleData fromManufacturerData(
    List<int> manufacturerData, {
    bool isBroadcastDevice = false,
  }) {
    final bytes = ElinkByteUtils.bytesFrom(manufacturerData);
    final cid = List<int>.filled(2, 0);
    final vid = List<int>.filled(2, 0);
    final pid = List<int>.filled(2, 0);
    final mac = List<int>.filled(6, 0);

    if (bytes.isEmpty) {
      return ElinkBleData(cid: cid, vid: vid, pid: pid, mac: mac);
    }

    if (bytes.length >= 14 && bytes[0] == 0x6E && bytes[1] == 0x49) {
      var start = 2;
      cid.setRange(0, 2, bytes.sublist(start, start += 2));
      vid.setRange(0, 2, bytes.sublist(start, start += 2));
      pid.setRange(0, 2, bytes.sublist(start, start += 2));
      mac.setRange(0, 6, bytes.sublist(start, start + 6));
    } else if (isBroadcastDevice && bytes.length >= 3) {
      var start = 0;
      cid[1] = bytes[start++];
      vid[1] = bytes[start++];
      pid[1] = bytes[start++];
      if (bytes.length >= 9) {
        mac.setRange(0, mac.length, bytes.sublist(start, start + 6));
      }
    }

    return ElinkBleData(cid: cid, vid: vid, pid: pid, mac: mac);
  }

  static int _twoByteValue(List<int> bytes) {
    if (bytes.length != 2) {
      return 0;
    }
    return ElinkByteUtils.bytesToInt(bytes);
  }

  static String _littleEndianMac(List<int> bytes) {
    return ElinkByteUtils.formatMac(bytes, littleEndian: true);
  }
}
