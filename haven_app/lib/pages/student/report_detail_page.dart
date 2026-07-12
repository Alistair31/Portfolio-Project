import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/preferences.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import 'exchange_page.dart';

/// Détail d'un signalement élève — infos, description, timeline des follow-ups,
/// et bouton d'annulation si le signalement est annulable (PENDING < 5 min).
class ReportDetailPage extends StatefulWidget {
  final String reportId;

  const ReportDetailPage({super.key, required this.reportId});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  Map<String, dynamic>? _report;
  bool _loading = true;
  bool _cancelling = false;
  // null = pas encore vérifié / pas de hash local, true = intact, false = altéré
  bool? _verified;
  Map<String, dynamic>? _snapshot;
  Timer? _cancelExpiry;

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

  static const _targetLabels = {
    'TEACHER':      'Professeur principal',
    'DIRECTOR_CPE': 'Direction / CPE',
    'RECTORAT':     'Rectorat',
  };

  static const _anonymityLabels = {
    'NONE':                   'Nom visible',
    'NAME_HIDDEN':            'Prénom masqué',
    'NAME_AND_CLASS_HIDDEN':  'Prénom et classe masqués',
    'FULLY_ANONYMOUS':        'Totalement anonyme',
  };

  static const _roleLabels = {
    'TEACHER':      'Professeur',
    'DIRECTOR_CPE': 'Direction / CPE',
    'RECTORAT':     'Rectorat',
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
    const jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    const mois  = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin',
                   'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    return '${jours[d.weekday - 1]} ${d.day} ${mois[d.month - 1]} ${d.year}';
  }

  static String _formatShort(String iso) {
    final d = DateTime.parse(iso).toLocal();
    const mois = ['jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin',
                   'juil.', 'août', 'sep.', 'oct.', 'nov.', 'déc.'];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${mois[d.month - 1]} · $h:$m';
  }

  bool get _canCancel {
    if (_report == null) return false;
    if (_report!['status'] != 'PENDING') return false;
    final created = DateTime.parse(_report!['createdAt'] as String);
    return DateTime.now().difference(created) < const Duration(minutes: 5);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _cancelExpiry?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final token = SessionService().getToken();
    if (token == null) return;
    try {
      final report = await ApiService().getReportDetail(token: token, id: widget.reportId);
      if (mounted) {
        setState(() { _report = report; _loading = false; });
        _scheduleCancelExpiry(report);
      }
      _checkIntegrity(token, report['id'] as String);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Déclenche un rebuild exactement à l'expiration de la fenêtre de 5 minutes,
  // pour que le bouton d'annulation disparaisse sans attendre une interaction.
  void _scheduleCancelExpiry(Map<String, dynamic> report) {
    _cancelExpiry?.cancel();
    if (report['status'] != 'PENDING') return;
    final created = DateTime.parse(report['createdAt'] as String);
    final remaining = const Duration(minutes: 5) - DateTime.now().difference(created);
    if (remaining > Duration.zero) {
      _cancelExpiry = Timer(remaining, () {
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _checkIntegrity(String token, String reportId) async {
    final localHash = await PreferencesService().getIntegrityHash(reportId);
    if (localHash == null) return;
    final results = await Future.wait([
      ApiService().verifyReport(token: token, id: reportId),
      PreferencesService().getReportSnapshot(reportId),
    ]);
    final verified = results[0] as bool?;
    final snapshot = results[1] as Map<String, dynamic>?;
    if (mounted) setState(() { _verified = verified; _snapshot = snapshot; });
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler le signalement'),
        content: const Text('Cette action est irréversible. Le signalement sera supprimé définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Retour'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.delButton),
            child: const Text('Annuler le signalement'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final token = SessionService().getToken();
    if (token == null) return;

    setState(() => _cancelling = true);
    try {
      await ApiService().cancelReport(token: token, id: widget.reportId);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      setState(() => _cancelling = false);
    }
  }

  void _showComparison() {
    final s = _snapshot!;
    final r = _report!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Comparaison du contenu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CompareRow(label: 'Type',
                original: _typeLabels[s['type']] ?? (s['type'] as String? ?? '—'),
                current:  _typeLabels[r['type']] ?? (r['type'] as String)),
              _CompareRow(label: 'Gravité',
                original: '${s['gravity']}/5',
                current:  '${r['gravity']}/5'),
              _CompareRow(label: 'Mode',
                original: s['mode'] == 'VICTIM' ? 'Victime' : 'Témoin',
                current:  r['mode']  == 'VICTIM' ? 'Victime' : 'Témoin'),
              _CompareRow(label: 'Anonymat',
                original: _anonymityLabels[s['anonymityLevel']] ?? (s['anonymityLevel'] as String? ?? '—'),
                current:  _anonymityLabels[r['anonymityLevel']] ?? (r['anonymityLevel'] as String)),
              _CompareRow(label: 'Description',
                original: s['description'] as String? ?? '—',
                current:  r['description'] as String),
            ],
          ),
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
          child: Column(
            children: [
              // En-tête
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: AppColors.racingGreen),
                    ),
                    const Text(
                      'Détail du signalement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.racingGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.eucalyptus))
                    : _report == null
                        ? const Center(child: Text('Impossible de charger le signalement.'))
                        : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final r = _report!;
    final status = r['status'] as String;
    final statusColor = _statusColor(status);
    final followUps = (r['followUps'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Badge statut
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(26),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: statusColor.withAlpha(80)),
              ),
              child: Text(
                _statusLabels[status] ?? status,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
          ),
          if (_verified != null) ...[
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: (_verified! ? AppColors.eucalyptus : AppColors.delButton).withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (_verified! ? AppColors.eucalyptus : AppColors.delButton).withAlpha(80),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _verified! ? Icons.verified_outlined : Icons.warning_amber_outlined,
                      size: 14,
                      color: _verified! ? AppColors.eucalyptus : AppColors.delButton,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _verified! ? 'Contenu original vérifié' : 'Contenu potentiellement modifié',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _verified! ? AppColors.eucalyptus : AppColors.delButton,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!_verified! && _snapshot != null) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _showComparison,
                  icon: const Icon(Icons.compare_arrows, size: 16),
                  label: const Text('Comparer avec l\'original'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.delButton),
                ),
              ),
            ],
          ],
          const SizedBox(height: 20),

          // Infos principales
          _InfoCard(children: [
            _InfoRow(label: 'Type',        value: _typeLabels[r['type']] ?? r['type'] as String),
            _InfoRow(label: 'Gravité',     value: '${r['gravity']}/5', trailing: _gravityDots(r['gravity'] as int)),
            _InfoRow(label: 'Destinataire', value: _targetLabels[r['targetLevel']] ?? r['targetLevel'] as String),
            _InfoRow(label: 'Anonymat',    value: _anonymityLabels[r['anonymityLevel']] ?? r['anonymityLevel'] as String),
            _InfoRow(label: 'Soumis le',   value: _formatDate(r['createdAt'] as String)),
          ]),
          const SizedBox(height: 14),

          // Description
          _SectionTitle(title: 'Description'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Text(
              r['description'] as String,
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Timeline follow-ups
          _SectionTitle(
            title: 'Historique',
            badge: followUps.isEmpty ? null : '${followUps.length}',
          ),
          const SizedBox(height: 8),
          if (followUps.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_empty, size: 16, color: AppColors.edward),
                  const SizedBox(width: 8),
                  const Text(
                    'Aucune action pour l\'instant.',
                    style: TextStyle(fontSize: 13, color: AppColors.corduroy),
                  ),
                ],
              ),
            )
          else
            ...followUps.map((fu) {
              final f = fu as Map<String, dynamic>;
              final role = (f['staff'] as Map<String, dynamic>?)?['role'] as String? ?? '';
              final newStatus = f['newStatus'] as String;
              return _FollowUpTile(
                roleLabel:       _roleLabels[role] ?? role,
                newStatusLabel:  _statusLabels[newStatus] ?? newStatus,
                newStatusColor:  _statusColor(newStatus),
                notes:           f['notes'] as String,
                dateLabel:       _formatShort(f['createdAt'] as String),
              );
            }),

          // Bouton échange avec le staff
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ExchangePage(reportId: widget.reportId),
              ),
            ),
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text('Parler à l\'équipe'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.eucalyptus,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),

