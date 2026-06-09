import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/primary_button.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;

  @override
  void dispose() {
    super.dispose();
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
                        ),
                        const SizedBox(height: 20),
                        AuthTextField(
                          label: 'Email',
                          icon: Icons.mail_outline,
                          hintText: 'Ex : contact@havenlabs.fr'
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: AuthTextField(
                                label: 'Code établissement',
                                icon: Icons.shield_outlined,
                                hintText: 'Ex : LSJ-31',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: AuthTextField(
                                label: 'Classe',
                                hintText: 'Ex : 4e B',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AuthTextField(
                          label: 'Mot de passe',
                          icon: Icons.lock_outline,
                          hintText: '8 caractères minimum',
                          obscureText: _obscurePassword,
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
                  onPressed: () {},
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
