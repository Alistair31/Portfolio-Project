import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/haven_bottom_bar.dart';
import '../report/report_target_page.dart';
import 'account_page.dart';
import 'report_detail_page.dart';

/// Écran « Suivi » — liste des signalements soumis par l'élève.
class SuiviPage extends StatefulWidget {
  const SuiviPage({super.key});

  @override
  State<SuiviPage> createState() => _SuiviPageState();
}

class _SuiviPageState extends State<SuiviPage> {
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

  static Color _statusColor(String status) {
    switch (status) {
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
      final reports = await ApiService().getMyReports(token: token);
      if (mounted) setState(() { _reports = reports; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onTabTap(int index) {
    if (index == 0) { Navigator.of(context).maybePop(); return; }
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AccountPage()),
      );
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
          child: RefreshIndicator(
            onRefresh: _load,
            color: AppColors.eucalyptus,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    child: const Text(
                      'Mes signalements',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.racingGreen,
                      ),
                    ),
                  ),
                ),
                if (_loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.eucalyptus),
                    ),
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
                          const Text(
                            'Aucun signalement pour l\'instant.',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.corduroy,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tire vers le bas pour actualiser.',
                            style: TextStyle(fontSize: 13, color: AppColors.edward),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    sliver: SliverList.separated(
                      itemCount: _reports.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final r = _reports[i];
                        return _ReportCard(
                          typeLabel:   _typeLabels[r['type']]     ?? r['type'] as String,
                          statusLabel: _statusLabels[r['status']] ?? r['status'] as String,
                          statusColor: _statusColor(r['status'] as String),
                          gravity:     r['gravity'] as int,
                          dateLabel:   _formatDate(r['createdAt'] as String),
                          trackingCode: r['trackingCode'] as String? ?? '',
                          followUpCount: (r['_count'] as Map<String, dynamic>?)?['followUps'] as int? ?? 0,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReportDetailPage(reportId: r['id'] as String),
                              ),
                            );
                            _load();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: HavenBottomBar(
        currentIndex: 1,
        onTap: _onTabTap,
        onCenterTap: _openReportFlow,
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String typeLabel;
  final String statusLabel;
  final Color statusColor;
  final int gravity;
  final String dateLabel;
  final String trackingCode;
  final int followUpCount;
  final VoidCallback onTap;

  const _ReportCard({
    required this.typeLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.gravity,
    required this.dateLabel,
    required this.trackingCode,
    required this.followUpCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    typeLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.racingGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Icon(
                      Icons.circle,
                      size: 7,
                      color: i < gravity ? AppColors.racingGreen : AppColors.hairlineStrong,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Gravité $gravity/5',
                  style: const TextStyle(fontSize: 12, color: AppColors.corduroy),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  dateLabel,
                  style: const TextStyle(fontSize: 12, color: AppColors.edward),
                ),
                if (trackingCode.isNotEmpty) ...[
                  const Text(
                    ' · ',
                    style: TextStyle(fontSize: 12, color: AppColors.edward),
                  ),
                  Text(
                    trackingCode,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.edward,
                      fontFeatures: [],
                    ),
                  ),
                ],
                const Spacer(),
                if (followUpCount > 0) ...[
                  const Icon(Icons.chat_bubble_outline, size: 12, color: AppColors.eucalyptus),
                  const SizedBox(width: 3),
                  Text(
                    '$followUpCount',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.eucalyptus,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.edward),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
