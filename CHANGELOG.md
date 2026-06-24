## 0.2.0

* **Breaking:** removed `disconnectCurrent`; disconnect a specific connection
  with `ElinkBle.disconnect(remoteId)`.
* Added Flutter-controlled Android command resend configuration with
  `ElinkBle.setAndroidCommandResendCount()`. `resendCount >= 1` enables SDK
  resend and `0` disables it; default is disabled.
* Added iOS multi-device connection support by routing each remoteId through
  its own `ELAILinkBleManager` session. Writes, RSSI, MTU queries, and
  disconnects are now scoped to the target remoteId.
* Optimized iOS connect by trying `retrievePeripherals(withIdentifiers:)` in
  the target session before falling back to a session-local scan.
* Scoped Flutter A6 handshake state by remoteId so multiple connected devices
  do not overwrite each other's handshake seed.
* Updated the example app with one tab per connected device, automatic tab
  switching after connection, per-device logs with per-tab clearing, connected
  scan-result state, and Android resend-count controls.

## 0.1.3

* Changed native `connect` behavior so Android and iOS no longer stop active
  BLE scanning from inside the plugin.
* Updated the example app's single-device flow to call `ElinkBle.stopScan()`
  before connecting the selected device.
* Documented that scan lifecycle ownership belongs to the business layer, so
  multi-device workflows can keep scanning while connecting devices.

## 0.1.2

* Added `wifiConfigureServerAndConnect` for the server-first WiFi provisioning
  flow: write server host, port, and path before WiFi MAC, password, and
  connect commands.
* Updated WiFi command sequencing to wait for command responses before sending
  the next provisioning step.
* Fixed empty server path payloads and exposed reusable server command builders.
* Updated the example WiFi provisioning page with default production server
  settings and removed the standalone Set Password action.
* Updated README examples to recommend the server-first WiFi provisioning flow.

## 0.1.1

* Added iOS maximum write length query support via `ElinkBle.getIosMtu()`.
  It reports CoreBluetooth `.withoutResponse` and `.withResponse` payload
  limits for the active connection.
* Updated the example connection page so Android requests MTU 517 while iOS
  reads the negotiated maximum write lengths.
* Documented the example BLE flow for scan, connect, handshake, BM version, and
  MTU handling.

## 0.1.0

* Added Dart-side WiFi provisioning support that builds A6 WiFi commands through
  the shared `writeA6` path instead of platform-specific WiFi method-channel
  calls.
* Added WiFi scan, status, response, MAC, SSID, password, device SN, and server
  configuration event parsing.
* Added typed WiFi models and streams for access points, connection status,
  command responses, and generic WiFi events.
* Added a WiFi command log switch. Command logs are disabled by default.
* Added manufacturer data MAC parsing and exposed the parsed MAC on scan
  results.
* Updated the example app with scan, connection, and WiFi provisioning pages.

## 0.0.3

* Added `ElinkDataProcessor.buildTlvPayloadChunks()` for splitting TLV lists
  into max-length A7 payload chunks.
* Added `ElinkDataProcessor.formatHex()` and updated the example app to reuse
  it for byte logs.

## 0.0.2

* Added common A6/A7 protocol frame parsing, validation, wrapping, and payload
  helpers.
* Added `ElinkPayload` as the shared `{type, data}` object for plain and TLV
  payload parsing.
* Added `ElinkBle.openBluetooth()` to guide users to enable Bluetooth.
* Added opt-in TLV parsing for A6/A7 payload logs in the example app; plain
  parsing remains the default.
* Renamed the model source file from `elink_models.dart` to
  `elink_ble_models.dart`.
* Filtered duplicate consecutive connection state events so repeated
  `connecting` logs are not emitted.

## 0.0.1

* Initial Elink BLE plugin scaffold.
