import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/brand_date_header.dart';
import '../../widgets/green_cta_button.dart';
import '../../widgets/haven_bottom_bar.dart';
import '../../widgets/mood_item.dart';
import '../../widgets/mood_journal_card.dart';
import '../report/report_target_page.dart';

/// Écran 3 · Espace élève — « Check-in émotionnel ».
/// L'élève choisit son humeur du jour (privée) et peut consulter
/// son journal d'humeur ou parler de sa journée.
class EmotionalCheckinPage extends StatefulWidget {
  const EmotionalCheckinPage({super.key});

  @override
  State<EmotionalCheckinPage> createState() => _EmotionalCheckinPageState();
}

class _EmotionalCheckinPageState extends State<EmotionalCheckinPage> {
  // « Ça va » sélectionné par défaut (comme la maquette).
  int _selectedMood = 3;

  static const List<MoodOption> _moods = [
    MoodOption(Icons.sentiment_very_dissatisfied, 'Très mal'),
    MoodOption(Icons.sentiment_dissatisfied, 'Pas bien'),
    MoodOption(Icons.sentiment_neutral, 'Bof'),
    MoodOption(Icons.sentiment_satisfied, 'Ça va'),
    MoodOption(Icons.sentiment_very_satisfied, 'Bien'),
  ];

  static const List<DayMood> _week = [
    DayMood('L', AppColors.deYork),
    DayMood('M', Color(0xFFDCC04A)), // Anzac
    DayMood('M', AppColors.deYork),
    DayMood('J', Color(0xFFE89B4E)), // Tulip Tree
    DayMood('V', Color(0xFFDCC04A)),
    DayMood('S', Color(0xFF2C9A78)), // Lochinvar
    DayMood('D', AppColors.deYork),
  ];

  void _onTabTap(int index) {
    // « Accueil » revient à l'écran précédent.
    if (index == 0) {
      Navigator.of(context).maybePop();
    }
  }

  void _openReportFlow() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReportTargetPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BrandDateHeader(date: 'Mardi 3 avril'),
                const SizedBox(height: 26),
                const Text(
                  'Comment tu te sens\naujourd\'hui ?',
                  style: TextStyle(
                    fontSize: 27,
                    height: 30 / 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: AppColors.racingGreen,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Juste pour toi. Personne ne le voit.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 18 / 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.corduroy,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0; i < _moods.length; i++)
                      MoodItem(
                        option: _moods[i],
                        selected: _selectedMood == i,
                        onTap: () => setState(() => _selectedMood = i),
                      ),
                  ],
                ),
                const Spacer(),
                const MoodJournalCard(week: _week),
                const SizedBox(height: 14),
                GreenCtaButton(
                  label: 'Parler de ma journée',
                  leadingIcon: Icons.chat_bubble_outline,
                  onPressed: () {},
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: HavenBottomBar(
        currentIndex: 0,
        onTap: _onTabTap,
        onCenterTap: _openReportFlow,
      ),
    );
  }
}
