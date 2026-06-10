import 'package:flutter/material.dart';
import 'package:flutter_elink_ble_example/bluetooth_connection_page.dart';
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BluetoothConnectionPage(
            connectedRemoteId: 'AA:BB:CC:DD:EE:FF',
            connectedMacAddress: 'AA:BB:CC:DD:EE:FF',
            bmVersion: null,
            enableTlvParse: false,
            logs: const <String>[],
            onDisconnect: () {},
            onGetBmVersion: () {},
            mtuActionLabel: 'Set MTU 517',
            onMtuAction: () => mtuRequested = true,
            onOpenWifiProvisioning: () => opened = true,
            onEnableTlvParseChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.wifi));
    await tester.tap(find.text('Set MTU 517'));

    expect(opened, isTrue);
    expect(mtuRequested, isTrue);
  });
}
