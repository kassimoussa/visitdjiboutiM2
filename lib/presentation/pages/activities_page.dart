import 'dart:async';
import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/models/activity.dart';
import '../../core/services/activity_service.dart';
import '../widgets/simple_activity_card.dart';
import '../../core/models/simple_activity.dart';
import '../../../core/utils/responsive.dart';

class ActivitiesPage extends StatefulWidget {
  final bool showFeaturedOnly;

  const ActivitiesPage({super.key, this.showFeaturedOnly = false});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  final ActivityService _activityService = ActivityService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Activity> _activities = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _isSearching = false;

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
    _debounce?.cancel();
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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadActivities();
    });
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
                        child: Text(AppLocalizations.of(context)!.commonReset),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Région
                  Text(
                    'Région',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10.h),
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
                        selectedColor: const Color(0xFF3860F8).withValues(alpha: 0.2),
                        checkmarkColor: const Color(0xFF3860F8),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.h),

                  // Difficulté
                  Text(
                    'Difficulté',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10.h),
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
                        selectedColor: const Color(0xFF3860F8).withValues(alpha: 0.2),
                        checkmarkColor: const Color(0xFF3860F8),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.h),

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
                  SizedBox(height: 20.h),

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
                        padding: Responsive.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Appliquer les filtres',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Rechercher une activité...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              )
            : Text(
                widget.showFeaturedOnly ? 'Activités populaires' : 'Activités',
                style: const TextStyle(color: Colors.white),
              ),
        backgroundColor: const Color(0xFF3860F8),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.arrow_back),
          onPressed: () {
            if (_isSearching) {
              setState(() {
                _isSearching = false;
                _searchController.clear();
                _loadActivities();
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          IconButton(
            onPressed: _showFiltersBottomSheet,
            icon: const Icon(Icons.tune, color: Colors.white),
            tooltip: 'Filtres',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_hasActiveFilters()) ...[
            SizedBox(height: 12.h),
            _buildActiveFiltersChips(),
          ],
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3860F8)),
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

  bool _hasActiveFilters() {
    return _selectedRegion != null ||
        _selectedDifficulty != null ||
        _minPrice != null ||
        _maxPrice != null ||
        (_hasSpots ?? false);
  }

  Widget _buildActiveFiltersChips() {
    return Container(
      padding: Responsive.symmetric(horizontal: 16),
      width: double.infinity,
      child: Wrap(
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
      ),
    );
  }

  Widget _buildActivitiesList() {
    return RefreshIndicator(
      onRefresh: _loadActivities,
      color: const Color(0xFF3860F8),
      child: ListView.builder(
        padding: Responsive.all(16),
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
                    'thumbnail_url':
                        activity.featuredImage!.thumbnailUrl ??
                        activity.featuredImage!.url,
                  }
                : null,
            tourOperator: activity.tourOperator != null
                ? {'name': activity.tourOperator!.name}
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
          Icon(Icons.kayaking, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'Aucune activité trouvée',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Essayez de modifier vos filtres',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
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
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          SizedBox(height: 16.h),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: Responsive.symmetric(horizontal: 40),
            child: Text(
              _errorMessage ?? 'Une erreur est survenue',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: _loadActivities,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Réessayer',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3860F8),
              padding: Responsive.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
