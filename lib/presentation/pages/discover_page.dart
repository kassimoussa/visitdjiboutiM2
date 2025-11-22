import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../../core/services/poi_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/localization_service.dart';
import '../../core/models/poi.dart';
import '../../core/models/poi_list_response.dart';
import '../../core/models/api_response.dart';
import '../../core/models/category.dart';
import '../widgets/poi_card.dart';
import '../../generated/l10n/app_localizations.dart';
import 'region_list_page.dart';
import '../../core/utils/retry_helper.dart';
import '../widgets/error_state_widget.dart'; 
class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final PoiService _poiService = PoiService();
  final FavoritesService _favoritesService = FavoritesService();
  final CacheService _cacheService = CacheService();
  final LocalizationService _localizationService = LocalizationService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Poi> _allPois = [];  // Tous les POIs chargés
  List<Poi> _filteredPois = [];  // POIs après filtrage local
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  Category? _selectedCategory;
  String _currentSearchQuery = '';
  int _currentPage = 1;
  bool _hasMorePages = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    
    // Écouter les changements de langue
    _localizationService.addListener(_onLanguageChanged);
    
    // Vider le cache POI au démarrage pour forcer le rechargement
    _cacheService.clearPoiCache().then((_) => _loadAllPois());
  }

  void _onLanguageChanged() {
    // Recharger les données quand la langue change
    print('[DISCOVER PAGE] Langue changée - Rechargement forcé des données');
    
    // Vider le cache et recharger
    _cacheService.clearPoiCache();
    _resetPagination();
    _loadAllPoisForced();
  }

  // Charge tous les POIs une seule fois depuis l'API
  Future<void> _loadAllPois({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMorePages || _isLoadingMore) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 1;
        _allPois.clear();
        _filteredPois.clear();
      });
    }

    try {
      final ApiResponse<PoiListData> response = await RetryHelper.apiCall(
        apiRequest: () => _poiService.getPois(
          page: loadMore ? _currentPage + 1 : 1,
          perPage: 100,
          useCache: true,
        ),
        maxAttempts: 3,
        operationName: "Chargement POIs DiscoverPage${loadMore ? ' (load more)' : ''}",
      );

      print('[DISCOVER PAGE] Réponse API reçue - success: ${response.isSuccess}, hasData: ${response.hasData}');

      if (response.isSuccess && response.hasData) {
        final poisData = response.data!;
        print('[DISCOVER PAGE] Nombre de POIs reçus: ${poisData.pois.length}');

        setState(() {
          if (loadMore) {
            _allPois.addAll(poisData.pois);
            _currentPage++;
          } else {
            _allPois = poisData.pois;
            // Créer des catégories avec hiérarchie pour l'écran Découvrir
            _categories = _buildCategoriesHierarchy(poisData.filters.categories);
            _currentPage = poisData.pagination.currentPage;
          }
          _hasMorePages = poisData.pagination.hasNextPage;
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = null;
        });

        // Appliquer les filtres actuels après le chargement
        _applyFilters();
      } else {
        throw Exception(response.message ?? 'Erreur de chargement POIs');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = RetryHelper.getErrorMessage(e);
        });

        // Afficher une snackbar seulement si ce n'est pas un load more
        if (!loadMore) {
          ErrorSnackBar.show(
            context,
            title: 'Erreur de chargement',
            message: RetryHelper.getErrorMessage(e),
            onRetry: _loadAllPois,
          );
        }
      }
    }
  }

  /// Remet à zéro la pagination
  void _resetPagination() {
    _currentPage = 1;
    _hasMorePages = true;
    _allPois.clear();
    _filteredPois.clear();
  }

  /// Version forcée qui bypass le cache pour les changements de langue
  Future<void> _loadAllPoisForced() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final ApiResponse<PoiListData> response = await RetryHelper.apiCall(
        apiRequest: () => _poiService.getPois(
          perPage: 50,
          page: 1,
          useCache: false,
        ),
        maxAttempts: 3,
        operationName: "Rechargement POIs forcé DiscoverPage (changement langue)",
      );

      if (response.isSuccess && response.hasData) {
        final poisData = response.data!;

        if (mounted) {
          setState(() {
            _allPois = poisData.pois;
            _categories = _buildCategoriesHierarchy(poisData.filters.categories);
            _currentPage = poisData.pagination.currentPage + 1;
            _hasMorePages = poisData.pagination.hasNextPage;
            _isLoading = false;
            _errorMessage = null;
          });

          print('[DISCOVER PAGE] POIs rechargés: ${_allPois.length} items (langue: ${_localizationService.currentLanguageCode})');

          // Appliquer les filtres après le rechargement
          _applyFilters();
        }
      } else {
        throw Exception(response.message ?? 'Erreur rechargement POIs');
      }
    } catch (e) {
      print('[DISCOVER PAGE] Erreur rechargement forcé: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = RetryHelper.getErrorMessage(e);
        });

        ErrorSnackBar.show(
          context,
          title: 'Erreur rechargement',
          message: RetryHelper.getErrorMessage(e),
          onRetry: _loadAllPoisForced,
        );
      }
    }
  }

  // Applique les filtres localement sans recharger depuis l'API
  void _applyFilters() {
    List<Poi> filtered = List.from(_allPois);
    
    // Filtrage par recherche textuelle
    if (_currentSearchQuery.isNotEmpty) {
      final searchQuery = _currentSearchQuery.toLowerCase();
      filtered = filtered.where((poi) {
        return poi.name.toLowerCase().contains(searchQuery) ||
               (poi.description?.toLowerCase().contains(searchQuery) ?? false) ||
               poi.primaryCategory.toLowerCase().contains(searchQuery);
      }).toList();
    }
    
    // Filtrage par catégorie
    if (_selectedCategory != null) {
      filtered = filtered.where((poi) {
        if (_selectedCategory!.isParentCategory) {
          // Si c'est une catégorie parente, inclure toutes ses sous-catégories
          final childIds = _selectedCategory!.subCategories
              ?.map((sub) => sub.id)
              .toList() ?? [];
          
          return poi.categories.any((poiCategory) => 
            poiCategory.id == _selectedCategory!.id || 
            childIds.contains(poiCategory.id)
          );
        } else {
          // Si c'est une sous-catégorie, filtrer exactement
          return poi.categories.any((poiCategory) => poiCategory.id == _selectedCategory!.id);
        }
      }).toList();
    }
    
    setState(() {
      _filteredPois = filtered;
    });
    
    print('[DISCOVER] Filtres appliqués: ${_filteredPois.length}/${_allPois.length} POIs');
  }

  Future<void> _refreshPois() async {
    await _loadAllPois();
  }

  void _onSearchChanged() {
    // Délai pour éviter trop de filtrage
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text == _currentSearchQuery) return;
      
      setState(() {
        _currentSearchQuery = _searchController.text;
      });
      _applyFilters();
    });
  }

  void _onCategoryChanged(Category? category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
      });
      _applyFilters();
    }
  }
  
  // Construit une hiérarchie de catégories avec les données reçues de l'API
  List<Category> _buildCategoriesHierarchy(List<Category> flatCategories) {
    print('[DISCOVER] Nombre de catégories reçues: ${flatCategories.length}');
    
    // Séparer les catégories parentes (level 0 ou IDs spécifiques) et enfants
    final parentCategories = <Category>[];
    final childCategories = <Category>[];
    
    for (final category in flatCategories) {
      print('[DISCOVER] Catégorie: ${category.name} (ID: ${category.id}, Level: ${category.level}, ParentId: ${category.parentId})');
      
      if (category.isParentCategory) {
        parentCategories.add(category);
      } else {
        childCategories.add(category);
      }
    }
    
    // Construire la hiérarchie : associer les enfants à leurs parents
    final categoriesWithChildren = <Category>[];
    
    for (final parent in parentCategories) {
      // Trouver tous les enfants de cette catégorie parente
      final children = childCategories
          .where((child) => child.parentId == parent.id)
          .toList();
      
      if (children.isNotEmpty) {
        // Créer une nouvelle catégorie avec ses sous-catégories
        final categoryWithChildren = Category(
          id: parent.id,
          name: parent.name,
          slug: parent.slug,
          description: parent.description,
          color: parent.color,
          icon: parent.icon,
          parentId: parent.parentId,
          level: parent.level,
          subCategories: children,
        );
        categoriesWithChildren.add(categoryWithChildren);
      } else {
        // Ajouter la catégorie parente sans enfants
        categoriesWithChildren.add(parent);
      }
    }
    
    print('[DISCOVER] Catégories parentes trouvées: ${categoriesWithChildren.length}');
    for (final cat in categoriesWithChildren) {
      print('[DISCOVER] Parent: ${cat.name} avec ${cat.subCategories?.length ?? 0} enfants');
    }
    
    return categoriesWithChildren;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      children: [
        _buildSearchAndFilters(),
        if (_selectedCategory != null) ...[
          SizedBox(height: 8.h),
          _buildActiveFiltersChips(),
        ],
        SizedBox(height: ResponsiveConstants.smallSpace),

        // Bouton Explorer par région
        Container(
          margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mediumSpace),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegionListPage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3860F8), Color(0xFF0072CE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ResponsiveConstants.smallSpace),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: const Icon(
                        Icons.map,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: ResponsiveConstants.mediumSpace),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explorer par région',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Découvrez le contenu par région de Djibouti',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: ResponsiveConstants.smallSpace),

        // Contenu principal
        Expanded(
          child: _buildContent(isSmallScreen),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: Responsive.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.discoverSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF3860F8)),
                ),
                contentPadding: Responsive.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _applyFilters(),
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              onPressed: _showFiltersBottomSheet,
              icon: const Icon(Icons.tune, color: Colors.white),
              tooltip: 'Filtres',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    return Container(
      padding: Responsive.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_selectedCategory != null)
            Chip(
              label: Text(_selectedCategory!.name),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _selectedCategory = null;
                });
                _applyFilters();
              },
            ),
        ],
      ),
    );
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => _buildFiltersSheet(),
    );
  }

  Widget _buildFiltersSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: Responsive.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: Responsive.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtres',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedCategory = null;
                          });
                          setState(() {
                            _selectedCategory = null;
                          });
                        },
                        child: Text(AppLocalizations.of(context)!.commonReset),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Catégories
                  if (_categories.isNotEmpty) ...[
                    Text(
                      'Catégorie',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory?.id == category.id;
                        return FilterChip(
                          label: Text(category.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setModalState(() {
                              _selectedCategory = selected ? category : null;
                            });
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          },
                          selectedColor: const Color(0xFF3860F8).withOpacity(0.2),
                          checkmarkColor: const Color(0xFF3860F8),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20.h),
                  ],

                  // Bouton Appliquer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applyFilters();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3860F8),
                        padding: Responsive.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.commonApplyFilters,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryBadge({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? const Color(0xFF3860F8)) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isSmallScreen) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF3860F8),
            ),
            SizedBox(height: ResponsiveConstants.mediumSpace),
            Text(AppLocalizations.of(context)!.commonLoading),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return ErrorStateWidget.loading(
        resourceName: "points d'intérêt",
        errorDetails: _errorMessage,
        onRetry: _loadAllPois,
      );
    }

    if (_filteredPois.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: ResponsiveConstants.mediumSpace),
            Text(
              _allPois.isEmpty 
                ? 'Aucun point d\'intérêt disponible'
                : 'Aucun résultat pour ces filtres',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16.sp,
              ),
            ),
            if (_searchController.text.isNotEmpty || _selectedCategory != null)
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedCategory = null;
                    _currentSearchQuery = '';
                  });
                  _applyFilters();
                },
                child: Text(AppLocalizations.of(context)!.commonClearAll),
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
        itemCount: _filteredPois.length + (_hasMorePages && _filteredPois.length == _allPois.length ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _filteredPois.length) {
            // Indicateur de chargement pour plus de données seulement si on affiche tous les POIs
            if (!_isLoadingMore && _filteredPois.length == _allPois.length) {
              // Déclencher le chargement automatiquement
              Future.microtask(() => _loadAllPois(loadMore: true));
            }
            return Container(
              padding: Responsive.all(16),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF3860F8),
                ),
              ),
            );
          }

          final poi = _filteredPois[index];
          return PoiCard(poi: poi);
        },
      ),
    );
  }

  Widget _buildCategoryBadge({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    Color? color,
  }) {
    return Padding(
      padding: Responsive.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : (color ?? const Color(0xFF3860F8)),
              ),
              SizedBox(width: 6.w),
            ],
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey[100],
        selectedColor: color ?? const Color(0xFF3860F8),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14.sp,
        ),
        padding: Responsive.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(
            color: isSelected ? (color ?? const Color(0xFF3860F8)) : Colors.grey[300]!,
            width: 1.w,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) return Icons.category;

    switch (iconName.toLowerCase()) {
      case 'restaurant':
      case 'dining':
        return Icons.restaurant;
      case 'hotel':
      case 'accommodation':
        return Icons.hotel;
      case 'beach':
      case 'plage':
        return Icons.beach_access;
      case 'mountain':
      case 'montagne':
        return Icons.terrain;
      case 'museum':
      case 'musée':
        return Icons.museum;
      case 'shopping':
      case 'magasin':
        return Icons.shopping_bag;
      case 'park':
      case 'parc':
        return Icons.park;
      case 'entertainment':
      case 'divertissement':
        return Icons.celebration;
      case 'sport':
        return Icons.sports;
      case 'nature':
        return Icons.nature;
      case 'culture':
        return Icons.palette;
      case 'history':
      case 'histoire':
        return Icons.history_edu;
      case 'adventure':
      case 'aventure':
        return Icons.explore;
      case 'wildlife':
      case 'faune':
        return Icons.pets;
      case 'religious':
      case 'religieux':
        return Icons.place;
      default:
        return Icons.category;
    }
  }

  @override
  void dispose() {
    _localizationService.removeListener(_onLanguageChanged);
    _searchController.dispose();
    super.dispose();
  }
}