import 'package:flutter_test/flutter_test.dart';
import 'package:haven_app/services/session_service.dart';

void main() {
  setUp(() {
    SessionService().clearToken();
  });

  group('SessionService — token', () {
    test('getToken returns null by default', () {
      expect(SessionService().getToken(), isNull);
    });

    test('setToken / getToken roundtrip', () {
      SessionService().setToken('tok-abc');
      expect(SessionService().getToken(), 'tok-abc');
    });

    test('setRefreshToken / getRefreshToken roundtrip', () {
      SessionService().setRefreshToken('ref-xyz');
      expect(SessionService().getRefreshToken(), 'ref-xyz');
    });

    test('static fields are shared between instances', () {
      SessionService().setToken('shared');
      // New instance reads the same static field
      expect(SessionService().getToken(), 'shared');
    });
  });

  group('SessionService — user', () {
    test('getRole returns null by default', () {
      expect(SessionService().getRole(), isNull);
    });

    test('getName returns null by default', () {
      expect(SessionService().getName(), isNull);
    });

    test('setUser stores role and name', () {
      SessionService().setUser(role: 'STUDENT', name: 'Alice');
      expect(SessionService().getRole(), 'STUDENT');
      expect(SessionService().getName(), 'Alice');
    });

    test('setUser works for every role', () {
      for (final role in ['STUDENT', 'TEACHER', 'DIRECTOR_CPE', 'RECTORAT', 'PARENT']) {
        SessionService().setUser(role: role, name: 'User');
        expect(SessionService().getRole(), role);
        SessionService().clearToken();
      }
    });
  });

  group('SessionService — clearToken', () {
    test('clearToken resets token', () {
      SessionService().setToken('tok');
      SessionService().clearToken();
      expect(SessionService().getToken(), isNull);
    });

    test('clearToken resets refreshToken', () {
      SessionService().setRefreshToken('ref');
      SessionService().clearToken();
      expect(SessionService().getRefreshToken(), isNull);
    });

    test('clearToken resets role and name', () {
      SessionService().setUser(role: 'TEACHER', name: 'Bob');
      SessionService().clearToken();
      expect(SessionService().getRole(), isNull);
      expect(SessionService().getName(), isNull);
    });
  });
}
