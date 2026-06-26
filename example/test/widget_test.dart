import 'package:flutter/material.dart';
import 'package:flutter_elink_ble_example/bluetooth_connection_page.dart';
import 'package:flutter_elink_ble_example/connected_device_info.dart';
import 'package:flutter_elink_ble_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows Elink BLE home page', (WidgetTester tester) async {
    await tester.pumpWidget(const ElinkExampleApp());

    expect(find.text('Elink BLE'), findsOneWidget);
    expect(find.text('Scan'), findsWidgets);
    expect(find.text('No BLE devices'), findsOneWidget);
    expect(find.text('Connection'), findsNothing);
    expect(find.text('WiFi'), findsNothing);
    expect(find.byIcon(Icons.bluetooth_searching), findsWidgets);
    expect(find.byIcon(Icons.wifi), findsNothing);
  });

  testWidgets('connection page exposes WiFi and MTU actions', (
    WidgetTester tester,
  ) async {
    var opened = false;
    var mtuRequested = false;
    var logsCleared = false;
    var legacyBmRequested = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BluetoothConnectionPage(
            connectedDevice: const ConnectedDeviceInfo(
              remoteId: 'AA:BB:CC:DD:EE:FF',
              macAddress: 'AA:BB:CC:DD:EE:FF',
              bmVersion: null,
              handshakeReady: false,
            ),
            enableTlvParse: false,
            logs: const <String>['[00:00:00] demo'],
            onClearLogs: () => logsCleared = true,
            onDisconnect: () {},
            onGetBmVersion: () {},
            onGetLegacyBmVersion: () => legacyBmRequested = true,
            mtuActionLabel: 'Set MTU 517',
            onMtuAction: () => mtuRequested = true,
            onOpenWifiProvisioning: () => opened = true,
            onEnableTlvParseChanged: (_) {},
            showAndroidCommandResendSetting: false,
            androidCommandResendCount: 0,
            onAndroidCommandResendCountChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.wifi));
    await tester.tap(find.text('BM 0x0E'));
    await tester.tap(find.text('Set MTU 517'));
    await tester.tap(find.byTooltip('Clear logs'));

    expect(opened, isTrue);
    expect(mtuRequested, isTrue);
    expect(logsCleared, isTrue);
    expect(legacyBmRequested, isTrue);
  });
}
