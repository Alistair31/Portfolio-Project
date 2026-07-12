import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Humeur d'un jour dans le journal hebdomadaire.
class DayMood {
  final String label;
  final Color color;

  const DayMood(this.label, this.color);
}

/// Carte « Ton journal d'humeur » : en-tête + pastilles (22px) de la semaine.
class MoodJournalCard extends StatelessWidget {
  final List<DayMood> week;
  final VoidCallback? onHistory;

  const MoodJournalCard({super.key, required this.week, this.onHistory});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.hairline),
        boxShadow: const [
          BoxShadow(color: Color(0x0814201B), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Ton journal d'humeur",
                style: TextStyle(
                  fontSize: 14.5,
                  height: 19 / 14.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: AppColors.racingGreen,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onHistory,
                behavior: HitTestBehavior.opaque,
                child: const Text(
                  'Historique',
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.eucalyptus,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final day in week)
                Column(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: day.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      day.label,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 13 / 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mantle,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
