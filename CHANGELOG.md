## 0.0.2

* Added common A6/A7 protocol frame parsing, validation, wrapping, and payload
  helpers.
* Added `ElinkPayload` as the shared `{type, data}` object for plain and TLV
  payload parsing.
* Added opt-in TLV parsing for A6/A7 payload logs in the example app; plain
  parsing remains the default.
* Renamed the model source file from `elink_models.dart` to
  `elink_ble_models.dart`.
* Filtered duplicate consecutive connection state events so repeated
  `connecting` logs are not emitted.

## 0.0.1

* Initial Elink BLE plugin scaffold.
