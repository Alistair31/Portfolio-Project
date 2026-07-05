import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';

class StaffReportDetailPage extends StatefulWidget {
  final String reportId;
  const StaffReportDetailPage({super.key, required this.reportId});

  @override
  State<StaffReportDetailPage> createState() => _StaffReportDetailPageState();
}

class _StaffReportDetailPageState extends State<StaffReportDetailPage> {
  Map<String, dynamic>? _report;
  bool _loading = true;
  bool _updating = false;
  bool _sendingMessage = false;
  final _msgController = TextEditingController();

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
    'NONE':                  'Nom visible',
    'NAME_HIDDEN':           'Prénom masqué',
    'NAME_AND_CLASS_HIDDEN': 'Prénom et classe masqués',
    'FULLY_ANONYMOUS':       'Totalement anonyme',
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = SessionService().getToken();
    if (token == null) return;
    try {
      final report = await ApiService().getStaffReportDetail(token: token, id: widget.reportId);
      if (mounted) setState(() { _report = report; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _sendingMessage) return;

    final token = SessionService().getToken();
    if (token == null) return;

    setState(() => _sendingMessage = true);
    try {
      await ApiService().sendStaffReportMessage(token: token, id: widget.reportId, body: text);
      _msgController.clear();
      await _load(); // rafraîchit la conversation
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _sendingMessage = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final notes = await _askNotes(newStatus);
    if (notes == null) return; // dialog annulé

    final token = SessionService().getToken();
    if (token == null) return;
    setState(() => _updating = true);
    try {
      await ApiService().updateReportStatus(
        token: token, id: widget.reportId, status: newStatus, notes: notes.isEmpty ? null : notes,
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _escalate() async {
    final notes = await _askNotes('ESCALATE');
    if (notes == null) return;

    final token = SessionService().getToken();
    if (token == null) return;
    setState(() => _updating = true);
    try {
      await ApiService().escalateReport(token: token, id: widget.reportId, notes: notes.isEmpty ? null : notes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signalement transféré au Rectorat.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<String?> _askNotes(String action) async {
    final ctrl = TextEditingController();
    final label = action == 'IN_PROGRESS' ? 'Prise en charge'
        : action == 'CLOSED'    ? 'Clôture'
        : 'Transfert au Rectorat';

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Note facultative (optionnel)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = SessionService().getRole() ?? '';
    final canEdit = role == 'TEACHER' || role == 'DIRECTOR_CPE';

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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.racingGreen),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.eucalyptus))
                    : _report == null
                        ? const Center(child: Text('Impossible de charger le signalement.'))
                        : _buildContent(canEdit),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool canEdit) {
    final r = _report!;
    final status = r['status'] as String;
    final followUps = (r['followUps'] as List<dynamic>?) ?? [];
    final messages = (r['messages'] as List<dynamic>?) ?? [];
    final author = r['author'] as Map<String, dynamic>?;

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
                color: _statusColor(status).withAlpha(26),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _statusColor(status).withAlpha(80)),
              ),
              child: Text(
                _statusLabels[status] ?? status,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _statusColor(status)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Code de suivi
          if ((r['trackingCode'] as String?)?.isNotEmpty == true)
            Center(
              child: Text(
                r['trackingCode'] as String,
                style: const TextStyle(fontSize: 12, color: AppColors.edward, letterSpacing: 1),
              ),
            ),
          const SizedBox(height: 16),

          // Infos
          _Card(children: [
            _Row(label: 'Type',        value: _typeLabels[r['type']] ?? (r['type'] as String)),
            _Row(label: 'Gravité',     value: '${r['gravity']}/5', trailing: _gravityDots(r['gravity'] as int)),
            _Row(label: 'Destinataire', value: _targetLabels[r['targetLevel']] ?? (r['targetLevel'] as String)),
            _Row(label: 'Anonymat',    value: _anonymityLabels[r['anonymityLevel']] ?? (r['anonymityLevel'] as String)),
            _Row(label: 'Soumis le',   value: _formatDate(r['createdAt'] as String)),
            if (author?['name'] != null)
              _Row(label: 'Élève', value: author!['name'] as String),
            if (author?['className'] != null)
              _Row(label: 'Classe', value: author!['className'] as String),
          ]),
          const SizedBox(height: 14),

          // Description
          const _SectionTitle(title: 'Description'),
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
              style: const TextStyle(fontSize: 14, height: 1.55, color: AppColors.textDark),
            ),
          ),
          const SizedBox(height: 20),

          // Historique
          _SectionTitle(
            title: 'Historique',
            badge: followUps.isEmpty ? null : '${followUps.length}',
          ),
          const SizedBox(height: 8),
          if (followUps.isEmpty)
            const Text('Aucune action pour l\'instant.',
              style: TextStyle(fontSize: 13, color: AppColors.edward))
          else
            ...followUps.map((f) {
              final fu = f as Map<String, dynamic>;
              final staff = fu['staff'] as Map<String, dynamic>?;
              final fuStatus = fu['newStatus'] as String;
              return _FollowUpTile(
                staffName:    staff?['name'] as String? ?? '—',
                newStatus:    _statusLabels[fuStatus] ?? fuStatus,
                statusColor:  _statusColor(fuStatus),
                notes:        fu['notes'] as String,
                dateLabel:    _formatShort(fu['createdAt'] as String),
              );
            }),

          // Conversation libre avec l'élève
          const SizedBox(height: 28),
          _SectionTitle(
            title: 'Conversation avec l\'élève',
            badge: messages.isEmpty ? null : '${messages.length}',
          ),
          const SizedBox(height: 12),
          if (messages.isEmpty)
            const Text('Aucun message pour l\'instant.',
              style: TextStyle(fontSize: 13, color: AppColors.edward))
          else
            ...messages.map((m) {
              final msg = m as Map<String, dynamic>;
              final isStudent = msg['senderRole'] == 'STUDENT';
              return _MsgBubble(
                text:      msg['body'] as String,
                isStudent: isStudent,
                dateLabel: _formatShort(msg['createdAt'] as String),
              );
            }),
          const SizedBox(height: 12),
          // Zone de réponse — disponible pour tout agent ayant accès au signalement
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: TextField(
                    controller: _msgController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                    decoration: const InputDecoration(
                      hintText: 'Répondre à l\'élève…',
                      hintStyle: TextStyle(color: AppColors.edward),
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _sendingMessage ? null : _sendMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.eucalyptus,
                    shape: BoxShape.circle,
                  ),
                  child: _sendingMessage
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),

          // Actions staff (TEACHER / DIRECTOR_CPE uniquement)
          if (canEdit && status != 'CLOSED') ...[
            const SizedBox(height: 28),
            const _SectionTitle(title: 'Actions'),
            const SizedBox(height: 12),
            if (status == 'PENDING')
              _ActionButton(
                label: 'Prendre en charge',
                icon: Icons.play_arrow_outlined,
                color: const Color(0xFF4A90D9),
                loading: _updating,
                onTap: () => _updateStatus('IN_PROGRESS'),
              ),
            if (status == 'IN_PROGRESS')
              _ActionButton(
                label: 'Clôturer le signalement',
                icon: Icons.check_circle_outline,
                color: AppColors.eucalyptus,
                loading: _updating,
                onTap: () => _updateStatus('CLOSED'),
              ),
            const SizedBox(height: 10),
            _ActionButton(
              label: 'Transférer au Rectorat',
              icon: Icons.upload_outlined,
              color: AppColors.corduroy,
              loading: _updating,
              onTap: _escalate,
            ),
          ],
        ],
      ),
    );
  }

  Widget _gravityDots(int gravity) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (i) => Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Icon(Icons.circle, size: 7,
        color: i < gravity ? AppColors.racingGreen : AppColors.hairlineStrong),
    )),
  );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label, required this.icon, required this.color,
    required this.loading, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
            const Spacer(),
            if (loading)
              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: color))
            else
              Icon(Icons.chevron_right, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? badge;
  const _SectionTitle({required this.title, this.badge});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.racingGreen)),
      if (badge != null) ...[
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(color: AppColors.eucalyptus.withAlpha(30), borderRadius: BorderRadius.circular(10)),
          child: Text(badge!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.eucalyptus)),
        ),
      ],
    ],
  );
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.hairline),
    ),
    child: Column(children: children),
  );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  const _Row({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        SizedBox(width: 110,
          child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.corduroy))),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.racingGreen))),
        ?trailing,
      ],
    ),
  );
}

