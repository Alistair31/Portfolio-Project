import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class ReportCategoryPage extends StatefulWidget {
  const ReportCategoryPage({super.key});

  @override
  State<ReportCategoryPage> createState() => _ReportCategoryPageState();
}

class _ReportCategoryPageState extends State<ReportCategoryPage> {
  int? _selected;

  static const _categories = [
    _Category(icon: Icons.chat_bubble_outline, label: 'Moqueries,\ninsultes'),
    _Category(icon: Icons.group_outlined, label: 'Mise à l\'écart'),
    _Category(icon: Icons.warning_amber_outlined, label: 'Violence\nphysique'),
    _Category(icon: Icons.flag_outlined, label: 'Cyberharcèlem\nent'),
    _Category(icon: Icons.vpn_key_outlined, label: 'Racket'),
    _Category(icon: Icons.more_horiz, label: 'Rumeurs'),
    _Category(icon: Icons.shield_outlined, label: 'Discrimination'),
    _Category(icon: Icons.add, label: 'Autre'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: AppColors.textDark, onPressed: () => Navigator.of(context).pop()),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'De quoi s\'agit-il ?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            Text(
              'ÉTAPE 2 / 3',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.8),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choisis ce qui s\'en rapproche le plus. Pas sûr·e ? On en parlera ensemble.',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, i) => _CategoryChip(
                    category: _categories[i],
                    selected: _selected == i,
                    onTap: () => setState(() => _selected = i),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Continuer',
                trailingIcon: Icons.arrow_forward,
                onPressed: _selected != null ? () {} : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Category {
  final IconData icon;
  final String label;
  const _Category({required this.icon, required this.label});
}

class _CategoryChip extends StatelessWidget {
  final _Category category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.category, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.brand : AppColors.fieldBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : const Color(0xFFF0F9F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                category.icon,
                color: selected ? Colors.white : AppColors.textGreen,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textDark,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
