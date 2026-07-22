package com.elinkthings.flutter_elink_ble

/** 按 remoteId 跟踪当前监听绑定实例，实例变化时允许重新挂载监听。 */
internal class ElinkAndroidListenerBindingRegistry<T : Any> {
    private val bindings = mutableMapOf<String, T>()

    /** 绑定新实例并返回是否需要挂载监听；同一实例重复绑定时返回 false。 */
    @Synchronized
    fun bindIfChanged(remoteId: String, instance: T): Boolean {
        val key = elinkAndroidRemoteIdKey(remoteId)
        if (bindings[key] === instance) return false
        bindings[key] = instance
        return true
    }

    /** 判断指定实例是否仍是 remoteId 当前有效的监听绑定。 */
    @Synchronized
    fun isCurrent(remoteId: String, instance: T): Boolean {
        return bindings[elinkAndroidRemoteIdKey(remoteId)] === instance
    }

    /** 移除 remoteId 当前绑定，供正常断开连接时释放实例引用。 */
    @Synchronized
    fun remove(remoteId: String) {
        bindings.remove(elinkAndroidRemoteIdKey(remoteId))
    }

    /** 仅当指定实例仍为当前绑定时移除，避免失败回滚误删更新后的实例。 */
    @Synchronized
    fun removeIfCurrent(remoteId: String, instance: T) {
        val key = elinkAndroidRemoteIdKey(remoteId)
        if (bindings[key] === instance) {
            bindings.remove(key)
        }
    }

    /** 清空全部监听绑定，供蓝牙适配器会话失效和插件释放时调用。 */
    @Synchronized
    fun clear() {
        bindings.clear()
    }
}
