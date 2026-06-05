import 'package:flutter/material.dart';

import '../login/login_page.dart';

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

  void _goToLogin() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginPage(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) =>
                  FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
            child: child,
          ),
        ),
      );
    });
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
            SizedBox(height: 24),
            Text(
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
