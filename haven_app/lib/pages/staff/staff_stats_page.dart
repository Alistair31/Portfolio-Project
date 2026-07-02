import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';

/// Onglet Stats du tableau de bord staff — données réelles du backend.
class StaffStatsPage extends StatefulWidget {
  const StaffStatsPage({super.key});

  @override
  State<StaffStatsPage> createState() => _StaffStatsPageState();
}

class _StaffStatsPageState extends State<StaffStatsPage> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  List<Map<String, dynamic>> _timelinePoints = [];
  bool _timelineLoading = true;
  String _selectedPeriod = 'week';

  static const _typeLabels = {
    'CYBER':    'Cyberharcèlement',
    'VERBAL':   'Moqueries, insultes',
    'OTHER':    'Mise à l\'écart',
    'PHYSICAL': 'Violence physique',
    'SEXUAL':   'Violence sexuelle',
  };

  static const _periodLabels = {
    'week':  'Semaine',
    'month': 'Mois',
    'year':  'Année',
  };

  @override
  void initState() {
    super.initState();
    _load();
    _loadTimeline();
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

  Future<void> _loadTimeline() async {
    final token = SessionService().getToken();
    if (token == null) {
      if (mounted) setState(() => _timelineLoading = false);
      return;
    }
    try {
      final points = await ApiService().getTimeline(token: token, period: _selectedPeriod);
      if (mounted) setState(() { _timelinePoints = points; _timelineLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _timelineLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    setState(() { _timelineLoading = true; });
    await Future.wait([_load(), _loadTimeline()]);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.eucalyptus));
    }
    if (_stats == null) {
      return const Center(child: Text('Impossible de charger les statistiques.'));
    }

    final total     = _stats!['total'] as int? ?? 0;
    final rate      = ((_stats!['resolutionRate'] as num?) ?? 0).toDouble();
    final byType    = (_stats!['byType'] as Map<String, dynamic>?) ?? {};
    final byGravity = (_stats!['byGravity'] as Map<String, dynamic>?) ?? {};
    final gravityValues = List.generate(5, (i) => (byGravity['${i + 1}'] as int?) ?? 0);
    final maxGravity = gravityValues.fold(1, (m, v) => v > m ? v : m);

    final typeEntries = byType.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.eucalyptus,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.racingGreen,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 20),

            // ── Graphe d'évolution ──────────────────────────────────────────
            _TimelineCard(
              points: _timelinePoints,
              loading: _timelineLoading,
              selectedPeriod: _selectedPeriod,
              periodLabels: _periodLabels,
              onPeriodChanged: (p) {
                setState(() { _selectedPeriod = p; _timelineLoading = true; });
                _loadTimeline();
              },
            ),
            const SizedBox(height: 20),

            // ── Gravité ─────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Par niveau de gravité',
                    style: TextStyle(fontSize: 12, color: AppColors.corduroy, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.racingGreen,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 76,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(5, (i) {
                        final ratio = gravityValues[i] / maxGravity;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 50 * ratio,
                                  decoration: BoxDecoration(
                                    color: i == 4 ? AppColors.eucalyptus : AppColors.grannySmith,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Niv.${i + 1}',
                                  style: const TextStyle(fontSize: 9, color: AppColors.edward),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Ce qui évolue (par type) ────────────────────────────────────
            const Text(
              'CE QUI ÉVOLUE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.corduroy,
              ),
            ),
            const SizedBox(height: 10),
            ...typeEntries.take(4).map((e) {
              final count = e.value as int;
              final label = _typeLabels[e.key] ?? e.key;
              final ratio = count / (total.clamp(1, 99999));
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.racingGreen),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 5,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: AppColors.hairline,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: ratio,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.eucalyptus,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '$count',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.racingGreen),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // ── Métriques clés ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    value: '${(rate * 100).round()}%',
                    label: 'Signalements\nrésolus',
                    color: AppColors.grannySmith,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    value: '$total',
                    label: 'Total\nsignalements',
                    color: const Color(0xFFE8F3FC),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Carte graphe d'évolution ────────────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  final List<Map<String, dynamic>> points;
  final bool loading;
  final String selectedPeriod;
  final Map<String, String> periodLabels;
  final ValueChanged<String> onPeriodChanged;

  const _TimelineCard({
    required this.points,
    required this.loading,
    required this.selectedPeriod,
    required this.periodLabels,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final counts = points.map((p) => (p['count'] as int? ?? 0).toDouble()).toList();
    final maxY = counts.isEmpty ? 1.0 : counts.reduce((a, b) => a > b ? a : b);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Évolution',
                style: TextStyle(fontSize: 12, color: AppColors.corduroy, fontWeight: FontWeight.w500),
              ),
              // Sélecteur de période
              Row(
                children: periodLabels.entries.map((e) {
                  final selected = e.key == selectedPeriod;
                  return GestureDetector(
                    onTap: () => onPeriodChanged(e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.eucalyptus : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? AppColors.eucalyptus : AppColors.hairline,
                        ),
                      ),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.corduroy,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 140,
            child: loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.eucalyptus, strokeWidth: 2))
                : points.isEmpty
                    ? const Center(child: Text('Aucune donnée', style: TextStyle(color: AppColors.corduroy, fontSize: 13)))
                    : LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: (maxY * 1.25).ceilToDouble().clamp(1, double.infinity),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: AppColors.hairline,
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, _) {
                                  final i = value.toInt();
                                  if (i < 0 || i >= points.length) return const SizedBox.shrink();
                                  // N'affiche qu'un label sur deux si beaucoup de points
                                  if (points.length > 8 && i % 2 != 0) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      points[i]['label'] as String? ?? '',
                                      style: const TextStyle(fontSize: 9, color: AppColors.edward),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                points.length,
                                (i) => FlSpot(i.toDouble(), counts[i]),
                              ),
                              isCurved: true,
                              curveSmoothness: 0.3,
                              color: AppColors.eucalyptus,
                              barWidth: 2.5,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, p, bar, idx) => FlDotCirclePainter(
                                  radius: spot.y == maxY ? 4 : 2.5,
                                  color: AppColors.eucalyptus,
                                  strokeWidth: 0,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.eucalyptus.withValues(alpha: 0.15),
                                    AppColors.eucalyptus.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (_) => AppColors.racingGreen,
                              getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                                '${s.y.toInt()}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              )).toList(),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Carte métrique ──────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MetricCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.racingGreen,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.outerSpace, height: 1.4),
          ),
        ],
      ),
    );
  }
}
