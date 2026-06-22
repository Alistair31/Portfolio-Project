
class SessionService {
  static String? _token;

  void setToken(String token) {
    _token = token;
  }
  String? getToken() {
    return _token;
  }
  void clearToken() {
    _token = null;
  }
}