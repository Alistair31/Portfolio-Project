import 'package:flutter/material.dart';
import 'package:haven_app/pages/admin/admin_page.dart';
import 'package:haven_app/pages/parent/parent_home_page.dart';
import 'package:haven_app/pages/parent_portal_page.dart';
import 'package:haven_app/pages/staff/staff_home_page.dart';
import 'package:haven_app/pages/student/student_home_page.dart';
import 'package:haven_app/services/preferences.dart';
import '../../services/session_service.dart';
import '../../pages/onboarding/onboarding_page.dart';
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

      if (!mounted) return;
      SessionService().setToken(response.token);
      SessionService().setRefreshToken(response.refreshToken);
      SessionService().setUser(role: response.user.role, name: response.user.name);
      if (_checkbox) {
        await PreferencesService().saveToken(response.token);
        await PreferencesService().saveRefreshToken(response.refreshToken);
        await PreferencesService().saveRole(response.user.role);
        await PreferencesService().saveName(response.user.name);
      }
      if (!mounted) return;
      final onboardWait = await PreferencesService().hasSeenOnboarding();

      if (!mounted) return;
      if (!onboardWait) {
        Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingFlow()));
        } else {
        switch (response.user.role) {

          case 'STUDENT':
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const StudentHomePage()),
            );
          case 'TEACHER':
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const StaffHomePage()),
            );
          case 'DIRECTOR_CPE':
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const StaffHomePage()),
            );
          case 'RECTORAT':
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const StaffHomePage()),
            );
          case 'PARENT':
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ParentHomePage()),
            );
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Rôle inconnu')),
            );
        }
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
                            hintText: 'Ex : test@haven.fr',
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
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
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ParentPortalPage()),
                              ),
                              child: const Text(
                                'Portail parents (code de suivi)',
                                style: TextStyle(fontSize: 11, color: AppColors.corduroy),
                              ),
                            ),
                          ),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AdminPage()),
                              ),
                              child: const Text('Admin',
                                style: TextStyle(fontSize: 11, color: AppColors.edward)),
                            ),
                          ),
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
