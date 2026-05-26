# flutter_elink_ble

[中文 README](README.md)

Flutter plugin for the ElinkThings BLE SDK. The Dart API exposes Bluetooth adapter state, scanning, connection lifecycle, protocol data callbacks, characteristic events, and Elink protocol helpers.

Native code delegates scan, connect, disconnect, and write operations to the official Elink SDK:

- Android: `AILinkBleManager` from `AILinkSDKRepositoryAndroid`
- iOS: `ELAILinkBleManager` from `AILinkBleSDK.framework`

## Features

- Listen to Bluetooth state with `ElinkBle.bluetoothState` or `ElinkBle.setBluetoothStateCallback`.
- Scan Elink broadcast and connectable devices.
- Connect, disconnect, and write BLE data through the native SDK.
- Receive SDK A6/A7 payload callbacks through `ElinkBle.protocolDataPackets`.
- Receive passthrough or non-protocol data through `ElinkBle.passthroughDataPackets`.
- Receive low-level characteristic events through `ElinkBle.characteristicEvents`.
- Parse `CID`, `VID`, `PID`, and `MAC` from Elink manufacturer data.
- Use native SDK helpers for broadcast decrypt and MCU A7 encrypt/decrypt; handshake is handled uniformly in the Flutter A6 data layer.

## Installation

```yaml
dependencies:
  flutter_elink_ble:
    path: ../flutter_elink_ble
```

## Android Setup

The Android implementation initializes the Elink native SDK and bridges SDK callbacks to Dart. It does not implement its own BLE scanning or connection logic.

If the host project does not already include JitPack, add it:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}
```

The plugin manifest declares BLE permissions, but the host app must still request runtime permissions for the current Android version:

```xml
<uses-feature android:name="android.hardware.bluetooth_le" android:required="false" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_CONNECTED_DEVICE" />
```

Android 12 and later must request `BLUETOOTH_SCAN`, `BLUETOOTH_ADVERTISE`, and `BLUETOOTH_CONNECT`; the ordinary AILink SDK scan entry checks the complete Nearby devices permission set. Android 11 and earlier usually require location permission for BLE scanning.

## iOS Setup

Add Bluetooth usage descriptions to the host app `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Need BLE permission to scan and connect Elink devices.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Need BLE permission to scan and connect Elink devices.</string>
```

The plugin currently vendors `AILinkBleSDK.framework`. The sample framework contains an `arm64` device slice, so it is suitable for real device builds. For simulator builds, replace it with an `AILinkBleSDK.xcframework` that includes simulator slices.

`AILinkBleSDK.framework` is a static archive and contains Objective-C categories such as `ELAILinkBleManager+WIFI`. The plugin podspec injects `-ObjC` into the Pod target so those category methods are linked into `flutter_elink_ble.framework`. Run `pod install` again after updating the plugin; otherwise runtime may fail with `unrecognized selector`.

If Bluetooth is on but scanning fails on iOS, check the host app permission text and the app's Bluetooth permission in iOS Settings. Native errors are normalized as `bluetooth_off`, `bluetooth_unauthorized`, `bluetooth_unsupported`, or `bluetooth_not_ready`.

## Quick Start

```dart
import 'package:flutter_elink_ble/flutter_elink_ble.dart';

final supported = await ElinkBle.isSupported;
await ElinkBle.refreshAdapterState();

final stateSub = ElinkBle.bluetoothState.listen((state) {
  print('Bluetooth state: ${state.name}');
});

ElinkBle.setBluetoothStateCallback((state) {
  print('Bluetooth callback: ${state.name}');
});

final scanSub = ElinkBle.scanResults.listen((results) {
  for (final result in results) {
    final elinkData = ElinkDataProcessor.parseAdvertisement(
      result.advertisementData.manufacturerData,
      isBroadcastDevice: result.advertisementData.isBroadcastDevice,
    );
    print('${result.device.remoteId} ${elinkData.macAddress}');
  }
});

await ElinkBle.startScan(
  timeout: const Duration(seconds: 10),
  androidScanMode: ElinkAndroidScanMode.lowLatency, // Android only.
);
```

Connect and write:

```dart
await ElinkBle.connect(result.device);

await ElinkBle.writeA6(result.device.remoteId, [0x01, 0x02]);

await ElinkBle.writeA7(result.device.remoteId, [0x03, 0x04], cid: 0x1234);

await ElinkBle.write(
  result.device.remoteId,
  ElinkDataProcessor.wrapA6Frame([0x01, 0x02]),
);

await ElinkBle.readRssi(result.device.remoteId);

await ElinkBle.setAndroidMtu(result.device.remoteId, 247);
await ElinkBle.setAndroidPreferredPhy(
  result.device.remoteId,
  txPhy: ElinkAndroidPhy.phy2M,
  rxPhy: ElinkAndroidPhy.phy2M,
);

