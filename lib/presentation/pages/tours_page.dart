import 'package:flutter/material.dart';
import '../../core/models/tour.dart';
import '../../core/models/tour_operator.dart';
import '../../core/services/tour_service.dart';
import '../../core/services/tour_operator_service.dart';
import '../../generated/l10n/app_localizations.dart';
import '../widgets/shimmer_loading.dart';
import 'tour_detail_page.dart';

class ToursPage extends StatefulWidget {
  final int? operatorId;

  const ToursPage({super.key, this.operatorId});

  @override
  State<ToursPage> createState() => _ToursPageState();
}

class _ToursPageState extends State<ToursPage> {
  final TourService _tourService = TourService();
  final TourOperatorService _tourOperatorService = TourOperatorService();
  final TextEditingController _searchController = TextEditingController();

  List<Tour> _tours = [];
  List<TourOperator> _operators = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Filtres
  TourType? _selectedType;
  TourDifficulty? _selectedDifficulty;
  int? _selectedOperatorId;
  RangeValues? _priceRange;
  int? _maxDuration;
  bool _showFeaturedOnly = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedOperatorId = widget.operatorId;
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
        !_isLoadingMore && _hasMoreData) {
      _loadMoreTours();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger opérateurs pour les filtres
      final operatorsResponse = await _tourOperatorService.getTourOperators();
      _operators = operatorsResponse.data ?? [];

      // Charger tours
      await _loadTours(reset: true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTours({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _tours.clear();
      _hasMoreData = true;
    }

    try {
      final response = await _tourService.getTours(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        type: _selectedType,
        difficulty: _selectedDifficulty,
        operatorId: _selectedOperatorId,
        minPrice: _priceRange?.start.toInt(),
        maxPrice: _priceRange?.end.toInt(),
        maxDurationHours: _maxDuration,
        featured: _showFeaturedOnly ? true : null,
        page: _currentPage,
      );

      setState(() {
        if (reset) {
          _tours = response.data.tours;
        } else {
          _tours.addAll(response.data.tours);
        }

        _hasMoreData = _currentPage < (response.data.pagination?.lastPage ?? 1);
        _currentPage++;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: $e';
      });
    }
  }

  Future<void> _loadMoreTours() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _loadTours();

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshTours() async {
    await _loadTours(reset: true);
  }

  void _applyFilters() {
    _loadTours(reset: true);
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _selectedDifficulty = null;
      _selectedOperatorId = null;
      _priceRange = null;
      _maxDuration = null;
      _showFeaturedOnly = false;
      _searchController.clear();
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tours'),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildActiveFilters(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _buildToursList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un tour...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onSubmitted: (_) => _applyFilters(),
      ),
    );
  }

  Widget _buildActiveFilters() {
    final hasFilters = _selectedType != null ||
        _selectedDifficulty != null ||
        _selectedOperatorId != null ||
        _priceRange != null ||
        _maxDuration != null ||
        _showFeaturedOnly;

    if (!hasFilters) return const SizedBox.shrink();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (_selectedType != null)
                  _buildFilterChip(_selectedType!.label, () {
                    setState(() => _selectedType = null);
                    _applyFilters();
                  }),
                if (_selectedDifficulty != null)
                  _buildFilterChip(_selectedDifficulty!.label, () {
                    setState(() => _selectedDifficulty = null);
                    _applyFilters();
                  }),
                if (_selectedOperatorId != null)
                  _buildFilterChip(
                    _operators.firstWhere((op) => op.id == _selectedOperatorId).name,
                    () {
                      setState(() => _selectedOperatorId = null);
                      _applyFilters();
                    }
                  ),
                if (_showFeaturedOnly)
                  _buildFilterChip('Vedettes', () {
                    setState(() => _showFeaturedOnly = false);
                    _applyFilters();
                  }),
              ],
            ),
          ),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Tout effacer'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: onRemove,
        deleteIcon: const Icon(Icons.close, size: 16),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => const ShimmerLoading(
        child: Card(
          child: SizedBox(height: 200),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildToursList() {
    if (_tours.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tour, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun tour trouvé',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Essayez de modifier vos critères de recherche',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshTours,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _tours.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _tours.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return _buildTourCard(_tours[index]);
        },
      ),
    );
  }

  Widget _buildTourCard(Tour tour) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToTourDetail(tour),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du tour
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: tour.featuredImage?.url != null
                  ? Image.network(
                      tour.featuredImage!.url,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.tour, size: 64, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.tour, size: 64, color: Colors.grey),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags et badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3860F8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${tour.type.icon} ${tour.displayType}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3860F8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${tour.difficulty.icon} ${tour.displayDifficulty}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (tour.isFeatured) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '⭐ Vedette',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Titre
                  Text(
                    tour.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description courte
                  if (tour.shortDescription != null)
                    Text(
                      tour.shortDescription!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Informations pratiques
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        tour.displayDuration,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      if (tour.tourOperator != null) ...[
                        const SizedBox(width: 16),
                        Icon(Icons.business, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tour.tourOperator!.name,
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Prix et rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tour.displayPrice,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3860F8),
                        ),
                      ),
                      if (tour.averageRating != null && tour.reviewsCount != null)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${tour.averageRating!.toStringAsFixed(1)} (${tour.reviewsCount})',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
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

  void _navigateToTourDetail(Tour tour) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TourDetailPage(tour: tour),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filtres',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            _resetFilters();
                            Navigator.pop(context);
                          },
                          child: const Text('Réinitialiser'),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          // Type de tour
                          _buildFilterSection(
                            'Type de tour',
                            DropdownButton<TourType?>(
                              isExpanded: true,
                              value: _selectedType,
                              hint: const Text('Sélectionner un type'),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Tous')),
                                ...TourType.values.map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text('${type.icon} ${type.label}'),
                                )),
                              ],
                              onChanged: (value) => setModalState(() => _selectedType = value),
                            ),
                          ),

                          // Difficulté
                          _buildFilterSection(
                            'Difficulté',
                            DropdownButton<TourDifficulty?>(
                              isExpanded: true,
                              value: _selectedDifficulty,
                              hint: const Text('Sélectionner une difficulté'),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Toutes')),
                                ...TourDifficulty.values.map((difficulty) => DropdownMenuItem(
                                  value: difficulty,
                                  child: Text('${difficulty.icon} ${difficulty.label}'),
                                )),
                              ],
                              onChanged: (value) => setModalState(() => _selectedDifficulty = value),
                            ),
                          ),

                          // Opérateur
                          if (_operators.isNotEmpty)
                            _buildFilterSection(
                              'Opérateur de tour',
                              DropdownButton<int?>(
                                isExpanded: true,
                                value: _selectedOperatorId,
                                hint: const Text('Sélectionner un opérateur'),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('Tous')),
                                  ..._operators.map((operator) => DropdownMenuItem(
                                    value: operator.id,
                                    child: Text(operator.name),
                                  )),
                                ],
                                onChanged: (value) => setModalState(() => _selectedOperatorId = value),
                              ),
                            ),

                          // Tours vedettes
                          _buildFilterSection(
                            'Tours vedettes',
                            SwitchListTile(
                              title: const Text('Afficher uniquement les tours vedettes'),
                              value: _showFeaturedOnly,
                              onChanged: (value) => setModalState(() => _showFeaturedOnly = value),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _applyFilters();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3860F8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Appliquer les filtres'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 20),
      ],
    );
  }
}