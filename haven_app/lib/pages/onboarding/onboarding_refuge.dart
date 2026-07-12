import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/feature_chip.dart';
import '../../widgets/haven_logo.dart';
import '../../widgets/haven_wordmark.dart';
import '../../widgets/primary_button.dart';

/// Onboarding premiere partie.
/// Accueil doux et centré : halo, titre rassurant, bouton vert.
class OnboardingRefuge extends StatelessWidget {
  final VoidCallback? onStart;
  final VoidCallback? onHowItWorks;

  const OnboardingRefuge({super.key, this.onStart, this.onHowItWorks});

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: HavenWordmark(),
                ),
                const Spacer(flex: 3),
                const Center(child: HavenLogo(size: 134)),
                const SizedBox(height: 32),
                const Text(
                  'Ici, tu peux\nparler.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Un espace à toi, confidentiel et\nbienveillant. Disponible jour et nuit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                const Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FeatureChip(
                      icon: Icons.visibility_off_outlined,
                      label: 'Anonyme si tu veux',
                    ),
                    FeatureChip(
                      icon: Icons.lock_outline,
                      label: 'Confidentiel',
                    ),
                  ],
                ),
                const Spacer(flex: 4),
                PrimaryButton(
                  label: 'Parler maintenant',
                  trailingIcon: Icons.arrow_forward,
                  onPressed: onStart,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: onHowItWorks,
                  child: const Text(
                    'Comment ça marche ?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'En lien avec ton établissement · complément du\nprogramme pHARe',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
