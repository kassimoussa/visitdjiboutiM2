import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/responsive.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.drawerAbout),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: Responsive.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Logo et titre
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: Color(0xFF3860F8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60.r),
              ),
              child: Center(
                child: Text(
                  '🇩🇯',
                  style: TextStyle(fontSize: 60.sp),
                ),
              ),
            ),
            
            SizedBox(height: ResponsiveConstants.largeSpace),
            
            Text(
              'Visit Djibouti',
              style: TextStyle(
                fontSize: ResponsiveConstants.headline5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3860F8),
              ),
            ),
            
            SizedBox(height: ResponsiveConstants.smallSpace),
            
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: ResponsiveConstants.body1,
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Description
            Container(
              padding: Responsive.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3860F8).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Visit Djibouti is the official app of the Djibouti Tourism Office. Discover the wonders of our country: from the lunar landscapes of Lake Assal to the coral reefs of Moucha Islands, passing through the bustling markets of Djibouti City.', // TODO: Add translation key
                style: TextStyle(
                  fontSize: ResponsiveConstants.body1,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Statistiques
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '50+',
                    'Points of Interest', // TODO: Add translation key
                    Icons.place,
                    const Color(0xFF3860F8),
                  ),
                ),
                SizedBox(width: ResponsiveConstants.smallSpace),
                Expanded(
                  child: _buildStatCard(
                    '100+',
                    'Events', // TODO: Add translation key
                    Icons.event,
                    const Color(0xFF009639),
                  ),
                ),
                SizedBox(width: ResponsiveConstants.smallSpace),
                Expanded(
                  child: _buildStatCard(
                    '6',
                    'Régions',
                    Icons.map,
                    const Color(0xFF0072CE),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Fonctionnalités
            _buildSection(
              'Fonctionnalités',
              [
                _buildFeatureItem(
                  Icons.explore,
                  'Découvrir',
                  'Plus de 50 points d\'intérêt avec photos et descriptions détaillées',
                ),
                _buildFeatureItem(
                  Icons.event,
                  'Événements',
                  'Calendrier complet des événements culturels et touristiques',
                ),
                _buildFeatureItem(
                  Icons.map,
                  'Cartes interactives',
                  'Navigation GPS et localisation des POIs proches',
                ),
                _buildFeatureItem(
                  Icons.favorite,
                  'Favoris',
                  'Sauvegardez vos lieux préférés et planifiez vos visites',
                ),
                _buildFeatureItem(
                  Icons.offline_pin,
                  'Mode hors ligne',
                  'Accédez aux informations même sans connexion Internet',
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Équipe
            _buildSection(
              'Développé par',
              [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF3860F8),
                    child: Text('OT', style: TextStyle(color: Colors.white)),
                  ),
                  title: const Text('Office du Tourisme de Djibouti'),
                  subtitle: const Text('Organisme officiel de promotion touristique'),
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveConstants.largeSpace),
            
            // Partenaires
            _buildSection(
              'Partenaires',
              [
                ListTile(
                  leading: const Icon(Icons.business, color: Color(0xFF3860F8)),
                  title: const Text('Ministère du Commerce et du Tourisme'),
                  subtitle: const Text('République de Djibouti'),
                ),
                ListTile(
                  leading: const Icon(Icons.hotel, color: Color(0xFF009639)),
                  title: const Text('Association des Hôteliers'),
                  subtitle: const Text('Secteur privé du tourisme'),
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Technologies utilisées
            _buildSection(
              'Technologies',
              [
                _buildTechItem('Flutter', 'Framework mobile multiplateforme'),
                _buildTechItem('Dart', 'Langage de programmation moderne'),
                _buildTechItem('Laravel', 'API Backend robuste et sécurisée'),
                _buildTechItem('Google Maps', 'Cartographie et géolocalisation'),
              ],
            ),
            
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Contact et liens
            _buildSection(
              'Contact & Liens',
              [
                _buildContactItem(
                  Icons.web,
                  'Site web officiel',
                  'www.office-tourisme.dj',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ouverture du site web...'),
                      ),
                    );
                  },
                ),
                _buildContactItem(
                  Icons.email,
                  'Email',
                  'info@office-tourisme.dj',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ouverture de l\'application email...'),
                      ),
                    );
                  },
                ),
                _buildContactItem(
                  Icons.phone,
                  'Téléphone',
                  '+253 21 35 68 00',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ouverture de l\'application téléphone...'),
                      ),
                    );
                  },
                ),
                _buildContactItem(
                  Icons.location_on,
                  'Adresse',
                  'Place du 27 Juin, Djibouti-ville',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ouverture de la carte...'),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Copyright
            Container(
              padding: Responsive.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  Text(
                    '© 2024 Office du Tourisme de Djibouti',
                    style: TextStyle(
                      fontSize: ResponsiveConstants.body2,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveConstants.smallSpace),
                  Text(
                    'Tous droits réservés. Cette application est développée pour promouvoir le tourisme à Djibouti.',
                    style: TextStyle(
                      fontSize: ResponsiveConstants.caption,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: ResponsiveConstants.largeSpace),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: Responsive.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: ResponsiveConstants.smallSpace),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: ResponsiveConstants.subtitle1,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: ResponsiveConstants.caption,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveConstants.subtitle1,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3860F8),
          ),
        ),
        SizedBox(height: ResponsiveConstants.mediumSpace),
        ...children,
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: Responsive.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: Responsive.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3860F8),
              size: 20,
            ),
          ),
          SizedBox(width: ResponsiveConstants.mediumSpace),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.tinySpace),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body2,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String tech, String description) {
    return Padding(
      padding: Responsive.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: Responsive.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF009639).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              tech,
              style: TextStyle(
                color: Color(0xFF009639),
                fontSize: ResponsiveConstants.caption,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: ResponsiveConstants.smallSpace),
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3860F8)),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.launch, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}