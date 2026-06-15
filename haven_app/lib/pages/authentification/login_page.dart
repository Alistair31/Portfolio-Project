import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/haven_logo.dart';
import '../../widgets/primary_button.dart';
import '../../services/api_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _checkbox = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final response = await ApiService().login(email, password);
      
      switch (response.user.role) {

        case 'STUDENT':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const Placeholder()),
          );
        case 'TEACHER':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const Placeholder()),
          );
        case 'DIRECTOR_CPE':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const Placeholder()),
          );
        case 'RECTORAT':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const Placeholder()),
          );
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Rôle inconnu')),
          );
      }
    }

    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // Ne scrolle que si le contenu dépasse vraiment (ex : clavier
                // ouvert ou très petit écran). Sinon tout tient à l'écran.
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(flex: 3),
                          const Center(child: HavenLogo(size: 88)),
                          const SizedBox(height: 22),
                          const Text(
                            'Content de te\nrevoir.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 34,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ton espace est privé. Toujours.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 28),
                          AuthTextField(
                            label: 'Email', controller: _emailController,
                            icon: Icons.mail_outline,
                            hintText: 'Ex : contact@havenlabs.fr',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 18),
                          AuthTextField(
                            label: 'Mot de passe', controller: _passwordController,
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            hintText: 'Ex: Haven@2026',
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
                            ),
                          ),
                          //Rester connecté 
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _checkbox,
                                onChanged: (value) {
                                  setState(() {
                                    _checkbox = value ?? false;
                                  });
                                },
                                activeColor: AppColors.buttonGreen,
                              ),
                              const Text(
                                'Rester connecté',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(flex: 4),
                          PrimaryButton(
                            label: 'Se connecter',
                            trailingIcon: Icons.arrow_forward,
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: 18),
                          _buildSignUpRow(),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpRow() {
    return Center(
      child: Text.rich(
        TextSpan(
          text: 'Première fois ? ',
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textMuted,
          ),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) =>  RegisterPage()),
                  );
                },
                child: const Text(
                  'Crée ton accès',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
