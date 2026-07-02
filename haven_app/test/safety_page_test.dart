import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haven_app/pages/student/safety_page.dart';

// SafetyPage est une colonne non-scrollable — la surface de test doit être
// suffisamment haute pour contenir tout le contenu (≥ 800px logiques).
void _useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  Widget buildPage() => const MaterialApp(home: SafetyPage());

  testWidgets('renders headline text', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(buildPage());
    expect(find.text('Tu comptes.\nVraiment.'), findsOneWidget);
  });

  testWidgets('shows the three emergency numbers', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(buildPage());
    expect(find.text('3114'), findsOneWidget);
    expect(find.text('119'),  findsOneWidget);
    expect(find.text('3018'), findsOneWidget);
  });

  testWidgets('shows Rester avec Haven button', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(buildPage());
    expect(find.text('Rester avec Haven'), findsOneWidget);
  });

  testWidgets('shows three Appeler buttons', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(buildPage());
    expect(find.text('Appeler'), findsNWidgets(3));
  });

  testWidgets('tapping Appeler on 3114 opens dialog with correct label', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(buildPage());

    await tester.tap(find.text('Appeler').first);
    await tester.pumpAndSettle();

    expect(find.text('Appeler le 3114'), findsOneWidget);
    expect(find.text('Fermer'), findsOneWidget);
  });

  testWidgets('dialog for 119 shows correct label', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(buildPage());

    await tester.tap(find.text('Appeler').at(1));
    await tester.pumpAndSettle();

    expect(find.text('Appeler le 119'), findsOneWidget);
  });

  testWidgets('dialog closes on Fermer tap', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(buildPage());
    await tester.tap(find.text('Appeler').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();

    expect(find.text('Appeler le 3114'), findsNothing);
    expect(find.text('Tu comptes.\nVraiment.'), findsOneWidget);
  });

  testWidgets('shows team anonymity info card', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(buildPage());
    expect(
      find.textContaining("L'équipe de ton établissement est prévenue"),
      findsOneWidget,
    );
  });
}
