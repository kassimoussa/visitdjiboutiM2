import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/services/poi_service.dart';
import '../../core/services/event_service.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/localization_service.dart';
import '../../core/models/poi.dart';
import '../widgets/poi_card.dart';
import '../widgets/event_card.dart';
import '../../core/models/event.dart';
import '../../core/models/poi_list_response.dart';
import '../../core/models/event_list_response.dart';
import '../../core/models/api_response.dart';
import 'region_page.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/responsive.dart';
import 'tour_operators_page.dart';
import 'essentials_page.dart';
import 'embassies_page.dart';

class HomePage extends StatefulWidget {
  final Function(int) onTabChange;
  const HomePage({super.key, required this.onTabChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PoiService _poiService = PoiService();
  final EventService _eventService = EventService();
  final CacheService _cacheService = CacheService();
  final LocalizationService _localizationService = LocalizationService();
  
  List<Poi> _featuredPois = [];
  List<Event> _upcomingEvents = [];
  bool _isLoadingPois = true;
  bool _isLoadingEvents = true;

  PageController? _poisPageController;
  PageController? _eventsPageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _eventsPageController = PageController(viewportFraction: 0.85);
    
    // Écouter les changements de langue
    _localizationService.addListener(_onLanguageChanged);
    
    _cacheService.clearPoiCache().then((_) {
      _loadFeaturedPois();
      _loadUpcomingEvents();
    });
  }

  void _onLanguageChanged() {
    // Recharger les données quand la langue change
    print('[HOME PAGE] Langue changée - Rechargement forcé des données');
    
    // Vider le cache local immédiatement
    _cacheService.clearPoiCache();
    
    // Ajouter un petit délai pour laisser le temps au service de mettre à jour les headers
    Future.delayed(const Duration(milliseconds: 300), () {
      print('[HOME PAGE] Rechargement avec nouveaux headers');
      _loadFeaturedPoisForced();
      _loadUpcomingEventsForced();
    });
  }

  @override
  void dispose() {
    _localizationService.removeListener(_onLanguageChanged);
    _timer?.cancel();
    _poisPageController?.dispose();
    _eventsPageController?.dispose();
    super.dispose();
  }

  Future<void> _loadFeaturedPois() async {
    print('🏠 [HOME] Chargement POIs - Langue: ${_localizationService.currentLanguageCode}');
    try {
      final ApiResponse<PoiListData> response = await _poiService.getPois(
        perPage: 15,
        useCache: false, // Force API call pour tester les traductions
      );
      
      print('🏠 [HOME] Réponse API reçue - Success: ${response.isSuccess}');
      if (response.isSuccess && response.hasData) {
        final allPois = response.data!.pois;
        allPois.shuffle();
        
        if (mounted) {
          setState(() {
            _featuredPois = allPois.take(8).toList();
            _isLoadingPois = false;
          });
          
          print('🏠 [HOME] POIs chargés: ${_featuredPois.length} items');
          print('🏠 [HOME] Premier POI: ${_featuredPois.isNotEmpty ? _featuredPois.first.name : "aucun"}');

          if (_featuredPois.length > 1) {
            _setupCarousel();
          }
        }
      } else {
        if (mounted) setState(() => _isLoadingPois = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPois = false);
    }
  }

  void _setupCarousel() {
    _currentPage = _featuredPois.isNotEmpty ? _featuredPois.length * 10 : 0;
    _poisPageController?.dispose();
    _poisPageController = PageController(
      viewportFraction: 0.8,
      initialPage: _currentPage,
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (_featuredPois.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_poisPageController != null && _poisPageController!.hasClients) {
          _currentPage++;
          _poisPageController!.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Future<void> _loadUpcomingEvents() async {
    try {
      final ApiResponse<EventListData> response = await _eventService.getEvents(
        status: 'upcoming',
        perPage: 5,
        sortBy: 'start_date',
        sortOrder: 'asc',
      );
      
      if (response.isSuccess && response.hasData) {
        if (mounted) {
          setState(() {
            _upcomingEvents = response.data!.events;
            _isLoadingEvents = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingEvents = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingEvents = false);
    }
  }

  /// Version forcée qui bypass le cache pour les changements de langue
  Future<void> _loadFeaturedPoisForced() async {
    setState(() {
      _isLoadingPois = true;
    });
    
    try {
      final ApiResponse<PoiListData> response = await _poiService.getPois(
        perPage: 15,
        useCache: false, // Force l'appel API sans cache
      );
      
      if (response.isSuccess && response.hasData) {
        final allPois = response.data!.pois;
        allPois.shuffle();
        
        if (mounted) {
          setState(() {
            _featuredPois = allPois.take(8).toList();
            _isLoadingPois = false;
          });
          print('[HOME PAGE] POIs rechargés: ${_featuredPois.length} items (langue: ${_localizationService.currentLanguageCode})');

          if (_featuredPois.length > 1) {
            _setupCarousel();
          }
        }
      } else {
        if (mounted) setState(() => _isLoadingPois = false);
      }
    } catch (e) {
      print('[HOME PAGE] Erreur rechargement POIs: $e');
      if (mounted) setState(() => _isLoadingPois = false);
    }
  }

  /// Version forcée qui bypass le cache pour les changements de langue
  Future<void> _loadUpcomingEventsForced() async {
    setState(() {
      _isLoadingEvents = true;
    });
    
    try {
      final ApiResponse<EventListData> response = await _eventService.getEvents(
        status: 'upcoming',
        perPage: 5,
        sortBy: 'start_date',
        sortOrder: 'asc',
        useCache: false, // Force l'appel API sans cache
      );
      
      if (response.isSuccess && response.hasData) {
        if (mounted) {
          setState(() {
            _upcomingEvents = response.data!.events;
            _isLoadingEvents = false;
          });
          print('[HOME PAGE] Événements rechargés: ${_upcomingEvents.length} items (langue: ${_localizationService.currentLanguageCode})');
        }
      } else {
        if (mounted) setState(() => _isLoadingEvents = false);
      }
    } catch (e) {
      print('[HOME PAGE] Erreur rechargement événements: $e');
      if (mounted) setState(() => _isLoadingEvents = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: AppLocalizations.of(context)!.homeFeaturedPois,
              onShuffle: _isLoadingPois ? null : _loadFeaturedPois,
              onSeeAll: () => widget.onTabChange(1),
            ),
            const SizedBox(height: 12),
            _buildFeaturedPoisCarousel(isSmallScreen),
            
            const SizedBox(height: 24),
            
            _buildSectionHeader(
              title: AppLocalizations.of(context)!.homeUpcomingEvents,
              onSeeAll: () => widget.onTabChange(2),
            ),
            const SizedBox(height: 12),
            _buildUpcomingEventsCarousel(),
            
            const SizedBox(height: 24),
            
            _buildSectionHeader(
              title: AppLocalizations.of(context)!.homeDiscoverByRegion,
              subtitle: AppLocalizations.of(context)!.homeDiscoverByRegionSubtitle,
            ),
            const SizedBox(height: 12),
            _buildRegionGrid(isSmallScreen),

            const SizedBox(height: 24),
            _buildSectionHeader(title: AppLocalizations.of(context)!.homeEssentials),
            const SizedBox(height: 12),
            _buildEssentialsSection(),
          ],
        ),
    );
  }

  Widget _buildSectionHeader({required String title, String? subtitle, VoidCallback? onShuffle, VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        Row(
          children: [
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  AppLocalizations.of(context)!.commonSeeAll,
                  style: const TextStyle(color: Color(0xFF3860F8)),
                ),
              ),
            if (onShuffle != null)
              IconButton(
                onPressed: onShuffle,
                icon: const Icon(Icons.refresh),
                tooltip: AppLocalizations.of(context)!.homeShufflePois,
                color: const Color(0xFF3860F8),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturedPoisCarousel(bool isSmallScreen) {
    return SizedBox(
      height: 320.h,
      child: _isLoadingPois
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3860F8)))
          : _featuredPois.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.homeNoFeaturedPois,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is UserScrollNotification) {
                      _timer?.cancel();
                    } else if (notification is ScrollEndNotification) {
                      _startAutoScroll();
                    }
                    return true;
                  },
                  child: PageView.builder(
                    controller: _poisPageController,
                    itemBuilder: (context, index) {
                      final poi = _featuredPois[index % _featuredPois.length];
                      return AnimatedBuilder(
                        animation: _poisPageController!,
                        builder: (context, child) {
                          double scale = 1.0;
                          if (_poisPageController!.position.haveDimensions) {
                            double page = _poisPageController!.page ?? 0.0;
                            double difference = (page - index).abs();
                            scale = max(0.85, 1.0 - difference * 0.15);
                          }
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: PoiCard(poi: poi),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildUpcomingEventsCarousel() {
    return SizedBox(
      height: 340.h,
      child: _isLoadingEvents
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3860F8)))
          : _upcomingEvents.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.homeNoUpcomingEvents,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                )
              : PageView.builder(
                  controller: _eventsPageController,
                  itemCount: _upcomingEvents.length,
                  itemBuilder: (context, index) {
                    final event = _upcomingEvents[index];
                    return AnimatedBuilder(
                      animation: _eventsPageController!,
                      builder: (context, child) {
                        double scale = 1.0;
                        if (_eventsPageController!.position.haveDimensions) {
                          double page = _eventsPageController!.page ?? 0.0;
                          double difference = (page - index).abs();
                          scale = max(0.85, 1.0 - difference * 0.15);
                        }
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: EventCard(event: event),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildRegionGrid(bool isSmallScreen) {
    return GridView.count(
      crossAxisCount: isSmallScreen ? 1 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: isSmallScreen ? 8 : 12,
      crossAxisSpacing: isSmallScreen ? 8 : 12,
      childAspectRatio: isSmallScreen ? 2.5 : 1.5,
      children: [
        _buildRegionCard('Djibouti', '🏙️', const Color(0xFF3860F8)),
        _buildRegionCard('Tadjourah', '🏔️', const Color(0xFF009639)),
        _buildRegionCard('Ali Sabieh', '🌄', const Color(0xFF0072CE)),
        _buildRegionCard('Dikhil', '🏜️', const Color(0xFFE8D5A3)),
        _buildRegionCard('Obock', '⛵', const Color(0xFF006B96)),
        _buildRegionCard('Arta', '🌿', const Color(0xFF10B981)),
      ],
    );
  }

  Widget _buildRegionCard(String title, String emoji, Color color) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          try {
          } catch (e) {
          }
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegionPage(
                regionName: title,
                regionEmoji: emoji,
                regionColor: color,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.homeDiscover,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
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
      ),
    );
  }

  Widget _buildEssentialsSection() {
    return Column(
      children: [
        _buildEssentialLink(
          icon: Icons.business_center,
          title: AppLocalizations.of(context)!.homeTourOperators,
          subtitle: AppLocalizations.of(context)!.homeTourOperatorsSubtitle,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TourOperatorsPage())),
        ),
        const SizedBox(height: 12),
        _buildEssentialLink(
          icon: Icons.info_outline,
          title: AppLocalizations.of(context)!.homeEssentialInfo,
          subtitle: AppLocalizations.of(context)!.homeEssentialInfoSubtitle,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EssentialsPage())),
        ),
        const SizedBox(height: 12),
        _buildEssentialLink(
          icon: Icons.account_balance,
          title: AppLocalizations.of(context)!.homeEmbassies,
          subtitle: AppLocalizations.of(context)!.homeEmbassiesSubtitle,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmbassiesPage())),
        ),
      ],
    );
  }

  Widget _buildEssentialLink({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF3860F8), size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}