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
