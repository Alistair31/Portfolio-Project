import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// En-tête « Haven » + date du jour (check-in émotionnel).
class BrandDateHeader extends StatelessWidget {
  final String date;
  final String brand;

  const BrandDateHeader({super.key, required this.date, this.brand = 'Haven'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          brand,
          style: const TextStyle(
            fontSize: 19,
            height: 25 / 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: AppColors.racingGreen,
          ),
        ),
        const Spacer(),
        Text(
          date,
          style: const TextStyle(
            fontSize: 12.5,
            height: 16 / 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.mantle,
          ),
        ),
      ],
    );
  }
}
