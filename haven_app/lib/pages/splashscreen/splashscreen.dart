import 'package:flutter/material.dart';

import 'HavenStart.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isScalTheCircle = false;
  bool _isAtCenter = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _isAtCenter = true;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
            TweenAnimationBuilder<Offset>(
              tween: Tween<Offset>(
                begin: Offset(40, 40),
                end: _isAtCenter
                    ? Offset(screenWidth / 2 - 12, screenHeight / 2 - 12)
                    : Offset(40, 40),
              ),
              duration: Duration(milliseconds: 1500),
              curve: Cubic(.47, 0, .36, 1),
              builder: (context, offset, child) {
                return Stack(
                  children: [
                    CustomPaint(
                      painter: Rope(
                        start: Offset(0, 0),
                        end: offset,
                        color: const Color.fromARGB(221, 211, 122, 20),
                      ),
                      size: Size(screenWidth, screenHeight),
                    ),
                    Positioned(
                      top: offset.dy -12,
                      left: offset.dx -12,
                      child: Icon(
                        Icons.anchor,
                        color: Color(0xFF424242),  // gris foncé
                        size: 48,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Rope extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  Rope({required this.start, required this.end, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;


    final mid = Offset(
      (start.dx + end.dx) / 2 + 80,  // tire vers la droite
      (start.dy + end.dy) / 2 + 80,  // tire vers le bas
    );


    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(Rope oldDelegate) =>
    oldDelegate.start != start || oldDelegate.end != end || oldDelegate.color != color;

}
