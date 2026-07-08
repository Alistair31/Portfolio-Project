import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haven_app/theme/app_colors.dart';

void main() {
  group('AppColors.statusColor', () {
    test('maps each known status to its color', () {
      expect(AppColors.statusColor('PENDING'), const Color(0xFFE89B4E));
      expect(AppColors.statusColor('IN_PROGRESS'), const Color(0xFF4A90D9));
      expect(AppColors.statusColor('CLOSED'), AppColors.eucalyptus);
    });

    test('falls back to edward for an unknown status', () {
      expect(AppColors.statusColor('WHATEVER'), AppColors.edward);
    });
  });
}
