import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:haven_app/services/preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PreferencesService — token', () {
    test('getToken returns null initially', () async {
      expect(await PreferencesService().getToken(), isNull);
    });

    test('saveToken / getToken roundtrip', () async {
      await PreferencesService().saveToken('my-token');
      expect(await PreferencesService().getToken(), 'my-token');
    });

    test('removeToken clears stored value', () async {
      await PreferencesService().saveToken('tok');
      await PreferencesService().removeToken();
      expect(await PreferencesService().getToken(), isNull);
    });
  });

  group('PreferencesService — refreshToken', () {
    test('getRefreshToken returns null initially', () async {
      expect(await PreferencesService().getRefreshToken(), isNull);
    });

    test('saveRefreshToken / getRefreshToken roundtrip', () async {
      await PreferencesService().saveRefreshToken('ref-xyz');
      expect(await PreferencesService().getRefreshToken(), 'ref-xyz');
    });

    test('removeRefreshToken clears stored value', () async {
      await PreferencesService().saveRefreshToken('ref-xyz');
      await PreferencesService().removeRefreshToken();
      expect(await PreferencesService().getRefreshToken(), isNull);
    });
  });

  group('PreferencesService — role', () {
    test('getRole returns null initially', () async {
      expect(await PreferencesService().getRole(), isNull);
    });

    test('saveRole / getRole roundtrip', () async {
      await PreferencesService().saveRole('STUDENT');
      expect(await PreferencesService().getRole(), 'STUDENT');
    });

    test('removeRole clears stored value', () async {
      await PreferencesService().saveRole('TEACHER');
      await PreferencesService().removeRole();
      expect(await PreferencesService().getRole(), isNull);
    });
  });

  group('PreferencesService — name', () {
    test('getName returns null initially', () async {
      expect(await PreferencesService().getName(), isNull);
    });

    test('saveName / getName roundtrip', () async {
      await PreferencesService().saveName('Alice');
      expect(await PreferencesService().getName(), 'Alice');
    });

    test('removeName clears stored value', () async {
      await PreferencesService().saveName('Bob');
      await PreferencesService().removeName();
      expect(await PreferencesService().getName(), isNull);
    });
  });

  group('PreferencesService — onboarding', () {
    test('hasSeenOnboarding returns false initially', () async {
      expect(await PreferencesService().hasSeenOnboarding(), isFalse);
    });

    test('setOnboardingSeen marks onboarding as seen', () async {
      await PreferencesService().setOnboardingSeen();
      expect(await PreferencesService().hasSeenOnboarding(), isTrue);
    });
  });

  group('PreferencesService — integrity hash', () {
    test('getIntegrityHash returns null for unknown id', () async {
      expect(await PreferencesService().getIntegrityHash('ghost'), isNull);
    });

    test('saveIntegrityHash / getIntegrityHash roundtrip', () async {
      await PreferencesService().saveIntegrityHash('report-1', 'hash-abc');
      expect(await PreferencesService().getIntegrityHash('report-1'), 'hash-abc');
    });

    test('hashes are scoped by reportId', () async {
      await PreferencesService().saveIntegrityHash('r1', 'hash-1');
      await PreferencesService().saveIntegrityHash('r2', 'hash-2');
      expect(await PreferencesService().getIntegrityHash('r1'), 'hash-1');
      expect(await PreferencesService().getIntegrityHash('r2'), 'hash-2');
    });
  });

  group('PreferencesService — report snapshot', () {
    test('getReportSnapshot returns null for unknown id', () async {
      expect(await PreferencesService().getReportSnapshot('ghost'), isNull);
    });

    test('saveReportSnapshot / getReportSnapshot roundtrip', () async {
      final snapshot = {'type': 'VERBAL', 'gravity': 3, 'mode': 'VICTIM'};
      await PreferencesService().saveReportSnapshot('report-2', snapshot);
      final result = await PreferencesService().getReportSnapshot('report-2');
      expect(result?['type'], 'VERBAL');
      expect(result?['gravity'], 3);
      expect(result?['mode'], 'VICTIM');
    });

    test('snapshots are scoped by reportId', () async {
      await PreferencesService().saveReportSnapshot('r1', {'type': 'PHYSICAL'});
      await PreferencesService().saveReportSnapshot('r2', {'type': 'CYBER'});
      expect((await PreferencesService().getReportSnapshot('r1'))?['type'], 'PHYSICAL');
      expect((await PreferencesService().getReportSnapshot('r2'))?['type'], 'CYBER');
    });
  });
}
