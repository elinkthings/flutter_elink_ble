package com.elinkthings.flutter_elink_ble

import kotlin.test.Test
import kotlin.test.assertEquals

internal class ElinkBlePluginTest {
    @Test
    fun pluginClassNameUsesElinkPrefix() {
        assertEquals("ElinkBlePlugin", ElinkBlePlugin::class.simpleName)
    }
}
