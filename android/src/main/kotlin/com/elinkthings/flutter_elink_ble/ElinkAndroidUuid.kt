package com.elinkthings.flutter_elink_ble

import java.util.Locale
import java.util.UUID

/** Android BLE UUID 标准化工具，统一 16-bit 和 128-bit UUID 的转换。 */
internal object ElinkAndroidUuid {
    /** 将 UUID 压缩为 16-bit 文本，非蓝牙基础 UUID 保留完整大写文本。 */
    fun shortUuid(uuid: UUID): String {
        val text = uuid.toString().uppercase(Locale.US)
        return if (text.startsWith("0000") && text.endsWith("-0000-1000-8000-00805F9B34FB")) {
            text.substring(4, 8)
        } else {
            text
        }
    }

    /** 将字符串 UUID 规范化为短 UUID 文本，非法输入保持大写原文便于排查。 */
    fun shortUuidString(uuid: String): String {
        return if (uuid.isBlank()) {
            ""
        } else {
            runCatching { shortUuid(elinkUuid(uuid)) }.getOrElse { uuid.uppercase(Locale.US) }
        }
    }

    /** 将 16-bit 或完整 UUID 文本转换成 Android UUID。 */
    fun elinkUuid(shortOrFullUuid: String): UUID {
        val upper = shortOrFullUuid.uppercase(Locale.US)
        return if (upper.length == 4) {
            UUID.fromString("0000$upper-0000-1000-8000-00805F9B34FB")
        } else {
            UUID.fromString(upper)
        }
    }
}
