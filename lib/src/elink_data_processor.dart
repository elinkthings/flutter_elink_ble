import 'dart:typed_data';

import '../flutter_elink_ble_platform_interface.dart';
import 'elink_models.dart';

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
    final cid = List<int>.filled(2, 0);
    final vid = List<int>.filled(2, 0);
    final pid = List<int>.filled(2, 0);
    final mac = List<int>.filled(6, 0);
    final length = manufacturerData.length;

    if (manufacturerData.isEmpty) {
      return ElinkBleData(cid: cid, vid: vid, pid: pid, mac: mac);
    }

    if (isBroadcastDevice && length >= 3) {
      var start = 0;
      cid[1] = manufacturerData[start++];
      vid[1] = manufacturerData[start++];
      pid[1] = manufacturerData[start++];
      if (length >= 10) {
        mac.setRange(0, mac.length, manufacturerData.sublist(start, start + 6));
      }
    } else if (length >= 14 &&
        manufacturerData[0] == 0x6E &&
        manufacturerData[1] == 0x49) {
      var start = 2;
      cid.setRange(0, 2, manufacturerData.sublist(start, start += 2));
      vid.setRange(0, 2, manufacturerData.sublist(start, start += 2));
      pid.setRange(0, 2, manufacturerData.sublist(start, start += 2));
      mac.setRange(0, 6, manufacturerData.sublist(start, start + 6));
    }

    return ElinkBleData(cid: cid, vid: vid, pid: pid, mac: mac);
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
  static Future<Uint8List?> initHandshake() {
    return _platform.initHandshake();
  }

  /// 根据设备下发的 handshake command 生成加密回复。
  /// Build encrypted handshake response for the device command.
  static Future<Uint8List?> getHandshakeEncryptData(List<int> payload) {
    return _platform.getHandshakeEncryptData(Uint8List.fromList(payload));
  }

  /// 检查 handshake 是否完成。
  /// Check whether handshake is complete.
  static Future<bool> checkHandshakeStatus(List<int> payload) {
    return _platform.checkHandshakeStatus(Uint8List.fromList(payload));
  }

  /// 生成获取 BM 模块版本的 A6 payload。
  /// Build the A6 payload for querying the BM module version.
  static List<int> getBmVersionPayload() {
    return const <int>[getBmVersionCommand];
  }

  /// 生成获取 BM 模块版本的完整 A6 packet，主要用于日志显示。
  /// Build the full A6 packet for querying BM version, mostly for logging.
  static List<int> getBmVersionPacket() {
    return wrapA6Data(getBmVersionPayload());
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
  static List<int> wrapA6Data(List<int> payload) {
    final mutablePayload = <int>[payload.length, ...payload];
    return <int>[a6Start, ...mutablePayload, checksum(mutablePayload), a6End];
  }

  /// 包装 A7 加密数据帧。
  /// Wrap encrypted payload into an A7 frame.
  static List<int> wrapA7Data(List<int> cid, List<int> encryptedPayload) {
    final mutablePayload = <int>[
      ...cid,
      encryptedPayload.length,
      ...encryptedPayload,
    ];
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

  /// 是否为合法 A6 packet.
  /// Whether the data is a valid A6 packet.
  static bool isA6Packet(List<int> data) {
    return data.length >= 4 &&
        data.first == a6Start &&
        data.last == a6End &&
        hasValidChecksum(data);
  }

  /// 是否为合法 A7 packet.
  /// Whether the data is a valid A7 packet.
  static bool isA7Packet(List<int> data) {
    return data.length >= 6 &&
        data.first == a7Start &&
        data.last == a7End &&
        hasValidChecksum(data);
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
  static List<int> unwrapA6Data(List<int> data) {
    if (!isA6Packet(data)) {
      return const <int>[];
    }
    final length = data[1] & 0xff;
    final end = 2 + length;
    if (data.length < end) {
      return const <int>[];
    }
    return data.sublist(2, end);
  }

  /// 兼容 SDK 回调：如果是完整 A6 packet 则拆 payload，否则视为 payload。
  /// Normalize SDK callbacks: unwrap full A6 packets, otherwise treat input as payload.
  static List<int> normalizeA6Payload(List<int> data) {
    if (isA6Packet(data)) {
      return unwrapA6Data(data);
    }
    if (data.length > 1 && data[0] == a6Start && data[1] == a6Start) {
      final withoutExtraHead = data.sublist(1);
      if (isA6Packet(withoutExtraHead)) {
        return unwrapA6Data(withoutExtraHead);
      }
    }
    return data.toList(growable: false);
  }

  /// 去掉 A7 frame header/CID/checksum/end，返回 encrypted payload。
  /// Remove A7 frame header, CID, checksum, and end byte; return encrypted payload.
  static List<int> unwrapA7Data(List<int> data) {
    if (!isA7Packet(data)) {
      return const <int>[];
    }
    final length = data[3] & 0xff;
    final end = 4 + length;
    if (data.length < end) {
      return const <int>[];
    }
    return data.sublist(4, end);
  }

  /// int 转 bytes，默认 little-endian，适配 Elink payload 常见字段。
  /// Convert int to bytes; defaults to little-endian for common Elink payload fields.
  static List<int> intToBytes(
    int value, {
    int length = 4,
    bool littleEndian = true,
  }) {
    final bytes = <int>[];
    if (littleEndian) {
      for (var i = 0; i < length; i++) {
        bytes.add((value >> (i * 8)) & 0xff);
      }
    } else {
      for (var i = length - 1; i >= 0; i--) {
        bytes.add((value >> (i * 8)) & 0xff);
      }
    }
    return bytes;
  }
}
