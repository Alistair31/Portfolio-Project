import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bouton "pilule" à contour (fond blanc) avec icône à gauche.
class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? leadingIcon;
  final VoidCallback? onPressed;

  const SecondaryButton({
    super.key,
    required this.label,
    this.leadingIcon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fieldBackground,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AppColors.outlineBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 20, color: AppColors.textDark),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
