import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';
import 'report_category_page.dart';

class ReportWhoPage extends StatefulWidget {
  const ReportWhoPage({super.key});

  @override
  State<ReportWhoPage> createState() => _ReportWhoPageState();
}

class _ReportWhoPageState extends State<ReportWhoPage> {
  int? _selected;

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
              'Tu signales pour…',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            Text(
              'ÉTAPE 1 / 3',
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
                'Il n\'y a pas de mauvaise réponse. On avance ensemble, doucement.',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 24),
              _SelectionCard(
                icon: Icons.person_outline,
                title: 'Je vis une situation',
                subtitle: 'Quelque chose m\'arrive, à moi.',
                selected: _selected == 0,
                onTap: () => setState(() => _selected = 0),
              ),
              const SizedBox(height: 12),
              _SelectionCard(
                icon: Icons.group_outlined,
                title: 'Je m\'inquiète pour quelqu\'un',
                subtitle: 'J\'ai vu, ou je connais une personne concernée.',
                selected: _selected == 1,
                onTap: () => setState(() => _selected = 1),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Continuer',
                trailingIcon: Icons.arrow_forward,
                onPressed: _selected != null
                    ? () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ReportCategoryPage()),
                        )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: selected ? AppColors.brand : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.brand : AppColors.fieldBorder,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.25)
                        : const Color(0xFFF0F9F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: selected ? Colors.white : AppColors.textGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: selected ? Colors.white.withValues(alpha: 0.8) : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 28),
              ],
            ),
          ),
          if (selected)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.textGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
    );
  }
}
