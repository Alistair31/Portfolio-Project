import '../models/chat_node.dart';

// Arbre de décision complet du chatbot Haven.
// Structure : Map<id, ChatNode> — lookup en O(1) par id.
//
// Règle de nommage des ids :
//   root           → point d'entrée
//   node_*         → nœud intermédiaire
//   terminal_*     → nœud terminal (déclenche une action)

const Map<String, ChatNode> chatTree = {

  // -------------------------------------------------------------------------
  // Point d'entrée
  // -------------------------------------------------------------------------
  'root': ChatNode(
    id: 'root',
    message:
        'Bonjour, je suis Haven Assistant.\n'
        'Je suis là pour t\'aider à trouver la bonne direction.\n\n'
        'De quoi as-tu besoin ?',
    options: [
      ChatOption(label: 'Je veux faire un signalement',          nextNodeId: 'node_report_type'),
      ChatOption(label: 'Je vis quelque chose de difficile',     nextNodeId: 'node_difficult'),
      ChatOption(label: 'Je ne sais pas par où commencer',       nextNodeId: 'node_explain'),
      ChatOption(label: '🚨 Je suis en danger maintenant',       nextNodeId: 'terminal_emergency'),
    ],
  ),

  // -------------------------------------------------------------------------
  // Branche 1 — Signalement direct
  // -------------------------------------------------------------------------
  'node_report_type': ChatNode(
    id: 'node_report_type',
    message: 'Quel type de situation veux-tu signaler ?',
    options: [
      ChatOption(label: 'Violence physique',             nextNodeId: 'terminal_report_physical'),
      ChatOption(label: 'Mots blessants / intimidation', nextNodeId: 'terminal_report_verbal'),
      ChatOption(label: 'Harcèlement en ligne',          nextNodeId: 'terminal_report_cyber'),
      ChatOption(label: 'Violence à caractère sexuel',   nextNodeId: 'node_sexual_sensitive'),
      ChatOption(label: 'Je ne sais pas / autre',        nextNodeId: 'terminal_report_other'),
    ],
  ),

  // -------------------------------------------------------------------------
  // Branche 2 — Je vis quelque chose de difficile
  // -------------------------------------------------------------------------
  'node_difficult': ChatNode(
    id: 'node_difficult',
    message:
        'Je suis désolé(e) que tu traverses quelque chose de difficile.\n'
        'Tu as bien fait de venir ici. De quoi s\'agit-il ?',
    options: [
      ChatOption(label: 'On me fait du mal physiquement',              nextNodeId: 'node_physical_guidance'),
      ChatOption(label: 'On me dit des choses blessantes / on me harcèle', nextNodeId: 'node_verbal_guidance'),
      ChatOption(label: 'Je me sens seul(e) ou très mal',             nextNodeId: 'node_feeling'),
      ChatOption(label: '🚨 C\'est grave, j\'ai besoin d\'aide maintenant', nextNodeId: 'terminal_emergency'),
    ],
  ),

  'node_physical_guidance': ChatNode(
    id: 'node_physical_guidance',
    message:
        'Tu n\'es pas seul(e), et ce que tu vis ne devrait pas arriver.\n'
        'Qu\'est-ce que tu voudrais faire ?',
    options: [
      ChatOption(label: 'Signaler la situation',                   nextNodeId: 'terminal_report_physical'),
      ChatOption(label: '🚨 C\'est urgent, j\'ai besoin d\'aide', nextNodeId: 'terminal_emergency'),
      ChatOption(label: 'Je voulais juste en parler',              nextNodeId: 'node_feeling'),
    ],
  ),

  'node_verbal_guidance': ChatNode(
    id: 'node_verbal_guidance',
    message:
        'Le harcèlement par les mots est aussi grave que le physique.\n'
        'Que veux-tu faire ?',
    options: [
      ChatOption(label: 'Signaler (mots blessants / intimidation)', nextNodeId: 'terminal_report_verbal'),
      ChatOption(label: 'Signaler (harcèlement en ligne)',           nextNodeId: 'terminal_report_cyber'),
      ChatOption(label: 'J\'ai besoin de parler à quelqu\'un',      nextNodeId: 'node_feeling'),
    ],
  ),

  // -------------------------------------------------------------------------
  // Branche 3 — Je ne sais pas par où commencer
  // -------------------------------------------------------------------------
  'node_explain': ChatNode(
    id: 'node_explain',
    message:
        'Haven te permet de signaler des situations de violence ou de harcèlement '
        'de façon sécurisée, même anonymement.\n\n'
        'Tu peux aussi accéder à des numéros d\'aide si tu en as besoin.\n\n'
        'Par où veux-tu commencer ?',
    options: [
      ChatOption(label: 'Faire un signalement',           nextNodeId: 'node_report_type'),
      ChatOption(label: 'Parler à un professionnel',      nextNodeId: 'node_feeling'),
      ChatOption(label: '🚨 J\'ai besoin d\'aide urgente', nextNodeId: 'terminal_emergency'),
    ],
  ),

  // -------------------------------------------------------------------------
  // Branche 4 — Je me sens mal / j'ai besoin de parler
  // -------------------------------------------------------------------------
  'node_feeling': ChatNode(
    id: 'node_feeling',
    message:
        'Il est important de ne pas rester seul(e) avec ça.\n'
        'Des professionnels sont disponibles pour t\'écouter, '
        'sans jugement, gratuitement et anonymement.',
    options: [
      ChatOption(label: 'Voir les numéros d\'aide',           nextNodeId: 'terminal_resource'),
      ChatOption(label: 'Faire un signalement quand même',    nextNodeId: 'node_report_type'),
      ChatOption(label: '🚨 C\'est vraiment urgent',          nextNodeId: 'terminal_emergency'),
    ],
  ),

  // -------------------------------------------------------------------------
  // Branche sensible — Violence sexuelle
  // -------------------------------------------------------------------------
  'node_sexual_sensitive': ChatNode(
    id: 'node_sexual_sensitive',
    message:
        'Ce que tu vis est très sérieux, et il faut que tu saches '
        'que tu n\'as aucune responsabilité dans ce qui t\'arrive.\n\n'
        'Des professionnels peuvent t\'aider. Que veux-tu faire ?',
    options: [
      ChatOption(label: 'Faire un signalement',                    nextNodeId: 'terminal_report_sexual'),
      ChatOption(label: 'Parler à un adulte / professionnel',      nextNodeId: 'terminal_emergency'),
    ],
  ),

  // -------------------------------------------------------------------------
  // Nœuds terminaux — Signalements
  // -------------------------------------------------------------------------
  'terminal_report_physical': ChatNode(
    id: 'terminal_report_physical',
    message:
        'Je t\'amène vers le formulaire de signalement.\n'
        'Le type "Violence physique" est déjà sélectionné.',
    action: OpenReportAction('PHYSICAL'),
  ),

  'terminal_report_verbal': ChatNode(
    id: 'terminal_report_verbal',
    message:
        'Je t\'amène vers le formulaire de signalement.\n'
        'Le type "Violence verbale" est déjà sélectionné.',
    action: OpenReportAction('VERBAL'),
  ),

  'terminal_report_cyber': ChatNode(
    id: 'terminal_report_cyber',
    message:
        'Je t\'amène vers le formulaire de signalement.\n'
        'Le type "Cyberharcèlement" est déjà sélectionné.',
    action: OpenReportAction('CYBER'),
  ),

  'terminal_report_sexual': ChatNode(
    id: 'terminal_report_sexual',
    message:
        'Je t\'amène vers le formulaire de signalement.\n'
        'Le type "Violence sexuelle" est déjà sélectionné.',
    action: OpenReportAction('SEXUAL'),
  ),

  'terminal_report_other': ChatNode(
    id: 'terminal_report_other',
    message: 'Je t\'amène vers le formulaire. Tu pourras préciser le type toi-même.',
    action: OpenReportAction('OTHER'),
  ),

  // -------------------------------------------------------------------------
  // Nœud terminal — Urgence
  // -------------------------------------------------------------------------
  'terminal_emergency': ChatNode(
    id: 'terminal_emergency',
    message:
        'Si tu es en danger immédiat, contacte les secours maintenant.\n'
        'Ces numéros sont gratuits, disponibles 24h/24, et confidentiels.',
    action: ShowEmergencyAction(),
  ),

  // -------------------------------------------------------------------------
  // Nœud terminal — Ressources
  // -------------------------------------------------------------------------
  'terminal_resource': ChatNode(
    id: 'terminal_resource',
    message: 'Voici des numéros où des professionnels peuvent t\'écouter :',
    action: ShowResourceAction(
      '📞 3114 — Numéro national prévention suicide (24h/24)\n'
      '📞 3020 — Harcèlement scolaire\n'
      '📞 119  — Enfance en danger\n'
      '📞 3018 — Cyberharcèlement',
    ),
  ),
};
