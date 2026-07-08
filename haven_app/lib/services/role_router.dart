import 'package:flutter/material.dart';
import 'package:haven_app/pages/parent/parent_home_page.dart';
import 'package:haven_app/pages/staff/staff_home_page.dart';
import 'package:haven_app/pages/student/student_home_page.dart';

import '../pages/authentification/login_page.dart';

/// Page d'accueil correspondant à un rôle utilisateur. Centralisé ici pour que
/// HavenStart (auto-login) et la fin de l'onboarding routent toujours de la
/// même façon — un rôle inconnu ramène à l'écran de connexion plutôt que
/// d'échouer silencieusement sur une page qui ne lui correspond pas.
Widget homeForRole(String role) {
  return switch (role) {
    'STUDENT' => const StudentHomePage(),
    'TEACHER' || 'DIRECTOR_CPE' || 'RECTORAT' => const StaffHomePage(),
    'PARENT' => const ParentHomePage(),
    _ => const LoginPage(),
  };
}
