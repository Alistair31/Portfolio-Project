import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class PreferencesService {
  // Le token d'accès et le refresh token sont des identifiants de session :
  // ils vont dans le stockage chiffré (Keystore Android / Keychain iOS) plutôt
  // que dans SharedPreferences (XML/JSON en clair, lisible sur un appareil root
  // ou via une sauvegarde adb si allowBackup n'est pas désactivé).
  static const _secureStorage = FlutterSecureStorage();

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('hasSeenOnboarding', true);
  }

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool('hasSeenOnboarding') ?? false;
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'token', value: token);
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: 'token');
  }

  Future<void> removeToken() async {
    await _secureStorage.delete(key: 'token');
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: 'refreshToken');
  }

  Future<void> removeRefreshToken() async {
    await _secureStorage.delete(key: 'refreshToken');
  }

  Future<void> saveIntegrityHash(String reportId, String hash) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('integrity_$reportId', hash);
  }

  Future<String?> getIntegrityHash(String reportId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('integrity_$reportId');
  }

  Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<void> removeRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('role');
  }

  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
  }

  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  Future<void> removeName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('name');
  }

  Future<void> saveReportSnapshot(String reportId, Map<String, dynamic> snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('snapshot_$reportId', jsonEncode(snapshot));
  }

  Future<Map<String, dynamic>?> getReportSnapshot(String reportId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('snapshot_$reportId');
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
