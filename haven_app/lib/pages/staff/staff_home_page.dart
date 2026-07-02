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
      final reports = await ApiService().getReports(token: token, status: _selectedStatus);
      if (mounted) setState(() { _reports = reports; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
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
            onRefresh: _load,
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
                                onTap: () => Navigator.of(context).push(
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
                                ),
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
                            'Aucun signalement.',
                            style: TextStyle(fontSize: 15, color: AppColors.corduroy, fontWeight: FontWeight.w500),
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
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
                            _load();
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
                                        color: _statusColor(status).withAlpha(26),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _statusLabels[status] ?? status,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _statusColor(status),
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
              ],
            ),
          ),
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
