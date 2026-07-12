import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/action_mini_card.dart';
import '../../widgets/conversation_card.dart';
import '../../widgets/greeting_header.dart';
import '../../widgets/haven_bottom_bar.dart';
import '../../widgets/sos_button.dart';
import '../../widgets/talk_hero_card.dart';
import '../chatbot/chatbot_page.dart';
import '../report/report_target_page.dart';
import 'account_page.dart';
import 'safe_space_page.dart';
import 'follow_up_page.dart';

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
  bool _reportsLoaded = false;
  int _activeReports = 0;
  int _totalReports = 0;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  // Récupère le nombre réel de signalements de l'élève pour la carte
  // « Mes signalements » (auparavant codé en dur à « 1 en cours »).
  Future<void> _loadReports() async {
    final token = SessionService().getToken();
    if (token == null) return;
    try {
      final reports = await ApiService().getMyReports(token: token);
      if (!mounted) return;
      setState(() {
        _totalReports = reports.length;
        _activeReports = reports.where((r) => r['status'] != 'CLOSED').length;
        _reportsLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _reportsLoaded = true);
    }
  }

  String get _reportsSubtitle {
    if (!_reportsLoaded) return 'Suivi de tes signalements';
    if (_totalReports == 0) return 'Aucun pour l\'instant';
    if (_activeReports == 0) return 'Tous traités';
    return '$_activeReports en cours';
  }

  void _onTabTap(int index) {
    if (index == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const SuiviPage()))
          .then((_) => _loadReports());
      return;
    }
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AccountPage()),
      );
      return;
    }
    setState(() => _currentIndex = index);
  }

  Future<void> _openReportFlow() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReportTargetPage()),
    );
    _loadReports();
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
                      onStart: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ChatbotPage()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConversationCard(
                      title: 'Conversation en cours',
                      subtitle: "Reprends où tu t'es arrêté·e",
                      badgeLabel: 'suivi',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ChatbotPage()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ActionMiniCard(
                            icon: Icons.access_time_outlined,
                            title: 'Mes signalements',
                            subtitle: _reportsSubtitle,
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SuiviPage()),
                              );
                              _loadReports();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ActionMiniCard(
                            icon: Icons.bookmark_border,
                            title: 'Espace Safe',
                            subtitle: 'Ressources & droits',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SafeSpacePage()),
                            ),
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
