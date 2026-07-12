import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Petit logotype "🛡 Haven" utilisé en en-tête des pages d'onboarding.
/// La couleur s'adapte au fond (foncé sur fond clair, etc.).
class HavenWordmark extends StatelessWidget {
  final Color color;
  final double fontSize;
  final bool showShield;

  const HavenWordmark({
    super.key,
    this.color = AppColors.textDark,
    this.fontSize = 20,
    this.showShield = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showShield) ...[
          Icon(Icons.shield_outlined, size: fontSize + 2, color: color),
          const SizedBox(width: 8),
        ],
        Text(
          'Haven',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
