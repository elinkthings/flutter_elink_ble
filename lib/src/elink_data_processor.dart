import 'dart:typed_data';

import '../flutter_elink_ble_platform_interface.dart';
import 'elink_byte_utils.dart';
import 'elink_ble_models.dart';

/// Elink 协议数据处理工具。
/// Elink protocol data helper.
///
/// 这里只处理 packet framing、checksum、广播解析和加解密桥接；BLE scan/connect
/// 生命周期由 [ElinkBle] 管理。
/// This class only handles packet framing, checksum, advertisement parsing,
/// and encryption/decryption bridges. BLE lifecycle is managed by [ElinkBle].
class ElinkDataProcessor {
  const ElinkDataProcessor._();

  static const int a6Start = 0xA6;
  static const int a6End = 0x6A;
  static const int a7Start = 0xA7;
  static const int a7End = 0x7A;
  static const int setHandshake = 0x23;
  static const int getHandshake = 0x24;
  static const int getBmVersionCommand = 0x0E;

  static FlutterElinkBlePlatform get _platform {
    return FlutterElinkBlePlatform.instance;
  }

  /// 解析 manufacturerData 中的 CID/VID/PID/MAC。
  /// Parse CID, VID, PID, and MAC from manufacturerData.
  ///
  /// Broadcast device (`F0A0`) 与 connect device (`FFE0`) 的 payload layout
  /// 不同，因此通过 [isBroadcastDevice] 选择解析路径。
  /// Broadcast device (`F0A0`) and connect device (`FFE0`) use different
  /// payload layouts, so [isBroadcastDevice] selects the parser path.
  static ElinkBleData parseAdvertisement(
    List<int> manufacturerData, {
    bool isBroadcastDevice = false,
  }) {
    return ElinkBleData.fromManufacturerData(
      manufacturerData,
      isBroadcastDevice: isBroadcastDevice,
    );
  }

  /// 将 Android `manufacturerSpecificData` map 展平成 iOS/Dart 相同的 byte list。
  /// Flatten Android `manufacturerSpecificData` map into the same byte list used by iOS/Dart.
  static List<int> manufacturerDataFromMap(Map<int, List<int>> data) {
    return data.entries
        .expand((entry) {
          return <int>[...intToBytes(entry.key, length: 2), ...entry.value];
        })
        .toList(growable: false);
  }

  /// 解密 broadcast payload，实际算法由 native Elink SDK 提供。
  /// Decrypt broadcast payload through the native Elink SDK.
  static Future<Uint8List?> decryptBroadcast(List<int> payload) {
    return _platform.decryptBroadcast(Uint8List.fromList(payload));
  }

  /// 生成 handshake 首包。
  /// Build the initial handshake packet.
  static Future<Uint8List?> initHandshake({String? remoteId}) {
    return _platform.initHandshake(remoteId: remoteId);
  }

  /// 根据设备下发的 handshake command 生成加密回复。
  /// Build encrypted handshake response for the device command.
  static Future<Uint8List?> getHandshakeEncryptData(
    List<int> payload, {
    String? remoteId,
  }) {
    return _platform.getHandshakeEncryptData(
      Uint8List.fromList(payload),
      remoteId: remoteId,
    );
  }

  /// 检查 handshake 是否完成。
  /// Check whether handshake is complete.
  static Future<bool> checkHandshakeStatus(
    List<int> payload, {
    String? remoteId,
  }) {
    return _platform.checkHandshakeStatus(
      Uint8List.fromList(payload),
      remoteId: remoteId,
    );
  }

  /// 生成获取 BM 模块版本的 A6 payload。
  /// Build the A6 payload for querying the BM module version.
  static List<int> getBmVersionPayload() {
    return const <int>[getBmVersionCommand];
  }

  /// 生成获取 BM 模块版本的完整 A6 packet，主要用于日志显示。
  /// Build the full A6 packet for querying BM version, mostly for logging.
  static List<int> getBmVersionPacket() {
    return wrapA6Frame(getBmVersionPayload());
  }

  /// 解析 BM 模块版本回包；入参可为完整 A6 packet 或 A6 payload。
  /// Parse a BM version response from either a full A6 packet or an A6 payload.
  static String? parseBmVersion(List<int> data) {
    final payload = normalizeA6Payload(data);
    if (payload.length < 10 || payload[0] != getBmVersionCommand) {
      return null;
    }
    final name = String.fromCharCodes([payload[1], payload[2]]);
    final model = (payload[3] & 0xff).toString().padLeft(2, '0');
    final hardware = payload[4] & 0xff;
    final software = ((payload[5] & 0xff) / 10.0).toStringAsFixed(1);
    final custom = payload[6] & 0xff;
    final year = (payload[7] & 0xff) + 2000;
    final month = (payload[8] & 0xff).toString().padLeft(2, '0');
    final day = (payload[9] & 0xff).toString().padLeft(2, '0');
    return '$name${model}H${hardware}S$software.$custom'
        '_$year$month$day';
  }

