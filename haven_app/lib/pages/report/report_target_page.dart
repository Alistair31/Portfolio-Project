import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/green_cta_button.dart';
import '../../widgets/selectable_option_card.dart';
import '../../widgets/step_header.dart';

/// Écran 4 · Signaler — « Tu signales pour... » (étape 1 / 3).
/// L'utilisateur·rice indique si la situation le/la concerne directement
/// (victime) ou s'il/elle s'inquiète pour quelqu'un (témoin).
class ReportTargetPage extends StatefulWidget {
  const ReportTargetPage({super.key});

  @override
  State<ReportTargetPage> createState() => _ReportTargetPageState();
}

class _ReportTargetPageState extends State<ReportTargetPage> {
  int _selected = 0;

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
                  padding: const EdgeInsets.only(top: 6, bottom: 16),
                  child: StepHeader(
                    title: 'Tu signales pour...',
                    step: 'ÉTAPE 1 / 3',
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 2, bottom: 22),
                  child: Text(
                    "Il n'y a pas de mauvaise réponse. On avance ensemble, doucement.",
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 21 / 14.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.corduroy,
                    ),
                  ),
                ),
                SelectableOptionCard(
                  icon: Icons.person_outline,
                  title: 'Je vis une situation',
                  subtitle: "Quelque chose m'arrive, à moi.",
                  selected: _selected == 0,
                  onTap: () => setState(() => _selected = 0),
                ),
                const SizedBox(height: 14),
                SelectableOptionCard(
                  icon: Icons.people_alt_outlined,
                  title: "Je m'inquiète pour quelqu'un",
                  subtitle: "J'ai vu, ou je connais une personne concernée.",
                  selected: _selected == 1,
                  onTap: () => setState(() => _selected = 1),
                ),
                const Spacer(),
                GreenCtaButton(
                  label: 'Continuer',
                  trailingIcon: Icons.arrow_forward,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
