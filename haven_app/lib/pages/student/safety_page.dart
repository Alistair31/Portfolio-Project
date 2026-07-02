import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Écran 8 · Filet de sécurité — détection de crise.
/// Affiché quand l'élève signale être en danger immédiat.
class SafetyPage extends StatelessWidget {
  const SafetyPage({super.key});

  static const _lines = [
    _HelpLine(number: '3114', label: 'Souffrance &\nprévention du suicide'),
    _HelpLine(number: '119',  label: 'Enfance en danger'),
    _HelpLine(number: '3018', label: 'Violences numériques\n& cyberharcèlement'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.grannySmith, AppColors.backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icône coeur
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColors.eucalyptus,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_outline, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tu comptes.\nVraiment.',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: -0.8,
                    color: AppColors.racingGreen,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Ce que tu ressens est important. Tu n'as pas à rester seul·e avec ça — quelqu'un peut t'écouter, tout de suite.",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.outerSpace,
                  ),
                ),
                const SizedBox(height: 28),

                // Numéros d'urgence
                for (final line in _lines) ...[
                  _PhoneLine(line: line),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 20),

                // Info équipe établissement
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_outlined, size: 18, color: AppColors.eucalyptus),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "L'équipe de ton établissement est prévenue. En cas de danger vital, ton anonymat peut être levé — uniquement pour te protéger.",
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.outerSpace,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Bouton retour
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text(
                    'Rester avec Haven',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.racingGreen,
                    ),
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
// Ligne d'appel d'urgence
// ---------------------------------------------------------------------------

class _PhoneLine extends StatelessWidget {
  final _HelpLine line;
  const _PhoneLine({required this.line});

  void _call(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Appeler le ${line.number}'),
        content: Text('${line.label.replaceAll('\n', ' ')}\nGratuit · anonyme · 24h/24'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.eucalyptus),
            child: const Text('Appeler'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.iconTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_outlined, size: 18, color: AppColors.racingGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.number,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.racingGreen,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  line.label,
                  style: const TextStyle(fontSize: 12, color: AppColors.corduroy, height: 1.3),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _call(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.grannySmith,
              foregroundColor: AppColors.racingGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            child: const Text('Appeler'),
          ),
        ],
      ),
    );
  }
}

class _HelpLine {
  final String number;
  final String label;
  const _HelpLine({required this.number, required this.label});
}
