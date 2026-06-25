import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bouton « pilule » compact (plus petit que [PrimaryButton]).
/// Foncé (Racing Green) par défaut ; icône optionnelle avant/après le libellé.
class CompactPillButton extends StatelessWidget {
  final String label;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const CompactPillButton({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.onPressed,
    this.backgroundColor = AppColors.racingGreen,
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 18, color: foregroundColor),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 15,
                  height: 20 / 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, size: 18, color: foregroundColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
