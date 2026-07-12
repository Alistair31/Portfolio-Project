import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haven_app/theme/responsive.dart';

Widget _withMediaQuery({required Size size, required Widget child, TextScaler textScaler = TextScaler.noScaling}) {
  return MediaQuery(
    data: MediaQueryData(size: size, textScaler: textScaler),
    child: child,
  );
}

void main() {
  group('Responsive.isTablet', () {
    testWidgets('false for a phone-sized screen', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_withMediaQuery(
        size: const Size(390, 844),
        child: Builder(builder: (context) { ctx = context; return const SizedBox(); }),
      ));
      expect(Responsive.isTablet(ctx), isFalse);
    });

    testWidgets('true at the 600dp breakpoint and above', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_withMediaQuery(
        size: const Size(600, 900),
        child: Builder(builder: (context) { ctx = context; return const SizedBox(); }),
      ));
      expect(Responsive.isTablet(ctx), isTrue);
    });
  });

  group('Responsive.scale', () {
    testWidgets('leaves the value untouched on phone', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_withMediaQuery(
        size: const Size(390, 844),
        child: Builder(builder: (context) { ctx = context; return const SizedBox(); }),
      ));
      expect(Responsive.scale(ctx, 16), 16);
    });

    testWidgets('boosts the value by 1.15x on tablet', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_withMediaQuery(
        size: const Size(820, 1180),
        child: Builder(builder: (context) { ctx = context; return const SizedBox(); }),
      ));
      expect(Responsive.scale(ctx, 16), closeTo(18.4, 0.01));
    });
  });

  group('Responsive.boostedTextScaler', () {
    testWidgets('matches the system scaler on phone (no boost)', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_withMediaQuery(
        size: const Size(390, 844),
        textScaler: const TextScaler.linear(1.2), // ex: accessibilité "texte plus grand"
        child: Builder(builder: (context) { ctx = context; return const SizedBox(); }),
      ));
      expect(Responsive.boostedTextScaler(ctx).scale(10), closeTo(12.0, 0.01));
    });

    testWidgets('multiplies the system scaler by the tablet boost', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_withMediaQuery(
        size: const Size(820, 1180),
        textScaler: const TextScaler.linear(1.2),
        child: Builder(builder: (context) { ctx = context; return const SizedBox(); }),
      ));
      // 1.2 (accessibilité système) * 1.15 (boost tablette) = 1.38
      expect(Responsive.boostedTextScaler(ctx).scale(10), closeTo(13.8, 0.01));
    });
  });
}
