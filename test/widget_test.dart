import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_control/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Health Control App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HealthControlApp());
    expect(find.byType(HealthControlApp), findsOneWidget);
  });
}
