class SessionService {
  static String? _token;
  static String? _refreshToken;
  static String? _role;
  static String? _name;

  void setToken(String token) => _token = token;
  String? getToken() => _token;

  void setRefreshToken(String refreshToken) => _refreshToken = refreshToken;
  String? getRefreshToken() => _refreshToken;

  void clearToken() { _token = null; _refreshToken = null; _role = null; _name = null; }

  void setUser({required String role, required String name}) {
    _role = role;
    _name = name;
  }

  String? getRole() => _role;
  String? getName() => _name;
}
