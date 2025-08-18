import 'package:flutter/material.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final List<Map<String, dynamic>> _pois = [
    {
      'id': 1,
      'name': 'Lac Assal',
      'description': 'Le point le plus bas d\'Afrique et l\'un des lacs les plus salés au monde',
      'region': 'Tadjourah',
      'category': 'Nature',
      'rating': 4.8,
      'distance': 120.5,
      'image': '🏔️',
      'isFeatured': true,
    },
    {
      'id': 2,
      'name': 'Îles Moucha et Maskali',
      'description': 'Paradis tropical avec récifs coralliens et plages de sable blanc',
      'region': 'Djibouti',
      'category': 'Plage',
      'rating': 4.6,
      'distance': 7.2,
      'image': '🏖️',
      'isFeatured': true,
    },
    {
      'id': 3,
      'name': 'Forêt du Day',
      'description': 'Forêt primaire unique en son genre dans la Corne de l\'Afrique',
      'region': 'Tadjourah',
      'category': 'Nature',
      'rating': 4.3,
      'distance': 35.8,
      'image': '🌲',
      'isFeatured': false,
    },
    {
      'id': 4,
      'name': 'Goubbet al-Kharab',
      'description': 'Baie mystérieuse avec activité volcanique sous-marine',
      'region': 'Tadjourah',
      'category': 'Géologie',
      'rating': 4.1,
      'distance': 95.3,
      'image': '🌋',
      'isFeatured': false,
    },
    {
      'id': 5,
      'name': 'Plage de Khor Ambado',
      'description': 'Magnifique plage avec mangroves et oiseaux migrateurs',
      'region': 'Tadjourah',
      'category': 'Plage',
      'rating': 4.4,
      'distance': 45.7,
      'image': '🦩',
      'isFeatured': false,
    },
    {
      'id': 6,
      'name': 'Marché Central',
      'description': 'Marché traditionnel avec épices, artisanat et produits locaux',
      'region': 'Djibouti',
      'category': 'Culture',
      'rating': 4.0,
      'distance': 2.1,
      'image': '🏪',
      'isFeatured': false,
    },
  ];

  String _selectedCategory = 'Tous';
  final List<String> _categories = ['Tous', 'Nature', 'Plage', 'Culture', 'Géologie'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    final filteredPois = _selectedCategory == 'Tous' 
        ? _pois 
        : _pois.where((poi) => poi['category'] == _selectedCategory).toList();

    return Column(
        children: [
          // Barre de recherche
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un lieu...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          
          // Filtres par catégorie
          Container(
            height: isSmallScreen ? 45 : 50,
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFF3860F8),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Liste des POIs
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
              itemCount: filteredPois.length,
              itemBuilder: (context, index) {
                final poi = filteredPois[index];
                return _buildPoiCard(poi);
              },
            ),
          ),
        ],
      );
  }

  Widget _buildPoiCard(Map<String, dynamic> poi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image avec badge featured
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8D5A3),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    poi['image'],
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
              if (poi['isFeatured'])
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3860F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Populaire',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre et favori
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        poi['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Description
                Text(
                  poi['description'],
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Métadonnées
                Row(
                  children: [
                    // Catégorie
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF009639).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        poi['category'],
                        style: const TextStyle(
                          color: Color(0xFF009639),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Note
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      poi['rating'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Distance
                    Icon(
                      Icons.location_on,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${poi['distance']} km',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}