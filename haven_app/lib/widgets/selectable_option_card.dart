import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Grande carte de choix sélectionnable (ex. victime / témoin).
/// Active : fond vert (Granny Smith), contour Eucalyptus, icône sur fond
/// blanc translucide et coche. Inactive : carte blanche, icône sur fond menthe.
class SelectableOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const SelectableOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: selected ? AppColors.grannySmith : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected ? AppColors.eucalyptus : AppColors.hairline,
                width: selected ? 2 : 1,
              ),
              boxShadow: [
                selected
                    ? BoxShadow(
                        color: AppColors.eucalyptus.withValues(alpha: 0.42),
                        blurRadius: 28,
                        spreadRadius: -14,
                        offset: const Offset(0, 14),
                      )
                    : const BoxShadow(
                        color: Color(0x0814201B),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.45)
                        : AppColors.iconTint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 26, color: AppColors.racingGreen),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    height: 25 / 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.racingGreen,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.outerSpace : AppColors.corduroy,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            Positioned(
              top: 22,
              right: 22,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: AppColors.eucalyptus,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 15, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
