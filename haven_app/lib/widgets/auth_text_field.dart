import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Champ de saisie avec un label au-dessus et une icône à gauche.
/// Sert aussi bien pour le code établissement que le mot de passe.
class AuthTextField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const AuthTextField({
    super.key,
    required this.label,
    this.icon,
    this.hintText,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.label,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.fieldBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            cursorColor: AppColors.textDark,
            cursorWidth: 2,
            cursorHeight: 20,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: AppColors.iconMuted,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: icon == null
                  ? null
                  : Icon(icon, color: AppColors.iconMuted, size: 20),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