          // Bouton annulation
          if (_canCancel) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _cancelling ? null : _cancel,
              icon: _cancelling
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.delButton),
                    )
                  : const Icon(Icons.close, size: 18),
              label: Text(_cancelling ? 'Annulation…' : 'Annuler le signalement'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.delButton,
                side: const BorderSide(color: AppColors.delButton),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Possible uniquement dans les 5 minutes suivant l\'envoi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.edward),
            ),
          ],
        ],
      ),
    );
  }

  Widget _gravityDots(int gravity) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Padding(
        padding: const EdgeInsets.only(left: 3),
        child: Icon(
          Icons.circle,
          size: 7,
          color: i < gravity ? AppColors.racingGreen : AppColors.hairlineStrong,
        ),
      )),
    );
  }
}

// ── Widgets internes ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? badge;

  const _SectionTitle({required this.title, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.label,
            letterSpacing: 0.3,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.blueRomance,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badge!,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.eucalyptus),
            ),
          ),
        ],
      ],
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String original;
  final String current;

  const _CompareRow({required this.label, required this.original, required this.current});

  @override
  Widget build(BuildContext context) {
    final changed = original != current;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.corduroy)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Original', style: TextStyle(fontSize: 10, color: AppColors.eucalyptus)),
                    const SizedBox(height: 2),
                    Text(original, style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
                  ],
                ),
              ),
              if (changed) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Actuel', style: TextStyle(fontSize: 10, color: AppColors.delButton)),
                      const SizedBox(height: 2),
                      Text(current, style: const TextStyle(fontSize: 12, color: AppColors.delButton, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (changed)
            const Divider(color: AppColors.hairlineStrong, height: 16),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget trailing;

  const _InfoRow({required this.label, required this.value, this.trailing = const SizedBox.shrink()});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.corduroy),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.racingGreen),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _FollowUpTile extends StatelessWidget {
  final String roleLabel;
  final String newStatusLabel;
  final Color newStatusColor;
  final String notes;
  final String dateLabel;

  const _FollowUpTile({
    required this.roleLabel,
    required this.newStatusLabel,
    required this.newStatusColor,
    required this.notes,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: newStatusColor,
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 1, height: 60, color: AppColors.hairline),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        roleLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.racingGreen,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateLabel,
                        style: const TextStyle(fontSize: 11, color: AppColors.edward),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: newStatusColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      newStatusLabel,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: newStatusColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notes,
                    style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textDark),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
