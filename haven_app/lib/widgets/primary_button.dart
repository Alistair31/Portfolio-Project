import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bouton plein "pilule" avec libellé centré et icône optionnelle à droite.
/// Vert par défaut ; on peut passer une couleur foncée via [backgroundColor]
/// (+ [foregroundColor]) pour les variantes "Clair" et "Lueur".
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const PrimaryButton({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.onPressed,
    this.backgroundColor = AppColors.buttonGreen,
    this.foregroundColor = AppColors.textDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
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
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 20, color: foregroundColor),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 10),
                Icon(trailingIcon, size: 20, color: foregroundColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
