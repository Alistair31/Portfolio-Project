import 'package:flutter/material.dart';

/// Palette centralisée de l'app Haven.
/// On passe par ici pour garder les mêmes couleurs sur toutes les pages.
class AppColors {
  AppColors._();

  /// Vert principal de la marque (repris du splashscreen).
  static const Color brand = Color.fromARGB(255, 48, 214, 120);

  /// Vert "doux" utilisé pour les boutons pleins.
  static const Color buttonGreen = Color.fromARGB(255, 85, 231, 121);
  static const Color buttonGreenDark = Color(0xFF6FC98A);

  /// Dégradé de fond (haut -> bas).
  static const Color backgroundTop = Color.fromARGB(255, 226, 246, 231);
  static const Color backgroundBottom = Color(0xFFFAF9F4);

  /// Textes.
  static const Color textDark = Color(0xFF16181C);
  static const Color textMuted = Color(0xFF7C828A);
  static const Color label = Color(0xFF5B6470);
  static const Color textGreen = Color.fromARGB(251, 31, 146, 86);

  /// Champs de saisie.
  static const Color fieldBackground = Colors.white;
  static const Color fieldBorder = Color(0xFFEAEAE3);
  static const Color iconMuted = Color(0xFF9AA0A6);

  /// Boutons secondaires (contour).
  static const Color outlineBorder = Color(0xFFE6E6DF);

  /// Bandeau d'information (fond vert clair + texte vert foncé).
  static const Color infoBackground = Color(0xFFD7F0DE);
  static const Color infoText = Color(0xFF2A6B45);

  static const Color backgroundBottomBlack = Color.fromARGB(255, 0, 0, 0);

  /// Onboarding — grand bloc vert plein (variante « Lueur »).
  static const Color cardGreen = Color(0xFF8DE0A3);

  /// Onboarding — surlignage « marqueur » derrière un mot (variante « Clair »).
  static const Color highlightGreen = Color(0xFF8DE0A3);

  /// Bouton plein foncé (variantes « Clair » & « Lueur »).
  static const Color buttonDark = Color(0xFF16181C);

  /// Bouton plein foncé pour suppression de compte.
  static const Color delButton = Color.fromARGB(192, 255, 0, 0);

  // --- Tokens maquette Figma (Espace élève) ---

  /// Racing Green — textes foncés / titres.
  static const Color racingGreen = Color(0xFF14201B);

  /// Mantle — textes secondaires.
  static const Color mantle = Color(0xFF8A958F);

  /// Granny Smith Apple — vert principal (grand bloc + FAB).
  static const Color grannySmith = Color(0xFF8BEBA0);

  /// Outer Space — sous-titre du grand bloc.
  static const Color outerSpace = Color(0xFF23332C);

  /// Blue Romance — fond du badge « suivi ».
  static const Color blueRomance = Color(0xFFCBF6D4);

  /// Eucalyptus — point du badge « suivi ».
  static const Color eucalyptus = Color(0xFF2C8A6B);

  /// Fond des pastilles d'icône (cartes).
  static const Color iconTint = Color(0xFFE3FAE8);

  /// Edward — éléments de navigation inactifs.
  static const Color edward = Color(0xFFAAB2AC);

  /// Ecru White — anneau autour du FAB.
  static const Color ecruWhite = Color(0xFFFBFAF5);

  /// Bordure fine « Racing Green 9% » (rgba(20,32,27,.09)).
  static const Color hairline = Color(0x1714201B);

  /// Bordure « Racing Green 16% » (humeurs non sélectionnées).
  static const Color hairlineStrong = Color(0x2914201B);

  /// Corduroy — sous-titres doux (check-in / signalement).
  static const Color corduroy = Color(0xFF56655D);

  /// De York — humeur sélectionnée + pastilles « positives » du journal.
  static const Color deYork = Color(0xFF8BCB7E);

  // --- Espace élève / Check-in / Signalement ---

  /// Bouton d'urgence (SOS) — corail (Burnt Sienna).
  static const Color sos = Color(0xFFE8654E);

  /// Accent vert foncé pour les éléments sélectionnés
  /// (humeur du check-in, carte de signalement active).
  static const Color selectionGreen = Color(0xFF2E8B57);

  /// Fond vert clair d'une carte sélectionnée (choix du signalement).
  static const Color selectionCardBg = Color(0xFFA9E6BF);

  /// Grand bloc « Besoin de parler ? » — dégradé (haut -> bas).
  static const Color heroGreenTop = Color(0xFF82D99C);
  static const Color heroGreenBottom = Color(0xFFA9E8BF);

  /// Couleur associée au statut d'un signalement (badges, timeline de suivi).
  static Color statusColor(String status) {
    switch (status) {
      case 'PENDING':     return const Color(0xFFE89B4E);
      case 'IN_PROGRESS': return const Color(0xFF4A90D9);
      case 'CLOSED':      return eucalyptus;
      default:            return edward;
    }
  }
}
