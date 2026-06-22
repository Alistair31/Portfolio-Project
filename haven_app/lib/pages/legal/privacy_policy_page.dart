import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.infoBackground,
      appBar: AppBar(title: const Text('Politique de confidentialité'),
      backgroundColor: AppColors.infoBackground),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              title: '1. Qui collecte tes données ?',
              body:
                  "Haven est une application développée dans le cadre d'un projet scolaire. "
                  "Le responsable du traitement est l'équipe Haven (contact : PLACEHOLDER_EMAIL).",
            ),
            _Section(
              title: '2. Quelles données sont collectées ?',
              body:
                  "Lors de ton inscription, nous collectons :\n"
                  "• Ton prénom\n"
                  "• Ton adresse email\n"
                  "• Ton mot de passe (chiffré, jamais lisible)\n"
                  "• Ton code établissement\n"
                  "• Ta classe\n\n"
                  "Lors de tes signalements, des informations sur les situations rapportées "
                  "peuvent être collectées. Tu choisis toi-même ton niveau d'anonymat.",
            ),
            _Section(
              title: '3. Pourquoi ces données sont-elles utilisées ?',
              body:
                  "Tes données sont utilisées uniquement pour :\n"
                  "• Créer et gérer ton compte\n"
                  "• Te permettre de faire des signalements en toute sécurité\n"
                  "• Informer les responsables de ton établissement des situations signalées\n\n"
                  "Tes données ne sont jamais vendues ni transmises à des tiers commerciaux.",
            ),
            _Section(
              title: '4. Combien de temps sont-elles conservées ?',
              body:
                  "Ton compte et tes données sont conservés pendant la durée de ton utilisation "
                  "de l'application, et supprimés dans un délai de 30 jours suivant ta demande de suppression.",
            ),
            _Section(
              title: '5. Tes droits',
              body:
                  "Conformément au RGPD, tu as le droit de :\n"
                  "• Accéder à tes données\n"
                  "• Les corriger\n"
                  "• Demander leur suppression\n"
                  "• T'opposer à leur traitement\n\n"
                  "Pour exercer ces droits, contacte-nous à : PLACEHOLDER_EMAIL\n\n"
                  "Si tu as moins de 15 ans, l'accord d'un parent ou tuteur est nécessaire.",
            ),
            _Section(
              title: '6. Sécurité',
              body:
                  "Tes données sont stockées de façon sécurisée. "
                  "Ton mot de passe est chiffré et ne peut être lu par personne, y compris l'équipe Haven.",
            ),
            SizedBox(height: 32),
            Text(
              'Dernière mise à jour : juin 2026',
              style: TextStyle(fontSize: 13,
              color: AppColors.textDark),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(body,
          style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
