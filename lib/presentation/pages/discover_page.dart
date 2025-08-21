import 'package:flutter/material.dart';
import '../../core/services/poi_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/models/poi.dart';
import '../../core/models/poi_list_response.dart';
import '../../core/models/api_response.dart';
import '../../core/models/category.dart';
import 'poi_detail_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final PoiService _poiService = PoiService();
  final FavoritesService _favoritesService = FavoritesService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Poi> _pois = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'Tous';
  int _currentPage = 1;
  bool _hasMorePages = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadPois();
  }

  Future<void> _loadPois({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMorePages || _isLoadingMore) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 1;
        _pois.clear();
      });
    }

    try {
      final ApiResponse<PoiListData> response = await _poiService.getPois(
        search: _searchController.text.isEmpty ? null : _searchController.text,
        categoryId: _selectedCategory == 'Tous' ? null : 
                   _categories.firstWhere((c) => c.name == _selectedCategory, 
                   orElse: () => const Category(id: -1, name: '', slug: '')).id,
        page: loadMore ? _currentPage + 1 : 1,
        perPage: 10,
      );

      if (response.isSuccess && response.hasData) {
        final poisData = response.data!;
        setState(() {
          if (loadMore) {
            _pois.addAll(poisData.pois);
            _currentPage++;
          } else {
            _pois = poisData.pois;
            _categories = [
              const Category(id: -1, name: 'Tous', slug: 'tous'),
              ...poisData.filters.categories
            ];
            _currentPage = poisData.pagination.currentPage;
          }
          _hasMorePages = poisData.pagination.hasNextPage;
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = response.message ?? 'Erreur lors du chargement';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = 'Une erreur inattendue s\'est produite';
      });
    }
  }

  Future<void> _refreshPois() async {
    await _loadPois();
  }

  void _onSearchChanged() {
    // Délai pour éviter trop de requêtes
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == _searchController.text) {
        _loadPois();
      }
    });
  }

  void _onCategoryChanged(String category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
      });
      _loadPois();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      children: [
        // Barre de recherche
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _onSearchChanged(),
            decoration: InputDecoration(
              hintText: 'Rechercher un lieu...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadPois();
                      },
                    )
                  : null,
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
        if (_categories.isNotEmpty)
          Container(
            height: isSmallScreen ? 45 : 50,
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category.name == _selectedCategory;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (_) => _onCategoryChanged(category.name),
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

        // Contenu principal
        Expanded(
          child: _buildContent(isSmallScreen),
        ),
      ],
    );
  }

  Widget _buildContent(bool isSmallScreen) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF3860F8),
            ),
            SizedBox(height: 16),
            Text('Chargement des points d\'intérêt...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPois,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3860F8),
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_pois.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun point d\'intérêt trouvé',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            if (_searchController.text.isNotEmpty || _selectedCategory != 'Tous')
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _selectedCategory = 'Tous';
                  _loadPois();
                },
                child: const Text('Effacer les filtres'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshPois,
      color: const Color(0xFF3860F8),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
        itemCount: _pois.length + (_hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _pois.length) {
            // Indicateur de chargement pour plus de données
            if (!_isLoadingMore) {
              // Déclencher le chargement automatiquement
              Future.microtask(() => _loadPois(loadMore: true));
            }
            return Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF3860F8),
                ),
              ),
            );
          }

          final poi = _pois[index];
          return _buildPoiCard(poi);
        },
      ),
    );
  }

  Widget _buildPoiCard(Poi poi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PoiDetailPage(poi: poi),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
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
                  child: poi.featuredImage != null && poi.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            poi.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.place,
                                  size: 60,
                                  color: Color(0xFF3860F8),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF3860F8),
                                ),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.place,
                            size: 60,
                            color: Color(0xFF3860F8),
                          ),
                        ),
                ),
                if (poi.isFeatured)
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
                          poi.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FutureBuilder<bool>(
                        future: _favoritesService.isFavorite(poi.id),
                        builder: (context, snapshot) {
                          final isFavorite = snapshot.data ?? false;
                          return IconButton(
                            onPressed: () async {
                              try {
                                final success = await _favoritesService.toggleFavorite(poi.id);
                                if (success && mounted) {
                                  setState(() {}); // Refresh pour mettre à jour l'UI
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isFavorite 
                                          ? '${poi.name} retiré des favoris' 
                                          : '${poi.name} ajouté aux favoris',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Erreur lors de la modification des favoris'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    poi.shortDescription,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Métadonnées
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      // Catégorie
                      if (poi.categories.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF009639).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            poi.primaryCategory,
                            style: const TextStyle(
                              color: Color(0xFF009639),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      // Région
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0072CE).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: Color(0xFF0072CE),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              poi.region,
                              style: const TextStyle(
                                color: Color(0xFF0072CE),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Favoris count
                      if (poi.favoritesCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.pink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite,
                                size: 12,
                                color: Colors.pink,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${poi.favoritesCount}',
                                style: const TextStyle(
                                  color: Colors.pink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}