  /// 将 CID int 转为协议使用的 2-byte 大端序。
  /// Convert a CID int to the 2-byte big-endian protocol representation.
  static List<int> cidToBytes(int cid) {
    return intToBytes(cid, length: 2, littleEndian: false);
  }

  /// 将协议中的 2-byte CID 转为 int，默认大端序。
  /// Convert a 2-byte protocol CID to int. Big-endian by default.
  static int cidFromBytes(List<int> cid) {
    if (cid.length != 2) {
      throw ArgumentError.value(cid, 'cid', 'CID must contain exactly 2 bytes');
    }
    return bytesToInt(cid, littleEndian: false);
  }

  /// 解析完整 A6 frame。
  /// Parse a full A6 frame.
  ///
  /// A6 格式：0xA6 + payloadLength(1) + payload(n) + checksum + 0x6A。
  /// A6 format: 0xA6 + payloadLength(1) + payload(n) + checksum + 0x6A.
  static ElinkProtocolFrame parseA6Frame(List<int> data) {
    final packet = ElinkByteUtils.checkedBytes(data, 'data');
    if (packet.length < 4) {
      throw FormatException('A6 frame must contain at least 4 bytes', data);
    }
    if (packet.first != a6Start || packet.last != a6End) {
      throw FormatException('Invalid A6 frame header or tail', data);
    }
    final payloadLength = packet[1] & 0xff;
    final expectedLength = payloadLength + 4;
    if (packet.length != expectedLength) {
      throw FormatException(
        'A6 payload length mismatch: expected $expectedLength bytes, '
        'got ${packet.length}',
        data,
      );
    }
    if (!hasValidChecksum(packet)) {
      throw FormatException('Invalid A6 checksum', data);
    }
    return ElinkProtocolFrame(
      protocol: ElinkProtocolDataType.a6,
      payload: packet.sublist(2, 2 + payloadLength),
      checksum: packet[packet.length - 2] & 0xff,
      rawData: packet,
    );
  }

  /// 尝试解析完整 A6 frame；无效时返回 null。
  /// Try to parse a full A6 frame and return null when invalid.
  static ElinkProtocolFrame? tryParseA6Frame(List<int> data) {
    try {
      return parseA6Frame(data);
    } on Object {
      return null;
    }
  }

  /// 解析完整 A7 frame。
  /// Parse a full A7 frame.
  ///
  /// A7 格式：0xA7 + CID(2) + payloadLength(1) + payload(n) + checksum + 0x7A。
  /// A7 format: 0xA7 + CID(2) + payloadLength(1) + payload(n) + checksum + 0x7A.
  static ElinkProtocolFrame parseA7Frame(List<int> data) {
    final packet = ElinkByteUtils.checkedBytes(data, 'data');
    if (packet.length < 6) {
      throw FormatException('A7 frame must contain at least 6 bytes', data);
    }
    if (packet.first != a7Start || packet.last != a7End) {
      throw FormatException('Invalid A7 frame header or tail', data);
    }
    final payloadLength = packet[3] & 0xff;
    final expectedLength = payloadLength + 6;
    if (packet.length != expectedLength) {
      throw FormatException(
        'A7 payload length mismatch: expected $expectedLength bytes, '
        'got ${packet.length}',
        data,
      );
    }
    if (!hasValidChecksum(packet)) {
      throw FormatException('Invalid A7 checksum', data);
    }
    final cidBytes = packet.sublist(1, 3);
    return ElinkProtocolFrame(
      protocol: ElinkProtocolDataType.a7,
      cid: cidFromBytes(cidBytes),
      cidBytes: cidBytes,
      payload: packet.sublist(4, 4 + payloadLength),
      checksum: packet[packet.length - 2] & 0xff,
      rawData: packet,
    );
  }

  /// 尝试解析完整 A7 frame；无效时返回 null。
  /// Try to parse a full A7 frame and return null when invalid.
  static ElinkProtocolFrame? tryParseA7Frame(List<int> data) {
    try {
      return parseA7Frame(data);
    } on Object {
      return null;
    }
  }

