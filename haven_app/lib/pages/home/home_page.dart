import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/haven_logo.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/delete_button.dart';
import '../../widgets/haven_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  static const _pages = [
    _AccueilTab(),
    _SuiviTab(),
    _CompteTab(),
  ];

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
        child: SafeArea(child: _pages[_currentIndex]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.buttonGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: HavenBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _AccueilTab extends StatelessWidget {
  const _AccueilTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HavenLogo(size: 96),
          SizedBox(height: 24),
          Text(
            'Bienvenue sur Haven',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Ton espace est prêt.',
            style: TextStyle(fontSize: 16, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SuiviTab extends StatelessWidget {
  const _SuiviTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Suivi — à venir', style: TextStyle(color: AppColors.textMuted)),
    );
  }
}

class _CompteTab extends StatelessWidget {
  const _CompteTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LogoutButton(),
          SizedBox(height: 16),
          DeleteAccountButton(),
        ],
      ),
    );
  }
}
