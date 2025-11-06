import 'package:flutter/material.dart';
import '../../core/models/activity.dart';
import '../../core/services/activity_service.dart';
import '../widgets/simple_activity_card.dart';
import '../../core/models/simple_activity.dart';

class ActivitiesPage extends StatefulWidget {
  final bool showFeaturedOnly;

  const ActivitiesPage({super.key, this.showFeaturedOnly = false});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  final ActivityService _activityService = ActivityService();
  final TextEditingController _searchController = TextEditingController();

  List<Activity> _activities = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  // Filtres
  String? _selectedRegion;
  ActivityDifficulty? _selectedDifficulty;
  int? _minPrice;
  int? _maxPrice;
  bool? _hasSpots;

  final List<String> _regions = [
    'Djibouti',
    'Ali Sabieh',
    'Dikhil',
    'Tadjourah',
    'Obock',
    'Arta',
  ];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await _activityService.getActivities(
        search: _searchController.text.isEmpty ? null : _searchController.text,
        region: _selectedRegion,
        difficulty: _selectedDifficulty,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        hasSpots: _hasSpots,
        perPage: 50,
      );

      if (mounted) {
        setState(() {
          _activities = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[ACTIVITIES PAGE] Erreur: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFiltersSheet(),
    );
  }

  Widget _buildFiltersSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtres',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedRegion = null;
                            _selectedDifficulty = null;
                            _minPrice = null;
                            _maxPrice = null;
                            _hasSpots = null;
                          });
                          setState(() {
                            _selectedRegion = null;
                            _selectedDifficulty = null;
                            _minPrice = null;
                            _maxPrice = null;
                            _hasSpots = null;
                          });
                        },
                        child: const Text('Réinitialiser'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Région
                  const Text(
                    'Région',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _regions.map((region) {
                      final isSelected = _selectedRegion == region;
                      return FilterChip(
                        label: Text(region),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedRegion = selected ? region : null;
                          });
                          setState(() {
                            _selectedRegion = selected ? region : null;
                          });
                        },
                        selectedColor: const Color(0xFF3860F8).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF3860F8),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Difficulté
                  const Text(
                    'Difficulté',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ActivityDifficulty.values.map((difficulty) {
                      final isSelected = _selectedDifficulty == difficulty;
                      return FilterChip(
                        label: Text(difficulty.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedDifficulty = selected ? difficulty : null;
                          });
                          setState(() {
                            _selectedDifficulty = selected ? difficulty : null;
                          });
                        },
                        selectedColor: const Color(0xFF3860F8).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF3860F8),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Places disponibles
                  CheckboxListTile(
                    title: const Text('Seulement avec places disponibles'),
                    value: _hasSpots ?? false,
                    onChanged: (value) {
                      setModalState(() {
                        _hasSpots = value;
                      });
                      setState(() {
                        _hasSpots = value;
                      });
                    },
                    activeColor: const Color(0xFF3860F8),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 20),

                  // Bouton Appliquer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadActivities();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3860F8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Appliquer les filtres',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.showFeaturedOnly ? 'Activités populaires' : 'Activités',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3860F8),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3860F8),
                    ),
                  )
                : _hasError
                    ? _buildErrorWidget()
                    : _activities.isEmpty
                        ? _buildEmptyWidget()
                        : _buildActivitiesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une activité...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3860F8)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _loadActivities(),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _showFiltersBottomSheet,
                  icon: const Icon(Icons.tune, color: Colors.white),
                  tooltip: 'Filtres',
                ),
              ),
            ],
          ),
          if (_hasActiveFilters()) ...[
            const SizedBox(height: 12),
            _buildActiveFiltersChips(),
          ],
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedRegion != null ||
        _selectedDifficulty != null ||
        _minPrice != null ||
        _maxPrice != null ||
        (_hasSpots ?? false);
  }

  Widget _buildActiveFiltersChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_selectedRegion != null)
          Chip(
            label: Text(_selectedRegion!),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() {
                _selectedRegion = null;
              });
              _loadActivities();
            },
          ),
        if (_selectedDifficulty != null)
          Chip(
            label: Text(_selectedDifficulty!.label),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() {
                _selectedDifficulty = null;
              });
              _loadActivities();
            },
          ),
        if (_hasSpots ?? false)
          Chip(
            label: const Text('Places disponibles'),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() {
                _hasSpots = null;
              });
              _loadActivities();
            },
          ),
      ],
    );
  }

  Widget _buildActivitiesList() {
    return RefreshIndicator(
      onRefresh: _loadActivities,
      color: const Color(0xFF3860F8),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          // Convertir Activity en SimpleActivity pour utiliser SimpleActivityCard
          final simpleActivity = SimpleActivity(
            id: activity.id,
            slug: activity.slug,
            title: activity.title,
            shortDescription: activity.shortDescription,
            price: activity.price.toString(),
            formattedPrice: activity.displayPrice,
            currency: activity.currency,
            difficulty: activity.difficulty.name,
            difficultyLabel: activity.displayDifficulty,
            region: activity.region,
            durationFormatted: activity.displayDuration,
            availableSpots: activity.availableSpots,
            isFeatured: activity.isFeatured,
            weatherDependent: activity.weatherDependent,
            featuredImage: activity.featuredImage != null
                ? {
                    'url': activity.featuredImage!.url,
                    'thumbnail_url': activity.featuredImage!.thumbnailUrl ?? activity.featuredImage!.url,
                  }
                : null,
            tourOperator: activity.tourOperator != null
                ? {
                    'name': activity.tourOperator!.name,
                  }
                : null,
          );
          return SimpleActivityCard(activity: simpleActivity);
        },
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.kayaking,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune activité trouvée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _errorMessage ?? 'Une erreur est survenue',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadActivities,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Réessayer',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3860F8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
