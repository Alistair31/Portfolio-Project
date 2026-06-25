// Modèle de données pour l'arbre de décision du chatbot.
// Aucune dépendance externe — tout est Dart pur.

// Action exécutée quand un nœud terminal est atteint.
// Sealed class = liste exhaustive de cas possibles, vérifiée à la compilation.
sealed class ChatAction {
  const ChatAction();
}

// Ouvre le formulaire de signalement avec un type pré-sélectionné
class OpenReportAction extends ChatAction {
  final String reportType; // 'PHYSICAL', 'VERBAL', 'CYBER', 'SEXUAL', 'OTHER'
  const OpenReportAction(this.reportType);
}

// Affiche la carte d'urgence avec les numéros (3114, 3020, 119...)
class ShowEmergencyAction extends ChatAction {
  const ShowEmergencyAction();
}

// Affiche une ressource textuelle (conseil, numéro unique, lien...)
class ShowResourceAction extends ChatAction {
  final String message;
  const ShowResourceAction(this.message);
}

// Un choix proposé à l'élève (bouton cliquable)
class ChatOption {
  final String label;       // texte affiché sur le bouton
  final String nextNodeId;  // id du nœud suivant dans l'arbre

  const ChatOption({required this.label, required this.nextNodeId});
}

// Un nœud de l'arbre de décision
class ChatNode {
  final String id;
  final String message;           // message affiché par le bot
  final List<ChatOption> options; // boutons proposés à l'élève (vide si terminal)
  final ChatAction? action;       // action exécutée si nœud terminal (options vides)

  const ChatNode({
    required this.id,
    required this.message,
    this.options = const [],
    this.action,
  });

  // Un nœud est terminal s'il n'a pas d'options (fin de branche)
  bool get isTerminal => options.isEmpty;
}
