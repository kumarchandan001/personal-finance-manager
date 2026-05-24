import 'package:flutter_test/flutter_test.dart';
import 'package:fintelia/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App builds and runs successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: FINTELIAApp()));

    // Verify that the app starts.
    expect(find.byType(FINTELIAApp), findsOneWidget);
  });
}
