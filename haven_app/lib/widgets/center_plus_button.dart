import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bouton central « + » (signaler) de la barre de navigation :
/// disque vert (Granny Smith), anneau ecru et ombre portée verte.
class CenterPlusButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CenterPlusButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.grannySmith,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ecruWhite, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.eucalyptus.withValues(alpha: 0.42),
              blurRadius: 18,
              spreadRadius: -8,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.add, size: 24, color: AppColors.racingGreen),
      ),
    );
  }
}
