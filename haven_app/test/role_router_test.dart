import 'package:flutter_test/flutter_test.dart';
import 'package:haven_app/pages/authentification/login_page.dart';
import 'package:haven_app/pages/parent/parent_home_page.dart';
import 'package:haven_app/pages/staff/staff_home_page.dart';
import 'package:haven_app/pages/student/student_home_page.dart';
import 'package:haven_app/services/role_router.dart';

void main() {
  group('homeForRole', () {
    // Régression bug #27 : un RECTORAT (ou TEACHER/DIRECTOR_CPE) se connectant
    // pour la première fois sur un appareil passait par l'onboarding, qui
    // renvoyait ensuite tout le monde vers StudentHomePage sans distinction de rôle.
    test('STUDENT goes to StudentHomePage', () {
      expect(homeForRole('STUDENT'), isA<StudentHomePage>());
    });

    test('TEACHER, DIRECTOR_CPE and RECTORAT all go to StaffHomePage', () {
      for (final role in ['TEACHER', 'DIRECTOR_CPE', 'RECTORAT']) {
        expect(homeForRole(role), isA<StaffHomePage>(), reason: 'role: $role');
      }
    });

    test('PARENT goes to ParentHomePage', () {
      expect(homeForRole('PARENT'), isA<ParentHomePage>());
    });

    test('an unknown or empty role falls back to LoginPage rather than a broken home', () {
      expect(homeForRole(''), isA<LoginPage>());
      expect(homeForRole('SOMETHING_ELSE'), isA<LoginPage>());
    });
  });
}
