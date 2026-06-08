package com.elinkthings.flutter_elink_ble

import android.Manifest
import android.content.ActivityNotFoundException
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.location.LocationManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.provider.Settings
import androidx.core.content.ContextCompat
import com.pingwang.bluetoothlib.AILinkBleManager
import com.pingwang.bluetoothlib.AILinkSDK
import com.pingwang.bluetoothlib.bean.BleValueBean
import com.pingwang.bluetoothlib.config.BleConfig
import com.pingwang.bluetoothlib.device.ElinkBleCrypto
import com.pingwang.bluetoothlib.device.SendBleBean
import com.pingwang.bluetoothlib.device.SendDataBean
import com.pingwang.bluetoothlib.device.SendMcuBean
import com.pingwang.bluetoothlib.listener.OnBleDeviceDataListener
import com.pingwang.bluetoothlib.listener.OnBleMtuListener
import com.pingwang.bluetoothlib.listener.OnBleOtherDataListener
import com.pingwang.bluetoothlib.listener.OnBleRssiListener
import com.pingwang.bluetoothlib.listener.OnCallbackBle
import com.pingwang.bluetoothlib.listener.OnCharacteristicListener
import com.pingwang.bluetoothlib.utils.BleLog
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayDeque
import java.util.Locale
import java.util.UUID

class ElinkBlePlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var context: Context
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private val handler = Handler(Looper.getMainLooper())
    private var eventSink: EventChannel.EventSink? = null
    private var bluetoothAdapter: BluetoothAdapter? = null
    private val scanResults = mutableMapOf<String, BleValueBean>()
    private val listenerAttachedRemoteIds = mutableSetOf<String>()
    private var connectedRemoteId: String? = null
    private var bluetoothStateReceiver: BroadcastReceiver? = null
    private var sdkCallback: OnCallbackBle? = null
    private var sdkReady = false
    private val scanStartTimesMs = ArrayDeque<Long>()
    private var isScanning = false
    private var activeScanConfig: ScanConfig? = null
    private var lastScanStopElapsedMs = 0L

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        bluetoothAdapter = (context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager)?.adapter
        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
        registerBluetoothStateReceiver()
        initVendorSdk()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        unregisterBluetoothStateReceiver()
        disposeSdkResources()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        emitAdapterState()
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "isSupported" -> result.success(
                    context.packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)
                )
                "getAdapterState" -> result.success(mapOf("state" to adapterStateName()))
                "openBluetooth" -> {
                    openBluetoothInternal()
                    result.success(null)
                }
                "startScan" -> {
                    val timeoutMs = call.argument<Int>("timeoutMs") ?: 10000
                    val services = call.argument<List<String>>("withServices") ?: DEFAULT_SCAN_SERVICES
                    val scanMode = call.argument<Int>("androidScanMode")
                    startScanInternal(timeoutMs.toLong(), services, scanMode)
                    result.success(null)
                }
                "stopScan" -> {
                    stopScanInternal()
                    result.success(null)
                }
                "connect" -> {
                    val remoteId = call.argument<String>("remoteId") ?: ""
                    val autoConnect = call.argument<Boolean>("autoConnect") ?: false
                    connectInternal(remoteId, autoConnect)
                    result.success(null)
                }
                "disconnect" -> {
                    val remoteId = call.argument<String>("remoteId") ?: ""
                    disconnectInternal(remoteId)
                    result.success(null)
                }
                "disconnectCurrent" -> {
                    disconnectCurrentInternal()
                    result.success(null)
                }
                "readRssi" -> {
                    val remoteId = call.argument<String>("remoteId") ?: ""
                    readRssiInternal(remoteId)
                    result.success(null)
                }
                "setAndroidMtu" -> {
                    val remoteId = call.argument<String>("remoteId") ?: ""
                    val mtu = call.argument<Int>("mtu") ?: 0
                    result.success(setAndroidMtuInternal(remoteId, mtu))
                }
                "setAndroidPreferredPhy" -> {
                    val remoteId = call.argument<String>("remoteId") ?: ""
                    val txPhy = call.argument<Int>("txPhy") ?: 0
                    val rxPhy = call.argument<Int>("rxPhy") ?: 0
                    result.success(setAndroidPreferredPhyInternal(remoteId, txPhy, rxPhy))
                }
                "write" -> {
                    val remoteId = call.argument<String>("remoteId") ?: ""
                    val data = call.argument<ByteArray>("data") ?: byteArrayOf()
                    val type = call.argument<String>("type") ?: "withoutResponse"
                    writeInternal(remoteId, data, type)
                    result.success(null)
                }
                "writeA6" -> {
                    val remoteId = call.argument<String>("remoteId") ?: ""
                    val payload = call.argument<ByteArray>("payload") ?: byteArrayOf()
                    writeA6Internal(remoteId, payload)
                    result.success(null)
                }
                "writeA7" -> {
                    val remoteId = call.argument<String>("remoteId") ?: ""
                    val payload = call.argument<ByteArray>("payload") ?: byteArrayOf()
                    val cid = call.argument<Int>("cid")
                    writeA7Internal(remoteId, payload, cid)
                    result.success(null)
                }
                "decryptBroadcast" -> {
                    val payload = call.arguments as? ByteArray
                    result.success(payload?.let { decryptBroadcast(it) })
                }
                "initHandshake" -> result.success(initHandshakeData())
                "getHandshakeEncryptData" -> {
                    val payload = call.arguments as? ByteArray
                    result.success(payload?.let { getHandshakeEncryptData(it) })
                }
                "checkHandshakeStatus" -> {
                    val payload = call.arguments as? ByteArray
                    result.success(payload?.let { checkHandshakeStatus(it) } ?: false)
                }
                "mcuEncrypt" -> {
                    val args = call.arguments as? Map<*, *>
                    val cid = args?.get("cid") as? ByteArray ?: byteArrayOf()
                    val mac = args?.get("mac") as? ByteArray ?: byteArrayOf()
                    val payload = args?.get("payload") as? ByteArray ?: byteArrayOf()
                    result.success(mcuEncrypt(cid, mac, payload))
                }
                "mcuDecrypt" -> {
                    val args = call.arguments as? Map<*, *>
                    val mac = args?.get("mac") as? ByteArray ?: byteArrayOf()
                    val payload = args?.get("payload") as? ByteArray ?: byteArrayOf()
                    result.success(mcuDecrypt(mac, payload))
                }
                "dispose" -> {
                    disposeSdkResources()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (throttled: ScanThrottledException) {
            val details = mapOf("retryAfterMs" to throttled.retryAfterMs)
            result.error("scan_throttled", throttled.message, details)
            emitError(
                "scan_throttled",
                throttled.message ?: "Android BLE scan was throttled",
                details
            )
        } catch (security: SecurityException) {
            result.error("permission_denied", security.message, null)
            emitError("permission_denied", security.message ?: "Bluetooth permission denied")
        } catch (error: Throwable) {
            result.error("elink_ble_error", error.message, null)
            emitError("elink_ble_error", error.message ?: error.toString())
        }
    }

    // 监听系统 BluetoothAdapter state，补齐用户手动开关蓝牙时的状态回调。
    // Listen for system BluetoothAdapter state changes and forward them to Flutter.
    private fun registerBluetoothStateReceiver() {
        if (bluetoothStateReceiver != null) return
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action != BluetoothAdapter.ACTION_STATE_CHANGED) return
                val state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)
                emitAdapterState(state)
            }
        }
        bluetoothStateReceiver = receiver
        val filter = IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED)
        ContextCompat.registerReceiver(
            context,
            receiver,
            filter,
            ContextCompat.RECEIVER_NOT_EXPORTED
        )
    }

    private fun unregisterBluetoothStateReceiver() {
        val receiver = bluetoothStateReceiver ?: return
        runCatching { context.unregisterReceiver(receiver) }
        bluetoothStateReceiver = null
    }

    private fun initVendorSdk() {
        try {
            BleLog.init(true)
            AILinkSDK.getInstance().init(context)
            AILinkBleManager.getInstance().init(context, object : AILinkBleManager.onInitListener {
                override fun onInitSuccess() {
                    sdkReady = true
                    sdkCallback = object : OnCallbackBle {
                        override fun bleOpen() = emitAdapterState()
                        override fun bleClose() = emitAdapterState()
                        override fun onStartScan() {
                            isScanning = true
                        }
                        override fun onScanTimeOut() {
                            markScanStopped()
                            emit(mapOf("type" to "scanStopped"))
                        }
                        override fun onScanErr(type: Int, time: Long) {
                            markScanStopped()
                            emitScanError(type, time)
                            emit(mapOf("type" to "scanStopped"))
                        }
                        override fun onScanning(data: BleValueBean?) {
                            if (data != null) {
                                scanResults[data.address] = data
                                emitScanResult(data)
                            }
                        }
                        override fun onConnecting(mac: String?) {
                            mac?.let { emitConnection(it, "connecting") }
                        }
                        override fun onConnectionSuccess(mac: String?) {
                            mac?.let {
                                connectedRemoteId = it
                                emitConnection(it, "connected")
                                attachDeviceListeners(it)
                            }
                        }
                        override fun onServicesDiscovered(mac: String?) {
                            mac?.let {
                                attachDeviceListeners(it)
                                emit(
                                    mapOf(
                                        "type" to "servicesDiscovered",
                                        "remoteId" to it,
                                        "serviceUuid" to ELINK_CONNECT_SERVICE,
                                        "characteristicUuids" to listOf(
                                            ELINK_WRITE_CHARACTERISTIC,
                                            ELINK_NOTIFY_CHARACTERISTIC,
                                            ELINK_WRITE_NOTIFY_CHARACTERISTIC
                                        )
                                    )
                                )
                            }
                        }
                        override fun onDisConnected(mac: String?, code: Int) {
                            mac?.let {
                                if (connectedRemoteId == it) {
                                    connectedRemoteId = null
                                }
                                listenerAttachedRemoteIds.remove(it)
                                emitConnection(it, "disconnected", "code=$code")
                            }
                        }
                    }
                    AILinkBleManager.getInstance().setOnCallbackBle(sdkCallback)
                }

                override fun onInitFailure() {
                    sdkReady = false
                    emitError("sdk_init_failure", "AILink Android SDK initialization failed")
                }
            })
        } catch (ignored: Throwable) {
            sdkReady = false
            emitError("sdk_init_failure", ignored.message ?: "AILink Android SDK initialization failed")
        }
    }

    private fun startScanInternal(
        timeoutMs: Long,
        withServices: List<String>,
        androidScanMode: Int?
    ) {
        ensureSdkReady()
        ensureCanStartScan()
        ensureBluetoothPoweredOn()
        val uuids = withServices.mapNotNull { service ->
            runCatching { elinkUuid(service) }.getOrNull()
        }
        val scanConfig = ScanConfig(
            services = uuids.map { shortUuid(it) }.distinct().sorted(),
            scanMode = androidScanMode
        )
        if (isScanning && activeScanConfig == scanConfig) {
            return
        }
        val nowMs = SystemClock.elapsedRealtime()
        val retryAfterMs = scanThrottleRetryAfterMs(nowMs)
        if (retryAfterMs > 0) {
            throw ScanThrottledException(retryAfterMs, scanThrottleMessage(retryAfterMs))
        }
        if (isScanning || activeScanConfig != null) {
            stopScanInternal(emitStopped = false)
        }
        scanResults.clear()
        recordScanStart(SystemClock.elapsedRealtime())
        isScanning = true
        activeScanConfig = scanConfig
        try {
            if (androidScanMode == null) {
                AILinkBleManager.getInstance().startScan(timeoutMs, *uuids.toTypedArray())
            } else {
                AILinkBleManager.getInstance().startScan(timeoutMs, androidScanMode, *uuids.toTypedArray())
            }
        } catch (error: Throwable) {
            markScanStopped()
            throw error
        }
    }

    private fun stopScanInternal(emitStopped: Boolean = true) {
        runCatching { AILinkBleManager.getInstance().stopScan() }
        markScanStopped()
        if (emitStopped) {
            emit(mapOf("type" to "scanStopped"))
        }
    }

    // 请求系统打开蓝牙；Android 会弹出系统确认或跳转蓝牙设置。
    // Request enabling Bluetooth through the system prompt or Bluetooth settings.
    private fun openBluetoothInternal() {
        val adapter = bluetoothAdapter
            ?: throw IllegalStateException("Bluetooth is not supported on this device")
        if (!hasConnectPermission()) {
            throw SecurityException("Missing Bluetooth connect permission")
        }
        if (adapter.isEnabled) {
            emitAdapterState(BluetoothAdapter.STATE_ON)
            return
        }
        val requestIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        val settingsIntent = Intent(Settings.ACTION_BLUETOOTH_SETTINGS)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            context.startActivity(requestIntent)
        } catch (_: ActivityNotFoundException) {
            context.startActivity(settingsIntent)
        }
    }

    private fun connectInternal(remoteId: String, autoConnect: Boolean) {
        ensureSdkReady()
        if (!hasConnectPermission()) {
            throw SecurityException("Missing Bluetooth connect permission")
        }
        if (remoteId.isBlank()) {
            throw IllegalArgumentException("remoteId is empty")
        }
        ensureBluetoothPoweredOn()
        emitConnection(remoteId, "connecting")
        stopScanInternal()
        val bleValue = scanResults[remoteId]
        if (bleValue != null && !autoConnect) {
            AILinkBleManager.getInstance().connectDevice(bleValue)
        } else {
            AILinkBleManager.getInstance().connectDevice(remoteId)
        }
    }

    private fun disconnectInternal(remoteId: String) {
        if (remoteId.isBlank()) {
            throw IllegalArgumentException("remoteId is empty")
        }
        emitConnection(remoteId, "disconnecting")
        if (connectedRemoteId == remoteId) {
            connectedRemoteId = null
        }
        AILinkBleManager.getInstance().disconnect(remoteId)
    }

    private fun disconnectCurrentInternal() {
        val remoteId = connectedRemoteId ?: return
        disconnectInternal(remoteId)
    }

    private fun readRssiInternal(remoteId: String) {
        ensureSdkReady()
        if (!hasConnectPermission()) {
            throw SecurityException("Missing Bluetooth connect permission")
        }
        ensureBluetoothPoweredOn()
        val device = AILinkBleManager.getInstance().getBleDevice(remoteId)
            ?: throw IllegalStateException("Device is not connected: $remoteId")
        device.readRssi()
    }

    private fun setAndroidMtuInternal(remoteId: String, mtu: Int): Boolean {
        ensureSdkReady()
        if (!hasConnectPermission()) {
            throw SecurityException("Missing Bluetooth connect permission")
        }
        ensureBluetoothPoweredOn()
        if (mtu <= 0) {
            throw IllegalArgumentException("mtu must be greater than 0")
        }
        val device = AILinkBleManager.getInstance().getBleDevice(remoteId)
            ?: throw IllegalStateException("Device is not connected: $remoteId")
        return device.setMtu(mtu)
    }

    private fun setAndroidPreferredPhyInternal(
        remoteId: String,
        txPhy: Int,
        rxPhy: Int
    ): Boolean {
        ensureSdkReady()
        if (!hasConnectPermission()) {
            throw SecurityException("Missing Bluetooth connect permission")
        }
        ensureBluetoothPoweredOn()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return false
        }
        val device = AILinkBleManager.getInstance().getBleDevice(remoteId)
            ?: throw IllegalStateException("Device is not connected: $remoteId")
        return device.setPreferredPhy(txPhy, rxPhy)
    }

    private fun writeInternal(remoteId: String, data: ByteArray, type: String) {
        ensureSdkReady()
        if (!hasConnectPermission()) {
            throw SecurityException("Missing Bluetooth connect permission")
        }
        ensureBluetoothPoweredOn()
        val device = AILinkBleManager.getInstance().getBleDevice(remoteId)
            ?: throw IllegalStateException("Device is not connected: $remoteId")
        val writeUuid = if (type == "withResponse") {
            BleConfig.UUID_WRITE_AILINK
        } else {
            BleConfig.UUID_WRITE_NOTIFY_AILINK
        }
        val sendData = SendDataBean(data, writeUuid, BleConfig.WRITE_DATA, BleConfig.UUID_SERVER_AILINK)
        device.sendData(sendData)
    }

    private fun writeA6Internal(remoteId: String, payload: ByteArray) {
        ensureSdkReady()
        if (!hasConnectPermission()) {
            throw SecurityException("Missing Bluetooth connect permission")
        }
        ensureBluetoothPoweredOn()
        val device = AILinkBleManager.getInstance().getBleDevice(remoteId)
            ?: throw IllegalStateException("Device is not connected: $remoteId")
        val sendBleBean = SendBleBean()
        sendBleBean.setHex(payload)
        device.sendData(sendBleBean)
    }

    private fun writeA7Internal(remoteId: String, payload: ByteArray, cid: Int?) {
        ensureSdkReady()
        if (!hasConnectPermission()) {
            throw SecurityException("Missing Bluetooth connect permission")
        }
        ensureBluetoothPoweredOn()
        val device = AILinkBleManager.getInstance().getBleDevice(remoteId)
            ?: throw IllegalStateException("Device is not connected: $remoteId")
        val deviceType = cid ?: device.cid
        val sendMcuBean = SendMcuBean()
        sendMcuBean.setHex(deviceType, payload)
        device.sendData(sendMcuBean)
    }

    private fun attachDeviceListeners(remoteId: String) {
        if (listenerAttachedRemoteIds.contains(remoteId)) return
        val device = AILinkBleManager.getInstance().getBleDevice(remoteId) ?: return
        listenerAttachedRemoteIds.add(remoteId)
        // SDK 会先回调带 uuid 的 default method，再回调不带 uuid 的 method。
        // Use only UUID callbacks to avoid forwarding the same packet twice.
        device.setOnBleDeviceDataListener(object : OnBleDeviceDataListener {
            override fun onNotifyData(uuid: String, data: ByteArray, type: Int) {
                emitProtocolData(remoteId, "a7", data, uuid, type)
            }

            override fun onNotifyDataA6(uuid: String, data: ByteArray) {
                emitProtocolData(remoteId, "a6", data, uuid, null)
            }
        })
        // 同上，只接收带 uuid 的透传入口。
        // Same rule for passthrough data: consume the UUID overload only.
        device.setOnBleOtherDataListener(object : OnBleOtherDataListener {
            override fun onNotifyOtherData(uuid: String, data: ByteArray) {
                emitPassthroughData(remoteId, data, uuid)
            }
        })
        device.setOnCharacteristicListener(object : OnCharacteristicListener {
            override fun onCharacteristicReadOK(characteristic: BluetoothGattCharacteristic) {
                emitCharacteristicEvent(remoteId, "read", characteristic)
            }

            override fun onCharacteristicWriteOK(characteristic: BluetoothGattCharacteristic) {
                emitCharacteristicEvent(remoteId, "write", characteristic)
            }

            override fun onDescriptorWriteOK(descriptor: BluetoothGattDescriptor) {
                emitCharacteristicEvent(remoteId, "descriptorWrite", descriptor)
            }

            override fun onCharacteristicChanged(characteristic: BluetoothGattCharacteristic) {
                emitCharacteristicEvent(remoteId, "changed", characteristic)
            }
        })
        device.setOnBleRssiListener(object : OnBleRssiListener {
            override fun OnRssi(rssi: Int) {
                emitRssi(remoteId, rssi)
            }
        })
        device.setOnBleMtuListener(object : OnBleMtuListener {
            override fun OnMtu(mtu: Int) {
                emitMtu(remoteId, mtu, null)
            }

            override fun onMtuAvailable(mtu: Int) {
                emitMtu(remoteId, null, mtu)
            }
        })
    }

    private fun emitScanResult(result: BleValueBean) {
        val serviceUuids = result.parcelUuids?.map { shortUuid(it.uuid) } ?: emptyList()
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

    private fun emitProtocolData(
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
                "characteristicUuid" to shortUuidString(characteristicUuid),
                "deviceType" to deviceType,
                "data" to data
            )
        )
    }

    private fun emitPassthroughData(remoteId: String, data: ByteArray, characteristicUuid: String) {
        emit(
            mapOf(
                "type" to "passthroughData",
                "remoteId" to remoteId,
                "characteristicUuid" to shortUuidString(characteristicUuid),
                "data" to data
            )
        )
    }

    private fun emitCharacteristicEvent(
        remoteId: String,
        operation: String,
        characteristic: BluetoothGattCharacteristic
    ) {
        emit(
            mapOf(
                "type" to "characteristicEvent",
                "remoteId" to remoteId,
                "operation" to operation,
                "serviceUuid" to shortUuid(characteristic.service.uuid),
                "characteristicUuid" to shortUuid(characteristic.uuid),
                "descriptorUuid" to "",
                "data" to (characteristic.value ?: byteArrayOf())
            )
        )
    }

    private fun emitCharacteristicEvent(
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
                "serviceUuid" to shortUuid(characteristic.service.uuid),
                "characteristicUuid" to shortUuid(characteristic.uuid),
                "descriptorUuid" to shortUuid(descriptor.uuid),
                "data" to (descriptor.value ?: byteArrayOf())
            )
        )
    }

    private fun emitRssi(remoteId: String, rssi: Int) {
        emit(
            mapOf(
                "type" to "rssi",
                "remoteId" to remoteId,
                "rssi" to rssi
            )
        )
    }

    private fun emitMtu(remoteId: String, mtu: Int?, availableMtu: Int?) {
        emit(
            mapOf(
                "type" to "mtu",
                "remoteId" to remoteId,
                "mtu" to mtu,
                "availableMtu" to availableMtu
            )
        )
    }

    private fun emitAdapterState() {
        emit(mapOf("type" to "adapterState", "state" to adapterStateName()))
    }

    private fun emitAdapterState(adapterState: Int) {
        emit(mapOf("type" to "adapterState", "state" to adapterStateName(adapterState)))
    }

    private fun emitConnection(remoteId: String, state: String, reason: String? = null) {
        emit(
            mapOf(
                "type" to "connectionState",
                "remoteId" to remoteId,
                "state" to state,
                "reason" to reason
            )
        )
    }

    private fun emitError(code: String, message: String, details: Map<String, Any?>? = null) {
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

    private fun emit(event: Map<String, Any?>) {
        handler.post { eventSink?.success(event) }
    }

    private fun adapterStateName(): String {
        return adapterStateName(bluetoothAdapter?.state)
    }

    private fun adapterStateName(adapterState: Int?): String {
        return when (adapterState) {
            BluetoothAdapter.STATE_ON -> "on"
            BluetoothAdapter.STATE_OFF -> "off"
            BluetoothAdapter.STATE_TURNING_ON -> "turningOn"
            BluetoothAdapter.STATE_TURNING_OFF -> "turningOff"
            null -> "unavailable"
            else -> "unknown"
        }
    }

    private fun missingScanPermissions(): List<String> {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // AILink SDK 普通扫描入口会检查完整 Nearby devices 权限。
            // AILink SDK ordinary scan gate checks all nearby-device permissions.
            listOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_ADVERTISE,
                Manifest.permission.BLUETOOTH_CONNECT
            ).filterNot { permission ->
                ContextCompat.checkSelfPermission(context, permission) ==
                    PackageManager.PERMISSION_GRANTED
            }.map { permission ->
                permission.substringAfterLast('.')
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            listOf(Manifest.permission.ACCESS_FINE_LOCATION).filterNot { permission ->
                ContextCompat.checkSelfPermission(context, permission) ==
                    PackageManager.PERMISSION_GRANTED
            }.map { permission ->
                permission.substringAfterLast('.')
            }
        } else {
            emptyList()
        }
    }

    private fun hasConnectPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_CONNECT) ==
                PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun ensureSdkReady() {
        if (!sdkReady) {
            throw IllegalStateException("AILink Android SDK is not initialized")
        }
    }

    private fun ensureCanStartScan() {
        val missingPermissions = missingScanPermissions()
        if (missingPermissions.isNotEmpty()) {
            throw SecurityException(
                "Missing Bluetooth scan requirement: ${missingPermissions.joinToString(", ")}"
            )
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S && !isLocationServiceEnabled()) {
            throw IllegalStateException("Location service is disabled; Android BLE scan requires location enabled")
        }
    }

    private fun ensureBluetoothPoweredOn() {
        val isPoweredOn = runCatching { bluetoothAdapter?.isEnabled == true }
            .getOrElse { true }
        if (!isPoweredOn) {
            throw IllegalStateException("Bluetooth is not powered on")
        }
    }

    private fun isLocationServiceEnabled(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) return true
        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
            ?: return false
        return runCatching {
            locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
                locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
        }.getOrDefault(false)
    }

    private fun markScanStopped() {
        if (isScanning || activeScanConfig != null) {
            lastScanStopElapsedMs = SystemClock.elapsedRealtime()
        }
        isScanning = false
        activeScanConfig = null
    }

    private fun pruneScanStartHistory(nowMs: Long) {
        while (
            scanStartTimesMs.isNotEmpty() &&
            nowMs - scanStartTimesMs.peekFirst() >= ANDROID_SCAN_LIMIT_WINDOW_MS
        ) {
            scanStartTimesMs.removeFirst()
        }
    }

    private fun recordScanStart(nowMs: Long) {
        pruneScanStartHistory(nowMs)
        scanStartTimesMs.addLast(nowMs)
    }

    private fun scanThrottleRetryAfterMs(nowMs: Long): Long {
        pruneScanStartHistory(nowMs)
        var retryAfterMs = 0L
        if (!isScanning && lastScanStopElapsedMs > 0L) {
            retryAfterMs = maxOf(
                retryAfterMs,
                lastScanStopElapsedMs + ANDROID_SCAN_RESTART_COOLDOWN_MS - nowMs
            )
        }
        if (scanStartTimesMs.size >= ANDROID_SCAN_LIMIT_MAX_STARTS) {
            retryAfterMs = maxOf(
                retryAfterMs,
                scanStartTimesMs.peekFirst() + ANDROID_SCAN_LIMIT_WINDOW_MS - nowMs
            )
        }
        return retryAfterMs.coerceAtLeast(0L)
    }

    private fun scanThrottleMessage(retryAfterMs: Long): String {
        return "Android BLE scan throttled; retry after ${retryAfterMs}ms. " +
            "Avoid more than $ANDROID_SCAN_LIMIT_MAX_STARTS startScan calls in " +
            "${ANDROID_SCAN_LIMIT_WINDOW_MS / 1000}s."
    }

    private fun emitScanError(type: Int, time: Long) {
        val message = scanErrorMessage(type, time)
        if (type == BleConfig.SCAN_FAILED_SCANNING_TOO_FREQUENTLY) {
            val retryAfterMs = scanThrottleRetryAfterMs(
                SystemClock.elapsedRealtime()
            ).coerceAtLeast(ANDROID_SCAN_RESTART_COOLDOWN_MS)
            emitError(
                "scan_throttled",
                "$message; retry after ${retryAfterMs}ms",
                mapOf("scanErrorType" to type, "time" to time, "retryAfterMs" to retryAfterMs)
            )
        } else {
            emitError("scan_error", message, mapOf("scanErrorType" to type, "time" to time))
        }
    }

    private fun scanErrorMessage(type: Int, time: Long): String {
        val reason = when (type) {
            BleConfig.SCAN_FAILED_SCANNING_TOO_FREQUENTLY ->
                "scan started too frequently"
            BleConfig.SCAN_FAILED_TOO_THREE ->
                "Android scanner failed after SDK retry"
            BleConfig.SCAN_FAILED_OUT_OF_HARDWARE_RESOURCES ->
                "scanner permission check failed or hardware resources are unavailable"
            else -> "unknown scan error"
        }
        return "AILink scan error type=$type time=$time: $reason"
    }

    private fun initHandshakeData(): ByteArray {
        return ElinkBleCrypto.initHandshakeData()
    }

    private fun getHandshakeEncryptData(data: ByteArray): ByteArray? {
        return ElinkBleCrypto.getHandshakeEncryptData(data)
    }

    private fun checkHandshakeStatus(data: ByteArray): Boolean {
        return ElinkBleCrypto.checkHandshakeStatus(data)
    }

    private fun mcuEncrypt(cid: ByteArray, mac: ByteArray, payload: ByteArray): ByteArray? {
        return ElinkBleCrypto.mcuEncrypt(cid, mac, payload)
    }

    private fun mcuDecrypt(mac: ByteArray, packet: ByteArray): ByteArray? {
        return ElinkBleCrypto.mcuDecrypt(mac, packet)
    }

    private fun decryptBroadcast(payload: ByteArray): ByteArray? {
        return ElinkBleCrypto.decryptBroadcast(payload)
    }

    private fun shortUuid(uuid: UUID): String {
        val text = uuid.toString().uppercase(Locale.US)
        return if (text.startsWith("0000") && text.endsWith("-0000-1000-8000-00805F9B34FB")) {
            text.substring(4, 8)
        } else {
            text
        }
    }

    private fun shortUuidString(uuid: String): String {
        return if (uuid.isBlank()) {
            ""
        } else {
            runCatching { shortUuid(elinkUuid(uuid)) }.getOrElse { uuid.uppercase(Locale.US) }
        }
    }

    private fun elinkUuid(shortOrFullUuid: String): UUID {
        val upper = shortOrFullUuid.uppercase(Locale.US)
        return if (upper.length == 4) {
            UUID.fromString("0000$upper-0000-1000-8000-00805F9B34FB")
        } else {
            UUID.fromString(upper)
        }
    }

    private fun disposeSdkResources() {
        stopScanInternal()
        connectedRemoteId?.let { remoteId ->
            runCatching { AILinkBleManager.getInstance().disconnect(remoteId) }
        }
        sdkCallback?.let { AILinkBleManager.getInstance().removeOnCallbackBle(it) }
        sdkCallback = null
        sdkReady = false
        connectedRemoteId = null
        scanResults.clear()
        listenerAttachedRemoteIds.clear()
    }

    private data class ScanConfig(
        val services: List<String>,
        val scanMode: Int?
    )

    private class ScanThrottledException(
        val retryAfterMs: Long,
        message: String
    ) : IllegalStateException(message)

    companion object {
        private const val METHOD_CHANNEL = "flutter_elink_ble/methods"
        private const val EVENT_CHANNEL = "flutter_elink_ble/events"
        private const val ELINK_CONNECT_SERVICE = "FFE0"
        private const val ELINK_WRITE_CHARACTERISTIC = "FFE1"
        private const val ELINK_NOTIFY_CHARACTERISTIC = "FFE2"
        private const val ELINK_WRITE_NOTIFY_CHARACTERISTIC = "FFE3"
        private const val ANDROID_SCAN_LIMIT_WINDOW_MS = 30_000L
        private const val ANDROID_SCAN_LIMIT_MAX_STARTS = 5
        private const val ANDROID_SCAN_RESTART_COOLDOWN_MS = 1_000L
        private val DEFAULT_SCAN_SERVICES = listOf("F0A0", "FFE0")
    }
}
