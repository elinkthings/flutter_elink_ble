import 'package:flutter_elink_ble/flutter_elink_ble.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('adapter support is callable', (WidgetTester tester) async {
    final supported = await ElinkBle.isSupported;
    expect(supported, isA<bool>());
  });
}
