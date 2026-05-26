import 'package:flutter/material.dart';
import 'package:haven_app/pages/splashscreen/splashscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haven',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          primary: Colors.white,
          secondary: Colors.green,
          brightness: Brightness.dark,
          ),
      ),
    );
  }
}
