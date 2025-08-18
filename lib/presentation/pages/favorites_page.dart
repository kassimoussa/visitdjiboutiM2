import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> _favoritePois = [
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
      'dateAdded': DateTime(2024, 1, 15),
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
      'dateAdded': DateTime(2024, 1, 20),
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
      'dateAdded': DateTime(2024, 2, 5),
    },
    {
      'id': 4,
      'name': 'Marché Central',
      'description': 'Marché traditionnel avec épices, artisanat et produits locaux',
      'region': 'Djibouti',
      'category': 'Culture',
      'rating': 4.0,
      'distance': 2.1,
      'image': '🏪',
      'isFeatured': false,
      'dateAdded': DateTime(2024, 2, 10),
    },
  ];

  String _sortBy = 'Récent';
  final List<String> _sortOptions = ['Récent', 'Alphabétique', 'Distance', 'Note'];

  @override
  Widget build(BuildContext context) {
    _sortFavorites();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _favoritePois.isEmpty
            ? _buildEmptyState()
            : _buildFavoritesList(),
      ),
    );
  }


  Widget _buildFavoritesList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _favoritePois.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final poi = _favoritePois[index];
        return _buildModernFavoriteCard(poi);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.favorite_outline,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Aucun favori',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Explorez Djibouti et ajoutez vos lieux\npréférés à votre collection',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3860F8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Découvrir des lieux',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFavoriteCard(Map<String, dynamic> poi) {
    final dateAdded = poi['dateAdded'] as DateTime;
    final formattedDate = '${dateAdded.day}/${dateAdded.month}/${dateAdded.year}';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showPoiDetails(poi),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF3860F8).withOpacity(0.1),
                        const Color(0xFF006B96).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      poi['image'],
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                if (poi['isFeatured'])
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3860F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Populaire',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => _removeFavorite(poi['id']),
                      icon: const Icon(
                        Icons.favorite,
                        color: Color(0xFFEF4444),
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    poi['description'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(poi['category'], Colors.green),
                      const SizedBox(width: 8),
                      _buildRatingChip(poi['rating']),
                      const Spacer(),
                      Text(
                        '${poi['distance']} km',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ajouté le $formattedDate',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRatingChip(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: Colors.amber,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toString(),
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _sortFavorites() {
    switch (_sortBy) {
      case 'Récent':
        _favoritePois.sort((a, b) => b['dateAdded'].compareTo(a['dateAdded']));
        break;
      case 'Alphabétique':
        _favoritePois.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case 'Distance':
        _favoritePois.sort((a, b) => a['distance'].compareTo(b['distance']));
        break;
      case 'Note':
        _favoritePois.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
    }
  }

  void _removeFavorite(int poiId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Supprimer des favoris',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          content: Text(
            'Voulez-vous vraiment supprimer ce lieu de vos favoris ?',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _favoritePois.removeWhere((poi) => poi['id'] == poiId);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Lieu supprimé des favoris'),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Supprimer',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPoiDetails(Map<String, dynamic> poi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3860F8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              poi['image'],
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                poi['name'],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                poi['region'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      poi['description'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildDetailChip('Catégorie', poi['category']),
                        const SizedBox(width: 12),
                        _buildDetailChip('Note', '${poi['rating']} ⭐'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailChip('Distance', '${poi['distance']} km'),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.directions_outlined),
                            label: const Text('Itinéraire'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Plus d\'infos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3860F8),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3860F8).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Color(0xFF3860F8),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

}