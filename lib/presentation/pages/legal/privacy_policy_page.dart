import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.authPrivacyPolicy),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/logo_visitdjibouti.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.privacy_tip,
                          color: Color(0xFF3860F8),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.authPrivacyPolicy,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2233),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dernière mise à jour : 23 octobre 2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Introduction
            _buildSection(
              title: '1. Introduction',
              content:
                  'Visit Djibouti ("nous", "notre" ou "nos") s\'engage à protéger votre vie privée. '
                  'Cette politique de confidentialité explique comment nous collectons, utilisons, '
                  'divulguons et protégeons vos informations personnelles lorsque vous utilisez notre '
                  'application mobile Visit Djibouti.',
            ),

            // Informations collectées
            _buildSection(
              title: '2. Informations que nous collectons',
              content:
                  'Nous collectons les types d\'informations suivants :\n\n'
                  '• Informations d\'inscription : nom, adresse e-mail, mot de passe\n'
                  '• Informations de profil : préférences de voyage, langues\n'
                  '• Données d\'utilisation : pages visitées, fonctionnalités utilisées\n'
                  '• Données de localisation : lorsque vous activez les services de localisation\n'
                  '• Informations techniques : type d\'appareil, système d\'exploitation, identifiant unique',
            ),

            // Utilisation des données
            _buildSection(
              title: '3. Comment nous utilisons vos informations',
              content:
                  'Nous utilisons vos informations pour :\n\n'
                  '• Fournir et améliorer nos services\n'
                  '• Personnaliser votre expérience utilisateur\n'
                  '• Vous envoyer des notifications importantes\n'
                  '• Analyser l\'utilisation de l\'application\n'
                  '• Assurer la sécurité et prévenir la fraude\n'
                  '• Respecter nos obligations légales',
            ),

            // Partage des données
            _buildSection(
              title: '4. Partage de vos informations',
              content:
                  'Nous ne vendons jamais vos informations personnelles. Nous pouvons partager vos '
                  'informations uniquement dans les cas suivants :\n\n'
                  '• Avec votre consentement explicite\n'
                  '• Avec nos prestataires de services (hébergement, analytique)\n'
                  '• Pour respecter des obligations légales\n'
                  '• Pour protéger nos droits et notre sécurité',
            ),

            // Sécurité
            _buildSection(
              title: '5. Sécurité de vos données',
              content:
                  'Nous mettons en œuvre des mesures de sécurité techniques et organisationnelles '
                  'appropriées pour protéger vos informations personnelles contre tout accès non autorisé, '
                  'modification, divulgation ou destruction. Cela inclut le chiffrement des données sensibles '
                  'et l\'utilisation de connexions sécurisées.',
            ),

            // Droits des utilisateurs
            _buildSection(
              title: '6. Vos droits',
              content:
                  'Vous avez le droit de :\n\n'
                  '• Accéder à vos informations personnelles\n'
                  '• Corriger des informations inexactes\n'
                  '• Supprimer votre compte et vos données\n'
                  '• Vous opposer au traitement de vos données\n'
                  '• Retirer votre consentement à tout moment\n'
                  '• Exporter vos données dans un format lisible',
            ),

            // Cookies et technologies
            _buildSection(
              title: '7. Cookies et technologies similaires',
              content:
                  'Nous utilisons des cookies et des technologies similaires pour améliorer votre '
                  'expérience, analyser l\'utilisation de l\'application et personnaliser le contenu. '
                  'Vous pouvez gérer vos préférences concernant les cookies dans les paramètres de l\'application.',
            ),

            // Conservation des données
            _buildSection(
              title: '8. Conservation des données',
              content:
                  'Nous conservons vos informations personnelles aussi longtemps que nécessaire pour '
                  'fournir nos services ou pour respecter nos obligations légales. Lorsque vous supprimez '
                  'votre compte, vos données personnelles sont supprimées de nos systèmes dans un délai de 30 jours.',
            ),

            // Modifications
            _buildSection(
              title: '9. Modifications de cette politique',
              content:
                  'Nous pouvons mettre à jour cette politique de confidentialité de temps à autre. '
                  'Nous vous informerons de tout changement important en publiant la nouvelle politique sur '
                  'cette page et en mettant à jour la date de "Dernière mise à jour".',
            ),

            // Contact
            _buildSection(
              title: '10. Nous contacter',
              content:
                  'Pour toute question concernant cette politique de confidentialité, veuillez nous contacter :\n\n'
                  '📧 Email : privacy@visitdjibouti.dj\n'
                  '📱 Téléphone : +253 21 35 28 00\n'
                  '📍 Adresse : Office National du Tourisme de Djibouti\n'
                  '   Place du 27 Juin, Djibouti',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3860F8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
