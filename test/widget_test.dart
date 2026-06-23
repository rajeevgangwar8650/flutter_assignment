import 'package:flutter_assignment/app.dart';
import 'package:flutter_assignment/config/di/injection_container.dart' as di;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows login when no saved session exists', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await di.initDependencies();

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
