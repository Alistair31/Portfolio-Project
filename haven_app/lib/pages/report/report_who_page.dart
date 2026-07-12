import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/green_cta_button.dart';
import '../../widgets/selectable_option_card.dart';
import '../../widgets/step_header.dart';
import 'report_category_page.dart';

/// Écran 6 · Signaler — « Niveau d'anonymat » (étape 1 / 3).
/// L'utilisateur·rice choisit ce qu'il/elle accepte de partager avec l'équipe.
class ReportWhoPage extends StatefulWidget {
  final String mode; // 'VICTIM' | 'WITNESS'

  const ReportWhoPage({super.key, required this.mode});

  @override
  State<ReportWhoPage> createState() => _ReportWhoPageState();
}

class _ReportWhoPageState extends State<ReportWhoPage> {
  int _selected = 0;

  // Les 3 niveaux exposés dans la maquette, mappés sur les valeurs backend.
  static const _options = [
    _AnonOption(
      icon: Icons.visibility_off_outlined,
      title: 'Anonyme',
      subtitle: "Personne ne saura qui tu es. Tu suis la suite avec un code.",
      value: 'FULLY_ANONYMOUS',
    ),
    _AnonOption(
      icon: Icons.groups_outlined,
      title: 'Ma classe seulement',
      subtitle: "L'équipe voit ta classe pour agir, mais pas ton nom.",
      value: 'NAME_HIDDEN',
    ),
    _AnonOption(
      icon: Icons.person_outline,
      title: 'Identifié·e',
      subtitle: "Tu te présentes à l'adulte référent de confiance.",
      value: 'NONE',
    ),
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
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 6, 26, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 8),
                  child: StepHeader(
                    title: 'Tu choisis ce que tu partages.',
                    step: 'ÉTAPE 1 / 3',
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 2, bottom: 22),
                  child: Text(
                    "Et tu peux changer d'avis à tout moment, sans rien justifier.",
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 21 / 14.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.corduroy,
                    ),
                  ),
                ),
                for (int i = 0; i < _options.length; i++) ...[
                  SelectableOptionCard(
                    icon: _options[i].icon,
                    title: _options[i].title,
                    subtitle: _options[i].subtitle,
                    selected: _selected == i,
                    onTap: () => setState(() => _selected = i),
                  ),
                  if (i < _options.length - 1) const SizedBox(height: 14),
                ],
                const Spacer(),
                GreenCtaButton(
                  label: 'Continuer',
                  trailingIcon: Icons.arrow_forward,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReportCategoryPage(
                        mode: widget.mode,
                        anonymityLevel: _options[_selected].value,
                      ),
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

class _AnonOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;

  const _AnonOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });
}
