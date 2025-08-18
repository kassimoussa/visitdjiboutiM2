import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<Map<String, dynamic>> _nearbyPois = [
    {
      'name': 'Marché Central',
      'distance': 2.1,
      'category': 'Culture',
      'image': '🏪',
    },
    {
      'name': 'Mosquée Hamoudi',
      'distance': 3.5,
      'category': 'Religion',
      'image': '🕌',
    },
    {
      'name': 'Port de Djibouti',
      'distance': 4.2,
      'category': 'Commerce',
      'image': '⚓',
    },
    {
      'name': 'Stade du Ville',
      'distance': 5.8,
      'category': 'Sport',
      'image': '🏟️',
    },
  ];

  bool _showNearbyList = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Stack(
        children: [
          // Placeholder pour la carte Google Maps
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF006B96).withOpacity(0.3),
                  const Color(0xFFE8D5A3).withOpacity(0.3),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Simulation d'une carte avec des points d'intérêt
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.map,
                              size: 64,
                              color: Color(0xFF3860F8),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Carte Interactive',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Google Maps sera intégrée ici\navec les POIs de Djibouti',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Simulation de markers POI
                Positioned(
                  top: 100,
                  left: 80,
                  child: _buildMapMarker('🏪', 'Marché Central'),
                ),
                Positioned(
                  top: 150,
                  right: 100,
                  child: _buildMapMarker('🕌', 'Mosquée Hamoudi'),
                ),
                Positioned(
                  bottom: 200,
                  left: 60,
                  child: _buildMapMarker('⚓', 'Port de Djibouti'),
                ),
                Positioned(
                  bottom: 180,
                  right: 80,
                  child: _buildMapMarker('🏟️', 'Stade du Ville'),
                ),
                Positioned(
                  top: 200,
                  left: MediaQuery.of(context).size.width / 2 - 15,
                  child: _buildMapMarker('📍', 'Ma position', isUserLocation: true),
                ),
              ],
            ),
          ),
          
          // Barre de recherche en overlay
          Positioned(
            top: isSmallScreen ? 12 : 16,
            left: isSmallScreen ? 12 : 16,
            right: isSmallScreen ? 60 : 80,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher sur la carte...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
          
          // Liste des POIs proches (conditionnelle)
          if (_showNearbyList)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.45 : 0.4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle pour drag
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Titre
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            'POIs à proximité',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showNearbyList = false;
                              });
                            },
                            child: const Text('Fermer'),
                          ),
                        ],
                      ),
                    ),
                    
                    // Liste
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _nearbyPois.length,
                        itemBuilder: (context, index) {
                          final poi = _nearbyPois[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF3860F8).withOpacity(0.1),
                              child: Text(
                                poi['image'],
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            title: Text(
                              poi['name'],
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(poi['category']),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${poi['distance']} km',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3860F8),
                                  ),
                                ),
                                const Icon(
                                  Icons.directions,
                                  size: 16,
                                  color: Color(0xFF3860F8),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Action pour centrer sur le POI
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Centrage sur ${poi['name']}'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        
          // Bouton toggle liste en top-right
          Positioned(
            top: isSmallScreen ? 12 : 16,
            right: isSmallScreen ? 12 : 16,
            child: FloatingActionButton.small(
              heroTag: 'toggle',
              onPressed: () {
                setState(() {
                  _showNearbyList = !_showNearbyList;
                });
              },
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3860F8),
              child: Icon(_showNearbyList ? Icons.map : Icons.list),
            ),
          ),
        ],
      );
  }

  Widget _buildMapMarker(String emoji, String label, {bool isUserLocation = false}) {
    return GestureDetector(
      onTap: () {
        _showPoiBottomSheet(label, emoji);
      },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isUserLocation 
                  ? const Color(0xFF10B981)
                  : const Color(0xFF3860F8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          if (!isUserLocation) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showPoiBottomSheet(String name, String emoji) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Point d\'intérêt à Djibouti',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Itinéraire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3860F8),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.info),
                    label: const Text('Détails'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}