// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:kita_kerja/main.dart';

void main() {
  testWidgets('App smoke test initializes without errors', (WidgetTester tester) async {
    // Build our app and trigger initial frame.
    await tester.pumpWidget(const MyApp());

    // Verify MyApp renders initial preloader
    expect(find.byType(MyApp), findsOneWidget);

    // Pump past preloader duration to clear timers
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
