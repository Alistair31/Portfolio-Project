import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'center_plus_button.dart';

/// Barre de navigation basse : 4 emplacements (Accueil, +, Suivi, Compte),
/// fond blanc 85 % flouté, fine bordure haute. Le « + » central **flotte**
/// au-dessus de la barre et déclenche [onCenterTap] (signalement).
class HavenBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onCenterTap;

  const HavenBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCenterTap,
  });

  static const double _barHeight = 52;
  static const double _padTop = 6;
  static const double _fab = 50;

  /// De combien le « + » dépasse au-dessus du bord supérieur de la barre.
  static const double _raise = 18;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final padBottom = 4 + bottomInset;
    final barTotal = _padTop + _barHeight + padBottom;

    return SizedBox(
      height: barTotal + _raise,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 4 emplacements égaux dans la largeur utile (− 8px de marge de chaque côté).
          final slot = (constraints.maxWidth - 16) / 4;
          final fabCenterX = 8 + slot * 1.5; // centre du 2e emplacement
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Barre floutée, collée en bas.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(8, _padTop, 8, padBottom),
                      decoration: const BoxDecoration(
                        color: Color(0xD9FFFFFF), // White 85%
                        border: Border(top: BorderSide(color: AppColors.hairline)),
                      ),
                      child: SizedBox(
                        height: _barHeight,
                        child: Row(
                          children: [
                            Expanded(
                              child: _NavItem(
                                icon: Icons.home_outlined,
                                label: 'Accueil',
                                selected: currentIndex == 0,
                                onTap: () => onTap(0),
                              ),
                            ),
                            const Expanded(child: SizedBox()), // place du « + »
                            Expanded(
                              child: _NavItem(
                                icon: Icons.access_time_outlined,
                                label: 'Suivi',
                                selected: currentIndex == 1,
                                onTap: () => onTap(1),
                              ),
                            ),
                            Expanded(
                              child: _NavItem(
                                icon: Icons.person_outline,
                                label: 'Compte',
                                selected: currentIndex == 2,
                                onTap: () => onTap(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // « + » flottant, au-dessus de la barre, centré sur son emplacement.
              Positioned(
                top: 0,
                left: fabCenterX - _fab / 2,
                child: CenterPlusButton(onTap: onCenterTap),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.racingGreen : AppColors.edward;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              height: 14 / 10.5,
              color: color,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
