import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/haven_bottom_bar.dart';
import '../student/safety_page.dart';

/// Écran 12b · Ressources & droits — liens informatifs + numéros d'urgence.
class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  static const _tiles = [
    _Tile(icon: Icons.menu_book_outlined,   title: 'Comprendre le harcèlement', sub: 'Le reconnaître, le nommer'),
    _Tile(icon: Icons.balance_outlined,     title: 'Que dit la loi ?',           sub: 'Tes droits, simplement expliqués'),
    _Tile(icon: Icons.shield_outlined,      title: 'Le programme pHARe',         sub: 'Comment ton école agit'),
    _Tile(icon: Icons.favorite_outline,     title: 'Aider un·e ami·e',           sub: 'Quoi faire, quoi dire'),
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
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tu n\'es pas seul·e,\net tu as des droits.',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          letterSpacing: -0.6,
                          color: AppColors.racingGreen,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Numéros d'urgence
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SafetyPage()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.racingGreen,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.phone_outlined, color: AppColors.grannySmith, size: 20),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '3018 · 119 · 3114',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    Text(
                                      'Aide gratuite, 24h/24',
                                      style: TextStyle(fontSize: 12, color: AppColors.grannySmith),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.grannySmith,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Appeler',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.racingGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                sliver: SliverList.separated(
                  itemCount: _tiles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ResourceTile(tile: _tiles[i]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HavenBottomBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) Navigator.of(context).maybePop();
        },
        onCenterTap: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ResourceTile extends StatelessWidget {
  final _Tile tile;
  const _ResourceTile({required this.tile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tile.title} — bientôt disponible')),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.iconTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tile.icon, size: 20, color: AppColors.racingGreen),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tile.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.racingGreen,
                    ),
                  ),
                  Text(
                    tile.sub,
                    style: const TextStyle(fontSize: 12, color: AppColors.corduroy),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.edward),
          ],
        ),
      ),
    );
  }
}

class _Tile {
  final IconData icon;
  final String title;
  final String sub;
  const _Tile({required this.icon, required this.title, required this.sub});
}
