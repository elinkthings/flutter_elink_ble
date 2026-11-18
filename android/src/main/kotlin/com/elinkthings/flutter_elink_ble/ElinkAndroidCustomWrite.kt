package com.elinkthings.flutter_elink_ble

import android.bluetooth.BluetoothGattCharacteristic
import com.pingwang.bluetoothlib.config.BleConfig
import com.pingwang.bluetoothlib.device.BleDevice
import com.pingwang.bluetoothlib.device.SendDataBean
import java.util.UUID

/** 校验自定义服务/特征并交给 SDK 发送队列，不改变原有 Elink 写入配置。 */
internal object ElinkAndroidCustomWrite {
    /** 解析 16/32/128-bit UUID，严格拒绝 Java UUID.fromString 可容忍的残缺格式。 */
    fun parseUuid(value: String): UUID {
        val full = when {
            Regex("^[0-9a-fA-F]{4}$").matches(value) -> "0000$value-0000-1000-8000-00805f9b34fb"
            Regex("^[0-9a-fA-F]{8}$").matches(value) -> "$value-0000-1000-8000-00805f9b34fb"
            Regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$").matches(value) -> value
            else -> throw IllegalArgumentException("Invalid UUID: $value")
        }
        return UUID.fromString(full)
    }

    /** 只向已发现且可写的唯一目标提交原始数据；实际写入类型由 SDK 按属性选择。 */
    fun send(device: BleDevice, data: ByteArray, serviceUuid: String, characteristicUuid: String) {
        val serviceId = parseUuid(serviceUuid)
        val characteristicId = parseUuid(characteristicUuid)
        val gatt = device.bluetoothGatt ?: throw IllegalStateException("Device is not connected")
        val services = gatt.services.filter { it.uuid == serviceId }
        require(services.size == 1) { "Service is missing or ambiguous: $serviceUuid" }
        val characteristics = services.single().characteristics.filter { it.uuid == characteristicId }
        require(characteristics.size == 1) { "Characteristic is missing or ambiguous: $characteristicUuid" }
        // SDK 1.15.19 按 characteristic UUID 缓存，跨 service 同 UUID 会误命中；拒绝该歧义。
        require(gatt.services.sumOf { service ->
            service.characteristics.count { it.uuid == characteristicId }
        } == 1) { "Android SDK does not support duplicate characteristic UUIDs across services" }
        val writable = BluetoothGattCharacteristic.PROPERTY_WRITE or
            BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE
        require(characteristics.single().properties and writable != 0) {
            "Characteristic is not writable: $characteristicUuid"
        }
        ElinkNativeLogger.d("write custom service=$serviceId characteristic=$characteristicId bytes=${data.size}")
        device.sendData(SendDataBean(data, characteristicId, BleConfig.WRITE_DATA, serviceId))
    }
}
