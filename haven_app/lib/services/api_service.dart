import 'package:http/http.dart' as http;
import 'dart:convert'; 

const String baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api',
);

class School {
  final String code;
  final String name;
  final String type;

  School({required this.code, required this.name, required this.type});
}

class AuthUser {
  final String id;
  final String name;
  final String role;

  AuthUser({required this.id, required this.name, required this.role});

}

class AuthResponse {
  final String token;
  final String refreshToken;
  final AuthUser user;

  AuthResponse({required this.token, required this.refreshToken, required this.user});

}

class TokenPair {
  final String token;
  final String refreshToken;

  TokenPair({required this.token, required this.refreshToken});
}

class ApiService {

    Future<AuthResponse> login(String email, String password) async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
        );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = AuthUser(
          id: data['user']['id'],
          name: data['user']['name'],
          role: data['user']['role'],
        );
        return AuthResponse(token: data['token'], refreshToken: data['refreshToken'], user: user);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']);
      }
    }

    // Échange le refresh token contre un nouveau couple access+refresh.
    // NB : aucun appel de ce fichier ne déclenche encore ce rafraîchissement
    // automatiquement sur une réponse 401 — il n'y a pas de client HTTP
    // centralisé ici, chaque méthode fait son propre http.get/post avec le
    // token courant. Cette méthode existe et fonctionne, mais reste à câbler
    // manuellement (ou via un futur client HTTP commun) partout où un appel
    // peut échouer avec un token expiré.
    Future<TokenPair?> refreshAccessToken(String refreshToken) async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body);
      return TokenPair(token: data['token'], refreshToken: data['refreshToken']);
    }

    Future<void> logout(String refreshToken) async {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
    }

    Future<String> register(String email, String password, String name, String className, String schoolCode) async { 
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name, 'className': className, 'schoolCode': schoolCode}),
        );

        if (response.statusCode == 200) {
        final regdata = jsonDecode(response.body);
        return regdata['message'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']);
      }
    }

    Future<List<School>> getSchools() async {
      final response = await http
          .get(Uri.parse('$baseUrl/schools'))
          .timeout(const Duration(seconds: 5), onTimeout: () => http.Response('[]', 408));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => School(code: e['code'], name: e['name'], type: e['type'] as String)).toList();
      } else {
        throw Exception('Impossible de charger les établissements');
      }
    }

    Future<Map<String, String>> submitReport({
      required String token,
      required String mode,
      required String type,
      required int gravity,
      required String description,
      required String targetLevel,
      required String anonymityLevel,
    }) async {
      final response = await http.post(
        Uri.parse('$baseUrl/reports'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'mode': mode,
          'type': type,
          'gravity': gravity,
          'description': description,
          'targetLevel': targetLevel,
          'anonymityLevel': anonymityLevel,
        }),
      );
      if (response.statusCode != 201) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de l\'envoi');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'id':            data['id'] as String,
        'integrityHash': data['integrityHash'] as String,
        'trackingCode':  data['trackingCode'] as String,
      };
    }

    Future<bool?> verifyReport({required String token, required String id}) async {
      final response = await http.get(
        Uri.parse('$baseUrl/reports/mine/$id/verify'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final verified = data['verified'];
      if (verified == null) return null;
      return verified as bool;
    }

    Future<void> submitMood({
      required String token,
      required int level,
    }) async {
      await http.post(
        Uri.parse('$baseUrl/mood'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'level': level}),
      );
    }

    Future<List<Map<String, dynamic>>> getMoodHistory({
      required String token,
      int days = 7,
    }) async {
      final response = await http.get(
        Uri.parse('$baseUrl/mood?days=$days'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    }

    Future<List<Map<String, dynamic>>> getMyReports({required String token}) async {
      final response = await http.get(
        Uri.parse('$baseUrl/reports/mine'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception('Erreur lors du chargement des signalements');
    }

    Future<Map<String, dynamic>> getReportDetail({
      required String token,
      required String id,
    }) async {
      final response = await http.get(
        Uri.parse('$baseUrl/reports/mine/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Signalement introuvable');
    }

    Future<void> cancelReport({required String token, required String id}) async {
      final response = await http.delete(
        Uri.parse('$baseUrl/reports/mine/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de l\'annulation');
      }
    }

    Future<void> requestAccountDeletion(String token) async {
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/account'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 409) {
        throw Exception('Une demande de suppression est déjà en attente.');
      }
      if (response.statusCode != 202) {
        throw Exception('Erreur lors de la demande de suppression.');
      }
    }

    Future<List<Map<String, dynamic>>> getReports({
      required String token,
      String? status,
    }) async {
      final uri = Uri.parse('$baseUrl/reports').replace(
        queryParameters: {'status': ?status},
      );
      final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception('Erreur lors du chargement des signalements');
    }

    Future<Map<String, dynamic>> getStaffReportDetail({
      required String token,
      required String id,
    }) async {
      final response = await http.get(
        Uri.parse('$baseUrl/reports/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Signalement introuvable');
    }

    Future<void> updateReportStatus({
      required String token,
      required String id,
      required String status,
      String? notes,
    }) async {
      final response = await http.patch(
        Uri.parse('$baseUrl/reports/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status, 'notes': ?notes}),
      );
      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de la mise à jour');
      }
    }

    Future<void> escalateReport({
      required String token,
      required String id,
      String? notes,
    }) async {
      final response = await http.post(
        Uri.parse('$baseUrl/reports/$id/escalate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'notes': notes}),
      );
      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors du transfert');
      }
    }

    Future<List<Map<String, dynamic>>> getNotifications({required String token}) async {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    }

    Future<void> markNotificationsRead({required String token}) async {
      await http.patch(
        Uri.parse('$baseUrl/notifications'),
        headers: {'Authorization': 'Bearer $token'},
      );
    }

    Future<String?> getParentCode({required String token}) async {
      final response = await http.get(
        Uri.parse('$baseUrl/student/parent-code'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as Map<String, dynamic>)['parentCode'] as String?;
      }
      return null;
    }

    Future<void> registerParent({
      required String email,
      required String password,
      required String name,
      required String parentCode,
    }) async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/parent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name, 'parentCode': parentCode}),
      );
      if (response.statusCode != 201) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de l\'inscription');
      }
    }

    Future<List<Map<String, dynamic>>> getParentReports({required String token}) async {
      final response = await http.get(
        Uri.parse('$baseUrl/parent/reports'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
      }
      throw Exception('Erreur chargement');
    }

    Future<Map<String, dynamic>> getParentReportDetail({required String token, required String id}) async {
      final response = await http.get(
        Uri.parse('$baseUrl/parent/reports/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) return jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception('Accès refusé');
    }

    Future<List<Map<String, dynamic>>> getAdminDeletionRequests({required String secret}) async {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/deletion-requests'),
        headers: {'Authorization': 'Bearer $secret'},
      );
      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
      }
      throw Exception('Secret invalide');
    }

    Future<void> processAdminDeletion({required String secret, required String id, required String action}) async {
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/deletion-requests/$id'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $secret'},
        body: jsonEncode({'action': action}),
      );
      if (response.statusCode != 200) throw Exception('Erreur');
    }

    Future<void> saveFcmToken({
      required String token,
      required String fcmToken,
    }) async {
      await http.patch(
        Uri.parse('$baseUrl/auth/fcm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fcmToken': fcmToken}),
      );
    }

    Future<Map<String, dynamic>> getStats({required String token}) async {
      final response = await http.get(
        Uri.parse('$baseUrl/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Impossible de charger les statistiques');
    }

    Future<List<Map<String, dynamic>>> getTimeline({
      required String token,
      required String period,
    }) async {
      final response = await http.get(
        Uri.parse('$baseUrl/stats/timeline?period=$period'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.cast<Map<String, dynamic>>();
      }
      throw Exception('Impossible de charger la timeline');
    }
  }
