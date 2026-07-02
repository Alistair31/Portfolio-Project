import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Écran 15 · Portail parents — accès par code de suivi.
/// Deux états : saisie du code → vue suivi (données simulées pour la démo).
class ParentPortalPage extends StatefulWidget {
  const ParentPortalPage({super.key});

  @override
  State<ParentPortalPage> createState() => _ParentPortalPageState();
}

class _ParentPortalPageState extends State<ParentPortalPage> {
  final _codeController = TextEditingController();
  bool _accessed = false;
  bool _loading = false;

  static const _steps = [
    _Step(label: 'Reçu',             sub: "Aujourd'hui · 8:42", done: true),
    _Step(label: 'Lu par l\'équipe', sub: "Aujourd'hui · 9:15", done: true),
    _Step(label: 'Enquête en cours', sub: 'Prochaine étape : RDV mardi 14:00', done: true, active: true),
    _Step(label: 'Résolution',       sub: '',                   done: false),
  ];

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _access() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saisis un code de suivi.')),
      );
      return;
    }
    setState(() => _loading = true);
    // Simulation d'une requête réseau — la page de suivi affiche des données mock.
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() { _loading = false; _accessed = true; });
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
          child: _accessed ? _buildTracking() : _buildEntry(),
        ),
      ),
    );
  }

  // ─── Saisie du code ───────────────────────────────────────────────────────

  Widget _buildEntry() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: AppColors.eucalyptus),
              const SizedBox(width: 6),
              const Text(
                'Haven · Portail parents',
                style: TextStyle(fontSize: 13, color: AppColors.corduroy, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 36),

          // Icône clé
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(color: AppColors.grannySmith, shape: BoxShape.circle),
            child: const Icon(Icons.key_outlined, color: AppColors.racingGreen, size: 26),
          ),
          const SizedBox(height: 28),

          const Text(
            'Suivez la situation\nde votre enfant.',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.2,
              letterSpacing: -0.6,
              color: AppColors.racingGreen,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Saisissez le code de suivi que votre enfant a choisi de vous transmettre.',
            style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.corduroy),
          ),
          const SizedBox(height: 28),

          const Text(
            'Code de suivi',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.corduroy),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.fieldBorder, width: 1.5),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(Icons.lock_outline, size: 18, color: AppColors.corduroy),
                ),
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.racingGreen,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'HVN-AB12-CD34',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bouton accéder
          ElevatedButton(
            onPressed: _loading ? null : _access,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.grannySmith,
              foregroundColor: AppColors.racingGreen,
              elevation: 0,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            child: _loading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.racingGreen),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Accéder au suivi'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
          ),
          const SizedBox(height: 16),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.hairline),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.visibility_off_outlined, size: 14, color: AppColors.corduroy),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Vous suivez l'avancement du traitement, sans accéder au contenu des échanges de votre enfant. Accès soumis à décharge en phase pilote.",
                    style: TextStyle(fontSize: 11, height: 1.5, color: AppColors.corduroy),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Vue suivi ────────────────────────────────────────────────────────────

  Widget _buildTracking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: AppColors.eucalyptus),
              const SizedBox(width: 6),
              const Text(
                'Haven · Portail parents',
                style: TextStyle(fontSize: 13, color: AppColors.corduroy, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suivi du signalement',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.racingGreen,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Carte statut
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
                      Row(
                        children: [
                          const Icon(Icons.flag_outlined, size: 16, color: AppColors.corduroy),
                          const SizedBox(width: 8),
                          const Text(
                            'Situation prise en charge',
                            style: TextStyle(fontSize: 13, color: AppColors.corduroy, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.grannySmith,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'en cours',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.racingGreen),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppColors.hairline),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Référent', style: TextStyle(fontSize: 11, color: AppColors.corduroy)),
                                Text('Mme Roussel · CPE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.racingGreen)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Dernière MAJ', style: TextStyle(fontSize: 11, color: AppColors.corduroy)),
                                Text("Auj. · 9:15", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.racingGreen)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Timeline
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < _steps.length; i++)
                        _TimelineRow(step: _steps[i], isLast: i == _steps.length - 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bouton contacter
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: OutlinedButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Contacter l'établissement"),
                content: const Text('Lycée Saint-Joseph — pHARe\nstandard@lycee-saintjoseph.fr'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Fermer')),
                ],
              ),
            ),
            icon: const Icon(Icons.phone_outlined, size: 18),
            label: const Text("Contacter l'établissement"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.racingGreen,
              side: const BorderSide(color: AppColors.hairlineStrong),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _TimelineRow extends StatelessWidget {
  final _Step step;
  final bool isLast;
  const _TimelineRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = step.done ? AppColors.eucalyptus : AppColors.hairlineStrong;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: step.active ? AppColors.eucalyptus : (step.done ? AppColors.eucalyptus : Colors.white),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: step.done
                      ? const Icon(Icons.check, size: 11, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: step.done ? AppColors.eucalyptus : AppColors.hairline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: step.done ? AppColors.racingGreen : AppColors.edward,
                    ),
                  ),
                  if (step.sub.isNotEmpty)
                    Text(
                      step.sub,
                      style: TextStyle(
                        fontSize: 12,
                        color: step.active ? AppColors.eucalyptus : AppColors.corduroy,
                      ),
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

class _Step {
  final String label;
  final String sub;
  final bool done;
  final bool active;
  const _Step({required this.label, required this.sub, required this.done, this.active = false});
}
