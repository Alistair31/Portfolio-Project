import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bouton d'urgence corail « SOS ».
class SosButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;

  const SosButton({super.key, this.onTap, this.label = 'SOS'});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sos,
      borderRadius: BorderRadius.circular(30),
      elevation: 3,
      shadowColor: AppColors.sos.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.phone_in_talk_outlined,
                size: 19,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
