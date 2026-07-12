import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haven_app/pages/splashscreen/splashscreen.dart';
import 'package:haven_app/theme/app_colors.dart';
import 'package:haven_app/theme/responsive.dart';

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
      // Point de vérité unique pour la lisibilité sur tablette : on enveloppe
      // TOUTE l'app (chaque route, y compris celles poussées plus tard via
      // Navigator) dans un MediaQuery dont le textScaler est boosté sur grand
      // écran. Ça couvre les 250+ TextStyle(fontSize: ...) codés en dur dans
      // les pages sans avoir à en toucher un seul — contrairement à un fix
      // par écran, celui-ci ne peut pas être "oublié" sur une page future.
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: Responsive.boostedTextScaler(context),
          ),
          child: child,
        );
      },
    );
  }
}
