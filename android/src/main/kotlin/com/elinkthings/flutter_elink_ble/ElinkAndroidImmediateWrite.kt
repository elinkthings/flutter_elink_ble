package com.elinkthings.flutter_elink_ble

import com.pingwang.bluetoothlib.config.BleConfig
import com.pingwang.bluetoothlib.device.BleDevice
import com.pingwang.bluetoothlib.device.SendDataBean

/** 将完整包及写入类型转换为 SDK 即时发送请求，不额外进行协议组包。 */
internal object ElinkAndroidImmediateWrite {
    /** 向指定设备发送；空数据返回 false，SDK 拒绝或异常均保留原始结果。 */
    fun send(device: BleDevice, data: ByteArray, type: String): Boolean {
        if (data.isEmpty()) return false
        val writeUuid = when (type) {
            "withResponse" -> BleConfig.UUID_WRITE_AILINK
            "withoutResponse" -> BleConfig.UUID_WRITE_NOTIFY_AILINK
            else -> throw IllegalArgumentException("Unknown write type: $type")
        }
        return device.sendDataNow(
            SendDataBean(data, writeUuid, BleConfig.WRITE_DATA, BleConfig.UUID_SERVER_AILINK)
        )
    }
}
