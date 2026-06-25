import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/action_mini_card.dart';
import '../../widgets/conversation_card.dart';
import '../../widgets/greeting_header.dart';
import '../../widgets/haven_bottom_bar.dart';
import '../../widgets/sos_button.dart';
import '../../widgets/talk_hero_card.dart';
import '../report/report_target_page.dart';
import 'emotional_checkin_page.dart';

/// Écran 3 · Espace élève — « Accueil connecté ».
/// Page d'accueil de l'élève une fois connecté·e : entrée vers la
/// conversation d'écoute, ses signalements, les ressources et le SOS.
class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _currentIndex = 0;

  void _onTabTap(int index) {
    // L'onglet « Suivi » ouvre le check-in émotionnel.
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const EmotionalCheckinPage()),
      );
      return;
    }
    setState(() => _currentIndex = index);
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
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GreetingHeader(
                      greeting: 'Bonjour,',
                      title: 'tu es au bon endroit.',
                      onNotifications: () {},
                    ),
                    const SizedBox(height: 16),
                    TalkHeroCard(
                      title: 'Besoin de parler de\nquelque chose ?',
                      subtitle:
                          "Je t'écoute, à ton rythme et en toute\nconfidentialité.",
                      onStart: () {},
                    ),
                    const SizedBox(height: 16),
                    ConversationCard(
                      title: 'Conversation en cours',
                      subtitle: "Reprends où tu t'es arrêté·e",
                      badgeLabel: 'suivi',
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ActionMiniCard(
                            icon: Icons.access_time_outlined,
                            title: 'Mes signalements',
                            subtitle: '1 en cours',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ActionMiniCard(
                            icon: Icons.bookmark_border,
                            title: 'Ressources',
                            subtitle: 'Comprendre, agir',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Bouton d'urgence flottant, au-dessus de la barre de navigation.
              Positioned(
                right: 22,
                bottom: 16,
                child: SosButton(onTap: () {}),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HavenBottomBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
        onCenterTap: _openReportFlow,
      ),
    );
  }
}
