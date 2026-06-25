import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haven_app/pages/splashscreen/splashscreen.dart';
import 'package:haven_app/theme/app_colors.dart';

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
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundBottom,
        // Police de la maquette (Hanken Grotesk) appliquée à tout le texte.
        textTheme: GoogleFonts.hankenGroteskTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brand,
          primary: AppColors.brand,
          secondary: Colors.green,
          brightness: Brightness.light,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
