import 'package:flutter/material.dart';

class HavenScreen extends StatelessWidget {
  const HavenScreen({super.key});

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
