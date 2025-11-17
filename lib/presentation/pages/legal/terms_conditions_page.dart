import 'package:flutter/material.dart';
import 'package:visitdjibouti/core/utils/responsive.dart';
import '../../../generated/l10n/app_localizations.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.authTermsAndConditions),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: Responsive.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: Responsive.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.asset(
                        'assets/images/logo_visitdjibouti.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.description,
                          color: Color(0xFF3860F8),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    AppLocalizations.of(context)!.authTermsAndConditions,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2233),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Dernière mise à jour : 23 octobre 2025',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Introduction
            _buildSection(
              title: '1. Acceptation des conditions',
              content:
                  'En accédant et en utilisant l\'application mobile Visit Djibouti ("l\'Application"), '
                  'vous acceptez d\'être lié par ces conditions générales d\'utilisation. Si vous n\'acceptez '
                  'pas ces conditions, veuillez ne pas utiliser l\'Application.',
            ),

            // Services
            _buildSection(
              title: '2. Description des services',
              content:
                  'Visit Djibouti est une application mobile qui fournit des informations sur :\n\n'
                  '• Les points d\'intérêt touristiques à Djibouti\n'
                  '• Les événements culturels et touristiques\n'
                  '• Les services d\'opérateurs touristiques\n'
                  '• Les informations pratiques pour les voyageurs\n'
                  '• Les fonctionnalités de réservation et de favoris',
            ),

            // Compte utilisateur
            _buildSection(
              title: '3. Compte utilisateur',
              content:
                  'Pour accéder à certaines fonctionnalités, vous devez créer un compte. '
                  'Vous vous engagez à :\n\n'
                  '• Fournir des informations exactes et à jour\n'
                  '• Maintenir la confidentialité de votre mot de passe\n'
                  '• Être responsable de toutes les activités sur votre compte\n'
                  '• Nous informer immédiatement de toute utilisation non autorisée\n'
                  '• Ne pas partager votre compte avec des tiers',
            ),

            // Utilisation acceptable
            _buildSection(
              title: '4. Utilisation acceptable',
              content:
                  'Vous vous engagez à ne pas :\n\n'
                  '• Utiliser l\'Application à des fins illégales\n'
                  '• Publier du contenu offensant ou inapproprié\n'
                  '• Tenter d\'accéder à des zones restreintes\n'
                  '• Perturber le fonctionnement de l\'Application\n'
                  '• Utiliser des robots ou des scripts automatisés\n'
                  '• Usurper l\'identité d\'une autre personne\n'
                  '• Copier ou redistribuer le contenu sans autorisation',
            ),

            // Propriété intellectuelle
            _buildSection(
              title: '5. Propriété intellectuelle',
              content:
                  'Tous les contenus de l\'Application (textes, images, logos, designs, code source) '
                  'sont la propriété de Visit Djibouti ou de ses partenaires et sont protégés par les '
                  'lois sur la propriété intellectuelle. Toute reproduction, distribution ou modification '
                  'non autorisée est strictement interdite.',
            ),

            // Réservations
            _buildSection(
              title: '6. Réservations et paiements',
              content:
                  'Lorsque vous effectuez une réservation via l\'Application :\n\n'
                  '• Les prix affichés sont indicatifs et peuvent varier\n'
                  '• Les confirmations sont envoyées par email\n'
                  '• Les annulations sont soumises aux politiques des prestataires\n'
                  '• Nous agissons comme intermédiaire entre vous et les prestataires\n'
                  '• Les paiements sont sécurisés et conformes aux normes PCI-DSS',
            ),

            // Responsabilité
            _buildSection(
              title: '7. Limitation de responsabilité',
              content:
                  'Visit Djibouti fournit l\'Application "en l\'état" sans garanties. Nous ne sommes '
                  'pas responsables de :\n\n'
                  '• L\'exactitude des informations fournies par des tiers\n'
                  '• Les dommages résultant de l\'utilisation de l\'Application\n'
                  '• Les interruptions de service ou les erreurs techniques\n'
                  '• Les pertes de données ou de contenu\n'
                  '• Les actions des prestataires de services touristiques',
            ),

            // Contenu utilisateur
            _buildSection(
              title: '8. Contenu utilisateur',
              content:
                  'Si vous publiez du contenu (avis, commentaires, photos) :\n\n'
                  '• Vous conservez vos droits de propriété\n'
                  '• Vous accordez à Visit Djibouti une licence d\'utilisation\n'
                  '• Vous garantissez posséder les droits sur ce contenu\n'
                  '• Nous pouvons supprimer du contenu inapproprié\n'
                  '• Vous êtes responsable du contenu que vous publiez',
            ),

            // Liens externes
            _buildSection(
              title: '9. Liens vers des sites tiers',
              content:
                  'L\'Application peut contenir des liens vers des sites web ou services tiers. '
                  'Nous ne sommes pas responsables du contenu ou des pratiques de ces sites. '
                  'L\'accès à ces sites se fait à vos propres risques.',
            ),

            // Modifications
            _buildSection(
              title: '10. Modifications du service',
              content:
                  'Nous nous réservons le droit de modifier, suspendre ou interrompre tout ou partie '
                  'de l\'Application à tout moment, avec ou sans préavis. Nous ne serons pas responsables '
                  'envers vous ou tout tiers pour toute modification ou interruption.',
            ),

            // Résiliation
            _buildSection(
              title: '11. Résiliation',
              content:
                  'Nous pouvons suspendre ou résilier votre accès à l\'Application en cas de violation '
                  'de ces conditions. Vous pouvez également supprimer votre compte à tout moment depuis '
                  'les paramètres de l\'Application. Les dispositions qui, par nature, doivent survivre '
                  'à la résiliation resteront en vigueur.',
            ),

            // Droit applicable
            _buildSection(
              title: '12. Droit applicable',
              content:
                  'Ces conditions sont régies par les lois de la République de Djibouti. '
                  'Tout litige sera soumis à la compétence exclusive des tribunaux de Djibouti.',
            ),

            // Modifications des conditions
            _buildSection(
              title: '13. Modifications des conditions',
              content:
                  'Nous pouvons modifier ces conditions à tout moment. Les modifications entreront en '
                  'vigueur dès leur publication dans l\'Application. Votre utilisation continue de '
                  'l\'Application après les modifications constitue votre acceptation des nouvelles conditions.',
            ),

            // Contact
            _buildSection(
              title: '14. Contact',
              content:
                  'Pour toute question concernant ces conditions d\'utilisation :\n\n'
                  '📧 Email : legal@visitdjibouti.dj\n'
                  '📱 Téléphone : +253 21 35 28 00\n'
                  '📍 Adresse : Office National du Tourisme de Djibouti\n'
                  '   Place du 27 Juin, Djibouti',
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: Responsive.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3860F8),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.grey[800],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