  /// 解析完整 A6/A7 frame。
  /// Parse a full A6/A7 frame.
  static ElinkProtocolFrame parseProtocolFrame(List<int> data) {
    if (data.isEmpty) {
      throw FormatException('Protocol frame is empty', data);
    }
    switch (data.first) {
      case a6Start:
        return parseA6Frame(data);
      case a7Start:
        return parseA7Frame(data);
      default:
        throw FormatException('Unsupported protocol frame header', data);
    }
  }

  /// 尝试解析完整 A6/A7 frame；无效时返回 null。
  /// Try to parse a full A6/A7 frame and return null when invalid.
  static ElinkProtocolFrame? tryParseProtocolFrame(List<int> data) {
    try {
      return parseProtocolFrame(data);
    } on Object {
      return null;
    }
  }

  /// 将 A7 payload 组成完整 frame。
  /// Wrap an A7 payload into a full frame.
  static List<int> wrapA7Frame({required int cid, required List<int> payload}) {
    return wrapA7Data(cidToBytes(cid), payload);
  }

  /// 解析普通 payload：首字节为 type，后续字节为 data。
  /// Parse a plain payload: first byte is type, remaining bytes are data.
  static ElinkPayload parsePlainPayload(List<int> payload) {
    final bytes = ElinkByteUtils.checkedBytes(payload, 'payload');
    if (bytes.isEmpty) {
      throw FormatException('Payload is empty', payload);
    }
    return ElinkPayload(type: bytes.first, data: bytes.sublist(1));
  }

  /// 尝试解析普通 payload；空 payload 或格式无效时返回 null。
  /// Try to parse a plain payload and return null when empty or malformed.
  static ElinkPayload? tryParsePlainPayload(List<int> payload) {
    try {
      return parsePlainPayload(payload);
    } on Object {
      return null;
    }
  }

  /// 按配置解析 payload。默认按 type + data 解析，开启后按 TLV 解析。
  /// Parse a payload. Defaults to type + data; TLV is opt-in.
  static List<ElinkPayload> parsePayload(
    List<int> payload, {
    bool parseTlv = false,
  }) {
    if (parseTlv) {
      return parseTlvPayload(payload);
    }
    if (payload.isEmpty) {
      return const <ElinkPayload>[];
    }
    return <ElinkPayload>[parsePlainPayload(payload)];
  }

  /// 尝试按配置解析 payload；格式无效时返回 null。
  /// Try to parse a payload and return null when malformed.
  static List<ElinkPayload>? tryParsePayload(
    List<int> payload, {
    bool parseTlv = false,
  }) {
    try {
      return parsePayload(payload, parseTlv: parseTlv);
    } on Object {
      return null;
    }
  }

  /// 解析 TLV payload，支持一个 payload 内包含多个 TLV。
  /// Parse a TLV payload. Multiple TLVs in one payload are supported.
  ///
  /// TLV 格式：T(1) + L(1) + V(n)。数据不完整时抛出 [FormatException]。
  /// TLV format: T(1) + L(1) + V(n). Throws [FormatException] when malformed.
  static List<ElinkPayload> parseTlvPayload(List<int> payload) {
    final bytes = ElinkByteUtils.checkedBytes(payload, 'payload');
    final tlvs = <ElinkPayload>[];
    var offset = 0;
    while (offset < bytes.length) {
      if (offset + 2 > bytes.length) {
        throw FormatException(
          'Incomplete TLV header at offset $offset',
          payload,
        );
      }
      final type = bytes[offset] & 0xff;
      final length = bytes[offset + 1] & 0xff;
      final dataStart = offset + 2;
      final dataEnd = dataStart + length;
      if (dataEnd > bytes.length) {
        throw FormatException(
          'TLV length exceeds payload at offset $offset',
          payload,
        );
      }
      tlvs.add(
        ElinkPayload(type: type, data: bytes.sublist(dataStart, dataEnd)),
      );
      offset = dataEnd;
    }
    return List<ElinkPayload>.unmodifiable(tlvs);
  }

  /// 尝试解析 TLV payload；格式无效时返回 null。
  /// Try to parse a TLV payload and return null when malformed.
  static List<ElinkPayload>? tryParseTlvPayload(List<int> payload) {
    try {
      return parseTlvPayload(payload);
    } on Object {
      return null;
    }
  }

  /// 构造单个 TLV。
  /// Build a single TLV.
  static ElinkPayload buildTlvEntry(int type, List<int> data) {
    return ElinkPayload(type: type, data: data);
  }

