import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../services/api_service.dart';

class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({super.key});

  Future<void> _requestDeletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Demander la suppression'),
        content: const Text(
          'Ta demande sera transmise à un administrateur.\n'
          'Ton compte sera supprimé après validation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Envoyer la demande'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final token = SessionService().getToken();
    if (token == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expirée. Reconnecte-toi.')),
      );
      return;
    }

    try {
      await ApiService().requestAccountDeletion(token);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande envoyée. Un administrateur traitera ta demande.'),
          duration: Duration(seconds: 4),
        ),
      );
    } on Exception catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _requestDeletion(context),
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      label: const Text('Supprimer mon compte', style: TextStyle(color: Colors.red)),
    );
  }
}
