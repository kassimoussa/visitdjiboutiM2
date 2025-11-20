import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/services/poi_service.dart';
import '../../core/services/event_service.dart';
import '../../core/services/tour_service.dart';
import '../../core/services/activity_service.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/localization_service.dart';
import '../../core/models/poi.dart';
import '../../core/models/tour.dart';
import '../../core/models/simple_activity.dart';
import '../widgets/poi_card.dart';
import '../widgets/event_card.dart';
import '../widgets/tour_card.dart';
import '../widgets/simple_activity_card.dart';
import '../../core/models/event.dart';
import '../../core/models/poi_list_response.dart';
import '../../core/models/event_list_response.dart';
import '../../core/models/api_response.dart';
import 'region_detail_page.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/responsive.dart';
import 'tour_operators_page.dart';
import 'tours_page.dart';
import 'activities_page.dart';
import 'essentials_page.dart';
import 'embassies_page.dart';
import '../../core/utils/retry_helper.dart';
import '../widgets/error_state_widget.dart';

class HomePage extends StatefulWidget {
  final Function(int) onTabChange;
  const HomePage({super.key, required this.onTabChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PoiService _poiService = PoiService();
  final EventService _eventService = EventService();
  final TourService _tourService = TourService();
  final ActivityService _activityService = ActivityService();
  final CacheService _cacheService = CacheService();
  final LocalizationService _localizationService = LocalizationService();

  List<Poi> _featuredPois = [];
  List<Event> _upcomingEvents = [];
  List<Tour> _featuredTours = [];
  List<SimpleActivity> _featuredActivities = [];
  bool _isLoadingPois = true;
  bool _isLoadingEvents = true;
  bool _isLoadingTours = true;
  bool _isLoadingActivities = true;

  PageController? _poisPageController;
  PageController? _eventsPageController;
  PageController? _toursPageController;
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
      _loadFeaturedTours();
      _loadFeaturedActivities();
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
      _loadFeaturedToursForced();
    });
  }

  @override
  void dispose() {
    _localizationService.removeListener(_onLanguageChanged);
    _timer?.cancel();
    _poisPageController?.dispose();
    _eventsPageController?.dispose();
    _toursPageController?.dispose();
    super.dispose();
  }

  Future<void> _loadFeaturedPois() async {
    print('🏠 [HOME] Chargement POIs - Langue: ${_localizationService.currentLanguageCode}');

    setState(() => _isLoadingPois = true);

    try {
      final ApiResponse<PoiListData> response = await RetryHelper.apiCall(
        apiRequest: () => _poiService.getPois(
          perPage: 15,
          useCache: true,
        ),
        maxAttempts: 3,
        operationName: "Chargement POIs featured HomePage",
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
        throw Exception(response.message ?? 'Erreur de chargement POIs');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPois = false);

        ErrorSnackBar.show(
          context,
          title: 'Erreur POIs',
          message: RetryHelper.getErrorMessage(e),
          onRetry: _loadFeaturedPois,
        );
      }
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
    // Auto-scroll désactivé temporairement - Mode manuel uniquement
    _timer?.cancel();
    // if (_featuredPois.length > 1) {
    //   _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
    //     if (_poisPageController != null && _poisPageController!.hasClients) {
    //       _currentPage++;
    //       _poisPageController!.animateToPage(
    //         _currentPage,
    //         duration: const Duration(milliseconds: 800),
    //         curve: Curves.easeInOut,
    //       );
    //     }
    //   });
    // }
  }

  Future<void> _loadUpcomingEvents() async {
    setState(() => _isLoadingEvents = true);

    try {
      final ApiResponse<EventListData> response = await RetryHelper.apiCall(
        apiRequest: () => _eventService.getEvents(
          status: 'upcoming',
          perPage: 5,
          sortBy: 'start_date',
          sortOrder: 'asc',
        ),
        maxAttempts: 3,
        operationName: "Chargement événements HomePage",
      );

      if (response.isSuccess && response.hasData) {
        if (mounted) {
          setState(() {
            _upcomingEvents = response.data!.events;
            _isLoadingEvents = false;
          });
        }
      } else {
        throw Exception(response.message ?? 'Erreur de chargement événements');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingEvents = false);

        ErrorSnackBar.show(
          context,
          title: 'Erreur événements',
          message: RetryHelper.getErrorMessage(e),
          onRetry: _loadUpcomingEvents,
        );
      }
    }
  }

  Future<void> _loadFeaturedTours() async {
    setState(() => _isLoadingTours = true);

    try {
      final response = await RetryHelper.apiCall(
        apiRequest: () => _tourService.getFeaturedTours(limit: 5),
        maxAttempts: 3,
        operationName: "Chargement tours HomePage",
      );

      if (mounted) {
        setState(() {
          _featuredTours = response.data.tours;
          _isLoadingTours = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTours = false);

        ErrorSnackBar.show(
          context,
          title: 'Erreur tours',
          message: RetryHelper.getErrorMessage(e),
          onRetry: _loadFeaturedTours,
        );
      }
    }
  }

  Future<void> _loadFeaturedActivities() async {
    setState(() => _isLoadingActivities = true);

    try {
      final activities = await RetryHelper.apiCall(
        apiRequest: () => _activityService.getFeaturedActivities(limit: 5),
        maxAttempts: 3,
        operationName: "Chargement activités HomePage",
      );

      if (mounted) {
        setState(() {
          _featuredActivities = activities;
          _isLoadingActivities = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingActivities = false);

        ErrorSnackBar.show(
          context,
          title: 'Erreur activités',
          message: RetryHelper.getErrorMessage(e),
          onRetry: _loadFeaturedActivities,
        );
      }
    }
  }

  /// Version forcée qui bypass le cache pour les changements de langue
  Future<void> _loadFeaturedPoisForced() async {
    setState(() => _isLoadingPois = true);

    try {
      final ApiResponse<PoiListData> response = await RetryHelper.apiCall(
        apiRequest: () => _poiService.getPois(
          perPage: 15,
          useCache: false,
        ),
        maxAttempts: 3,
        operationName: "Rechargement POIs forcé (changement langue)",
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
        throw Exception(response.message ?? 'Erreur rechargement POIs');
      }
    } catch (e) {
      print('[HOME PAGE] Erreur rechargement POIs: $e');
      if (mounted) {
        setState(() => _isLoadingPois = false);

        ErrorSnackBar.show(
          context,
          title: 'Erreur rechargement POIs',
          message: RetryHelper.getErrorMessage(e),
          onRetry: _loadFeaturedPoisForced,
        );
      }
    }
  }

  /// Version forcée qui bypass le cache pour les changements de langue
  Future<void> _loadUpcomingEventsForced() async {
    setState(() => _isLoadingEvents = true);

    try {
      final ApiResponse<EventListData> response = await RetryHelper.apiCall(
        apiRequest: () => _eventService.getEvents(
          status: 'upcoming',
          perPage: 5,
          sortBy: 'start_date',
          sortOrder: 'asc',
          useCache: false,
        ),
        maxAttempts: 3,
        operationName: "Rechargement événements forcé (changement langue)",
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
        throw Exception(response.message ?? 'Erreur rechargement événements');
      }
    } catch (e) {
      print('[HOME PAGE] Erreur rechargement événements: $e');
      if (mounted) {
        setState(() => _isLoadingEvents = false);

        ErrorSnackBar.show(
          context,
          title: 'Erreur rechargement événements',
          message: RetryHelper.getErrorMessage(e),
          onRetry: _loadUpcomingEventsForced,
        );
      }
    }
  }

  /// Version forcée qui bypass le cache pour les changements de langue
  Future<void> _loadFeaturedToursForced() async {
    setState(() => _isLoadingTours = true);

    try {
      final response = await RetryHelper.apiCall(
        apiRequest: () => _tourService.getFeaturedTours(limit: 5),
        maxAttempts: 3,
        operationName: "Rechargement tours forcé (changement langue)",
      );

      if (mounted) {
        setState(() {
          _featuredTours = response.data.tours;
          _isLoadingTours = false;
        });
        print('[HOME PAGE] Tours rechargés: ${_featuredTours.length} items (langue: ${_localizationService.currentLanguageCode})');
      }
    } catch (e) {
      print('[HOME PAGE] Erreur rechargement tours: $e');
      if (mounted) {
        setState(() => _isLoadingTours = false);

        ErrorSnackBar.show(
          context,
          title: 'Erreur rechargement tours',
          message: RetryHelper.getErrorMessage(e),
          onRetry: _loadFeaturedToursForced,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: AppLocalizations.of(context)!.homeFeaturedPois,
              onShuffle: _isLoadingPois ? null : _loadFeaturedPois,
              onSeeAll: () => widget.onTabChange(1),
            ),
            SizedBox(height: ResponsiveConstants.smallSpace),
            _buildFeaturedPoisCarousel(isSmallScreen),

            SizedBox(height: ResponsiveConstants.largeSpace),

            _buildSectionHeader(
              title: AppLocalizations.of(context)!.homeUpcomingEvents,
              onSeeAll: () => widget.onTabChange(2),
            ),
            SizedBox(height: ResponsiveConstants.smallSpace),
            _buildUpcomingEventsCarousel(),

            SizedBox(height: ResponsiveConstants.largeSpace),

            _buildSectionHeader(
              title: AppLocalizations.of(context)!.homeFeaturedTours,
              onSeeAll: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ToursPage(showFeaturedOnly: true)),
              ),
            ),
            SizedBox(height: ResponsiveConstants.smallSpace),
            _buildFeaturedToursCarousel(),

            SizedBox(height: ResponsiveConstants.largeSpace),

            _buildSectionHeader(
              title: AppLocalizations.of(context)!.homePopularActivities,
              onSeeAll: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ActivitiesPage(showFeaturedOnly: true)),
              ),
            ),
            SizedBox(height: ResponsiveConstants.smallSpace),
            _buildFeaturedActivitiesCarousel(),

            SizedBox(height: ResponsiveConstants.largeSpace),

            _buildSectionHeader(
              title: AppLocalizations.of(context)!.homeDiscoverByRegion,
              subtitle: AppLocalizations.of(context)!.homeDiscoverByRegionSubtitle,
            ),
            SizedBox(height: ResponsiveConstants.smallSpace),
            _buildRegionGrid(isSmallScreen),

            SizedBox(height: ResponsiveConstants.largeSpace),
            _buildSectionHeader(title: AppLocalizations.of(context)!.homeEssentials),
            SizedBox(height: ResponsiveConstants.smallSpace),
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
        // Utiliser Expanded pour éviter le débordement
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveConstants.subtitle1,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body2,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        // Utiliser SizedBox pour fixer la largeur des actions
        SizedBox(
          width: onSeeAll != null && onShuffle != null ? 140.w : 80.w,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    minimumSize: Size(60.w, 36.h),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.commonSeeAll,
                    style: TextStyle(
                      color: const Color(0xFF3860F8),
                      fontSize: ResponsiveConstants.caption,
                    ),
                  ),
                ),
              if (onShuffle != null)
                IconButton(
                  onPressed: onShuffle,
                  icon: const Icon(Icons.refresh),
                  tooltip: AppLocalizations.of(context)!.homeShufflePois,
                  color: const Color(0xFF3860F8),
                  padding: EdgeInsets.all(8.w),
                  constraints: BoxConstraints(
                    minWidth: 40.w,
                    minHeight: 40.h,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedPoisCarousel(bool isSmallScreen) {
    return SizedBox(
      height: 350.h,
      child: _isLoadingPois
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3860F8)))
          : _featuredPois.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.homeNoFeaturedPois,
                    style: TextStyle(color: Colors.grey[600], fontSize: ResponsiveConstants.body2),
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
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
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
      height: 350.h,
      child: _isLoadingEvents
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3860F8)))
          : _upcomingEvents.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.homeNoUpcomingEvents,
                    style: TextStyle(color: Colors.grey[600], fontSize: ResponsiveConstants.body2),
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
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: EventCard(event: event),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildFeaturedToursCarousel() {
    _toursPageController ??= PageController(viewportFraction: 0.85);

    return SizedBox(
      height: 340.h,
      child: _isLoadingTours
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3860F8)))
          : _featuredTours.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.homeNoFeaturedTours,
                    style: TextStyle(color: Colors.grey[600], fontSize: ResponsiveConstants.body2),
                  ),
                )
              : PageView.builder(
                  controller: _toursPageController,
                  itemCount: _featuredTours.length,
                  itemBuilder: (context, index) {
                    final tour = _featuredTours[index];
                    return AnimatedBuilder(
                      animation: _toursPageController!,
                      builder: (context, child) {
                        double scale = 1.0;
                        if (_toursPageController!.position.haveDimensions) {
                          double page = _toursPageController!.page ?? 0.0;
                          double difference = (page - index).abs();
                          scale = max(0.85, 1.0 - difference * 0.15);
                        }
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: TourCard(tour: tour),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildFeaturedActivitiesCarousel() {
    PageController activitiesPageController = PageController(viewportFraction: 0.85);

    return SizedBox(
      height: 350.h,
      child: _isLoadingActivities
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3860F8)))
          : _featuredActivities.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.homeNoActivities,
                    style: TextStyle(color: Colors.grey[600], fontSize: ResponsiveConstants.body2),
                  ),
                )
              : PageView.builder(
                  controller: activitiesPageController,
                  itemCount: _featuredActivities.length,
                  itemBuilder: (context, index) {
                    final activity = _featuredActivities[index];
                    return AnimatedBuilder(
                      animation: activitiesPageController,
                      builder: (context, child) {
                        double scale = 1.0;
                        if (activitiesPageController.position.haveDimensions) {
                          double page = activitiesPageController.page ?? 0.0;
                          double difference = (page - index).abs();
                          scale = max(0.85, 1.0 - difference * 0.15);
                        }
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: SimpleActivityCard(activity: activity),
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
        _buildRegionCard(AppLocalizations.of(context)!.homeRegionDjibouti, '🏙️', const Color(0xFF3860F8)),
        _buildRegionCard(AppLocalizations.of(context)!.homeRegionTadjourah, '🏔️', const Color(0xFF009639)),
        _buildRegionCard(AppLocalizations.of(context)!.homeRegionAliSabieh, '🌄', const Color(0xFF0072CE)),
        _buildRegionCard(AppLocalizations.of(context)!.homeRegionDikhil, '🏜️', const Color(0xFFE8D5A3)),
        _buildRegionCard(AppLocalizations.of(context)!.homeRegionObock, '⛵', const Color(0xFF006B96)),
        _buildRegionCard(AppLocalizations.of(context)!.homeRegionArta, '🌿', const Color(0xFF10B981)),
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
              builder: (context) => RegionDetailPage(
                regionName: title,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
        child: Container(
          height: ResponsiveConstants.cardImageHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
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
                blurRadius: 8.w,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  width: 20.w,
                  height: 20.h,
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
                      style: TextStyle(fontSize: 36.sp),
                    ),
                    SizedBox(height: ResponsiveConstants.smallSpace),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveConstants.body1,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1.h),
                            blurRadius: 2.w,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveConstants.tinySpace),
                    Text(
                      AppLocalizations.of(context)!.homeDiscover,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: ResponsiveConstants.caption,
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
        SizedBox(height: ResponsiveConstants.smallSpace),
        _buildEssentialLink(
          icon: Icons.info_outline,
          title: AppLocalizations.of(context)!.homeEssentialInfo,
          subtitle: AppLocalizations.of(context)!.homeEssentialInfoSubtitle,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EssentialsPage())),
        ),
        SizedBox(height: ResponsiveConstants.smallSpace),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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