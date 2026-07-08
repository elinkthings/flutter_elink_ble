package com.elinkthings.flutter_elink_ble

import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.os.Handler
import com.pingwang.bluetoothlib.bean.BleValueBean
import io.flutter.plugin.common.EventChannel

/** Android EventChannel 事件发送器，集中封装原生事件到 Flutter Map 的转换。 */
internal class ElinkAndroidEventEmitter(private val handler: Handler) {
    /** 当前 Flutter EventChannel sink，页面取消监听时置空。 */
    var eventSink: EventChannel.EventSink? = null

    /** 发送扫描结果事件。 */
    fun emitScanResult(result: BleValueBean) {
        val serviceUuids = result.parcelUuids?.map { ElinkAndroidUuid.shortUuid(it.uuid) } ?: emptyList()
        val manufacturerData = result.manufacturerData ?: byteArrayOf()
        emit(
            mapOf(
                "type" to "scanResult",
                "remoteId" to result.address,
                "platformName" to (result.name ?: ""),
                "macAddress" to result.address,
                "rssi" to result.rssi,
                "advertisementData" to mapOf(
                    "advName" to (result.name ?: ""),
                    "serviceUuids" to serviceUuids,
                    "manufacturerData" to manufacturerData
                )
            )
        )
    }

    /** 发送 A6/A7 协议数据事件。 */
    fun emitProtocolData(
        remoteId: String,
        protocol: String,
        data: ByteArray,
        characteristicUuid: String,
        deviceType: Int?
    ) {
        emit(
            mapOf(
                "type" to "protocolData",
                "remoteId" to remoteId,
                "protocol" to protocol,
                "characteristicUuid" to ElinkAndroidUuid.shortUuidString(characteristicUuid),
                "deviceType" to deviceType,
                "data" to data
            )
        )
    }

    /** 发送原生 SDK 握手状态事件。 */
    fun emitHandshake(remoteId: String, success: Boolean) {
        emit(
            mapOf(
                "type" to "handshake",
                "remoteId" to remoteId,
                "success" to success
            )
        )
    }

    /** 发送原生 SDK 解析后的 BM 版本事件。 */
    fun emitBmVersion(remoteId: String, version: String, command: Int) {
        emit(
            mapOf(
                "type" to "bmVersion",
                "remoteId" to remoteId,
                "version" to version,
                "command" to command,
                "rawPayload" to byteArrayOf(command.toByte())
            )
        )
    }

    /** 发送透传数据事件。 */
    fun emitPassthroughData(remoteId: String, data: ByteArray, characteristicUuid: String) {
        emit(
            mapOf(
                "type" to "passthroughData",
                "remoteId" to remoteId,
                "characteristicUuid" to ElinkAndroidUuid.shortUuidString(characteristicUuid),
                "data" to data
            )
        )
    }

    /** 发送 characteristic 读写或通知事件。 */
    fun emitCharacteristicEvent(
        remoteId: String,
        operation: String,
        characteristic: BluetoothGattCharacteristic
    ) {
        emit(
            mapOf(
                "type" to "characteristicEvent",
                "remoteId" to remoteId,
                "operation" to operation,
                "serviceUuid" to ElinkAndroidUuid.shortUuid(characteristic.service.uuid),
                "characteristicUuid" to ElinkAndroidUuid.shortUuid(characteristic.uuid),
                "descriptorUuid" to "",
                "data" to (characteristic.value ?: byteArrayOf())
            )
        )
    }

    /** 发送 descriptor 写入事件。 */
    fun emitCharacteristicEvent(
        remoteId: String,
        operation: String,
        descriptor: BluetoothGattDescriptor
    ) {
        val characteristic = descriptor.characteristic
        emit(
            mapOf(
                "type" to "characteristicEvent",
                "remoteId" to remoteId,
                "operation" to operation,
                "serviceUuid" to ElinkAndroidUuid.shortUuid(characteristic.service.uuid),
                "characteristicUuid" to ElinkAndroidUuid.shortUuid(characteristic.uuid),
                "descriptorUuid" to ElinkAndroidUuid.shortUuid(descriptor.uuid),
                "data" to (descriptor.value ?: byteArrayOf())
            )
        )
    }

    /** 发送 RSSI 读取事件。 */
    fun emitRssi(remoteId: String, rssi: Int) {
        emit(
            mapOf(
                "type" to "rssi",
                "remoteId" to remoteId,
                "rssi" to rssi
            )
        )
    }

    /** 发送 MTU 或可用 payload 长度事件。 */
    fun emitMtu(remoteId: String, mtu: Int?, availableMtu: Int?) {
        emit(
            mapOf(
                "type" to "mtu",
                "remoteId" to remoteId,
                "mtu" to mtu,
                "availableMtu" to availableMtu
            )
        )
    }

    /** 发送蓝牙适配器状态事件。 */
    fun emitAdapterState(state: String) {
        emit(mapOf("type" to "adapterState", "state" to state))
    }

    /** 发送连接状态事件。 */
    fun emitConnection(remoteId: String, state: String, reason: String? = null) {
        emit(
            mapOf(
                "type" to "connectionState",
                "remoteId" to remoteId,
                "state" to state,
                "reason" to reason
            )
        )
    }

    /** 发送错误事件。 */
    fun emitError(code: String, message: String, details: Map<String, Any?>? = null) {
        val event = mutableMapOf<String, Any?>(
            "type" to "error",
            "code" to code,
            "message" to message
        )
        if (details != null) {
            event["details"] = details
        }
        emit(event)
    }

    /** 发送 native 插件日志事件，由 Flutter 侧统一输出和入库。 */
    fun emitNativeLog(level: String, message: String, timestampMs: Long) {
        emit(
            mapOf(
                "type" to "nativeLog",
                "platform" to "Android",
                "level" to level,
                "message" to message,
                "timestampMs" to timestampMs
            )
        )
    }

    /** 向 Flutter EventChannel 投递原始事件。 */
    fun emit(event: Map<String, Any?>) {
        handler.post { eventSink?.success(event) }
    }
}
