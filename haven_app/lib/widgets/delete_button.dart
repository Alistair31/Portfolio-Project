import 'package:flutter/material.dart';
import '../services/preferences.dart';
import '../services/session_service.dart';
import '../services/api_service.dart';
import '../pages/authentification/login_page.dart';


class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({super.key,});

  Future<void> _deleteAccount(BuildContext context) async {
  final confirmed = await showDialog<bool>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: Text('ATTENTION'),
    content: Text('Etes vous sur de vouloir supprimer votre compte?\n'
             'Les données seront definitivement effacées sous les 30 jours\n'
             ' comme le prevois le Règlement Général sur la Protection des Données \n'),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(dialogContext).pop(false),
        child: Text('Annuler')),
      TextButton(
        onPressed: () => Navigator.of(dialogContext).pop(true),
        child: Text('Supprimer')),
    ],
  ),
);
if (confirmed != true) return;

final navigator = Navigator.of(context);
final token = SessionService().getToken();

if (token == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Session expirée. Reconnecte-toi pour supprimer ton compte.')),
  );
  return;
}

await ApiService().deleteAccount(token);
await PreferencesService().removeToken();

navigator.pushAndRemoveUntil(MaterialPageRoute(
  builder: (_) => const LoginPage()),
  (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _deleteAccount(context),
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      label: const Text('Supprimer mon compte', style: TextStyle(color: Colors.red)),
    );
  }
}
