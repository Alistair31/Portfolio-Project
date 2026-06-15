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
}