  /// 将多个 TLV 拼成 A7 payload。
  /// Build an A7 payload from multiple TLVs.
  static List<int> buildTlvPayload(Iterable<ElinkPayload> tlvs) {
    final payload = <int>[];
    for (final tlv in tlvs) {
      payload.addAll(tlv.tlvBytes);
      if (payload.length > 0xff) {
        throw RangeError.range(payload.length, 0, 0xff, 'payload.length');
      }
    }
    return payload;
  }

  /// 将 TLV 列表按最大 payload 长度拆成多个完整 A7 payload。
  /// Split TLVs into complete A7 payload chunks by max payload length.
  ///
  /// 单个 TLV 超过 [maxPayloadLength] 时不会拆分该 TLV，而是单独组成一个 payload。
  /// If one TLV exceeds [maxPayloadLength], it is kept whole in its own payload.
  static List<List<int>> buildTlvPayloadChunks(
    List<ElinkPayload> tlvs, {
    required int maxPayloadLength,
  }) {
    if (tlvs.isEmpty) {
      return const <List<int>>[];
    }
    final safeMaxLength = maxPayloadLength > 0 ? maxPayloadLength : 1;
    final chunks = <List<int>>[];
    var current = <ElinkPayload>[];
    var currentLength = 0;
    for (final tlv in tlvs) {
      final tlvLength = tlv.tlvBytes.length;
      if (current.isNotEmpty && currentLength + tlvLength > safeMaxLength) {
        chunks.add(buildTlvPayload(current));
        current = <ElinkPayload>[];
        currentLength = 0;
      }
      current.add(tlv);
      currentLength += tlvLength;
    }
    if (current.isNotEmpty) {
      chunks.add(buildTlvPayload(current));
    }
    return chunks;
  }

  /// 将多个 TLV 组成完整 A7 frame。
  /// Wrap multiple TLVs into a full A7 frame.
  static List<int> wrapA7TlvFrame({
    required int cid,
    required Iterable<ElinkPayload> tlvs,
  }) {
    return wrapA7Frame(cid: cid, payload: buildTlvPayload(tlvs));
  }

  /// 构造 A7 加密业务包：先 native encrypt，再 wrap 成 A7 frame.
  /// Build encrypted A7 business packet: native encrypt first, then wrap as A7 frame.
  static Future<List<int>> buildA7Packet({
    required List<int> cid,
    required List<int> mac,
    required List<int> payload,
  }) async {
    final encrypted = await _platform.mcuEncrypt(
      cid: Uint8List.fromList(cid),
      mac: Uint8List.fromList(mac),
      payload: Uint8List.fromList(payload),
    );
    return wrapA7Data(cid, encrypted ?? Uint8List(0));
  }

  /// 解密 A7 packet payload.
  /// Decrypt A7 packet payload.
  static Future<Uint8List?> decryptA7Packet({
    required List<int> mac,
    required List<int> packet,
  }) {
    return _platform.mcuDecrypt(
      mac: Uint8List.fromList(mac),
      payload: Uint8List.fromList(packet),
    );
  }

  /// 包装 A6 明文数据帧。
  /// Wrap plaintext payload into an A6 frame.
  static List<int> wrapA6Frame(List<int> payload) {
    final mutablePayload = <int>[payload.length, ...payload];
    return <int>[a6Start, ...mutablePayload, checksum(mutablePayload), a6End];
  }

  /// 包装 A6 明文数据帧。
  /// Wrap plaintext payload into an A6 frame.
  static List<int> wrapA6Data(List<int> payload) {
    return wrapA6Frame(payload);
  }

  /// 包装 A7 加密数据帧。
  /// Wrap encrypted payload into an A7 frame.
  static List<int> wrapA7Data(List<int> cid, List<int> encryptedPayload) {
    final cidBytes = ElinkByteUtils.checkedBytes(cid, 'cid');
    if (cidBytes.length != 2) {
      throw ArgumentError.value(cid, 'cid', 'CID must contain exactly 2 bytes');
    }
    final payload = ElinkByteUtils.checkedBytes(
      encryptedPayload,
      'encryptedPayload',
    );
    if (payload.length > 0xff) {
      throw RangeError.range(payload.length, 0, 0xff, 'payload.length');
    }
    final mutablePayload = <int>[...cidBytes, payload.length, ...payload];
    return <int>[a7Start, ...mutablePayload, checksum(mutablePayload), a7End];
  }

  /// Elink checksum: payload bytes 累加后取低 8 bit.
  /// Elink checksum: sum payload bytes and keep the low 8 bits.
  static int checksum(List<int> payload) {
    return payload.fold<int>(0, (sum, byte) => sum + byte) & 0xff;
  }

