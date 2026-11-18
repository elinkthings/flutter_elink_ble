package com.elinkthings.flutter_elink_ble

import com.pingwang.bluetoothlib.config.BleConfig
import com.pingwang.bluetoothlib.device.BleDevice
import com.pingwang.bluetoothlib.device.SendDataBean
import kotlin.test.Test
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.mockito.ArgumentCaptor
import org.mockito.Mockito

/** 验证即时发送的特征路由、设备隔离及原生拒绝结果。 */
internal class ElinkAndroidImmediateWriteTest {
    /** 完整包原样传入对应特征，且不会误用普通发送或其他设备。 */
    @Test
    fun sendsUnmodifiedPacketToRequestedDeviceAndCharacteristic() {
        val first = Mockito.mock(BleDevice::class.java)
        val second = Mockito.mock(BleDevice::class.java)
        Mockito.doReturn(true).`when`(first).sendDataNow(Mockito.any())
        Mockito.doReturn(true).`when`(second).sendDataNow(Mockito.any())
        val packet = byteArrayOf(0xA6.toByte(), 0x01, 0x00)

        assertTrue(ElinkAndroidImmediateWrite.send(first, packet, "withResponse"))
        val firstRequest = ArgumentCaptor.forClass(SendDataBean::class.java)
        Mockito.verify(first).sendDataNow(firstRequest.capture())
        assertContentEquals(packet, firstRequest.value.hex)
        assertEquals(BleConfig.UUID_WRITE_AILINK, firstRequest.value.uuid)
        assertEquals(BleConfig.UUID_SERVER_AILINK, firstRequest.value.uuidService)
        assertEquals(BleConfig.WRITE_DATA, firstRequest.value.type)
        Mockito.verifyNoInteractions(second)

        assertTrue(ElinkAndroidImmediateWrite.send(second, packet, "withoutResponse"))
        val secondRequest = ArgumentCaptor.forClass(SendDataBean::class.java)
        Mockito.verify(second).sendDataNow(secondRequest.capture())
        assertEquals(BleConfig.UUID_WRITE_NOTIFY_AILINK, secondRequest.value.uuid)
        Mockito.verifyNoMoreInteractions(first, second)
    }

    /** SDK 返回 false 或抛异常时不转换为成功，空数据不触发发送。 */
    @Test
    fun preservesRejectionAndExceptionsWithoutSendingEmptyPackets() {
        val device = Mockito.mock(BleDevice::class.java)
        Mockito.doReturn(false).`when`(device).sendDataNow(Mockito.any())
        assertFalse(ElinkAndroidImmediateWrite.send(device, byteArrayOf(1), "withoutResponse"))
        Mockito.clearInvocations(device)
        assertFalse(ElinkAndroidImmediateWrite.send(device, byteArrayOf(), "withoutResponse"))
        assertFailsWith<IllegalArgumentException> {
            ElinkAndroidImmediateWrite.send(device, byteArrayOf(1), "invalid")
        }
        Mockito.verifyNoInteractions(device)
        Mockito.doThrow(SecurityException("denied")).`when`(device).sendDataNow(Mockito.any())
        assertFailsWith<SecurityException> {
            ElinkAndroidImmediateWrite.send(device, byteArrayOf(1), "withoutResponse")
        }
    }
}
