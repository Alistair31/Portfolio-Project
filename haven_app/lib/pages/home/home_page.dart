import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/haven_logo.dart';

/// Écran d'accueil (placeholder) affiché une fois l'onboarding terminé.
/// À remplacer par le vrai tableau de bord de l'app.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
          ),
        ),
        child: const SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HavenLogo(size: 96),
                SizedBox(height: 24),
                Text(
                  'Bienvenue sur Haven',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ton espace est prêt.',
                  style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
