import 'package:flutter/material.dart';

/// Point de vérité unique pour l'adaptation de l'app aux grands écrans
/// (tablettes). Un seul réglage ici plutôt qu'un scale factor différent codé
/// en dur à chaque endroit qui en aurait besoin.
class Responsive {
  Responsive._();

  // 600dp est le seuil standard Material pour distinguer téléphone et
  // tablette (couvre aussi les phablets/grands téléphones en les traitant
  // comme des téléphones, pas comme des tablettes).
  static const double _tabletBreakpoint = 600;
  static const double _tabletBoost = 1.15;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= _tabletBreakpoint;

  static double _factor(BuildContext context) => isTablet(context) ? _tabletBoost : 1.0;

  /// Combine le textScaler existant (respecte le réglage d'accessibilité du
  /// système, ex. "texte plus grand" activé côté OS) avec le boost tablette,
  /// plutôt que de l'écraser. Branché une seule fois dans main.dart : couvre
  /// tout le texte de l'app sans avoir à toucher aux TextStyle individuels.
  static TextScaler boostedTextScaler(BuildContext context) {
    final current = MediaQuery.textScalerOf(context).scale(1.0);
    return TextScaler.linear(current * _factor(context));
  }

  /// Pour les dimensions qui ne passent pas par le textScaler (padding,
  /// tailles d'icône/avatar, largeurs fixes...). Contrairement au texte, pas
  /// branché automatiquement partout — à appliquer au cas par cas sur les
  /// écrans qu'on retouche, ex: `padding: EdgeInsets.all(Responsive.scale(context, 16))`.
  static double scale(BuildContext context, double value) => value * _factor(context);
}
