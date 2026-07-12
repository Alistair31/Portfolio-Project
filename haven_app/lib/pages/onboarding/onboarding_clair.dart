import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/haven_wordmark.dart';
import '../../widgets/primary_button.dart';

/// Onboarding — variante B · « Clair ».
/// Mise en page éditoriale : grand titre à gauche, mot surligné, bouton foncé.
class OnboardingClair extends StatelessWidget {
  final VoidCallback? onStart;

  const OnboardingClair({super.key, this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const HavenWordmark(showShield: false, fontSize: 22),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.brand,
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              _eyebrow(),
              const SizedBox(height: 18),
              _title(),
              const SizedBox(height: 22),
              const Text(
                'Un canal confidentiel pour signaler\nune situation de harcèlement. À ton\nrythme, 24h/24.',
                style: TextStyle(
                  fontSize: 17,
                  height: 1.45,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(flex: 3),
              const Divider(height: 1, color: AppColors.outlineBorder),
              const SizedBox(height: 18),
              Row(
                children: const [
                  _InlineFeature(
                    icon: Icons.visibility_off_outlined,
                    label: 'Anonyme',
                  ),
                  SizedBox(width: 24),
                  _InlineFeature(icon: Icons.lock_outline, label: 'Chiffré'),
                  SizedBox(width: 24),
                  _InlineFeature(icon: Icons.schedule, label: '24h/24'),
                ],
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Commencer',
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

  Widget _eyebrow() {
    return Row(
      children: [
        Container(width: 22, height: 2, color: AppColors.textGreen),
        const SizedBox(width: 10),
        const Text(
          'UN REFUGE POUR PARLER',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: AppColors.textGreen,
          ),
        ),
      ],
    );
  }

  Widget _title() {
    const titleStyle = TextStyle(
      fontSize: 46,
      height: 1.05,
      fontWeight: FontWeight.w800,
      color: AppColors.textDark,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dire,', style: titleStyle),
        const Text("c'est déjà", style: titleStyle),
        // Dernier mot avec un surlignage "marqueur" vert derrière le texte.
        IntrinsicWidth(
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 6,
                child: Container(height: 16, color: AppColors.highlightGreen),
              ),
              const Text('commencer.', style: titleStyle),
            ],
          ),
        ),
      ],
    );
  }
}

/// Garantie en ligne (icône + libellé) pour le bas de la variante « Clair ».
class _InlineFeature extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InlineFeature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: AppColors.textDark),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
