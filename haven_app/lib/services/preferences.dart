import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class PreferencesService {

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('hasSeenOnboarding', true);
  }

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool('hasSeenOnboarding') ?? false;
  }

  Future<void> saveToken(String token) async {
    final savTok = await SharedPreferences.getInstance();

    savTok.setString('token', token);
  }

  Future<String?> getToken() async {
    final savTok = await SharedPreferences.getInstance();

    return savTok.getString('token');
  }

  Future<void> removeToken() async {
    final byebye = await SharedPreferences.getInstance();

    byebye.remove('token');
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('refreshToken', refreshToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('refreshToken');
  }

  Future<void> removeRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove('refreshToken');
  }

  Future<void> saveIntegrityHash(String reportId, String hash) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('integrity_$reportId', hash);
  }

  Future<String?> getIntegrityHash(String reportId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('integrity_$reportId');
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
