package com.elinkthings.flutter_elink_ble

/** 当前 FlutterEngine 管理的 Android BLE 连接阶段。 */
internal enum class ElinkAndroidConnectionPhase {
    CONNECTING,
    CONNECTED,
    DISCONNECTING,
}

/** 当前 FlutterEngine 持有的 Android BLE 连接记录。 */
internal data class ElinkAndroidManagedConnection(
    val remoteId: String,
    var phase: ElinkAndroidConnectionPhase,
)

/** 按 FlutterEngine 记录其发起的连接，避免释放其他使用方持有的 SDK 连接。 */
internal class ElinkAndroidConnectionRegistry {
    private val connections = linkedMapOf<String, ElinkAndroidManagedConnection>()

    /** 在调用 SDK connect 前登记连接，覆盖连接中的 Engine detach 竞态。 */
    fun trackConnecting(remoteId: String) {
        connections[elinkAndroidRemoteIdKey(remoteId)] = ElinkAndroidManagedConnection(
            remoteId = remoteId,
            phase = ElinkAndroidConnectionPhase.CONNECTING,
        )
    }

    /** 仅更新当前 Engine 已登记连接的成功状态，并返回该连接是否属于当前 Engine。 */
    fun markConnected(remoteId: String): Boolean {
        val connection = connections[elinkAndroidRemoteIdKey(remoteId)] ?: return false
        connection.phase = ElinkAndroidConnectionPhase.CONNECTED
        return true
    }

    /** 标记当前 Engine 已登记的连接正在断开，并返回是否找到该连接。 */
    fun markDisconnecting(remoteId: String): Boolean {
        val connection = connections[elinkAndroidRemoteIdKey(remoteId)] ?: return false
        connection.phase = ElinkAndroidConnectionPhase.DISCONNECTING
        return true
    }

    /** 判断指定设备连接是否由当前 Engine 发起管理。 */
    fun owns(remoteId: String): Boolean {
        return connections.containsKey(elinkAndroidRemoteIdKey(remoteId))
    }

    /** 在连接进入断开终态或同步连接失败时移除记录。 */
    fun remove(remoteId: String): Boolean {
        return connections.remove(elinkAndroidRemoteIdKey(remoteId)) != null
    }

    /** 返回稳定快照，供 Engine detach 定向释放而不受回调修改影响。 */
    fun remoteIdsSnapshot(): List<String> {
        return connections.values.map { it.remoteId }
    }

    /** 返回连接状态副本，供 EventChannel 重新监听时恢复当前状态。 */
    fun connectionsSnapshot(): List<ElinkAndroidManagedConnection> {
        return connections.values.map { it.copy() }
    }

    /** 清空当前 Engine 的全部连接所有权记录。 */
    fun clear() {
        connections.clear()
    }
}