  /// 校验 packet checksum，packet 需包含 start/checksum/end.
  /// Validate packet checksum; packet must include start, checksum, and end bytes.
  static bool hasValidChecksum(List<int> packet) {
    if (packet.length < 4) {
      return false;
    }
    return checksum(packet.sublist(1, packet.length - 2)) ==
        (packet[packet.length - 2] & 0xff);
  }

  /// 格式化二进制数据。
  /// Format bytes as uppercase hex text.
  static String formatHex(Iterable<int> bytes) {
    return ElinkByteUtils.formatHex(bytes);
  }

  /// 是否为合法 A6 packet.
  /// Whether the data is a valid A6 packet.
  static bool isA6Packet(List<int> data) {
    return isA6Frame(data);
  }

  /// 是否为合法 A6 frame.
  /// Whether the data is a valid A6 frame.
  static bool isA6Frame(List<int> data) {
    return tryParseA6Frame(data) != null;
  }

  /// 是否为合法 A7 packet.
  /// Whether the data is a valid A7 packet.
  static bool isA7Packet(List<int> data) {
    return isA7Frame(data);
  }

  /// 是否为合法 A7 frame.
  /// Whether the data is a valid A7 frame.
  static bool isA7Frame(List<int> data) {
    return tryParseA7Frame(data) != null;
  }

  /// 是否为合法 A6/A7 frame.
  /// Whether the data is a valid A6/A7 frame.
  static bool isProtocolFrame(List<int> data) {
    return tryParseProtocolFrame(data) != null;
  }

  /// 是否为 set-handshake command (`0x23`).
  /// Whether the data is a set-handshake command (`0x23`).
  static bool isSetHandshakeCommand(List<int> data) {
    return data.length > 2 && data[0] == a6Start && data[2] == setHandshake;
  }

  /// 是否为 get-handshake command (`0x24`).
  /// Whether the data is a get-handshake command (`0x24`).
  static bool isGetHandshakeCommand(List<int> data) {
    return data.length > 2 && data[0] == a6Start && data[2] == getHandshake;
  }

  /// 去掉 A6 frame header/checksum/end，返回业务 payload。
  /// Remove A6 frame header, checksum, and end byte; return business payload.
  static List<int> unwrapA6Frame(List<int> data) {
    return tryParseA6Frame(data)?.payload.toList(growable: false) ??
        const <int>[];
  }

  /// 去掉 A6 frame header/checksum/end，返回业务 payload。
  /// Remove A6 frame header, checksum, and end byte; return business payload.
  static List<int> unwrapA6Data(List<int> data) {
    return unwrapA6Frame(data);
  }

  /// 兼容 SDK 回调：如果是完整 A6 packet 则拆 payload，否则视为 payload。
  /// Normalize SDK callbacks: unwrap full A6 packets, otherwise treat input as payload.
  static List<int> normalizeA6Payload(List<int> data) {
    if (isA6Packet(data)) {
      return unwrapA6Frame(data);
    }
    if (data.length > 1 && data[0] == a6Start && data[1] == a6Start) {
      final withoutExtraHead = data.sublist(1);
      if (isA6Packet(withoutExtraHead)) {
        return unwrapA6Frame(withoutExtraHead);
      }
    }
    return data.toList(growable: false);
  }

  /// 去掉 A7 frame header/CID/checksum/end，返回 encrypted payload。
  /// Remove A7 frame header, CID, checksum, and end byte; return encrypted payload.
  static List<int> unwrapA7Frame(List<int> data) {
    return tryParseA7Frame(data)?.payload.toList(growable: false) ??
        const <int>[];
  }

  /// 去掉 A7 frame header/CID/checksum/end，返回 encrypted payload。
  /// Remove A7 frame header, CID, checksum, and end byte; return encrypted payload.
  static List<int> unwrapA7Data(List<int> data) {
    return unwrapA7Frame(data);
  }

  /// bytes 转 int，默认大端序以匹配通信协议字段。
  /// Convert bytes to int. Big-endian by default for protocol fields.
  static int bytesToInt(List<int> bytes, {bool littleEndian = false}) {
    return ElinkByteUtils.bytesToInt(bytes, littleEndian: littleEndian);
  }

  /// int 转 bytes，默认 little-endian，适配 Elink payload 常见字段。
  /// Convert int to bytes; defaults to little-endian for common Elink payload fields.
  static List<int> intToBytes(
    int value, {
    int length = 4,
    bool littleEndian = true,
  }) {
    return ElinkByteUtils.intToBytes(
      value,
      length: length,
      littleEndian: littleEndian,
    );
  }
}
