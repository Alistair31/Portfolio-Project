import 'package:flutter/material.dart';
import '../pages/authentification/login_page.dart';
import '../services/preferences.dart';
import '../../theme/app_colors.dart';


class LogoutButton extends StatelessWidget{
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: Material(
      
      color: AppColors.buttonDark,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        onTap: () => _logout(context),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          child: Row(
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
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await PreferencesService().removeToken();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}