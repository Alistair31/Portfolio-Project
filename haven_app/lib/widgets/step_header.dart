import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'circle_icon_button.dart';

/// En-tête d'un flux par étapes : bouton retour (40px) + titre + libellé d'étape.
class StepHeader extends StatelessWidget {
  final String title;
  final String step;
  final VoidCallback? onBack;

  const StepHeader({
    super.key,
    required this.title,
    required this.step,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleIconButton(
          icon: Icons.arrow_back,
          size: 40,
          iconSize: 20,
          bordered: true,
          onTap: onBack,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  height: 22 / 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: AppColors.racingGreen,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                step,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 16 / 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mantle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
