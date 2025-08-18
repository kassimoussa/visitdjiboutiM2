import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggedIn = false;
  
  // Données utilisateur simulées
  final Map<String, dynamic> _userData = {
    'name': 'Ahmed Hassan',
    'email': 'ahmed.hassan@email.com',
    'avatar': '👤',
    'memberSince': '2023',
    'favoritesPois': 12,
    'eventsRegistered': 3,
  };

  // Données de favoris simulées
  final List<Map<String, dynamic>> _favoritePois = [
    {
      'name': 'Lac Assal',
      'region': 'Tadjourah',
      'image': '🏔️',
    },
    {
      'name': 'Îles Moucha',
      'region': 'Djibouti',
      'image': '🏖️',
    },
    {
      'name': 'Forêt du Day',
      'region': 'Tadjourah',
      'image': '🌲',
    },
  ];

  // Réservations d'événements simulées
  final List<Map<String, dynamic>> _eventRegistrations = [
    {
      'title': 'Marathon du Grand Bara',
      'date': '22 Mars 2024',
      'status': 'Confirmé',
      'image': '🏃',
    },
    {
      'title': 'Festival de la Mer Rouge',
      'date': '15 Mars 2024',
      'status': 'En attente',
      'image': '🎵',
    },
    {
      'title': 'Excursion Lac Assal',
      'date': '5 Avril 2024',
      'status': 'Confirmé',
      'image': '🚌',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoggedIn ? _buildLoggedInProfile() : _buildLoginScreen(),
    );
  }

  Widget _buildLoginScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Logo/Image
          Container(
            width: isSmallScreen ? 100 : 120,
            height: isSmallScreen ? 100 : 120,
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '🇩🇯',
                style: TextStyle(fontSize: isSmallScreen ? 50 : 60),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Titre
          const Text(
            'Bienvenue sur Visit Djibouti',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Connectez-vous pour sauvegarder vos favoris et gérer vos réservations',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          // Boutons de connexion OAuth
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                _simulateLogin();
              },
              icon: const Text('G', style: TextStyle(fontWeight: FontWeight.bold)),
              label: const Text('Continuer avec Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                _simulateLogin();
              },
              icon: const Text('f', style: TextStyle(fontWeight: FontWeight.bold)),
              label: const Text('Continuer avec Facebook'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Séparateur
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ou',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Formulaire email/password
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.email),
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.lock),
            ),
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _simulateLogin();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3860F8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Se connecter'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextButton(
            onPressed: () {
              // Action pour créer un compte
            },
            child: const Text('Créer un compte'),
          ),
          
          const SizedBox(height: 32),
          
          // Option continuer sans compte
          TextButton(
            onPressed: () {
              // Navigation sans connexion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vous pouvez naviguer sans créer de compte'),
                ),
              );
            },
            child: Text(
              'Continuer sans compte',
              style: TextStyle(
                color: Colors.grey[600],
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInProfile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header profil
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF3860F8),
                  const Color(0xFF3860F8).withOpacity(0.8),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      _userData['avatar'],
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Nom
                  Text(
                    _userData['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Email
                  Text(
                    _userData['email'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Membre depuis
                  Text(
                    'Membre depuis ${_userData['memberSince']}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Statistiques
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Favoris',
                    _userData['favoritesPois'].toString(),
                    Icons.favorite,
                    const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Événements',
                    _userData['eventsRegistered'].toString(),
                    Icons.event,
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          
          // Mes favoris
          _buildSection(
            'Mes favoris',
            _favoritePois.map((poi) => ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF3860F8).withOpacity(0.1),
                child: Text(poi['image']),
              ),
              title: Text(poi['name']),
              subtitle: Text(poi['region']),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite, color: Color(0xFFEF4444)),
              ),
            )).toList(),
          ),
          
          // Mes réservations
          _buildSection(
            'Mes réservations',
            _eventRegistrations.map((event) => ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF3860F8).withOpacity(0.1),
                child: Text(event['image']),
              ),
              title: Text(event['title']),
              subtitle: Text(event['date']),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: event['status'] == 'Confirmé'
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFF97316).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event['status'],
                  style: TextStyle(
                    color: event['status'] == 'Confirmé'
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF97316),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )).toList(),
          ),
          
          // Options
          _buildSection(
            'Paramètres',
            [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Langue'),
                subtitle: const Text('Français'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: const Color(0xFF3860F8),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Aide et support'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('À propos'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ],
          ),
          
          // Déconnexion
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoggedIn = false;
                  });
                },
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  void _simulateLogin() {
    setState(() {
      _isLoggedIn = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion réussie !'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }
}