import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/logout_button.dart';

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  List<Map<String, dynamic>> _reports = [];
  bool _loading = true;

  static const _typeLabels = {
    'PHYSICAL': 'Violence physique',
    'VERBAL':   'Violence verbale',
    'SEXUAL':   'Violence sexuelle',
    'CYBER':    'Cyberharcèlement',
    'OTHER':    'Autre',
  };

  static const _statusLabels = {
    'PENDING':     'En attente',
    'IN_PROGRESS': 'En cours',
    'CLOSED':      'Clôturé',
  };

  static Color _statusColor(String s) {
    switch (s) {
      case 'PENDING':     return const Color(0xFFE89B4E);
      case 'IN_PROGRESS': return const Color(0xFF4A90D9);
      case 'CLOSED':      return AppColors.eucalyptus;
      default:            return AppColors.edward;
    }
  }

  static String _formatDate(String iso) {
    final d = DateTime.parse(iso).toLocal();
    const mois = ['jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin',
                   'juil.', 'août', 'sep.', 'oct.', 'nov.', 'déc.'];
    return '${d.day} ${mois[d.month - 1]} ${d.year}';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final token = SessionService().getToken();
    if (token == null) { setState(() => _loading = false); return; }
    try {
      final reports = await ApiService().getParentReports(token: token);
      if (mounted) setState(() { _reports = reports; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
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
          child: RefreshIndicator(
            onRefresh: _load,
            color: AppColors.eucalyptus,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Espace parent',
                                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                              Text(SessionService().getName() ?? '',
                                style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.racingGreen)),
                            ],
                          ),
                        ),
                        const LogoutButton(),
                      ],
                    ),
                  ),
                ),
                if (_loading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColors.eucalyptus)),
                  )
                else if (_reports.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_outlined, size: 56, color: AppColors.edward),
                          const SizedBox(height: 14),
                          const Text('Aucun signalement de votre enfant.',
                            style: TextStyle(fontSize: 15, color: AppColors.corduroy, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          const Text('Tire vers le bas pour actualiser.',
                            style: TextStyle(fontSize: 13, color: AppColors.edward)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    sliver: SliverList.separated(
                      itemCount: _reports.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final r = _reports[i];
                        final status = r['status'] as String;
                        final author = r['author'] as Map<String, dynamic>?;
                        final followUpCount =
                            (r['_count'] as Map<String, dynamic>?)?['followUps'] as int? ?? 0;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.hairline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _typeLabels[r['type']] ?? (r['type'] as String),
                                      style: const TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.racingGreen),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status).withAlpha(26),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _statusLabels[status] ?? status,
                                      style: TextStyle(
                                        fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor(status)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ...List.generate(5, (j) => Padding(
                                    padding: const EdgeInsets.only(right: 3),
                                    child: Icon(Icons.circle, size: 7,
                                      color: j < (r['gravity'] as int)
                                          ? AppColors.racingGreen : AppColors.hairlineStrong),
                                  )),
                                  const SizedBox(width: 6),
                                  Text('Gravité ${r['gravity']}/5',
                                    style: const TextStyle(fontSize: 12, color: AppColors.corduroy)),
                                  const Spacer(),
                                  Text(_formatDate(r['createdAt'] as String),
                                    style: const TextStyle(fontSize: 12, color: AppColors.edward)),
                                ],
                              ),
                              if (author?['name'] != null || author?['className'] != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  [author?['name'], author?['className']]
                                      .where((v) => v != null).join(' · '),
                                  style: const TextStyle(fontSize: 12, color: AppColors.corduroy),
                                ),
                              ],
                              if (followUpCount > 0) ...[
                                const SizedBox(height: 6),
                                Row(children: [
                                  const Icon(Icons.chat_bubble_outline, size: 12, color: AppColors.eucalyptus),
                                  const SizedBox(width: 4),
                                  Text('$followUpCount suivi(s)',
                                    style: const TextStyle(fontSize: 12, color: AppColors.eucalyptus)),
                                ]),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
