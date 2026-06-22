// This is a basic Flutter widget test for Mini Nmap.

import 'package:flutter_test/flutter_test.dart';

import 'package:mini_nmap/main.dart';

void main() {
  testWidgets('Mini Nmap app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app shows the title "Mini Nmap".
    expect(find.text('Mini Nmap'), findsOneWidget);
    expect(find.text('Red detectada:'), findsOneWidget);
  });
}
