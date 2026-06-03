import 'package:flutter/material.dart';

import 'HavenStart.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isDotCenter = false;
  bool _isScalTheCircle = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _isDotCenter = true;
      });
      Future.delayed(Duration(milliseconds: 520), () {
        if (!mounted) return;
        setState(() {
          _isScalTheCircle = true;
        });
        Future.delayed(Duration(milliseconds: 600), () {
          if (!mounted) return;
          Navigator.push(
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 48, 214, 120),
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Center(
              child: AnimatedScale(
                duration: Duration(milliseconds: 600),
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
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              curve: Cubic(.47, -1.26, .36, 1),
              left: (MediaQuery.of(context).size.width / 2) -
                  12 -
                  (_isDotCenter ? 0 : 80),
              child: CircleAvatar(radius: 12, backgroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}