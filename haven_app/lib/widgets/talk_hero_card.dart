import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'compact_pill_button.dart';

/// Grand bloc vert d'appel à la parole (« Besoin de parler ? »),
/// avec cercle décoratif et bouton d'action foncé.
class TalkHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onStart;

  const TalkHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonLabel = 'Démarrer',
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        color: AppColors.grannySmith,
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.32),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 21,
                      height: 27 / 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.racingGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 18 / 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.outerSpace,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CompactPillButton(
                    label: buttonLabel,
                    trailingIcon: Icons.arrow_forward,
                    onPressed: onStart,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