class _MsgBubble extends StatelessWidget {
  final String text;
  final bool isStudent;
  final String dateLabel;
  const _MsgBubble({required this.text, required this.isStudent, required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    // Point de vue staff : message élève à gauche (entrant), réponse staff à droite.
    return Align(
      alignment: isStudent ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: isStudent ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isStudent ? Colors.white : AppColors.eucalyptus,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isStudent ? 4 : 18),
                    bottomRight: Radius.circular(isStudent ? 18 : 4),
                  ),
                  border: isStudent ? Border.all(color: AppColors.hairline) : null,
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: isStudent ? AppColors.textDark : Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                child: Text(dateLabel, style: const TextStyle(fontSize: 10, color: AppColors.edward)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowUpTile extends StatelessWidget {
  final String staffName;
  final String newStatus;
  final Color statusColor;
  final String notes;
  final String dateLabel;
  const _FollowUpTile({
    required this.staffName, required this.newStatus, required this.statusColor,
    required this.notes, required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(width: 8, height: 8,
            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
          Container(width: 1, height: 60, color: AppColors.hairline),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(staffName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.racingGreen)),
                const Spacer(),
                Text(dateLabel, style: const TextStyle(fontSize: 11, color: AppColors.edward)),
              ]),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withAlpha(26), borderRadius: BorderRadius.circular(10)),
                child: Text(newStatus, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
              ),
              const SizedBox(height: 6),
              Text(notes, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textDark)),
            ]),
          ),
        ),
      ],
    ),
  );
}
