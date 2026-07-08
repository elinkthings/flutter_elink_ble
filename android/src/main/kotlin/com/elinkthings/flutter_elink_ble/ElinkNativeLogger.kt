package com.elinkthings.flutter_elink_ble

import java.util.Locale

/**
 * Native 插件日志工具，统一 Android 日志级别、事件上报和二进制格式化。
 */
internal object ElinkNativeLogger {
    private var eventHandler: ((String, String, Long) -> Unit)? = null

    /**
     * 设置 native 日志事件回调，日志由 Flutter 侧统一输出和入库。
     */
    fun setEventHandler(handler: ((String, String, Long) -> Unit)?) {
        eventHandler = handler
    }

    /**
     * 输出 Debug 级别日志。
     */
    fun d(message: String) {
        log("D", message)
    }

    /**
     * 输出 Info 级别日志。
     */
    fun i(message: String) {
        log("I", message)
    }

    /**
     * 输出 Warning 级别日志。
     */
    fun w(message: String) {
        log("W", message)
    }

    /**
     * 输出 Error 级别日志。
     */
    fun e(message: String, throwable: Throwable? = null) {
        val throwableMessage = throwable?.let {
            " exception=${it.javaClass.simpleName}: ${it.message ?: it}"
        } ?: ""
        log("E", message + throwableMessage)
    }

    /**
     * 将二进制 payload 转成便于排查协议问题的十六进制文本。
     */
    fun hex(data: ByteArray): String {
        if (data.isEmpty()) return ""
        return data.joinToString(" ") { byte ->
            "%02X".format(Locale.US, byte.toInt() and 0xFF)
        }
    }

    /**
     * 按指定级别发送日志事件。
     */
    private fun log(level: String, message: String) {
        eventHandler?.invoke(level, message, System.currentTimeMillis())
    }
}
