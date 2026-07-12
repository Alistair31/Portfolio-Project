import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/logout_button.dart';
import 'rectorat_page.dart';
import 'staff_report_detail_page.dart';
import 'staff_stats_page.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  List<Map<String, dynamic>> _reports = [];
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _selectedStatus;

  static const _roleLabels = {
    'TEACHER':      'Professeur',
    'DIRECTOR_CPE': 'Direction / CPE',
    'RECTORAT':     'Rectorat',
  };

  static const _statusLabels = {
    'PENDING':     'En attente',
    'IN_PROGRESS': 'En cours',
    'CLOSED':      'Clôturé',
  };

  static const _typeLabels = {
    'PHYSICAL': 'Violence physique',
    'VERBAL':   'Violence verbale',
    'SEXUAL':   'Violence sexuelle',
    'CYBER':    'Cyberharcèlement',
    'OTHER':    'Autre',
  };

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
    _loadStats();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final token = SessionService().getToken();
    if (token == null) { setState(() => _loading = false); return; }
    try {
      final reports = await ApiService().getReports(token: token, status: _selectedStatus);
      if (mounted) setState(() { _reports = reports; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Aperçu statistique de la home — indépendant du filtre de statut de la liste.
  // Non bloquant : en cas d'échec, l'aperçu est simplement masqué.
  Future<void> _loadStats() async {
    final token = SessionService().getToken();
    if (token == null) return;
    try {
      final stats = await ApiService().getStats(token: token);
      if (mounted) setState(() => _stats = stats);
    } catch (_) {
      // silencieux : la liste reste utilisable sans l'aperçu
    }
  }

  Future<void> _refresh() => Future.wait([_load(), _loadStats()]);

  void _openFullStats() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Statistiques'),
          backgroundColor: AppColors.backgroundTop,
          foregroundColor: AppColors.racingGreen,
          elevation: 0,
        ),
        backgroundColor: AppColors.backgroundBottom,
        body: const StaffStatsPage(),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = SessionService().getRole() ?? '';
    final name = SessionService().getName() ?? '';

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
            onRefresh: _refresh,
            color: AppColors.eucalyptus,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _roleLabels[role] ?? role,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.racingGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const LogoutButton(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Raccourcis Stats / Vue académique
                        Row(
                          children: [
                            Expanded(
                              child: _QuickLink(
                                icon: Icons.bar_chart_outlined,
                                label: 'Statistiques',
                                onTap: _openFullStats,
                              ),
                            ),
                            if (role == 'RECTORAT') ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: _QuickLink(
                                  icon: Icons.account_balance_outlined,
                                  label: 'Vue académique',
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const RectoratPage()),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Filtres par statut
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'Tous',
                                selected: _selectedStatus == null,
                                onTap: () { setState(() => _selectedStatus = null); _load(); },
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'En attente',
                                selected: _selectedStatus == 'PENDING',
                                color: const Color(0xFFE89B4E),
                                onTap: () { setState(() => _selectedStatus = 'PENDING'); _load(); },
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'En cours',
                                selected: _selectedStatus == 'IN_PROGRESS',
                                color: const Color(0xFF4A90D9),
                                onTap: () { setState(() => _selectedStatus = 'IN_PROGRESS'); _load(); },
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Clôturés',
                                selected: _selectedStatus == 'CLOSED',
                                color: AppColors.eucalyptus,
                                onTap: () { setState(() => _selectedStatus = 'CLOSED'); _load(); },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (_loading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColors.eucalyptus)),
                  )
                else ...[
                  if (_reports.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined, size: 48, color: AppColors.edward),
                            const SizedBox(height: 12),
                            Text(
                              _selectedStatus == null
                                  ? 'Aucun signalement.'
                                  : 'Aucun signalement pour ce filtre.',
                              style: const TextStyle(fontSize: 15, color: AppColors.corduroy, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      sliver: SliverList.separated(
                        itemCount: _reports.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                        final r = _reports[i];
                        final status = r['status'] as String;
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => StaffReportDetailPage(reportId: r['id'] as String),
                            ));
                            _refresh();
                          },
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
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _typeLabels[r['type']] ?? (r['type'] as String),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.racingGreen,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.statusColor(status).withAlpha(26),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _statusLabels[status] ?? status,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.statusColor(status),
                                        ),
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
                                        color: j < (r['gravity'] as int) ? AppColors.racingGreen : AppColors.hairlineStrong),
                                    )),
                                    const SizedBox(width: 6),
                                    Text('Gravité ${r['gravity']}/5',
                                      style: const TextStyle(fontSize: 12, color: AppColors.corduroy)),
                                    const Spacer(),
                                    Text(_formatDate(r['createdAt'] as String),
                                      style: const TextStyle(fontSize: 12, color: AppColors.edward)),
                                  ],
                                ),
                                if ((r['author'] as Map<String, dynamic>)['name'] != null ||
                                    (r['author'] as Map<String, dynamic>)['className'] != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    [
                                      (r['author'] as Map)['name'],
                                      (r['author'] as Map)['className'],
                                    ].where((v) => v != null).join(' · '),
                                    style: const TextStyle(fontSize: 12, color: AppColors.corduroy),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Aperçu statistique compact, sous les suivis (remplit aussi
                  // la page quand la liste est vide).
                  if (_stats != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                        child: _MiniStats(stats: _stats!, onSeeAll: _openFullStats),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Aperçu statistique compact affiché sur la home staff, sous la liste des
/// suivis. Reprend les chiffres clés de `GET /api/stats` sans la version
/// complète (graphe d'évolution, répartitions détaillées) — voir « Voir tout ».
class _MiniStats extends StatelessWidget {
  final Map<String, dynamic> stats;
  final VoidCallback onSeeAll;

  const _MiniStats({required this.stats, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final total      = stats['total'] as int? ?? 0;
    final rate       = (((stats['resolutionRate'] as num?) ?? 0) * 100).round();
    final byStatus   = (stats['byStatus'] as Map<String, dynamic>?) ?? const {};
    final pending    = byStatus['PENDING'] as int? ?? 0;
    final inProgress = byStatus['IN_PROGRESS'] as int? ?? 0;
    final closed     = byStatus['CLOSED'] as int? ?? 0;

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
              const Text(
                'Aperçu',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.racingGreen),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSeeAll,
                behavior: HitTestBehavior.opaque,
                child: const Row(
                  children: [
                    Text('Voir tout', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.eucalyptus)),
                    Icon(Icons.chevron_right, size: 16, color: AppColors.eucalyptus),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$total',
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.racingGreen, letterSpacing: -1),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('signalements', style: TextStyle(fontSize: 13, color: AppColors.corduroy)),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$rate%',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.eucalyptus),
                  ),
                  const Text('résolus', style: TextStyle(fontSize: 11, color: AppColors.corduroy)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatPill(label: 'En attente', count: pending, color: const Color(0xFFE89B4E)),
              const SizedBox(width: 8),
              _StatPill(label: 'En cours', count: inProgress, color: const Color(0xFF4A90D9)),
              const SizedBox(width: 8),
              _StatPill(label: 'Clôturés', count: closed, color: AppColors.eucalyptus),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatPill({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10.5, color: AppColors.corduroy, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLink({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.eucalyptus),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.racingGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.racingGreen;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? c.withAlpha(30) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? c : AppColors.hairline),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? c : AppColors.corduroy,
          ),
        ),
      ),
    );
  }
}
