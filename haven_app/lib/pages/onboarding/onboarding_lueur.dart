import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/feature_chip.dart';
import '../../widgets/haven_wordmark.dart';
import '../../widgets/primary_button.dart';

/// Onboarding — variante C · « Lueur ».
/// Grand bloc vert plein en haut (logo + titre), garanties puis bouton foncé.
class OnboardingLueur extends StatelessWidget {
  final VoidCallback? onStart;

  const OnboardingLueur({super.key, this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _greenCard()),
              const SizedBox(height: 26),
              const Text(
                "Signale une situation de harcèlement, en\ntoute confidentialité. Une présence à\nl'écoute, 24h/24.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.45,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 22),
              const Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FeatureChip(
                    icon: Icons.visibility_off_outlined,
                    label: 'Anonyme',
                  ),
                  FeatureChip(icon: Icons.lock_outline, label: 'Chiffré'),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Commencer à parler',
                trailingIcon: Icons.arrow_forward,
                backgroundColor: AppColors.buttonDark,
                foregroundColor: Colors.white,
                onPressed: onStart,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _greenCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        color: AppColors.cardGreen,
        padding: const EdgeInsets.all(28),
        child: Stack(
          children: [
            // Cercle décoratif "lueur" en bas à droite.
            Positioned(
              right: -36,
              bottom: -44,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                HavenWordmark(),
                Spacer(),
                Text(
                  'Ici, ta\nparole est\nen sécurité.',
                  style: TextStyle(
                    fontSize: 42,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
