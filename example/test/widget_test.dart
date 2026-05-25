import 'package:flutter/material.dart';
import 'package:flutter_elink_ble_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows Elink BLE home page', (WidgetTester tester) async {
    await tester.pumpWidget(const ElinkExampleApp());

    expect(find.text('Elink BLE'), findsOneWidget);
    expect(find.byIcon(Icons.bluetooth_searching), findsOneWidget);
  });
}
