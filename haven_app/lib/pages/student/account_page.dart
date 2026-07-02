import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/preferences.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../authentification/login_page.dart';

/// Écran « Mon compte » — placeholder avec déconnexion et suppression.
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _loading = false;

  Future<void> _logout() async {
    SessionService().clearToken();
    await PreferencesService().removeToken();
    await PreferencesService().removeRefreshToken();
    await PreferencesService().removeRole();
    await PreferencesService().removeName();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Demander la suppression'),
        content: const Text(
          'Ta demande sera transmise à un administrateur.\n'
          'Ton compte sera supprimé après validation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.delButton),
            child: const Text('Envoyer la demande'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final token = SessionService().getToken();
    if (token == null) { _logout(); return; }

    setState(() => _loading = true);
    try {
      await ApiService().requestAccountDeletion(token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande envoyée. Un administrateur traitera ta demande.'),
          duration: Duration(seconds: 4),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back, color: AppColors.racingGreen),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Mon compte',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.racingGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Avatar placeholder
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.iconTint,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 36,
                      color: AppColors.racingGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Élève Haven',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.racingGreen,
                    ),
                  ),
                ),
                const Spacer(),

                // Bouton Déconnexion
                FilledButton.icon(
                  onPressed: _loading ? null : _logout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Se déconnecter'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.racingGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Bouton Supprimer le compte
                OutlinedButton.icon(
                  onPressed: _loading ? null : _deleteAccount,
                  icon: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.delButton,
                          ),
                        )
                      : const Icon(Icons.delete_outline, size: 18),
                  label: Text(_loading ? 'Envoi…' : 'Demander la suppression du compte'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.delButton,
                    side: const BorderSide(color: AppColors.delButton),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
