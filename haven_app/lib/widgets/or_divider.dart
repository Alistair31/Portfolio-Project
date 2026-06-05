import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Séparateur "—— ou ——" entre deux blocs d'actions.
class OrDivider extends StatelessWidget {
  final String label;

  const OrDivider({super.key, this.label = 'ou'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.outlineBorder, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.outlineBorder, height: 1)),
      ],
    );
  }
}
