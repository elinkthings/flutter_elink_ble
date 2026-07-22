package com.elinkthings.flutter_elink_ble

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

internal class ElinkBlePluginTest {
    @Test
    fun pluginClassNameUsesElinkPrefix() {
        assertEquals("ElinkBlePlugin", ElinkBlePlugin::class.simpleName)
    }

    // 验证连接所有权按 Engine 隔离且 remoteId 比较不受大小写影响。
    @Test
    fun connectionRegistryTracksOnlyCurrentEngineConnections() {
        val registry = ElinkAndroidConnectionRegistry()

        registry.trackConnecting("aa:bb:cc:dd:ee:ff")

        assertTrue(registry.owns("AA:BB:CC:DD:EE:FF"))
        assertTrue(registry.markConnected("AA:BB:CC:DD:EE:FF"))
        assertEquals(
            ElinkAndroidConnectionPhase.CONNECTED,
            registry.connectionsSnapshot().single().phase,
        )
        assertEquals(
            listOf("aa:bb:cc:dd:ee:ff"),
            registry.remoteIdsSnapshot(),
        )
        assertFalse(registry.owns("11:22:33:44:55:66"))
    }

    // 验证 detach 清理使用稳定快照，不会被同步断开回调修改。
    @Test
    fun connectionRegistrySnapshotRemainsStableDuringDetachCleanup() {
        val registry = ElinkAndroidConnectionRegistry()
        registry.trackConnecting("device-a")
        registry.trackConnecting("device-b")
        val snapshot = registry.remoteIdsSnapshot()

        registry.clear()

        assertEquals(listOf("device-a", "device-b"), snapshot)
        assertFalse(registry.owns("device-a"))
        assertFalse(registry.markDisconnecting("device-b"))
    }

    // 验证监听绑定按对象身份判断，remoteId 大小写变化不会导致同一实例重复挂载。
    @Test
    fun listenerBindingRegistryTracksCurrentInstanceIdentity() {
        val registry = ElinkAndroidListenerBindingRegistry<Any>()
        val firstDevice = Any()
        val secondDevice = Any()

        assertTrue(registry.bindIfChanged("aa:bb:cc:dd:ee:ff", firstDevice))
        assertFalse(registry.bindIfChanged("AA:BB:CC:DD:EE:FF", firstDevice))
        assertTrue(registry.isCurrent("AA:BB:CC:DD:EE:FF", firstDevice))

        assertTrue(registry.bindIfChanged("AA:BB:CC:DD:EE:FF", secondDevice))
        assertFalse(registry.isCurrent("aa:bb:cc:dd:ee:ff", firstDevice))
        assertTrue(registry.isCurrent("aa:bb:cc:dd:ee:ff", secondDevice))
    }

    // 验证旧实例失败回滚不会误删新绑定，适配器清理后同一实例可以重新挂载。
    @Test
    fun listenerBindingRegistryRollbackAndClearAreInstanceSafe() {
        val registry = ElinkAndroidListenerBindingRegistry<Any>()
        val firstDevice = Any()
        val secondDevice = Any()

        registry.bindIfChanged("device-a", firstDevice)
        registry.bindIfChanged("device-a", secondDevice)
        registry.removeIfCurrent("device-a", firstDevice)
        assertFalse(registry.bindIfChanged("device-a", secondDevice))

        registry.removeIfCurrent("device-a", secondDevice)
        assertTrue(registry.bindIfChanged("device-a", secondDevice))
        registry.clear()
        assertTrue(registry.bindIfChanged("device-a", secondDevice))
    }
}
