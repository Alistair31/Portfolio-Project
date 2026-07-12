import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Logo "halo" vert de Haven : cercles concentriques avec un dégradé radial.
/// Réutilisable partout (login, accueil, etc.) en jouant sur size.
class HavenLogo extends StatelessWidget {
  final double size;

  const HavenLogo({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.brand.withValues(alpha: 0.55),
            AppColors.brand.withValues(alpha: 0.28),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.40),
          ),
          child: Center(
            child: Container(
              width: size * 0.22,
              height: size * 0.22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
