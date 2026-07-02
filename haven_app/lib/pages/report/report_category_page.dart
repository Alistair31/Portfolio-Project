import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/green_cta_button.dart';
import '../../widgets/step_header.dart';
import 'report_page.dart';

/// Écran 5 · Signaler — « De quoi s'agit-il ? » (étape 2 / 3).
/// Grille de 8 catégories visuelles mappées sur les 5 types backend.
class ReportCategoryPage extends StatefulWidget {
  final String mode;           // 'VICTIM' | 'WITNESS'
  final String anonymityLevel; // valeur backend choisie à l'étape 1

  const ReportCategoryPage({
    super.key,
    required this.mode,
    required this.anonymityLevel,
  });

  @override
  State<ReportCategoryPage> createState() => _ReportCategoryPageState();
}

class _ReportCategoryPageState extends State<ReportCategoryPage> {
  int? _selected;

  static const _categories = [
    _Category(label: 'Moqueries,\ninsultes',   icon: Icons.chat_bubble_outline,    type: 'VERBAL'),
    _Category(label: 'Mise à l\'écart',         icon: Icons.person_remove_outlined,  type: 'OTHER'),
    _Category(label: 'Violence\nphysique',      icon: Icons.warning_amber_outlined,  type: 'PHYSICAL'),
    _Category(label: 'Cyberharcèlement',        icon: Icons.phone_android_outlined,  type: 'CYBER'),
    _Category(label: 'Racket',                  icon: Icons.vpn_key_outlined,        type: 'OTHER'),
    _Category(label: 'Rumeurs',                 icon: Icons.campaign_outlined,       type: 'VERBAL'),
    _Category(label: 'Discrimination',          icon: Icons.shield_outlined,         type: 'OTHER'),
    _Category(label: 'Autre',                   icon: Icons.add_circle_outline,      type: 'OTHER'),
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
                    title: 'De quoi s\'agit-il ?',
                    step: 'ÉTAPE 2 / 3',
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 2, bottom: 20),
                  child: Text(
                    'Choisis ce qui s\'en rapproche le plus. Pas sûr·e ? On en parlera ensemble.',
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 21 / 14.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.corduroy,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, i) => _CategoryTile(
                      category: _categories[i],
                      selected: _selected == i,
                      onTap: () => setState(() => _selected = i),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GreenCtaButton(
                  label: 'Continuer',
                  trailingIcon: Icons.arrow_forward,
                  onPressed: _selected == null
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReportPage(
                                mode: widget.mode,
                                initialType: _categories[_selected!].type,
                                initialAnonymity: widget.anonymityLevel,
                                categoryLabel: _categories[_selected!].label.replaceAll('\n', ' '),
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

// ---------------------------------------------------------------------------
// Tuile de catégorie
// ---------------------------------------------------------------------------

class _CategoryTile extends StatelessWidget {
  final _Category category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.grannySmith : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.eucalyptus : AppColors.hairline,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            selected
                ? BoxShadow(
                    color: AppColors.eucalyptus.withValues(alpha: 0.35),
                    blurRadius: 20,
                    spreadRadius: -10,
                    offset: const Offset(0, 8),
                  )
                : const BoxShadow(
                    color: Color(0x0814201B),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.45)
                    : AppColors.iconTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category.icon,
                size: 22,
                color: AppColors.racingGreen,
              ),
            ),
            Text(
              category.label,
              maxLines: 2,
              style: TextStyle(
                fontSize: 13.5,
                height: 18 / 13.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: AppColors.racingGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Données
// ---------------------------------------------------------------------------

class _Category {
  final String label;
  final IconData icon;
  final String type; // valeur backend : PHYSICAL | VERBAL | SEXUAL | CYBER | OTHER

  const _Category({
    required this.label,
    required this.icon,
    required this.type,
  });
}
