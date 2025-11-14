import 'package:flutter/material.dart';
import '../../core/models/tour.dart';
import '../../core/models/tour_operator.dart';
import '../../core/services/tour_service.dart';
import '../../core/services/tour_operator_service.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/tour_card.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/responsive.dart';

class ToursPage extends StatefulWidget {
  final int? operatorId;
  final bool showFeaturedOnly;

  const ToursPage({
    super.key,
    this.operatorId,
    this.showFeaturedOnly = false,
  });

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
        _errorMessage = AppLocalizations.of(context)!.commonErrorLoading;
      });
      print('[TOURS PAGE] Erreur: $e');
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
        // Ne pas filtrer par 'featured' dans l'API - juste récupérer tous les tours
        // Le filtre 'showFeaturedOnly' est géré par le widget.showFeaturedOnly mais pas envoyé à l'API
        page: _currentPage,
        perPage: 20,
      );

      print('[TOURS PAGE] Tours reçus: ${response.data.tours.length}');

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
      print('[TOURS PAGE] Erreur chargement: $e');
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
      if (widget.operatorId == null) {
        _selectedOperatorId = null;
      }
      _searchController.clear();
    });
    _applyFilters();
  }

  List<Tour> get _filteredTours {
    if (_searchController.text.isEmpty) return _tours;
    return _tours.where((tour) =>
      tour.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
      (tour.tourOperator?.name.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showFeaturedOnly
          ? AppLocalizations.of(context)!.homeFeaturedTours
          : 'Tours'),
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
    return Padding(
      padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.toursSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildActiveFilters() {
    final hasFilters = _selectedType != null ||
        _selectedDifficulty != null ||
        (_selectedOperatorId != null && widget.operatorId == null);

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
                if (_selectedOperatorId != null && widget.operatorId == null)
                  _buildFilterChip(
                    _operators.firstWhere((op) => op.id == _selectedOperatorId).name,
                    () {
                      setState(() => _selectedOperatorId = null);
                      _applyFilters();
                    }
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: _resetFilters,
            child: Text(AppLocalizations.of(context)!.commonClearAll),
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
      padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: ResponsiveConstants.mediumSpace),
        child: const ShimmerLoading(
          child: Card(
            child: SizedBox(height: 200),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          SizedBox(height: ResponsiveConstants.mediumSpace),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: ResponsiveConstants.mediumSpace),
          ElevatedButton(
            onPressed: _loadInitialData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3860F8),
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.commonRetry),
          ),
        ],
      ),
    );
  }

  Widget _buildToursList() {
    if (_filteredTours.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tour, size: 64, color: Colors.grey[400]),
            SizedBox(height: ResponsiveConstants.mediumSpace),
            Text(
              _searchController.text.isEmpty
                  ? AppLocalizations.of(context)!.homeNoFeaturedTours
                  : AppLocalizations.of(context)!.toursNotFound(_searchController.text),
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshTours,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
        itemCount: _filteredTours.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredTours.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Color(0xFF3860F8)),
              ),
            );
          }

          final tour = _filteredTours[index];
          return Padding(
            padding: EdgeInsets.only(bottom: ResponsiveConstants.mediumSpace),
            child: TourCard(tour: tour),
          );
        },
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
                        Text(
                          AppLocalizations.of(context)!.commonFilters,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            _resetFilters();
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)!.commonReset),
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
                            AppLocalizations.of(context)!.toursTourType,
                            DropdownButton<TourType?>(
                              isExpanded: true,
                              value: _selectedType,
                              hint: Text(AppLocalizations.of(context)!.toursSelectType),
                              items: [
                                DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context)!.commonAll)),
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
                            AppLocalizations.of(context)!.toursDifficulty,
                            DropdownButton<TourDifficulty?>(
                              isExpanded: true,
                              value: _selectedDifficulty,
                              hint: Text(AppLocalizations.of(context)!.toursSelectDifficulty),
                              items: [
                                DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context)!.commonAllFeminine)),
                                ...TourDifficulty.values.map((difficulty) => DropdownMenuItem(
                                  value: difficulty,
                                  child: Text('${difficulty.icon} ${difficulty.label}'),
                                )),
                              ],
                              onChanged: (value) => setModalState(() => _selectedDifficulty = value),
                            ),
                          ),

                          // Opérateur (seulement si pas de opérateur pré-sélectionné)
                          if (widget.operatorId == null && _operators.isNotEmpty)
                            _buildFilterSection(
                              AppLocalizations.of(context)!.toursTourOperator,
                              DropdownButton<int?>(
                                isExpanded: true,
                                value: _selectedOperatorId,
                                hint: Text(AppLocalizations.of(context)!.toursSelectOperator),
                                items: [
                                  DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context)!.commonAll)),
                                  ..._operators.map((operator) => DropdownMenuItem(
                                    value: operator.id,
                                    child: Text(operator.name),
                                  )),
                                ],
                                onChanged: (value) => setModalState(() => _selectedOperatorId = value),
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
                        child: Text(AppLocalizations.of(context)!.commonApplyFilters),
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
