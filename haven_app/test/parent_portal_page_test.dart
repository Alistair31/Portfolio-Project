import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haven_app/pages/parent_portal_page.dart';

void main() {
  Widget buildPage() => const MaterialApp(home: ParentPortalPage());

  testWidgets('shows code entry screen initially', (tester) async {
    await tester.pumpWidget(buildPage());

    expect(find.text('Suivez la situation\nde votre enfant.'), findsOneWidget);
    expect(find.text('Accéder au suivi'), findsOneWidget);
    expect(find.text('Suivi du signalement'), findsNothing);
  });

  testWidgets('shows Haven portal header label', (tester) async {
    await tester.pumpWidget(buildPage());
    expect(find.text('Haven · Portail parents'), findsOneWidget);
  });

  testWidgets('shows snackbar when tapping access with empty code', (tester) async {
    await tester.pumpWidget(buildPage());

    await tester.tap(find.text('Accéder au suivi'));
    await tester.pump();

    expect(find.text('Saisis un code de suivi.'), findsOneWidget);
    // Code entry screen is still visible
    expect(find.text('Suivi du signalement'), findsNothing);
  });

  testWidgets('shows loading indicator after entering code', (tester) async {
    await tester.pumpWidget(buildPage());

    await tester.enterText(find.byType(TextField), 'HVN-AB12-CD34');
    await tester.tap(find.text('Accéder au suivi'));
    await tester.pump(); // after tap, _loading = true

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Advance past the pending Future.delayed so the test can clean up cleanly.
    await tester.pump(const Duration(milliseconds: 700));
  });

  testWidgets('shows tracking view after 600ms delay', (tester) async {
    await tester.pumpWidget(buildPage());

    await tester.enterText(find.byType(TextField), 'HVN-AB12-CD34');
    await tester.tap(find.text('Accéder au suivi'));
    await tester.pump();                                    // kick off Future.delayed
    await tester.pump(const Duration(milliseconds: 700));  // advance past 600ms

    expect(find.text('Suivi du signalement'), findsOneWidget);
    expect(find.text('Accéder au suivi'), findsNothing);
  });

  testWidgets('tracking view shows Contacter établissement button', (tester) async {
    await tester.pumpWidget(buildPage());

    await tester.enterText(find.byType(TextField), 'HVN-TEST');
    await tester.tap(find.text('Accéder au suivi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.textContaining("Contacter l'établissement"), findsOneWidget);
  });

  testWidgets('tracking view shows Situation prise en charge card', (tester) async {
    await tester.pumpWidget(buildPage());

    await tester.enterText(find.byType(TextField), 'HVN-TEST');
    await tester.tap(find.text('Accéder au suivi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Situation prise en charge'), findsOneWidget);
  });

  testWidgets('contact dialog shows school info', (tester) async {
    await tester.pumpWidget(buildPage());

    await tester.enterText(find.byType(TextField), 'HVN-TEST');
    await tester.tap(find.text('Accéder au suivi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    await tester.tap(find.textContaining("Contacter l'établissement"));
    await tester.pumpAndSettle();

    expect(find.textContaining('Lycée Saint-Joseph'), findsOneWidget);
  });
}
