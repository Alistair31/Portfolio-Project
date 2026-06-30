import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/primary_button.dart';
import '../legal/privacy_policy_page.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _privacyConsentCheckbox = false;
  bool _isLoadingSchools = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  List<School> _schools = [];
  String? _selectedSchoolCode;
  String? _selectedGrade;

  static const Map<String, List<String>> _gradesByType = {
    'COLLEGE':  ['6e', '5e', '4e', '3e', '3e SEGPA'],
    'LYCEE':    ['2nde', '2nde STI2D', '1ère G', '1ère STI2D', 'T° G', 'T° STI2D'],
    'BTS_CPGE': ['CAP', 'BAC Pro', 'BTS', 'CPGE'],
    'MIXED':    ['6e', '5e', '4e', '3e', '3e SEGPA', '2nde', '2nde STI2D', '1ère G', '1ère STI2D', 'T° G', 'T° STI2D', 'CAP', 'BAC Pro', 'BTS', 'CPGE'],
  };

  List<String> get _grades {
    final school = _schools.where((s) => s.code == _selectedSchoolCode).firstOrNull;
    if (school == null) return [];
    return _gradesByType[school.type] ?? [];
  }
  final TextEditingController _classSectionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    try {
      final schools = await ApiService().getSchools();
      if (!mounted) return;
      setState(() {
        _schools = schools;
        _isLoadingSchools = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingSchools = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _classSectionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  void _handleRegister() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text;
    final classSection = _classSectionController.text.trim();
    final className = _selectedGrade != null
        ? '${_selectedGrade!} $classSection'.trim()
        : classSection;
    final schoolCode = _selectedSchoolCode ?? '';

    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Prénom requis")));
      return;
    }

    if (email.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email requis")));
      return;
    } else {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Format d'email invalide (ex : prenom@lycee.fr)")));
        return;
      }
    }

    if (_selectedSchoolCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Établissement requis")));
      return;
    }

    if (_selectedGrade == null || classSection.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Classe requise (niveau et lettre)")));
      return;
    }
    
    if (password.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mot de passe requis")));
      return;
    }

    if (_privacyConsentCheckbox) {
      try {
        final navigator = Navigator.of(context);
        final response = await ApiService().register(email, password, name, className, schoolCode);

        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Demande envoyée'),
            content: Text(response),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        if (mounted) navigator.pop();
      }
      catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
        }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Consentement aux regles d'utilisation requise")));
    }
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          label: 'Prénom',
                          icon: Icons.person_outline,
                          hintText: "Comme tu veux qu'on t'appelle",
                          controller: _nameController,
                        ),
                        const SizedBox(height: 20),
                        AuthTextField(
                          label: 'Email',
                          icon: Icons.mail_outline,
                          hintText: 'Ex : contact@havenlabs.fr',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                        ),
                        const SizedBox(height: 20),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Établissement',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.label,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.fieldBackground,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: AppColors.fieldBorder),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.03),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        alignment: Alignment.center,
                                        child: DropdownButtonFormField<String>(
                                                dropdownColor: Colors.white,
                                                isExpanded: true,
                                                isDense: true,
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                                hint: const Text('Établissement', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                                                style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                                                initialValue: _selectedSchoolCode,
                                                items: _schools.map((school) => DropdownMenuItem(
                                                  value: school.code,
                                                  child: Text(school.name, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                                                )).toList(),
                                                onChanged: _isLoadingSchools ? null : (value) => setState(() {
                                                  _selectedSchoolCode = value;
                                                  _selectedGrade = null;
                                                }),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Classe',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.label,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.fieldBackground,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: AppColors.fieldBorder),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.03),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: DropdownButtonFormField<String>(
                                                dropdownColor: Colors.white,
                                                isDense: false,
                                                isExpanded: true,
                                                decoration: const InputDecoration.collapsed(hintText: ''),
                                                hint: const Text('Niveau', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                                                style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                                                initialValue: _selectedGrade,
                                                items: _grades.map((grade) => DropdownMenuItem(
                                                  value: grade,
                                                  child: Text(grade, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                                                )).toList(),
                                                onChanged: (value) => setState(() => _selectedGrade = value),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Container(width: 1, color: AppColors.fieldBorder),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              flex: 1,
                                              child: TextField(
                                                controller: _classSectionController,
                                                decoration: const InputDecoration.collapsed(hintText: 'A…'),
                                                style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        AuthTextField(
                          label: 'Mot de passe',
                          icon: Icons.lock_outline,
                          hintText: '8 caractères minimum',
                          obscureText: _obscurePassword,
                          controller: _passwordController,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.iconMuted,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          )
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _privacyConsentCheckbox,
                              onChanged: (value) {
                                setState(() {
                                  _privacyConsentCheckbox = value ?? false;
                                });
                              },
                              activeColor: AppColors.buttonGreen,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PrivacyPolicyPage(),
                                ),
                              ),
                              child: const Text.rich(
                                TextSpan(
                                  text: "J'accepte la ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textMuted,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'politique de confidentialité',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildPrivacyNotice(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Créer mon accès',
                  trailingIcon: Icons.arrow_forward,
                  onPressed: _handleRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
            icon: const Icon(
              Icons.arrow_back,
              size: 20,
              color: AppColors.textDark,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Crée ton accès',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Ça prend 30 secondes',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrivacyNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.infoBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.visibility_off_outlined,
            size: 22,
            color: AppColors.infoText,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: "Ton prénom n'est ",
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.infoText,
                ),
                children: const [
                  TextSpan(
                    text: 'jamais',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text:
                        " montré sans ton accord. Tu choisis ton niveau d'anonymat à chaque signalement.",
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
