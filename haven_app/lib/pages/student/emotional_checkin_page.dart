import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brand_date_header.dart';
import '../../widgets/green_cta_button.dart';
import '../../widgets/haven_bottom_bar.dart';
import '../../widgets/mood_item.dart';
import '../../widgets/mood_journal_card.dart';
import '../chatbot/chatbot_page.dart';
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
  int _selectedMood = 3;
  List<DayMood> _week = _buildPlaceholderWeek();

  static const List<MoodOption> _moods = [
    MoodOption(Icons.sentiment_very_dissatisfied, 'Très mal'),
    MoodOption(Icons.sentiment_dissatisfied, 'Pas bien'),
    MoodOption(Icons.sentiment_neutral, 'Bof'),
    MoodOption(Icons.sentiment_satisfied, 'Ça va'),
    MoodOption(Icons.sentiment_very_satisfied, 'Bien'),
  ];

  // Correspondance niveau (1-5) → couleur du journal d'humeur
  static Color _levelToColor(int level) {
    switch (level) {
      case 1: return const Color(0xFFE57373); // rouge
      case 2: return const Color(0xFFE89B4E); // orange
      case 3: return const Color(0xFFDCC04A); // jaune
      case 4: return AppColors.deYork;         // vert clair
      case 5: return const Color(0xFF2C9A78); // vert foncé
      default: return AppColors.hairline;
    }
  }

  // Pastilles grises pour les 7 jours en attendant le chargement
  static List<DayMood> _buildPlaceholderWeek() {
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return DayMood(labels[day.weekday - 1], AppColors.hairline);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final token = SessionService().getToken();
    if (token == null) return;
    try {
      final entries = await ApiService().getMoodHistory(token: token, days: 7);
      if (!mounted) return;
      final today = DateTime.now();
      const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

      final week = List.generate(7, (i) {
        final day = today.subtract(Duration(days: 6 - i));
        // Dernier check-in enregistré pour ce jour
        final dayEntries = entries.where((e) {
          final date = DateTime.parse(e['createdAt'] as String);
          return date.year == day.year &&
              date.month == day.month &&
              date.day == day.day;
        }).toList();

        final label = labels[day.weekday - 1];
        if (dayEntries.isEmpty) return DayMood(label, AppColors.hairline);
        return DayMood(label, _levelToColor(dayEntries.last['level'] as int));
      });

      setState(() => _week = week);
    } catch (_) {
      // En cas d'erreur réseau, on garde les pastilles grises
    }
  }

  Future<void> _selectMood(int index) async {
    setState(() => _selectedMood = index);
    final token = SessionService().getToken();
    if (token == null) return;
    // level API : 1-5 (index 0-4 → +1)
    await ApiService().submitMood(token: token, level: index + 1);
    // Recharge l'historique pour mettre à jour la pastille du jour
    await _loadHistory();
  }

  void _onTabTap(int index) {
    if (index == 0) Navigator.of(context).maybePop();
  }

  void _openReportFlow() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReportTargetPage()),
    );
  }

  static String _formatDate(DateTime d) {
    const jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    const mois  = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin',
                   'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    return '${jours[d.weekday - 1]} ${d.day} ${mois[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final todayLabel = _formatDate(DateTime.now());

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
                BrandDateHeader(date: todayLabel),
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
                        onTap: () => _selectMood(i),
                      ),
                  ],
                ),
                const Spacer(),
                MoodJournalCard(week: _week),
                const SizedBox(height: 14),
                GreenCtaButton(
                  label: 'Parler de ma journée',
                  leadingIcon: Icons.chat_bubble_outline,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatbotPage()),
                  ),
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
