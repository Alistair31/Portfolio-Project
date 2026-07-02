import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/logout_button.dart';

/// Écran 14 · Sur-admin · Rectorat — vue académique agrégée.
/// Accessible pour le rôle RECTORAT uniquement.
class RectoratPage extends StatefulWidget {
  const RectoratPage({super.key});

  @override
  State<RectoratPage> createState() => _RectoratPageState();
}

class _RectoratPageState extends State<RectoratPage> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = SessionService().getToken();
    if (token == null) { setState(() => _loading = false); return; }
    try {
      final stats = await ApiService().getStats(token: token);
      if (mounted) setState(() { _stats = stats; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bySchool = _stats == null
        ? <Map<String, dynamic>>[]
        : ((_stats!['bySchool'] as List<dynamic>?) ?? []).cast<Map<String, dynamic>>();

    final totalSignal = _stats?['total'] as int? ?? 0;
    final globalRate  = ((_stats?['resolutionRate'] as num?) ?? 0).toDouble();
    final schools     = bySchool.length;

    final atRisk = bySchool.where((s) {
      final t = (s['total'] as int? ?? 0);
      if (t == 0) return false;
      final c = (s['closed'] as int? ?? 0);
      return c / t < 0.6;
    }).length;

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
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Académie de Toulouse',
                                    style: TextStyle(fontSize: 12, color: AppColors.corduroy),
                                  ),
                                  const Text(
                                    'Vue académique',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.racingGreen,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.racingGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Bannière vie privée
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.grannySmith.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.visibility_off_outlined, size: 15, color: AppColors.eucalyptus),
                              SizedBox(width: 8),
                              Text(
                                'Données agrégées — jamais nominatives.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.racingGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // KPIs
                        if (!_loading) ...[
                          Row(
                            children: [
                              _KpiCard(value: '$schools',                          label: 'Établis.'),
                              const SizedBox(width: 10),
                              _KpiCard(value: '$totalSignal',                      label: 'Signal.'),
                              const SizedBox(width: 10),
                              _KpiCard(value: '${(globalRate * 100).round()}%',    label: 'Résolus'),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Alerte si des établissements à risque
                          if (atRisk > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F0),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE8505B).withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFE8505B), size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '$atRisk ${atRisk == 1 ? 'établissement nécessite' : 'établissements nécessitent'} un soutien renforcé',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFE8505B),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: Color(0xFFE8505B), size: 18),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),

                          const Text(
                            'TAUX DE RÉSOLUTION PAR ÉTABLISSEMENT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.corduroy,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        if (_loading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(color: AppColors.eucalyptus),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                if (!_loading)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList.separated(
                      itemCount: bySchool.isEmpty ? 1 : bySchool.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        if (bySchool.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'Aucun établissement dans la base.',
                                style: TextStyle(color: AppColors.corduroy),
                              ),
                            ),
                          );
                        }
                        final s = bySchool[i];
                        final t = (s['total'] as int? ?? 0).clamp(1, 99999);
                        final c = s['closed'] as int? ?? 0;
                        final rate = c / t;
                        return _SchoolRow(
                          code: s['schoolCode'] as String? ?? '—',
                          rate: rate,
                          total: t,
                        );
                      },
                    ),
                  ),

                // Bouton déconnexion
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: const LogoutButton(),
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

// ---------------------------------------------------------------------------

class _KpiCard extends StatelessWidget {
  final String value;
  final String label;
  const _KpiCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.racingGreen,
                letterSpacing: -0.3,
              ),
            ),
            Text(value.isEmpty ? '' : label,
                style: const TextStyle(fontSize: 10, color: AppColors.corduroy)),
          ],
        ),
      ),
    );
  }
}

class _SchoolRow extends StatelessWidget {
  final String code;
  final double rate;
  final int total;
  const _SchoolRow({required this.code, required this.rate, required this.total});

  Color get _color {
    if (rate >= 0.8) return AppColors.eucalyptus;
    if (rate >= 0.6) return const Color(0xFFE89B4E);
    return const Color(0xFFE8505B);
  }

  @override
  Widget build(BuildContext context) {
    final pct = (rate * 100).round();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.racingGreen),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: rate,
                    minHeight: 6,
                    backgroundColor: AppColors.hairline,
                    color: _color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$pct%',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.racingGreen),
          ),
        ],
      ),
    );
  }
}
