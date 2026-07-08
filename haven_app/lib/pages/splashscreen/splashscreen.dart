import 'package:flutter/material.dart';

import 'haven_start.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isScalTheCircle = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(Duration(milliseconds: 820), () {
      if (!mounted) return;
      setState(() {
        _isScalTheCircle = true;
      });
      Future.delayed(Duration(milliseconds: 600), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                HavenScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
              ),
              child: child,
            ),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 48, 214, 120),
      body: Center(
        child: AnimatedScale(
          duration: Duration(milliseconds: 1800),
          curve: Cubic(0.58, -0.30, 0.365, 1),
          scale: _isScalTheCircle ? 10 : 1,
          child: CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white,
            child: Center(
              child: CircleAvatar(
                radius: 12,
                backgroundColor: _isScalTheCircle
                    ? Colors.white
                    : Color.fromARGB(255, 48, 214, 120),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
