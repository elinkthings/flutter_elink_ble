import 'package:flutter/material.dart';
import 'package:flutter_elink_ble/flutter_elink_ble.dart';
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

  testWidgets('connection page routes actions and selected priority', (
    WidgetTester tester,
  ) async {
    var opened = false;
    var mtuRequested = false;
    var randomQueries = 0;
    ElinkConnectionPriority? selectedPriority;
    var logsCleared = false;

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
            onSendRandomQuery: () => randomQueries++,
            onSetConnectPriority: (priority) => selectedPriority = priority,
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
    await tester.tap(find.text('Set MTU 517'));
    await tester.tap(find.text('Send random query now'));
    await tester.tap(find.byTooltip('Set connection priority'));
    await tester.pumpAndSettle();
    for (final priority in ElinkConnectionPriority.values) {
      expect(find.text(priority.name), findsOneWidget);
    }
    await tester.tap(find.text('high'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear logs'));

    expect(opened, isTrue);
    expect(mtuRequested, isTrue);
    expect(randomQueries, 1);
    expect(selectedPriority, ElinkConnectionPriority.high);
    expect(logsCleared, isTrue);
  });
}
