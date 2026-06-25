import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'circle_icon_button.dart';

/// En-tête d'accueil : salutation, titre et bouton notifications
/// (avec pastille d'alerte optionnelle).
class GreetingHeader extends StatelessWidget {
  final String greeting;
  final String title;
  final bool showNotificationDot;
  final VoidCallback? onNotifications;

  const GreetingHeader({
    super.key,
    required this.greeting,
    required this.title,
    this.showNotificationDot = true,
    this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 13,
                  height: 17 / 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mantle,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  height: 31 / 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.racingGreen,
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleIconButton(
              icon: Icons.notifications_none,
              iconSize: 20,
              bordered: true,
              onTap: onNotifications,
            ),
            if (showNotificationDot)
              Positioned(
                right: 12,
                top: 11,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.sos,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
