import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:haven_app/pages/report/report_summary_page.dart';
import 'package:haven_app/services/session_service.dart';

const _testPage = ReportSummaryPage(
  mode: 'VICTIM',
  type: 'VERBAL',
  categoryLabel: 'Moqueries, insultes',
  anonymityLevel: 'FULLY_ANONYMOUS',
  gravity: 3,
  description: 'Description du test unitaire pour Haven.',
  targetLevel: 'TEACHER',
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SessionService().clearToken();
  });

  Widget buildPage() => const MaterialApp(home: _testPage);

  testWidgets('shows ÉTAPE 3 / 3 step header', (tester) async {
    await tester.pumpWidget(buildPage());
    expect(find.text('ÉTAPE 3 / 3'), findsOneWidget);
  });

  testWidgets('shows page title', (tester) async {
    await tester.pumpWidget(buildPage());
    expect(find.text("Avant d'envoyer"), findsOneWidget);
  });

  testWidgets('shows categoryLabel in summary row', (tester) async {
    await tester.pumpWidget(buildPage());
    expect(find.text('Moqueries, insultes'), findsOneWidget);
  });

  testWidgets('maps FULLY_ANONYMOUS to Anonyme', (tester) async {
    await tester.pumpWidget(buildPage());
    expect(find.text('Anonyme'), findsOneWidget);
  });

  testWidgets('maps TEACHER target to Professeur principal', (tester) async {
    await tester.pumpWidget(buildPage());
    expect(find.text('Professeur principal'), findsOneWidget);
  });

  testWidgets('shows description in quoted block', (tester) async {
    await tester.pumpWidget(buildPage());
    expect(
      find.textContaining('Description du test unitaire pour Haven.'),
      findsOneWidget,
    );
  });

  testWidgets('shows danger button', (tester) async {
    await tester.pumpWidget(buildPage());
    expect(find.text('Je suis en danger maintenant'), findsOneWidget);
  });

  testWidgets('shows Envoyer button', (tester) async {
    await tester.pumpWidget(buildPage());
    expect(find.text("Envoyer à l'équipe"), findsOneWidget);
  });

  testWidgets('submit without session shows Session expirée snackbar', (tester) async {
    // SessionService has no token (cleared in setUp)
    await tester.pumpWidget(buildPage());

    await tester.tap(find.text("Envoyer à l'équipe"));
    await tester.pump();

    expect(find.text('Session expirée, reconnecte-toi'), findsOneWidget);
  });

  testWidgets('summary rows show Situation, Anonymat, Destinataire labels', (tester) async {
    await tester.pumpWidget(buildPage());
    expect(find.text('Situation'),    findsOneWidget);
    expect(find.text('Anonymat'),     findsOneWidget);
    expect(find.text('Destinataire'), findsOneWidget);
  });

  group('label mapping — anonymityLevel', () {
    testWidgets('NONE → Identifié·e', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ReportSummaryPage(
        mode: 'VICTIM', type: 'PHYSICAL', categoryLabel: 'Violence physique',
        anonymityLevel: 'NONE', gravity: 1,
        description: 'Test description minimum.', targetLevel: 'TEACHER',
      )));
      expect(find.text('Identifié·e'), findsOneWidget);
    });

    testWidgets('NAME_HIDDEN → Ma classe seulement', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ReportSummaryPage(
        mode: 'VICTIM', type: 'CYBER', categoryLabel: 'Cyberharcèlement',
        anonymityLevel: 'NAME_HIDDEN', gravity: 2,
        description: 'Test description minimum.', targetLevel: 'DIRECTOR_CPE',
      )));
      expect(find.text('Ma classe seulement'), findsOneWidget);
    });
  });

  group('label mapping — targetLevel', () {
    testWidgets('DIRECTOR_CPE → Direction / CPE', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ReportSummaryPage(
        mode: 'WITNESS', type: 'OTHER', categoryLabel: 'Autre',
        anonymityLevel: 'FULLY_ANONYMOUS', gravity: 2,
        description: 'Test description minimum.', targetLevel: 'DIRECTOR_CPE',
      )));
      expect(find.text('Direction / CPE'), findsOneWidget);
    });

    testWidgets('RECTORAT → Rectorat', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ReportSummaryPage(
        mode: 'VICTIM', type: 'SEXUAL', categoryLabel: 'Violence sexuelle',
        anonymityLevel: 'FULLY_ANONYMOUS', gravity: 5,
        description: 'Test description minimum.', targetLevel: 'RECTORAT',
      )));
      expect(find.text('Rectorat'), findsOneWidget);
    });
  });
}
