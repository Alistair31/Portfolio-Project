import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/green_cta_button.dart';
import 'report_summary_page.dart';

class ReportPage extends StatefulWidget {
  final String? initialType;
  final String? initialAnonymity;
  final String? categoryLabel;
  final String mode;

  const ReportPage({
    super.key,
    this.initialType,
    this.initialAnonymity,
    this.categoryLabel,
    this.mode = 'VICTIM',
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _descriptionController = TextEditingController();

  String? _selectedType;
  int _gravity = 3;
  String? _selectedTarget;
  String? _selectedAnonymity;
  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedAnonymity = widget.initialAnonymity;
  }

  static const _types = {
    'PHYSICAL': 'Violence physique',
    'VERBAL':   'Violence verbale',
    'SEXUAL':   'Violence sexuelle',
    'CYBER':    'Cyberharcèlement',
    'OTHER':    'Autre',
  };

  static const _targets = {
    'TEACHER':       'Professeur principal',
    'DIRECTOR_CPE':  'Direction / CPE',
    'RECTORAT':      'Rectorat',
  };

  static const _anonymityLevels = {
    'NONE':                   'Mon nom est visible',
    'NAME_HIDDEN':            'Prénom masqué',
    'NAME_AND_CLASS_HIDDEN':  'Prénom et classe masqués',
    'FULLY_ANONYMOUS':        'Totalement anonyme',
  };

  static const _gravityLabels = {
    1: 'Léger',
    2: 'Modéré',
    3: 'Sérieux',
    4: 'Grave',
    5: 'Très grave',
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _goToSummary() {
    if (_selectedType == null) {
      _snack('Choisis un type de situation'); return;
    }
    if (_selectedTarget == null) {
      _snack('Choisis à qui envoyer le signalement'); return;
    }
    if (_selectedAnonymity == null) {
      _snack('Choisis ton niveau d\'anonymat'); return;
    }
    if (_descriptionController.text.trim().length < 10) {
      _snack('Description trop courte (10 caractères minimum)'); return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportSummaryPage(
          mode: widget.mode,
          type: _selectedType!,
          categoryLabel: widget.categoryLabel ?? _types[_selectedType!] ?? _selectedType!,
          anonymityLevel: _selectedAnonymity!,
          gravity: _gravity,
          description: _descriptionController.text.trim(),
          targetLevel: _selectedTarget!,
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSection(
                        title: 'Type de situation',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _types.entries.map((e) {
                            final selected = _selectedType == e.key;
                            return ChoiceChip(
                              label: Text(e.value),
                              selected: selected,
                              onSelected: (_) => setState(() => _selectedType = e.key),
                              selectedColor: AppColors.buttonGreen,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: selected ? AppColors.buttonGreen : AppColors.fieldBorder,
                                width: selected ? 1.5 : 1,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : AppColors.textDark,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 13,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Niveau de gravité — ${_gravityLabels[_gravity]}',
                        child: Slider(
                          value: _gravity.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          activeColor: AppColors.buttonGreen,
                          inactiveColor: AppColors.fieldBorder,
                          onChanged: (v) => setState(() => _gravity = v.round()),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Description',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.fieldBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.fieldBorder),
                              ),
                              child: TextField(
                                controller: _descriptionController,
                                maxLines: 5,
                                maxLength: 1000,
                                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                                decoration: const InputDecoration(
                                  hintText: 'Décris la situation en quelques mots…',
                                  hintStyle: TextStyle(color: AppColors.textMuted),
                                  contentPadding: EdgeInsets.all(16),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline, size: 13, color: AppColors.textMuted),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    'Ne mentionne pas ton prénom ni d\'infos qui pourraient t\'identifier, même si tu choisis l\'anonymat.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Envoyer à',
                        child: _buildDropdown(
                          hint: 'Choisir un destinataire',
                          items: _targets,
                          value: _selectedTarget,
                          onChanged: (v) => setState(() => _selectedTarget = v),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Niveau d\'anonymat',
                        child: _buildDropdown(
                          hint: 'Choisir ton anonymat',
                          items: _anonymityLevels,
                          value: _selectedAnonymity,
                          onChanged: (v) => setState(() => _selectedAnonymity = v),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: GreenCtaButton(
                  label: 'Vérifier et envoyer',
                  trailingIcon: Icons.arrow_forward,
                  onPressed: _goToSummary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.fieldBackground,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, size: 20, color: AppColors.textDark),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Signaler une situation',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              Text(
                'Anonyme si tu le souhaites.',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.label),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildDropdown({
    required String hint,
    required Map<String, String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: Colors.white,
          hint: Text(hint, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
          value: value,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          items: items.entries.map((e) => DropdownMenuItem(
            value: e.key,
            child: Text(e.value),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
