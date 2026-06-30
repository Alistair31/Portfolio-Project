import 'package:flutter/material.dart';
import '../pages/authentification/login_page.dart';
import '../services/api_service.dart';
import '../services/preferences.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';


class LogoutButton extends StatelessWidget{
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.buttonDark,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        onTap: () => _logout(context),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout,
                size: 20,
                color: Colors.white),
              const SizedBox(
                width: 10),
              const Text(
                'Se déconnecter',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final refreshToken = SessionService().getRefreshToken();

    SessionService().clearToken();
    await PreferencesService().removeToken();
    await PreferencesService().removeRefreshToken();

    // Révocation côté serveur en best-effort : si le réseau est indisponible,
    // on ne bloque pas la déconnexion locale pour autant.
    if (refreshToken != null) {
      try {
        await ApiService().logout(refreshToken);
      } catch (_) {}
    }

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}