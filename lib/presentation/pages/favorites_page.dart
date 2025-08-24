import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/event_service.dart';
import '../../core/services/conversion_trigger_service.dart';
import '../../core/models/poi.dart';
import '../../core/models/event.dart';
import 'poi_detail_page.dart';
import 'event_detail_page.dart';
import '../widgets/conversion_prompt.dart';
import '../../core/models/anonymous_user.dart';
import '../../generated/l10n/app_localizations.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesService _favoritesService = FavoritesService();
  final EventService _eventService = EventService();
  final ConversionTriggerService _conversionService = ConversionTriggerService();
  
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _conversionService.checkAndShowConversionTrigger(context);
    });
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    
    try {
      // Utiliser le service unifié pour charger POIs et Events
      final pois = await _favoritesService.getFavoritePois();
      final events = await _favoritesService.getFavoriteEvents();
      
      setState(() {
        _favoritePois = pois;
        _favoriteEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des favoris: $e');
      setState(() => _isLoading = false);
    }
  }

  // Fonctions utilitaires pour la traduction
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

  // Fonction supprimée car maintenant gérée par le FavoritesService unifié

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
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3860F8)),
      ),
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
            return _buildPoiCard(item);
          } else if (item is Event) {
            return _buildEventCard(item);
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
    
    // Tri
    items.sort((a, b) {
      switch (_sortBy) {
        case 'recent':
          final aDate = a is Poi ? a.createdAt : (a as Event).createdAt;
          final bDate = b is Poi ? b.createdAt : (b as Event).createdAt;
          return bDate.compareTo(aDate); // Comparaison de strings ISO
        case 'alphabetical':
          final aName = a is Poi ? a.name : (a as Event).title;
          final bName = b is Poi ? b.name : (b as Event).title;
          return aName.compareTo(bName);
        case 'rating':
          final aRating = a is Poi ? 4.0 : 4.5; // Notes par défaut
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
        message = 'Aucun lieu favori'; // TODO: ajouter à l10n
        break;
      case 'events':
        message = 'Aucun événement favori'; // TODO: ajouter à l10n
        break;
      default:
        message = 'Aucun favori dans cette catégorie'; // TODO: ajouter à l10n
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
          ],
        ),
      ),
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
                // Naviguer vers l'onglet Découvrir
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                // Ici, vous pourriez utiliser un gestionnaire de navigation global
                // pour changer d'onglet vers "Découvrir"
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
      setState(() {
        _favoritePois.removeWhere((poi) => poi.id == poiId);
      });
      
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
    if (success) {
      setState(() {
        _favoriteEvents.removeWhere((event) => event.id == eventId);
      });
      
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
    } else {
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

  Widget _buildPoiCard(Poi poi) {
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
        onTap: () => _navigateToPoiDetail(poi),
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
                  child: poi.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            poi.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.place,
                                  size: 48,
                                  color: Color(0xFF3860F8),
                                ),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.place,
                            size: 48,
                            color: Color(0xFF3860F8),
                          ),
                        ),
                ),
                if (poi.isFeatured)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3860F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Populaire', // TODO: ajouter à l10n
                        style: const TextStyle(
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
                      onPressed: () => _removePoiFromFavorites(poi.id),
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
                    poi.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    poi.shortDescription,
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
                      if (poi.categories.isNotEmpty)
                        _buildInfoChip(poi.primaryCategory, Colors.green),
                      const SizedBox(width: 8),
                      _buildRatingChip(4.0), // Note par défaut car pas de rating dans POI
                      const Spacer(),
                      Text(
                        poi.region,
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
                    'Ajouté le ${_formatDateString(poi.createdAt)}', // TODO: ajouter à l10n
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

  Widget _buildEventCard(Event event) {
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
        onTap: () => _navigateToEventDetail(event),
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
                        const Color(0xFF009639).withOpacity(0.1),
                        const Color(0xFF3860F8).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: event.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            event.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.event,
                                  size: 48,
                                  color: Color(0xFF009639),
                                ),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.event,
                            size: 48,
                            color: Color(0xFF009639),
                          ),
                        ),
                ),
                if (event.isFeatured)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF009639),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'À la une', // TODO: ajouter à l10n
                        style: const TextStyle(
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(event.statusText),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
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
                      onPressed: () => _removeEventFromFavorites(event.id),
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
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.shortDescription,
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
                      if (event.categories.isNotEmpty)
                        _buildInfoChip(event.primaryCategory, Colors.orange),
                      const SizedBox(width: 8),
                      _buildRatingChip(4.5), // Note par défaut car pas de rating dans Event
                      const Spacer(),
                      Text(
                        event.priceText,
                        style: TextStyle(
                          color: event.isFree ? Colors.green : Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatDateString(event.startDate)} - ${_formatDateString(event.endDate ?? event.startDate)}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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