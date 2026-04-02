import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:authvault/main.dart';

void main() {
  testWidgets('AuthVault app builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AuthVaultApp()));
    expect(find.text('AuthVault'), findsOneWidget);
  });
}
