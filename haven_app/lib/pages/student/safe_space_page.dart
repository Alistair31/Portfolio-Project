import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/haven_bottom_bar.dart';
import '../report/report_target_page.dart';
import 'account_page.dart';
import 'resources_page.dart';
import 'follow_up_page.dart';

/// Écran 12a · Espace Safe — respiration + contacts disponibles.
class SafeSpacePage extends StatelessWidget {
  const SafeSpacePage({super.key});

  static const _contacts = [
    _Contact(role: 'Psychologue',    name: 'M. Da Silva',  status: _Status.available),
    _Contact(role: 'Infirmière',     name: 'Mme Petit',    status: _Status.busy),
    _Contact(role: 'CPE référente',  name: 'Mme Roussel',  status: _Status.available),
    _Contact(role: 'Référent pHARe', name: 'M. Anand',     status: _Status.absent),
  ];

  // Navigation cohérente avec les autres pages élève (cf. SuiviPage) :
  // Accueil → retour à la home (dessous dans la pile), Suivi/Compte → push,
  // et le « + » ouvre le flux de signalement.
  void _onTabTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).maybePop();
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SuiviPage()),
        );
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AccountPage()),
        );
        break;
    }
  }

  void _openReportFlow(BuildContext context) {
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
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Espace Safe',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                          color: AppColors.racingGreen,
                        ),
                      ),
                      const Text(
                        'Une bulle pour souffler.',
                        style: TextStyle(fontSize: 15, color: AppColors.corduroy),
                      ),
                      const SizedBox(height: 20),

                      // Carte respiration
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.racingGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.grannySmith, width: 2.5),
                              ),
                              child: const Icon(Icons.self_improvement, color: AppColors.grannySmith, size: 26),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Respire avec moi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Technique 4 · 4 · 4 · 2',
                                    style: TextStyle(fontSize: 12, color: AppColors.grannySmith),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _showBreathing(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.grannySmith,
                                foregroundColor: AppColors.racingGreen,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              child: const Text('Commencer'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section contacts
                      const Text(
                        'QUELQU\'UN À QUI PARLER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.corduroy,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                sliver: SliverList.separated(
                  itemCount: _contacts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _ContactRow(contact: _contacts[i]),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ResourcesPage()),
                    ),
                    icon: const Icon(Icons.book_outlined, size: 16),
                    label: const Text('Ressources & droits →'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.eucalyptus,
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HavenBottomBar(
        currentIndex: 0,
        onTap: (i) => _onTabTap(context, i),
        onCenterTap: () => _openReportFlow(context),
      ),
    );
  }

  void _showBreathing(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Respiration 4 · 4 · 4 · 2'),
        content: const Text(
          'Inspire 4 secondes\nBloque 4 secondes\nExpire 4 secondes\nPause 2 secondes\n\nRépète 4 fois.',
          style: TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

enum _Status { available, busy, absent }

class _ContactRow extends StatelessWidget {
  final _Contact contact;
  const _ContactRow({required this.contact});

  Color get _dot {
    switch (contact.status) {
      case _Status.available: return AppColors.eucalyptus;
      case _Status.busy:      return const Color(0xFFE89B4E);
      case _Status.absent:    return AppColors.edward;
    }
  }

  String get _label {
    switch (contact.status) {
      case _Status.available: return 'Disponible';
      case _Status.busy:      return 'Occupé·e';
      case _Status.absent:    return 'Absent·e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.iconTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, size: 18, color: AppColors.racingGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.role,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.racingGreen,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(color: _dot, shape: BoxShape.circle),
                    ),
                    Text(
                      '${contact.name} · $_label',
                      style: TextStyle(fontSize: 11, color: _dot),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.eucalyptus),
        ],
      ),
    );
  }
}

class _Contact {
  final String role;
  final String name;
  final _Status status;
  const _Contact({required this.role, required this.name, required this.status});
}
