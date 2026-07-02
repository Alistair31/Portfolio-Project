import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haven_app/pages/student/safety_page.dart';
import 'package:haven_app/pages/parent_portal_page.dart';

void main() {
  testWidgets('SafetyPage — renders Scaffold without crash', (tester) async {
    // SafetyPage needs a tall surface — its Column is not scrollable.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: SafetyPage()));
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('ParentPortalPage — renders Scaffold without crash', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ParentPortalPage()));
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
