package com.elinkthings.flutter_elink_ble

import java.util.Locale

/** 将 Android BLE remoteId 统一为不受大小写影响的内部索引键。 */
internal fun elinkAndroidRemoteIdKey(remoteId: String): String {
    return remoteId.uppercase(Locale.US)
}
