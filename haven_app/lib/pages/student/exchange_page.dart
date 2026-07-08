import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';

// Intervalle de rafraîchissement silencieux du fil de conversation. Pas de
// WebSocket/SSE côté backend : un polling léger est le moyen le plus simple
// de voir arriver les messages du staff sans devoir en envoyer un soi-même.
const _pollInterval = Duration(seconds: 4);

/// Écran 11 · Échanger — messagerie élève ↔ équipe pHARe.
/// Conversation bidirectionnelle : le contenu du signalement, les follow-ups de
/// statut du staff et les messages libres (élève et staff) sont fusionnés dans
/// un fil chronologique. L'élève peut répondre via POST /reports/mine/[id]/messages.
class ExchangePage extends StatefulWidget {
  final String reportId;

  const ExchangePage({super.key, required this.reportId});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  Map<String, dynamic>? _report;
  bool _loading = true;
  bool _sending = false;
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _pollTimer;

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
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = SessionService().getToken();
    if (token == null) { setState(() => _loading = false); return; }
    try {
      final report = await ApiService().getReportDetail(token: token, id: widget.reportId);
      if (mounted) {
        setState(() { _report = report; _loading = false; });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Rafraîchit silencieusement le fil en arrière-plan (le staff peut répondre
  // à tout moment) : pas de spinner, pas d'interruption de la saisie en cours.
  // Ne fait défiler vers le bas que si de nouveaux messages sont vraiment arrivés.
  Future<void> _poll() async {
    if (_sending) return;
    final token = SessionService().getToken();
    if (token == null) return;
    final previousCount = _conversation.length;
    try {
      final report = await ApiService().getReportDetail(token: token, id: widget.reportId);
      if (!mounted) return;
      setState(() => _report = report);
      if (_conversation.length > previousCount) _scrollToBottom();
    } catch (_) {
      // Échec silencieux : nouvelle tentative au prochain tick.
    }
  }

  // Fait défiler le fil jusqu'au dernier message après un (re)chargement.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;

    final token = SessionService().getToken();
    if (token == null) return;

    setState(() => _sending = true);
    try {
      await ApiService().sendReportMessage(token: token, id: widget.reportId, body: text);
      _inputController.clear();
      await _load(); // rafraîchit le fil avec le message envoyé
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
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

  // Fusionne follow-ups de statut + messages libres en un fil trié chronologiquement.
  List<Map<String, dynamic>> get _conversation {
    final entries = <Map<String, dynamic>>[];
    for (final fu in _followUps) {
      entries.add({
        'time':      DateTime.parse(fu['createdAt'] as String),
        'isStudent': false,
        'text':      fu['notes'] as String,
      });
    }
    final messages = (_report?['messages'] as List<dynamic>?) ?? [];
    for (final m in messages.cast<Map<String, dynamic>>()) {
      entries.add({
        'time':      DateTime.parse(m['createdAt'] as String),
        'isStudent': m['senderRole'] == 'STUDENT',
        'text':      m['body'] as String,
      });
    }
    entries.sort((a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));
    return entries;
  }

  Widget _buildMessages() {
    final conversation = _conversation;
    final description = _report?['description'] as String? ?? '';

    return ListView(
      controller: _scrollController,
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

        if (conversation.isEmpty && description.isEmpty)
          const _SystemMessage(text: "En attente d'une réponse de l'équipe…"),

        for (final e in conversation) ...[
          _ChatBubble(
            text: e['text'] as String,
            isStudent: e['isStudent'] as bool,
            time: _formatTime((e['time'] as DateTime).toIso8601String()),
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
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
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
            onTap: _sending ? null : _send,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.eucalyptus,
                shape: BoxShape.circle,
              ),
              child: _sending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