await ElinkBle.disconnect(result.device.remoteId);
await ElinkBle.disconnectCurrent();
```

Generic A6/A7 frame parsing and A7/TLV packet building:

```dart
final commonFrame = ElinkDataProcessor.parseProtocolFrame(
  ElinkDataProcessor.wrapA6Frame([0x0E]),
);
print('${commonFrame.protocol.name} ${commonFrame.payload}');

// Full A7 frame: A7 + CID(2) + payloadLength + TLV payload + checksum + 7A.
final frame = ElinkDataProcessor.parseA7Frame([
  0xA7, 0x00, 0x8F, 0x08,
  0x01, 0x06, 0x67, 0xA7, 0x1F, 0x0E, 0x01, 0x08,
  0xE2, 0x7A,
]);
final tlvs = ElinkDataProcessor.parseTlvPayload(frame.payload);
final timestamp = tlvs.first.readInt(length: 4); // Big-endian by default.

final plainPayloads = ElinkDataProcessor.parsePayload(frame.payload);
print(plainPayloads.first.type);

final request = ElinkDataProcessor.wrapA7TlvFrame(
  cid: 0x008F,
  tlvs: [
    ElinkPayload(type: 0x02), // L=0, no V.
    ElinkPayload(type: 0x03, data: [0x01, 0x01]),
  ],
);
await ElinkBle.write(result.device.remoteId, request);
```

Listen for protocol, passthrough, and characteristic callbacks:

```dart
final protocolSub = ElinkBle.protocolDataPackets.listen((packet) {
  print('${packet.protocol.name} ${packet.deviceType} ${packet.data}');
});

final passthroughSub = ElinkBle.passthroughDataPackets.listen((packet) {
  print(packet.data);
});

final characteristicSub = ElinkBle.characteristicEvents.listen((event) {
  print('${event.operation.name} ${event.characteristicUuid}');
});

final rssiSub = ElinkBle.rssiEvents.listen((event) {
  print('${event.remoteId} ${event.rssi}');
});

final mtuSub = ElinkBle.mtuEvents.listen((event) {
  print('${event.remoteId} ${event.mtu} ${event.availableMtu}');
});
```

Release resources when done:

```dart
await stateSub.cancel();
await scanSub.cancel();
await protocolSub.cancel();
await passthroughSub.cancel();
await characteristicSub.cancel();
await rssiSub.cancel();
await mtuSub.cancel();
await ElinkBle.disconnectCurrent();
await ElinkBle.dispose();
```

## Event Contract

Native events are normalized into these Dart streams:

| Native type | Dart API | Description |
| --- | --- | --- |
| `adapterState` | `ElinkBle.adapterState`, `ElinkBle.bluetoothState` | Bluetooth state |
| `scanResult` | `ElinkBle.scanResults` | Scan results deduplicated by remoteId |
| `scanStopped` | `ElinkBle.isScanning` | Scan stopped or timed out |
| `connectionState` | `ElinkBle.connectionEvents` | GATT connection state |
| `servicesDiscovered` | `ElinkBle.serviceDiscoveryEvents` | Service and characteristic discovery result |
| `protocolData` | `ElinkBle.protocolDataPackets` | SDK A6/A7 payload callback |
| `passthroughData` | `ElinkBle.passthroughDataPackets` | SDK passthrough or non-protocol data |
| `characteristicEvent` | `ElinkBle.characteristicEvents` | Low-level read, write, descriptor write, changed, or notification-state event |
| `rssi` | `ElinkBle.rssiEvents` | Connected-device RSSI read result |
| `mtu` | `ElinkBle.mtuEvents` | Android MTU change result |
| `handshake` | `ElinkBle.handshakeEvents` | Handshake result handled uniformly in the Flutter A6 layer |
| `error` | `ElinkBle.errors` | Plugin error |

## Notes

- Check `ElinkBle.bluetoothStateNow == ElinkAdapterState.on` before scanning.
- Android 7.0+ throttles BLE scanning; avoid more than 5 `startScan` calls in 30 seconds. The plugin reuses an active scan with the same configuration and blocks too-fast Android restarts with `scan_throttled` and `retryAfterMs`.
- iOS `remoteId` is `CBPeripheral.identifier`, not a MAC address.
- iOS does not support active MTU requests from apps; use the system-negotiated maximum write length instead.
- Android 12+ host apps must request `BLUETOOTH_SCAN`, `BLUETOOTH_ADVERTISE`, and `BLUETOOTH_CONNECT` runtime permissions themselves. Android 11 and earlier also require location permission for scanning, and system location services must be enabled.
- A6/A7 writes should use `writeA6` and `writeA7`; the native SDK adds frame headers, tails, and checksums.
- Raw `write` remains available only for business code that already builds full packets.
