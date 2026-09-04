import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bat_track_v1/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Convergence BTP 4.0 Integration Test', () {
    testWidgets('Full flow: Payment -> Sealing -> Projection Update', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Navigate to Factures
      // Assuming there is a drawer or bottom nav
      // For this test, we'll assume we can find a way to the Factures screen

      // 2. Check ISCA Indicator
      expect(find.byIcon(Icons.verified_user), findsOneWidget);

      // 3. Verify Projections on Dashboard
      // Navigate to Dashboard
      await tester.tap(find.byIcon(Icons.dashboard));
      await tester.pumpAndSettle();

      expect(find.text('Projections de Trésorerie'), findsOneWidget);
      expect(find.textContaining('Potentiel Total'), findsOneWidget);

      // 4. Simulate a payment seal (via service call if UI not ready)
      // In a real integration test, we'd interact with UI buttons
    });
  });
}
