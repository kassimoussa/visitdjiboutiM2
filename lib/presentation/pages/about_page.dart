import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            
            // Logo et titre
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF3860F8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Center(
                child: Text(
                  '🇩🇯',
                  style: TextStyle(fontSize: 60),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Visit Djibouti',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3860F8),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Description
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3860F8).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Visit Djibouti est l\'application officielle de l\'Office du Tourisme de Djibouti. Découvrez les merveilles de notre pays : des paysages lunaires du lac Assal aux récifs coralliens des îles Moucha, en passant par les marchés animés de Djibouti-ville.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Statistiques
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '50+',
                    'Points d\'intérêt',
                    Icons.place,
                    const Color(0xFF3860F8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '100+',
                    'Événements',
                    Icons.event,
                    const Color(0xFF009639),
                  ),
                ),
                const SizedBox(width: 12),
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
            
            const SizedBox(height: 32),
            
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
            
            const SizedBox(height: 32),
            
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
            
            const SizedBox(height: 24),
            
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
            
            const SizedBox(height: 32),
            
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
            
            const SizedBox(height: 32),
            
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
            
            const SizedBox(height: 32),
            
            // Copyright
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '© 2024 Office du Tourisme de Djibouti',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tous droits réservés. Cette application est développée pour promouvoir le tourisme à Djibouti.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3860F8),
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3860F8),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF009639).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tech,
              style: const TextStyle(
                color: Color(0xFF009639),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 14),
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