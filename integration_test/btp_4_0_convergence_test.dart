import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bat_track_v1/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Convergence BTP 4.0 Integration Test', () {
    testWidgets('Full flow: Sealing -> Dashboard Projections', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // We might need to handle login here if the app starts on LoginScreen
      // For this integration test, we check if we can see the Dashboard or elements of it.
      
      // Navigate to Dashboard if not already there
      final dashboardIcon = find.byIcon(Icons.dashboard);
      if (dashboardIcon.evaluate().isNotEmpty) {
        await tester.tap(dashboardIcon);
        await tester.pumpAndSettle();
      }

      // Check for Projections
      expect(find.text('Projections de Trésorerie'), findsOneWidget);
      expect(find.textContaining('Potentiel Total'), findsOneWidget);

      // Check for ISCA Integrity Indicator
      final verifiedIcon = find.byIcon(Icons.verified_user);
      final maybeIcon = find.byIcon(Icons.gpp_maybe);
      expect(verifiedIcon.evaluate().isNotEmpty || maybeIcon.evaluate().isNotEmpty, isTrue);
    });
  });
}
