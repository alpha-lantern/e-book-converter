import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin/main.dart';

void main() {
  testWidgets('Admin Dashboard smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the dashboard text is present.
    expect(find.text('Codex Admin Dashboard'), findsOneWidget);
  });
}
