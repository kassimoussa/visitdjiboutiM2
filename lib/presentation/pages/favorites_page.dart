import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/event_service.dart';
import '../../core/services/conversion_trigger_service.dart';
import '../../core/models/poi.dart';
import '../../core/models/event.dart';
import 'poi_detail_page.dart';
import 'event_detail_page.dart';
import '../../generated/l10n/app_localizations.dart';
import '../widgets/poi_card.dart';
import '../widgets/event_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesService _favoritesService = FavoritesService();
  final EventService _eventService = EventService();
  final ConversionTriggerService _conversionService = ConversionTriggerService();
  
  late StreamSubscription _favoritesSubscription;

  List<Poi> _favoritePois = [];
  List<Event> _favoriteEvents = [];
  bool _isLoading = true;
  String _selectedTab = 'all'; // all, pois, events  
  String _sortBy = 'recent';
  final List<String> _sortOptions = ['recent', 'alphabetical', 'rating'];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _favoritesSubscription = _favoritesService.favoritesStream.listen((_) {
      _loadFavorites();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _conversionService.checkAndShowConversionTrigger(context);
    });
  }

  @override
  void dispose() {
    _favoritesSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    
    try {
      final pois = await _favoritesService.getFavoritePois();
      final events = await _favoritesService.getFavoriteEvents();
      
      if (mounted) {
        setState(() {
          _favoritePois = pois;
          _favoriteEvents = events;
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
    switch (tab) {
      case 'all':
        return AppLocalizations.of(context)!.favoritesAllTab;
      case 'pois':
        return AppLocalizations.of(context)!.favoritesPoisTab;
      case 'events':
        return AppLocalizations.of(context)!.favoritesEventsTab;
      default:
        return tab;
    }
  }

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'recent':
        return AppLocalizations.of(context)!.favoritesSortRecent;
      case 'alphabetical':
        return AppLocalizations.of(context)!.favoritesSortAlphabetical;
      case 'rating':
        return AppLocalizations.of(context)!.favoritesSortRating;
      default:
        return sort;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (!_isLoading && (_favoritePois.isNotEmpty || _favoriteEvents.isNotEmpty))
              _buildTabBar(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : (_favoritePois.isEmpty && _favoriteEvents.isEmpty)
                      ? _buildEmptyState()
                      : _buildFavoritesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.favoritesTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2233),
            ),
          ),
          const Spacer(),
          if (!_isLoading && (_favoritePois.isNotEmpty || _favoriteEvents.isNotEmpty))
            PopupMenuButton<String>(
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
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Icon(Icons.sort, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final totalCount = _favoritePois.length + _favoriteEvents.length;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _buildTabButton('all', totalCount),
          const SizedBox(width: 8),
          _buildTabButton('pois', _favoritePois.length),
          const SizedBox(width: 8),
          _buildTabButton('events', _favoriteEvents.length),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, int count) {
    final isSelected = _selectedTab == tab;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3860F8) : Colors.white,
            borderRadius: BorderRadius.circular(12),
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
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    // Use Shimmer for loading state as well for consistency
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildFavoritesList() {
    final items = _getFilteredItems();
    
    if (items.isEmpty) {
      return _buildEmptyFilterState();
    }
    
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is Poi) {
            return PoiCard(poi: item);
          } else if (item is Event) {
            return EventCard(event: item);
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
        break;
      case 'pois':
        items.addAll(_favoritePois);
        break;
      case 'events':
        items.addAll(_favoriteEvents);
        break;
    }
    
    items.sort((a, b) {
      switch (_sortBy) {
        case 'recent':
          final aDate = a is Poi ? a.createdAt : (a as Event).createdAt;
          final bDate = b is Poi ? b.createdAt : (b as Event).createdAt;
          return bDate.compareTo(aDate);
        case 'alphabetical':
          final aName = a is Poi ? a.name : (a as Event).title;
          final bName = b is Poi ? b.name : (b as Event).title;
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
        padding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_outline,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.favoritesEmptyDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3860F8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              child: Text(
                AppLocalizations.of(context)!.discoverTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    )
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
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
              Text(
                AppLocalizations.of(context)!.favoritesEmpty,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.favoritesEmptyDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3860F8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.discoverTitle,
                  style: const TextStyle(
                    fontSize: 16,
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
      MaterialPageRoute(
        builder: (context) => PoiDetailPage(poi: poi),
      ),
    );
  }

  void _navigateToEventDetail(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailPage(event: event),
      ),
    );
  }

  Future<void> _removePoiFromFavorites(int poiId) async {
    final success = await _favoritesService.removePoiFromFavorites(poiId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.favoritesRemovedFromFavorites),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
            borderRadius: BorderRadius.circular(8),
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
        height: 160,
        color: Colors.white,
      ),
    );
  }

  Widget _buildShimmerCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerImagePlaceholder(), // Use the dedicated image placeholder
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 20,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 30,
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
}