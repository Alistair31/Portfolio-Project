import 'package:flutter/material.dart';
import '../../services/preferences.dart';
import '../../theme/app_colors.dart';
import '../student/student_home_page.dart';
import 'onboarding_clair.dart';
import 'onboarding_lueur.dart';
import 'onboarding_refuge.dart';

/// Onboarding affiché une fois l'inscription réussie.
/// Enchaîne les 3 écrans (Refuge → Clair → Lueur) ; le bouton de chaque écran
/// passe au suivant, le dernier ouvre l'accueil. On peut aussi swiper.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  int _index = 0;

  static const _pageCount = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _pageCount - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await PreferencesService().setOnboardingSeen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const StudentHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            children: [
              OnboardingRefuge(onStart: _next, onHowItWorks: _next),
              OnboardingClair(onStart: _next),
              OnboardingLueur(onStart: _next),
            ],
          ),
          // Points de progression, superposés en haut au centre.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Center(
                  child: _Dots(count: _pageCount, index: _index),
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

/// Indicateur de progression : le point actif s'allonge en pilule.
class _Dots extends StatelessWidget {
  final int count;
  final int index;

  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? AppColors.textDark
                : AppColors.textDark.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
