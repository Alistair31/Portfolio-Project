import 'package:flutter_test/flutter_test.dart';
import 'package:haven_app/services/api_service.dart';

void main() {
  group('AuthUser', () {
    test('stores id, name and role', () {
      final user = AuthUser(id: 'u1', name: 'Alice', role: 'STUDENT');
      expect(user.id, 'u1');
      expect(user.name, 'Alice');
      expect(user.role, 'STUDENT');
    });

    test('accepts every valid role', () {
      for (final role in ['STUDENT', 'TEACHER', 'DIRECTOR_CPE', 'RECTORAT', 'PARENT']) {
        final user = AuthUser(id: 'x', name: 'X', role: role);
        expect(user.role, role);
      }
    });
  });

  group('AuthResponse', () {
    test('stores token, refreshToken and user', () {
      final user = AuthUser(id: 'u2', name: 'Bob', role: 'TEACHER');
      final resp = AuthResponse(token: 'tok', refreshToken: 'ref', user: user);
      expect(resp.token, 'tok');
      expect(resp.refreshToken, 'ref');
      expect(resp.user.name, 'Bob');
      expect(resp.user.role, 'TEACHER');
    });
  });

  group('TokenPair', () {
    test('stores token and refreshToken', () {
      final pair = TokenPair(token: 'access', refreshToken: 'refresh');
      expect(pair.token, 'access');
      expect(pair.refreshToken, 'refresh');
    });
  });

  group('School', () {
    test('stores code, name and type', () {
      final school = School(code: 'LYC01', name: 'Lycée Fermat', type: 'LYC');
      expect(school.code, 'LYC01');
      expect(school.name, 'Lycée Fermat');
      expect(school.type, 'LYC');
    });
  });
}
