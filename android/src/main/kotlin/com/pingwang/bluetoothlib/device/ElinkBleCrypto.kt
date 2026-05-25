package com.pingwang.bluetoothlib.device

import com.pingwang.bluetoothlib.config.CmdConfig
import java.util.Arrays
import java.util.Locale

object ElinkBleCrypto {
    private var handshakeData: ByteArray? = null

    fun initHandshakeData(): ByteArray {
        handshakeData = AiLinkBleCheckUtil.getRandomKey(16)
        return AiLinkBleCheckUtil.sendHandshakeFormat(handshakeData, CmdConfig.SET_HANDSHAKE)
    }

    fun getHandshakeEncryptData(data: ByteArray): ByteArray? {
        val bleDataHandshake = AiLinkBleCheckUtil.returnHandshakeDataFormat(data)
        val appDataHandshake = AiLinkBleCheckUtil.bleEncrypt16(bleDataHandshake)
        return appDataHandshake?.let {
            AiLinkBleCheckUtil.sendHandshakeFormat(it, CmdConfig.GET_HANDSHAKE)
        }
    }

    fun checkHandshakeStatus(data: ByteArray): Boolean {
        val handshake = handshakeData ?: return false
        val bleDataHandshake = AiLinkBleCheckUtil.returnHandshakeDataFormat(data)
        val appDataHandshake = AiLinkBleCheckUtil.bleEncrypt16(handshake.copyOf())
        return Arrays.equals(appDataHandshake, bleDataHandshake)
    }

    fun mcuEncrypt(cid: ByteArray, mac: ByteArray, payload: ByteArray): ByteArray? {
        if (payload.isEmpty()) return byteArrayOf()
        return AiLinkBleCheckUtil.mcuEncrypt(cid, payload, littleEndianMac(mac))
    }

    fun mcuDecrypt(mac: ByteArray, packet: ByteArray): ByteArray? {
        var data = AiLinkBleCheckUtil.returnMcuDataFormat(packet)
        if (data != null && data.isNotEmpty() && packet.size >= 3) {
            val cid = byteArrayOf(packet[1], packet[2])
            data = AiLinkBleCheckUtil.mcuEncrypt(cid, data, littleEndianMac(mac))
        }
        return data
    }

    fun decryptBroadcast(payload: ByteArray): ByteArray {
        if (payload.size >= 20) {
            val cid = payload[0].toInt() and 0xff
            val vid = payload[1].toInt() and 0xff
            val pid = payload[2].toInt() and 0xff
            val sum = payload[9]
            val decryptData = payload.copyOfRange(10, 20)
            if (sum == checksum(decryptData)) {
                return AiLinkBleCheckUtil.decryptAndCidVidPid(decryptData, false, cid, vid, pid)
            }
        }
        return payload
    }

    private fun checksum(data: ByteArray): Byte {
        var sum = 0
        data.forEach { sum += it }
        return sum.toByte()
    }

    private fun littleEndianMac(bytes: ByteArray): String {
        return bytes.reversedArray().joinToString(":") {
            String.format(Locale.US, "%02X", it)
        }
    }
}
