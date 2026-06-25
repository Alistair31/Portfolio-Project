import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'status_dot.dart';

/// Petit badge « pastille + libellé » (ex. « • suivi »).
class StatusBadge extends StatelessWidget {
  final String label;
  final Color dotColor;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    this.dotColor = AppColors.eucalyptus,
    this.backgroundColor = AppColors.blueRomance,
    this.textColor = AppColors.racingGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusDot(color: dotColor, size: 6),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              height: 15 / 11.5,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
