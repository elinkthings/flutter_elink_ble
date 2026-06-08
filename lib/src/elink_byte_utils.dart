import 'dart:typed_data';

/// Byte conversion helpers shared by protocol parsing and model decoding (二进制数据转换工具，供协议解析和模型解码共用).
class ElinkByteUtils {
  /// Prevent instantiating this utility class (禁止实例化工具类).
  const ElinkByteUtils._();

  /// Normalize a native byte payload into `List<int>` (将 native 返回的 byte payload 统一转成 `List<int>`).
  ///
  /// [value] accepts `Uint8List` or regular `List<num>`; other types return an empty list (支持 `Uint8List` 或普通 `List<num>`；其他类型返回空列表).
  static List<int> bytesFrom(Object? value) {
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

  /// Validate one byte value and return a value in the 0-255 range (校验单个 byte 值并返回 0-255 范围内的结果).
  ///
  /// [value] is the integer to validate; a [RangeError] is thrown when it is outside the byte range (待校验的整数；超出 byte 范围会抛出 [RangeError]).
  ///
  /// [name] is used as the argument name in error messages (用于错误信息中的参数名).
  static int checkedByte(int value, String name) {
    if (value < 0 || value > 0xff) {
      throw RangeError.range(value, 0, 0xff, name);
    }
    return value & 0xff;
  }

  /// Validate a byte list; optional [maxLength] limits protocol field length (校验 byte list；可选 [maxLength] 用于限制协议字段长度).
  ///
  /// [value] is the byte list to validate (待校验的 byte list).
  ///
  /// [name] is used as the argument name in error messages (用于错误信息中的参数名).
  ///
  /// [maxLength] is the maximum allowed length; `null` means no length limit (最大允许长度；为 `null` 时不限制长度).
  static List<int> checkedBytes(
    List<int> value,
    String name, {
    int? maxLength,
  }) {
    if (maxLength != null && value.length > maxLength) {
      throw RangeError.range(value.length, 0, maxLength, '$name.length');
    }
    return value.map((byte) => checkedByte(byte, name)).toList(growable: false);
  }

  /// Convert bytes to an unsigned integer. Big-endian is the default for protocol fields (bytes 转无符号整数，默认大端序以匹配通信协议字段).
  ///
  /// [bytes] is the byte list to convert (待转换的 byte list).
  ///
  /// [littleEndian] parses bytes as little-endian when `true` (为 `true` 时按 little-endian 解析).
  static int bytesToInt(List<int> bytes, {bool littleEndian = false}) {
    final checkedBytes = ElinkByteUtils.checkedBytes(bytes, 'bytes');
    var value = 0;
    if (littleEndian) {
      for (var i = 0; i < checkedBytes.length; i++) {
        value |= checkedBytes[i] << (i * 8);
      }
      return value;
    }
    for (final byte in checkedBytes) {
      value = (value << 8) | byte;
    }
    return value;
  }

  /// Convert an unsigned integer to bytes. Little-endian is the default for common Elink payload fields (无符号整数转 bytes，默认 little-endian 以适配 Elink payload 常见字段).
  ///
  /// [value] is the unsigned integer to convert (待转换的无符号整数).
  ///
  /// [length] is the output byte length, from 1 to 8 (输出 byte 长度，范围为 1 到 8).
  ///
  /// [littleEndian] emits big-endian bytes when `false` (为 `false` 时输出 big-endian).
  static List<int> intToBytes(
    int value, {
    int length = 4,
    bool littleEndian = true,
  }) {
    if (length < 1 || length > 8) {
      throw RangeError.range(length, 1, 8, 'length');
    }
    final maxValue = 1 << (length * 8);
    if (value < 0 || value >= maxValue) {
      throw RangeError.range(value, 0, maxValue - 1, 'value');
    }
    final bytes = List<int>.filled(length, 0);
    for (var i = 0; i < length; i++) {
      final shift = littleEndian ? i * 8 : (length - 1 - i) * 8;
      bytes[i] = (value >> shift) & 0xff;
    }
    return bytes;
  }

  /// Format bytes as uppercase hex text (格式化二进制数据为大写 hex 文本).
  ///
  /// [bytes] is the data to format (待格式化的数据).
  ///
  /// [separator] is inserted between formatted bytes (每个 byte 之间的分隔符).
  static String formatHex(Iterable<int> bytes, {String separator = ' '}) {
    return bytes.map(_hexByte).join(separator).toUpperCase();
  }

  /// Format MAC bytes as uppercase colon-separated text (将 MAC byte list 格式化成大写冒号分隔文本).
  ///
  /// [bytes] is the MAC byte sequence (MAC byte 序列).
  ///
  /// [littleEndian] reverses the byte order before formatting when `true` (为 `true` 时会先反转 byte 顺序).
  static String formatMac(Iterable<int> bytes, {bool littleEndian = false}) {
    final orderedBytes = littleEndian ? bytes.toList().reversed : bytes;
    return orderedBytes.map(_hexByte).join(':').toUpperCase();
  }

  /// Format one byte as two hex digits (将单个 byte 格式化成两位 hex).
  ///
  /// [byte] is the byte value to format (待格式化的 byte 值).
  static String _hexByte(int byte) {
    return (byte & 0xff).toRadixString(16).padLeft(2, '0');
  }
}
