import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';

/// Écran 11 · Échanger — messagerie élève ↔ équipe pHARe.
/// Affiche les follow-ups du staff comme des bulles de chat.
/// La zone de saisie est UI-only côté élève (pas d'endpoint de message étudiant).
class ExchangePage extends StatefulWidget {
  final String reportId;

  const ExchangePage({super.key, required this.reportId});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  Map<String, dynamic>? _report;
  bool _loading = true;
  final _inputController = TextEditingController();

  static const _roleLabels = {
    'TEACHER':      'Professeur principal',
    'DIRECTOR_CPE': 'Direction / CPE',
    'RECTORAT':     'Rectorat',
  };

  static String _formatTime(String iso) {
    final d = DateTime.parse(iso).toLocal();
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = SessionService().getToken();
    if (token == null) { setState(() => _loading = false); return; }
    try {
      final report = await ApiService().getReportDetail(token: token, id: widget.reportId);
      if (mounted) setState(() { _report = report; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _followUps {
    final list = (_report?['followUps'] as List<dynamic>?) ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  String get _staffLabel {
    if (_followUps.isNotEmpty) {
      final role = (_followUps.last['staff'] as Map<String, dynamic>?)?['role'] as String? ?? '';
      return _roleLabels[role] ?? 'Équipe pHARe';
    }
    return 'Équipe pHARe';
  }

  String get _staffInitials {
    final label = _staffLabel;
    final parts = label.split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return label.substring(0, label.length.clamp(0, 2)).toUpperCase();
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
          child: Column(
            children: [
              _buildHeader(),
              // Bannière confiance
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.grannySmith.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.eucalyptus.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline, size: 15, color: AppColors.eucalyptus),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Tu parles avec un adulte de confiance de ton établissement.",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.racingGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Corps : messages
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.eucalyptus))
                    : _buildMessages(),
              ),

              // Zone de saisie
              SafeArea(
                top: false,
                child: _buildInput(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.racingGreen),
          ),
          // Avatar initiales
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.eucalyptus,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _staffInitials,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _staffLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.racingGreen,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.eucalyptus,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Text(
                      'en ligne',
                      style: TextStyle(fontSize: 11, color: AppColors.corduroy),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, size: 18, color: AppColors.corduroy),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    final followUps = _followUps;
    final description = _report?['description'] as String? ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        // Message initial (contenu du signalement élève)
        if (description.isNotEmpty) ...[
          _SystemMessage(text: "Ton signalement a été transmis à l'équipe."),
          const SizedBox(height: 8),
          _ChatBubble(
            text: description,
            isStudent: true,
            time: _report != null ? _formatTime(_report!['createdAt'] as String) : '',
          ),
          const SizedBox(height: 16),
        ],

        // Follow-ups staff
        if (followUps.isEmpty && description.isEmpty)
          const _SystemMessage(text: "En attente d'une réponse de l'équipe…"),

        for (final fu in followUps) ...[
          _ChatBubble(
            text: fu['notes'] as String,
            isStudent: false,
            time: _formatTime(fu['createdAt'] as String),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.fieldBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.fieldBorder),
              ),
              child: TextField(
                controller: _inputController,
                maxLines: 1,
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                decoration: const InputDecoration(
                  hintText: 'Écris un message…',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (_inputController.text.trim().isEmpty) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fonctionnalité de réponse bientôt disponible.")),
              );
              _inputController.clear();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.eucalyptus,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isStudent;
  final String time;

  const _ChatBubble({
    required this.text,
    required this.isStudent,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isStudent ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Column(
          crossAxisAlignment: isStudent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isStudent ? AppColors.eucalyptus : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isStudent ? 18 : 4),
                  bottomRight: Radius.circular(isStudent ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: isStudent ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
            if (time.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                child: Text(
                  time,
                  style: const TextStyle(fontSize: 10, color: AppColors.edward),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SystemMessage extends StatelessWidget {
  final String text;
  const _SystemMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.corduroy),
        ),
      ),
    );
  }
}
