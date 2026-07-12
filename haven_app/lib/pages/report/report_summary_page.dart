import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/preferences.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/green_cta_button.dart';
import '../../widgets/step_header.dart';
import '../student/safety_page.dart';

/// Écran 9 · Signaler — « Avant d'envoyer » (récapitulatif, ÉTAPE 3 / 3).
/// Affiche le résumé des choix avant la soumission effective au backend.
class ReportSummaryPage extends StatefulWidget {
  final String mode;
  final String type;
  final String categoryLabel;
  final String anonymityLevel;
  final int gravity;
  final String description;
  final String targetLevel;

  const ReportSummaryPage({
    super.key,
    required this.mode,
    required this.type,
    required this.categoryLabel,
    required this.anonymityLevel,
    required this.gravity,
    required this.description,
    required this.targetLevel,
  });

  @override
  State<ReportSummaryPage> createState() => _ReportSummaryPageState();
}

class _ReportSummaryPageState extends State<ReportSummaryPage> {
  bool _isSubmitting = false;

  static const _anonymityLabels = {
    'FULLY_ANONYMOUS': 'Anonyme',
    'NAME_HIDDEN':     'Ma classe seulement',
    'NAME_AND_CLASS_HIDDEN': 'Prénom et classe masqués',
    'NONE':            'Identifié·e',
  };

  static const _targetLabels = {
    'TEACHER':      'Professeur principal',
    'DIRECTOR_CPE': 'Direction / CPE',
    'RECTORAT':     'Rectorat',
  };

  Future<void> _submit() async {
    final token = SessionService().getToken();
    if (token == null) {
      _snack('Session expirée, reconnecte-toi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await ApiService().submitReport(
        token: token,
        mode: widget.mode,
        type: widget.type,
        gravity: widget.gravity,
        description: widget.description,
        targetLevel: widget.targetLevel,
        anonymityLevel: widget.anonymityLevel,
      );

      await PreferencesService().saveIntegrityHash(result['id']!, result['integrityHash']!);
      await PreferencesService().saveReportSnapshot(result['id']!, {
        'type':           widget.type,
        'gravity':        widget.gravity,
        'mode':           widget.mode,
        'anonymityLevel': widget.anonymityLevel,
        'description':    widget.description,
      });

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Signalement envoyé'),
          content: Text(
            'Ton code de suivi : ${result['trackingCode'] ?? ''}\n\n'
            'Conserve-le pour retrouver ton signalement et le partager avec tes parents si tu le souhaites.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final anonymityLabel = _anonymityLabels[widget.anonymityLevel] ?? widget.anonymityLevel;
    final targetLabel    = _targetLabels[widget.targetLevel]       ?? widget.targetLevel;

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                child: StepHeader(
                  title: 'Avant d\'envoyer',
                  step: 'ÉTAPE 3 / 3',
                  onBack: () => Navigator.of(context).maybePop(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Résumé des choix
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.hairline),
                        ),
                        child: Column(
                          children: [
                            _SummaryRow(
                              label: 'Situation',
                              value: widget.categoryLabel,
                              onModify: () => Navigator.of(context).pop(),
                            ),
                            const Divider(height: 1, color: AppColors.hairline, indent: 16, endIndent: 16),
                            _SummaryRow(
                              label: 'Anonymat',
                              value: anonymityLabel,
                              onModify: () => Navigator.of(context).pop(),
                            ),
                            const Divider(height: 1, color: AppColors.hairline, indent: 16, endIndent: 16),
                            _SummaryRow(
                              label: 'Destinataire',
                              value: targetLabel,
                              onModify: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Citation de la description
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.fieldBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: const Border(
                            left: BorderSide(color: AppColors.eucalyptus, width: 3),
                          ),
                        ),
                        child: Text(
                          '"${widget.description}"',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.55,
                            fontStyle: FontStyle.italic,
                            color: AppColors.outerSpace,
                          ),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info code de suivi
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.grannySmith.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.eucalyptus.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 18, color: AppColors.eucalyptus),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Ton signalement arrive à l'équipe référente pHARe. Tu reçois un code de suivi — conserve-le pour retrouver l'évolution de ton dossier.",
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: AppColors.racingGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bouton danger
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SafetyPage()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE8505B).withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Color(0xFFE8505B), size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Je suis en danger maintenant',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFE8505B),
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Color(0xFFE8505B), size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // CTA Envoyer
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: GreenCtaButton(
                    label: _isSubmitting ? 'Envoi en cours…' : 'Envoyer à l\'équipe',
                    trailingIcon: _isSubmitting ? null : Icons.send_outlined,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onModify;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.onModify,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.corduroy,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.racingGreen,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onModify,
            child: const Text(
              'Modifier',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.eucalyptus,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
