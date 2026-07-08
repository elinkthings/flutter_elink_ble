import Foundation

/// Native 插件日志工具，统一 Flutter 开关、日志级别和二进制格式化。
final class ElinkNativeLogger {
  private static var eventHandler: ((String, String, Int64) -> Void)?

  /// 设置 native 日志事件回调，日志由 Flutter 侧统一输出和入库。
  static func setEventHandler(_ handler: ((String, String, Int64) -> Void)?) {
    eventHandler = handler
  }

  /// 输出 Debug 级别日志。
  static func debug(_ message: String) {
    log(level: "D", message)
  }

  /// 输出 Info 级别日志。
  static func info(_ message: String) {
    log(level: "I", message)
  }

  /// 输出 Warning 级别日志。
  static func warning(_ message: String) {
    log(level: "W", message)
  }

  /// 输出 Error 级别日志。
  static func error(_ message: String) {
    log(level: "E", message)
  }

  /// 将二进制 payload 转成便于排查协议问题的十六进制文本。
  static func hex(_ data: Data) -> String {
    return data.map { String(format: "%02X", $0) }.joined(separator: " ")
  }

  /// 按指定级别发送日志事件。
  private static func log(level: String, _ message: String) {
    let timestampMs = Int64(Date().timeIntervalSince1970 * 1000)
    eventHandler?(level, message, timestampMs)
  }
}
