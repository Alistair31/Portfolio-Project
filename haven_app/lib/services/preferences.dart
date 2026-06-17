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
}
