import 'package:flutter/material.dart';
import '../../data/chat_tree_data.dart';
import '../../models/chat_node.dart';
import '../../theme/app_colors.dart';
import '../report/report_page.dart';

// Représente une entrée dans l'historique du chat (bulle affichée)
class _ChatEntry {
  final String text;
  final bool isBot;         // true = bulle gauche (bot), false = bulle droite (élève)
  final bool isEmergency;   // true = carte rouge urgence
  final bool isResource;    // true = carte info ressources

  const _ChatEntry({
    required this.text,
    required this.isBot,
    this.isEmergency = false,
    this.isResource = false,
  });
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final _scrollController = ScrollController();

  // Historique des messages affichés dans le chat
  final List<_ChatEntry> _entries = [];

  // Nœud actuel dans l'arbre de décision
  String _currentNodeId = 'root';

  // true quand un nœud terminal a été atteint (plus d'options à afficher)
  bool _isTerminal = false;

  // true pendant la courte pause simulant la "frappe" du bot
  bool _isBotTyping = false;

  @override
  void initState() {
    super.initState();
    // Affiche le message d'accueil au lancement
    _addBotMessage(chatTree['root']!.message);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Logique de navigation dans l'arbre
  // -------------------------------------------------------------------------

  void _onOptionTapped(ChatOption option) async {
    if (_isBotTyping) return; // ignore les taps pendant que le bot "frappe"

    // 1. Affiche le choix de l'élève comme bulle droite
    _addUserMessage(option.label);

    // 2. Récupère le nœud suivant
    final nextNode = chatTree[option.nextNodeId];
    if (nextNode == null) return;

    _currentNodeId = nextNode.id;

    // 3. Pause courte pour simuler une réponse humaine
    setState(() => _isBotTyping = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isBotTyping = false);

    // 4. Affiche le message du nœud suivant
    _addBotMessage(nextNode.message);

    // 5. Si terminal : exécute l'action
    if (nextNode.isTerminal && nextNode.action != null) {
      setState(() => _isTerminal = true);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      _executeAction(nextNode.action!);
    }
  }

  void _executeAction(ChatAction action) {
    switch (action) {
      case OpenReportAction(:final reportType):
        // Navigue vers le formulaire avec le type pré-sélectionné
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReportPage(initialType: reportType),
          ),
        );

      case ShowEmergencyAction():
        // Affiche la carte d'urgence inline dans le chat
        setState(() {
          _entries.add(const _ChatEntry(
            text:
                '🚨 URGENCE\n\n'
                '15 — SAMU (urgence médicale)\n'
                '17 — Police / Gendarmerie\n'
                '3114 — Prévention suicide (24h/24)\n'
                '3020 — Harcèlement scolaire\n'
                '119 — Enfance en danger\n'
                '3018 — Cyberharcèlement',
            isBot: true,
            isEmergency: true,
          ));
        });
        _scrollToBottom();

      case ShowResourceAction(:final message):
        // Affiche la carte ressources inline dans le chat
        setState(() {
          _entries.add(_ChatEntry(
            text: message,
            isBot: true,
            isResource: true,
          ));
        });
        _scrollToBottom();
    }
  }

  // -------------------------------------------------------------------------
  // Helpers d'ajout de messages
  // -------------------------------------------------------------------------

  void _addBotMessage(String text) {
    setState(() {
      _entries.add(_ChatEntry(text: text, isBot: true));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _entries.add(_ChatEntry(text: text, isBot: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // Attend le prochain frame pour que la liste soit rendue avant de scroller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // -------------------------------------------------------------------------
  // Recommencer depuis le début
  // -------------------------------------------------------------------------

  void _restart() {
    setState(() {
      _entries.clear();
      _currentNodeId = 'root';
      _isTerminal = false;
      _isBotTyping = false;
    });
    _addBotMessage(chatTree['root']!.message);
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final currentNode = chatTree[_currentNodeId];

    return Scaffold(
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
              _buildHeader(),
              // Liste des messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _entries.length + (_isBotTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Indicateur de frappe affiché en dernier
                    if (index == _entries.length) {
                      return _TypingIndicator();
                    }
                    final entry = _entries[index];
                    if (entry.isEmergency) return _EmergencyCard(text: entry.text);
                    if (entry.isResource)  return _ResourceCard(text: entry.text);
                    return _MessageBubble(text: entry.text, isBot: entry.isBot);
                  },
                ),
              ),
              // Zone des choix (visible uniquement si nœud non terminal)
              if (!_isTerminal && !_isBotTyping && currentNode != null)
                _buildOptions(currentNode.options),
              // Bouton recommencer quand terminal
              if (_isTerminal)
                _buildRestartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.fieldBackground,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, size: 18, color: AppColors.textDark),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.buttonGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Haven Assistant',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              Text('Là pour t\'aider',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(List<ChatOption> options) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        border: Border(top: BorderSide(color: AppColors.fieldBorder)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          final isUrgent = option.label.contains('🚨');
          return GestureDetector(
            onTap: () => _onOptionTapped(option),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isUrgent ? Colors.red.shade300 : AppColors.fieldBorder,
                  width: isUrgent ? 1.5 : 1,
                ),
              ),
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 14,
                  color: isUrgent ? Colors.red.shade700 : AppColors.textDark,
                  fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRestartButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: TextButton.icon(
        onPressed: _restart,
        icon: const Icon(Icons.refresh, size: 16, color: AppColors.textMuted),
        label: const Text('Recommencer', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
      ),
    );
  }
}

// -------------------------------------------------------------------------
// Widgets de présentation
// -------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isBot;

  const _MessageBubble({required this.text, required this.isBot});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isBot ? AppColors.fieldBackground : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(16),
            topRight:    const Radius.circular(16),
            bottomLeft:  Radius.circular(isBot ? 4 : 16),
            bottomRight: Radius.circular(isBot ? 16 : 4),
          ),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.5)),
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final String text;

  const _EmergencyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade300, width: 1.5),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.red.shade800, height: 1.7, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final String text;

  const _ResourceCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.blue.shade900, height: 1.7),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.fieldBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4), bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        // Trois points animés simulant la frappe
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            SizedBox(width: 4),
            _Dot(delay: 200),
            SizedBox(width: 4),
            _Dot(delay: 400),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(widget.delay / 1000, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: AppColors.textMuted,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
