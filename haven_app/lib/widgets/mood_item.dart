import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Données d'une humeur proposée au check-in (visage + libellé).
class MoodOption {
  final IconData icon;
  final String label;

  const MoodOption(this.icon, this.label);
}

/// Une humeur sélectionnable du check-in émotionnel.
/// Sélectionnée : disque 52px vert (De York), visage foncé, libellé ExtraBold.
/// Inactive : disque 44px blanc, contour 16 %, visage gris.
class MoodItem extends StatelessWidget {
  final MoodOption option;
  final bool selected;
  final VoidCallback onTap;

  const MoodItem({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double size = selected ? 52 : 44;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: selected ? AppColors.deYork : Colors.white,
              shape: BoxShape.circle,
              border: selected
                  ? null
                  : Border.all(color: AppColors.hairlineStrong, width: 2.75),
            ),
            child: Icon(
              option.icon,
              size: selected ? 30 : 26,
              color: selected ? AppColors.racingGreen : AppColors.mantle,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            option.label,
            style: TextStyle(
              fontSize: 10.5,
              height: 14 / 10.5,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? AppColors.racingGreen : AppColors.mantle,
            ),
          ),
        ],
      ),
    );
  }
}
