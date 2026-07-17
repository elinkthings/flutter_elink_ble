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
}
