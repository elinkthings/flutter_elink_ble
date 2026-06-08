/// Utility methods for formatting values in the example app (示例 App 格式化工具方法).
class ExampleTimeUtils {
  /// Prevent instantiating this utility class (禁止实例化工具类).
  ExampleTimeUtils._();

  /// Format a timestamp for compact logs (格式化紧凑日志时间戳).
  static String formatTimestamp(DateTime time) {
    return '${_twoDigits(time.hour)}:'
        '${_twoDigits(time.minute)}:'
        '${_twoDigits(time.second)}';
  }

  /// Format one integer as a two-digit decimal string (将整数格式化为两位十进制字符串).
  static String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}
