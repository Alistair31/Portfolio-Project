class SessionService {
  static String? _token;
  static String? _role;
  static String? _name;

  void setToken(String token) => _token = token;
  String? getToken() => _token;
  void clearToken() { _token = null; _role = null; _name = null; }

  void setUser({required String role, required String name}) {
    _role = role;
    _name = name;
  }

  String? getRole() => _role;
  String? getName() => _name;
}
