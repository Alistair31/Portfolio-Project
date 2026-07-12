import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:haven_app/services/api_service.dart';

// ApiService appelle les fonctions top-level de `package:http` (http.get/post/...)
// plutôt qu'un client injecté — http.runWithClient() permet de les intercepter
// dans une zone sans toucher au code de production.
Future<T> withMockClient<T>(
  Future<http.Response> Function(http.Request request) handler,
  Future<T> Function() body,
) {
  return http.runWithClient(body, () => MockClient((request) async => handler(request)));
}

void main() {
  group('ApiService.login', () {
    test('returns an AuthResponse on 200', () async {
      final result = await withMockClient(
        (request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/auth/login');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['email'], 'a@b.com');
          expect(body['password'], 'secret');
          return http.Response(
            jsonEncode({
              'token': 'access-tok',
              'refreshToken': 'refresh-tok',
              'user': {'id': 'u1', 'name': 'Alice', 'role': 'STUDENT'},
            }),
            200,
          );
        },
        () => ApiService().login('a@b.com', 'secret'),
      );

      expect(result.token, 'access-tok');
      expect(result.refreshToken, 'refresh-tok');
      expect(result.user.name, 'Alice');
      expect(result.user.role, 'STUDENT');
    });

    test('throws with the server error message on 401', () async {
      await expectLater(
        withMockClient(
          (request) async => http.Response(jsonEncode({'error': 'Invalid email or password'}), 401),
          () => ApiService().login('a@b.com', 'wrong'),
        ),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Invalid email or password'))),
      );
    });
  });

  group('ApiService.submitReport', () {
    test('extracts trackingCode from the response (régression bug #22)', () async {
      final result = await withMockClient(
        (request) async {
          expect(request.url.path, '/api/reports');
          return http.Response(
            jsonEncode({
              'success': true,
              'id': 'r1',
              'trackingCode': 'HVN-AB12-CD34',
              'integrityHash': 'hash123',
            }),
            201,
          );
        },
        () => ApiService().submitReport(
          token: 'tok',
          mode: 'VICTIM',
          type: 'VERBAL',
          gravity: 3,
          description: 'Une description suffisamment longue.',
          targetLevel: 'TEACHER',
          anonymityLevel: 'NONE',
        ),
      );

      expect(result['id'], 'r1');
      expect(result['trackingCode'], 'HVN-AB12-CD34');
      expect(result['integrityHash'], 'hash123');
    });

    test('throws on non-201 response', () async {
      await expectLater(
        withMockClient(
          (request) async => http.Response(jsonEncode({'error': 'Données invalides.'}), 400),
          () => ApiService().submitReport(
            token: 'tok',
            mode: 'VICTIM',
            type: 'VERBAL',
            gravity: 3,
            description: 'trop court',
            targetLevel: 'TEACHER',
            anonymityLevel: 'NONE',
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('ApiService.sendReportMessage (élève)', () {
    test('posts to reports/mine/:id/messages and returns the created message', () async {
      final result = await withMockClient(
        (request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/reports/mine/r1/messages');
          expect(jsonDecode(request.body)['body'], 'Bonjour, besoin d\'aide.');
          return http.Response(
            jsonEncode({
              'id': 'm1',
              'body': 'Bonjour, besoin d\'aide.',
              'senderRole': 'STUDENT',
              'createdAt': '2026-07-06T10:00:00.000Z',
            }),
            201,
          );
        },
        () => ApiService().sendReportMessage(token: 'tok', id: 'r1', body: 'Bonjour, besoin d\'aide.'),
      );

      expect(result['id'], 'm1');
      expect(result['senderRole'], 'STUDENT');
    });

    test('throws with the server error message when the report is not accessible', () async {
      await expectLater(
        withMockClient(
          (request) async => http.Response(jsonEncode({'error': 'Accès refusé'}), 403),
          () => ApiService().sendReportMessage(token: 'tok', id: 'other', body: 'x'),
        ),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Accès refusé'))),
      );
    });
  });

  group('ApiService.sendStaffReportMessage (staff)', () {
    test('posts to reports/:id/messages and returns the created message', () async {
      final result = await withMockClient(
        (request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/reports/r1/messages');
          return http.Response(
            jsonEncode({
              'id': 'm2',
              'body': 'On s\'en occupe.',
              'senderRole': 'TEACHER',
              'createdAt': '2026-07-06T11:00:00.000Z',
            }),
            201,
          );
        },
        () => ApiService().sendStaffReportMessage(token: 'staff-tok', id: 'r1', body: 'On s\'en occupe.'),
      );

      expect(result['senderRole'], 'TEACHER');
    });
  });

  group('ApiService.cancelReport', () {
    test('completes without error on 200', () async {
      await withMockClient(
        (request) async {
          expect(request.method, 'DELETE');
          expect(request.url.path, '/api/reports/mine/r1');
          return http.Response(jsonEncode({'success': true}), 200);
        },
        () => ApiService().cancelReport(token: 'tok', id: 'r1'),
      );
    });

    test('throws once the 5-minute cancellation window has expired (régression bug #24)', () async {
      await expectLater(
        withMockClient(
          (request) async => http.Response(
            jsonEncode({'error': "Le délai d'annulation de 5 minutes est dépassé."}),
            409,
          ),
          () => ApiService().cancelReport(token: 'tok', id: 'r1'),
        ),
        throwsA(predicate((e) => e is Exception && e.toString().contains('délai'))),
      );
    });
  });
}
