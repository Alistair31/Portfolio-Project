import 'package:flutter/material.dart';
import '../../services/preferences.dart';
import '../../services/role_router.dart';
import '../../services/session_service.dart';
import '../authentification/login_page.dart';

class HavenScreen extends StatefulWidget {
  const HavenScreen({super.key});

  @override
  State<HavenScreen> createState() => _HavenScreenState();
}

class _HavenScreenState extends State<HavenScreen> {
  @override
  void initState() {
    super.initState();
    _goToLogin();
  }

  Future<void> _goToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final prefs = PreferencesService();
    final token = await prefs.getToken();
    final role  = await prefs.getRole();
    final name  = await prefs.getName();

    if (!mounted) return;

    Widget destination;
    if (token != null && role != null) {
      SessionService().setToken(token);
      SessionService().setUser(role: role, name: name ?? '');
      destination = homeForRole(role);
    } else {
      destination = const LoginPage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => destination,
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/haven-logo.png', width: 150),
            const SizedBox(height: 24),
            const Text(
              'Haven',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 48, 214, 92),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
