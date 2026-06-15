import 'package:http/http.dart' as http;
import 'dart:convert'; 

const String baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api',
);

class AuthUser {
  final String id;
  final String name;
  final String role;
  
  AuthUser({required this.id, required this.name, required this.role});

}

class AuthResponse {
  final String token;
  final AuthUser user;

  AuthResponse({required this.token, required this.user});

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
        return AuthResponse(token: data['token'], user: user);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']);
      }
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
  }
