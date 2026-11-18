package com.elinkthings.flutter_elink_ble

import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattService
import com.pingwang.bluetoothlib.config.BleConfig
import com.pingwang.bluetoothlib.device.BleDevice
import com.pingwang.bluetoothlib.device.SendDataBean
import kotlin.test.Test
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import org.mockito.ArgumentCaptor
import org.mockito.Mockito

/** 验证自定义 UUID 写入在 SDK 排队前的目标校验及原始数据传递。 */
internal class ElinkAndroidCustomWriteTest {
    /** 短 UUID 与完整 UUID 等价，残缺格式不能交给宽松的 UUID.fromString。 */
    @Test
    fun validatesAndNormalizesUuids() {
        assertEquals(ElinkAndroidCustomWrite.parseUuid("FFF0"), ElinkAndroidCustomWrite.parseUuid("0000fff0-0000-1000-8000-00805f9b34fb"))
        assertEquals("1234abcd-0000-1000-8000-00805f9b34fb", ElinkAndroidCustomWrite.parseUuid("1234ABCD").toString())
        for (invalid in listOf("", "XYZ0", "1-2-3-4-5", " FFF0", "FFF0\n")) {
            assertFailsWith<IllegalArgumentException> { ElinkAndroidCustomWrite.parseUuid(invalid) }
        }
    }

    /** SDK 请求完整保留服务、特征和原始数据，不调用即时发送或其他设备。 */
    @Test
    fun submitsRawPacketToTheSpecifiedServiceAndCharacteristic() {
        val device = deviceWith(service("FFF0", "FFF1"))
        val other = deviceWith(service("FFF0", "FFF1"))
        val data = byteArrayOf(1, 2, 3)
        ElinkAndroidCustomWrite.send(device, data, "FFF0", "FFF1")
        val request = ArgumentCaptor.forClass(SendDataBean::class.java)
        Mockito.verify(device).sendData(request.capture())
        assertEquals(ElinkAndroidCustomWrite.parseUuid("FFF0"), request.value.uuidService)
        assertEquals(ElinkAndroidCustomWrite.parseUuid("FFF1"), request.value.uuid)
        assertEquals(BleConfig.WRITE_DATA, request.value.type)
        assertContentEquals(data, request.value.hex)
        Mockito.verify(other, Mockito.never()).sendData(Mockito.any())
        Mockito.verify(device, Mockito.never()).sendDataNow(Mockito.any())
    }

    /** 缺失、只读或 SDK 缓存无法区分的重复特征必须拒绝，不能静默错写。 */
    @Test
    fun rejectsMissingReadOnlyAndAmbiguousTargets() {
        val devices = listOf(
            deviceWith(service("FFF2", "FFF1")),
            deviceWith(service("FFF0", "FFF2")),
            deviceWith(service("FFF0", "FFF1", BluetoothGattCharacteristic.PROPERTY_READ)),
            deviceWith(service("FFF0", "FFF1"), service("FFF2", "FFF1"))
        )
        for (device in devices) {
            assertFailsWith<IllegalArgumentException> {
                ElinkAndroidCustomWrite.send(device, byteArrayOf(1), "FFF0", "FFF1")
            }
            Mockito.verify(device, Mockito.never()).sendData(Mockito.any())
        }
        val disconnected = Mockito.mock(BleDevice::class.java)
        assertFailsWith<IllegalStateException> {
            ElinkAndroidCustomWrite.send(disconnected, byteArrayOf(1), "FFF0", "FFF1")
        }
    }

    /** 创建只含指定特征的模拟服务，不访问真实 Android 蓝牙栈。 */
    private fun service(serviceUuid: String, characteristicUuid: String, properties: Int = BluetoothGattCharacteristic.PROPERTY_WRITE): BluetoothGattService {
        val characteristic = Mockito.mock(BluetoothGattCharacteristic::class.java)
        Mockito.`when`(characteristic.uuid).thenReturn(ElinkAndroidCustomWrite.parseUuid(characteristicUuid))
        Mockito.`when`(characteristic.properties).thenReturn(properties)
        val service = Mockito.mock(BluetoothGattService::class.java)
        Mockito.`when`(service.uuid).thenReturn(ElinkAndroidCustomWrite.parseUuid(serviceUuid))
        Mockito.`when`(service.characteristics).thenReturn(listOf(characteristic))
        return service
    }

    /** 为指定服务集合创建独立设备，用于验证目标选择和隔离。 */
    private fun deviceWith(vararg services: BluetoothGattService): BleDevice {
        val gatt = Mockito.mock(BluetoothGatt::class.java)
        Mockito.`when`(gatt.services).thenReturn(services.toList())
        val device = Mockito.mock(BleDevice::class.java)
        Mockito.`when`(device.bluetoothGatt).thenReturn(gatt)
        return device
    }
}
