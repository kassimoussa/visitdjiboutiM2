import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/event_service.dart';
import '../../core/services/conversion_trigger_service.dart';
import '../../core/models/poi.dart';
import '../../core/models/event.dart';
import '../../core/models/tour.dart';
import '../../core/models/activity.dart';
import 'poi_detail_page.dart';
import 'event_detail_page.dart';
import '../../generated/l10n/app_localizations.dart';
import '../widgets/poi_card.dart';
import '../widgets/event_card.dart';
import '../widgets/tour_card.dart';
import '../widgets/activity_card.dart';
import '../../core/utils/responsive.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesService _favoritesService = FavoritesService();
  final EventService _eventService = EventService();
  final ConversionTriggerService _conversionService =
      ConversionTriggerService();

  late StreamSubscription _favoritesSubscription;

  List<Poi> _favoritePois = [];
  List<Event> _favoriteEvents = [];
  List<Tour> _favoriteTours = [];
  List<Activity> _favoriteActivities = [];
  bool _isLoading = true;
  String _selectedTab = 'all'; // all, pois, events, tours, activities
  String _sortBy = 'recent';
  final List<String> _sortOptions = ['recent', 'alphabetical'];

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _syncAndLoadFavorites();
    _favoritesSubscription = _favoritesService.favoritesStream.listen((_) {
      _loadFavorites();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _conversionService.checkAndShowConversionTrigger(context);
    });
  }

  /// Synchronise les favoris depuis l'API puis les charge
  Future<void> _syncAndLoadFavorites() async {
    // Sync depuis l'API en premier
    await _favoritesService.syncFromAPI();
    // Puis charge les favoris locaux
    await _loadFavorites();
  }

  @override
  void dispose() {
    _favoritesSubscription.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      final pois = await _favoritesService.getFavoritePois();
      final events = await _favoritesService.getFavoriteEvents();
      final tours = await _favoritesService.getFavoriteTours();
      final activities = await _favoritesService.getFavoriteActivities();

      if (mounted) {
        setState(() {
          _favoritePois = pois;
          _favoriteEvents = events;
          _favoriteTours = tours;
          _favoriteActivities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des favoris: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getTabLabel(String tab) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return tab; // Fallback
    switch (tab) {
      case 'all':
        return l10n.favoritesAllTab;
      case 'pois':
        return l10n.favoritesPoisTab;
      case 'events':
        return l10n.favoritesEventsTab;
      case 'tours':
        return l10n.favoritesToursTab;
      case 'activities':
        return l10n.favoritesActivitiesTab;
      default:
        return tab;
    }
  }

  String _getSortLabel(String sort) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return sort; // Fallback
    switch (sort) {
      case 'recent':
        return l10n.favoritesSortRecent;
      case 'alphabetical':
        return l10n.favoritesSortAlphabetical;
      default:
        return sort;
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        // backgroundColor: Colors.grey[50], // Removed to use theme color
        elevation: 0,
        centerTitle: true, // Changed to true to match theme
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: MaterialLocalizations.of(context).searchFieldLabel,
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              )
            : Text(
                AppLocalizations.of(context)!.favoritesTitle,
                style: TextStyle(
                  fontSize: ResponsiveConstants.headline5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
        leading: IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.menu,
            color: Colors.white,
          ), // Changed to white
          onPressed: () {
            if (_isSearching) {
              setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchController.clear();
              });
            } else {
              Scaffold.of(context).openDrawer();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          if (!_isLoading &&
              (_favoritePois.isNotEmpty ||
                  _favoriteEvents.isNotEmpty ||
                  _favoriteTours.isNotEmpty ||
                  _favoriteActivities.isNotEmpty) &&
              !_isSearching)
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort, color: Colors.white),
              initialValue: _sortBy,
              onSelected: (value) {
                setState(() {
                  _sortBy = value;
                });
              },
              itemBuilder: (context) => _sortOptions.map((option) {
                return PopupMenuItem<String>(
                  value: option,
                  child: Text(_getSortLabel(option)),
                );
              }).toList(),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isLoading &&
                (_favoritePois.isNotEmpty ||
                    _favoriteEvents.isNotEmpty ||
                    _favoriteTours.isNotEmpty ||
                    _favoriteActivities.isNotEmpty))
              _buildTabBar(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : (_favoritePois.isEmpty &&
                        _favoriteEvents.isEmpty &&
                        _favoriteTours.isEmpty &&
                        _favoriteActivities.isEmpty)
                  ? _buildEmptyState()
                  : _buildFavoritesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final totalCount =
        _favoritePois.length +
        _favoriteEvents.length +
        _favoriteTours.length +
        _favoriteActivities.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabButton('all', totalCount),
            SizedBox(width: 8.w),
            _buildTabButton('pois', _favoritePois.length),
            SizedBox(width: 8.w),
            _buildTabButton('events', _favoriteEvents.length),
            SizedBox(width: 8.w),
            _buildTabButton('tours', _favoriteTours.length),
            SizedBox(width: 8.w),
            _buildTabButton('activities', _favoriteActivities.length),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tab, int count) {
    final isSelected = _selectedTab == tab;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tab),
      child: Container(
        padding: Responsive.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3860F8) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF3860F8) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          '${_getTabLabel(tab)} ($count)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveConstants.body2,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    // Use Shimmer for loading state as well for consistency
    return ListView.separated(
      padding: Responsive.all(20),
      itemCount: 5,
      separatorBuilder: (context, index) =>
          SizedBox(height: ResponsiveConstants.mediumSpace),
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildFavoritesList() {
    final items = _getFilteredItems();

    if (items.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return Center(
          child: Text(
            'Aucun résultat pour "$_searchQuery"',
            style: TextStyle(
              fontSize: ResponsiveConstants.body1,
              color: Colors.grey[600],
            ),
          ),
        );
      }
      return _buildEmptyFilterState();
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.separated(
        padding: Responsive.all(20),
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: ResponsiveConstants.mediumSpace),
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is Poi) {
            return PoiCard(poi: item);
          } else if (item is Event) {
            return EventCard(event: item);
          } else if (item is Tour) {
            return TourCard(tour: item);
          } else if (item is Activity) {
            return ActivityCard(activity: item);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<dynamic> _getFilteredItems() {
    List<dynamic> items = [];

    switch (_selectedTab) {
      case 'all':
        items.addAll(_favoritePois);
        items.addAll(_favoriteEvents);
        items.addAll(_favoriteTours);
        items.addAll(_favoriteActivities);
        break;
      case 'pois':
        items.addAll(_favoritePois);
        break;
      case 'events':
        items.addAll(_favoriteEvents);
        break;
      case 'tours':
        items.addAll(_favoriteTours);
        break;
      case 'activities':
        items.addAll(_favoriteActivities);
        break;
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      items = items.where((item) {
        if (item is Poi) {
          return item.name.toLowerCase().contains(query);
        } else if (item is Event) {
          return item.title.toLowerCase().contains(query);
        } else if (item is Tour) {
          return item.displayTitle.toLowerCase().contains(query);
        } else if (item is Activity) {
          return item.title.toLowerCase().contains(query);
        }
        return false;
      }).toList();
    }

    items.sort((a, b) {
      switch (_sortBy) {
        case 'recent':
          String? aDateStr;
          String? bDateStr;
          if (a is Poi) {
            aDateStr = a.createdAt;
          } else if (a is Event) {
            aDateStr = a.createdAt;
          } else if (a is Tour) {
            aDateStr = a.createdAt;
          } else if (a is Activity) {
            aDateStr = a.createdAt;
          }
          if (b is Poi) {
            bDateStr = b.createdAt;
          } else if (b is Event) {
            bDateStr = b.createdAt;
          } else if (b is Tour) {
            bDateStr = b.createdAt;
          } else if (b is Activity) {
            bDateStr = b.createdAt;
          }
          final aDate = DateTime.tryParse(aDateStr ?? '') ?? DateTime(1970);
          final bDate = DateTime.tryParse(bDateStr ?? '') ?? DateTime(1970);
          return bDate.compareTo(aDate);
        case 'alphabetical':
          String aName = '';
          String bName = '';
          if (a is Poi) {
            aName = a.name;
          } else if (a is Event) {
            aName = a.title;
          } else if (a is Tour) {
            aName = a.displayTitle;
          } else if (a is Activity) {
            aName = a.title;
          }
          if (b is Poi) {
            bName = b.name;
          } else if (b is Event) {
            bName = b.title;
          } else if (b is Tour) {
            bName = b.displayTitle;
          } else if (b is Activity) {
            bName = b.title;
          }
          return aName.compareTo(bName);
        case 'rating':
          final aRating = a is Poi ? 4.0 : 4.5;
          final bRating = b is Poi ? 4.0 : 4.5;
          return bRating.compareTo(aRating);
        default:
          return 0;
      }
    });

    return items;
  }

  Widget _buildEmptyFilterState() {
    String message = '';
    switch (_selectedTab) {
      case 'pois':
        message = 'Aucun lieu favori';
        break;
      case 'events':
        message = 'Aucun événement favori';
        break;
      default:
        message = 'Aucun favori dans cette catégorie';
    }

    return Center(
      child: Padding(
        padding: Responsive.all(40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_outline, size: 60, color: Colors.grey[400]),
              SizedBox(height: ResponsiveConstants.mediumSpace),
              Text(
                message,
                style: TextStyle(
                  fontSize: ResponsiveConstants.subtitle2,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: ResponsiveConstants.mediumSpace),
              Text(
                AppLocalizations.of(context)!.favoritesEmptyDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveConstants.body1,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: ResponsiveConstants.extraLargeSpace),
              ElevatedButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3860F8),
                  foregroundColor: Colors.white,
                  padding: Responsive.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.discoverTitle,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: Responsive.all(40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(60.r),
                ),
                child: Icon(
                  Icons.favorite_outline,
                  size: 60,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: ResponsiveConstants.extraLargeSpace),
              Text(
                AppLocalizations.of(context)!.favoritesEmpty,
                style: TextStyle(
                  fontSize: ResponsiveConstants.headline6,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: ResponsiveConstants.smallSpace),
              Text(
                AppLocalizations.of(context)!.favoritesEmptyDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveConstants.body1,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: ResponsiveConstants.extraLargeSpace),
              ElevatedButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3860F8),
                  foregroundColor: Colors.white,
                  padding: Responsive.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.discoverTitle,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPoiDetail(Poi poi) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PoiDetailPage(poi: poi)),
    );
  }

  void _navigateToEventDetail(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventDetailPage(event: event)),
    );
  }

  Future<void> _removePoiFromFavorites(int poiId) async {
    final success = await _favoritesService.removePoiFromFavorites(poiId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.favoritesRemovedFromFavorites,
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    }
  }

  Future<void> _removeEventFromFavorites(int eventId) async {
    final success = await _favoritesService.removeEventFromFavorites(eventId);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.commonError),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    }
  }

  Widget _buildShimmerImagePlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 160.h,
        color: Colors.white,
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerImagePlaceholder(), // Use the dedicated image placeholder
          Padding(
            padding: Responsive.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 20.h,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 30.h,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return _formatDate(date);
    } catch (e) {
      return dateString.split('T').first; // Fallback
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'à venir':
      case 'upcoming':
        return Colors.blue;
      case 'en cours':
      case 'ongoing':
        return Colors.green;
      case 'terminé':
      case 'ended':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: Responsive.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRatingChip(double rating) {
    return Container(
      padding: Responsive.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 14),
          SizedBox(width: 4.w),
          Text(
            rating.toString(),
            style: TextStyle(
              color: Colors.amber,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
