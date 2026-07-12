import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Carte blanche réutilisable : coins arrondis (20), bordure fine
/// « Racing Green 9% », ombre douce et zone cliquable optionnelle.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.hairline),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0814201B),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
