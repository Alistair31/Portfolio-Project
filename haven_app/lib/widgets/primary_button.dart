import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bouton plein "pilule" (vert) avec libellé centré et icône optionnelle à droite.
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    this.trailingIcon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.buttonGreen,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          height: 62,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 10),
                Icon(trailingIcon, size: 20, color: AppColors.textDark),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
