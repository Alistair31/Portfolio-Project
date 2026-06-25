import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'status_badge.dart';
import 'surface_card.dart';

/// Carte « Conversation en cours » : avatar dégradé, titre, badge de suivi
/// optionnel, sous-titre et chevron.
class ConversationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badgeLabel;
  final VoidCallback? onTap;

  const ConversationCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.badgeLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-0.24, -0.32),
                radius: 0.9055,
                colors: [AppColors.grannySmith, Color(0xFF8BEBE0)],
              ),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 20 / 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: AppColors.racingGreen,
                        ),
                      ),
                    ),
                    if (badgeLabel != null) ...[
                      const SizedBox(width: 8),
                      StatusBadge(label: badgeLabel!),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.mantle),
        ],
      ),
    );
  }
}
