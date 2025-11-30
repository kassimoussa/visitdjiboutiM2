import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/models/poi.dart';
import '../../core/models/content.dart';
import '../../core/services/poi_service.dart';
import '../../core/services/content_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/directions_service.dart';
import '../../core/utils/map_marker_helper.dart';
import '../../core/utils/retry_helper.dart';
import '../widgets/error_state_widget.dart';
import 'poi_detail_page.dart';
import '../../generated/l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/utils/responsive.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  final PoiService _poiService = PoiService();
  final ContentService _contentService = ContentService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final LocationService _locationService = LocationService();
  final DirectionsService _directionsService = DirectionsService();

  // Cluster Manager natif pour grouper les markers
  late ClusterManager _clusterManager;
  Map<MarkerId, Poi> _markerPoiMap = {}; // Association marker ID -> POI
  Map<MarkerId, Content> _markerContentMap =
      {}; // Association marker ID -> Content

  // Mode d'affichage : true = tous les contenus, false = POIs seulement
  final bool _showAllContent = true;

  // Données pour le mode POI uniquement
  List<Poi> _pois = [];
  List<Poi> _filteredPois = [];

  // Données pour le mode "tous les contenus"
  List<Content> _allContent = [];
  List<Content> _filteredContent = [];

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _showNearbyList = false;
  final TextEditingController _searchController = TextEditingController();

  // Position de l'utilisateur
  Position? _userPosition;
  bool _isLocatingUser = false;
  bool _isSearching = false;

  // POI ou Content sélectionné pour les directions
  Poi? _selectedPoiForDirections;
  Content? _selectedContentForDirections;

  // Coordonnées centrées sur le pays de Djibouti
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(11.6000, 42.8500),
    zoom: 8.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeClusterManager();
    _loadData();
    _getUserLocation();
  }

  /// Charge les données selon le mode sélectionné
  Future<void> _loadData() async {
    if (_showAllContent) {
      await _loadAllContent();
    } else {
      await _loadPois();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  /// Initialise le cluster manager natif
  void _initializeClusterManager() {
    _clusterManager = ClusterManager(
      clusterManagerId: ClusterManagerId('poi_cluster'),
    );
  }

  /// Crée les markers avec clustering natif (pour POIs)
  Future<void> _createMarkers(List<Poi> pois) async {
    final markers = <Marker>{};
    final markerPoiMap = <MarkerId, Poi>{};

    for (final poi in pois) {
      final markerId = MarkerId('poi_${poi.id}');
      markerPoiMap[markerId] = poi;

      final marker = Marker(
        markerId: markerId,
        position: LatLng(poi.latitude, poi.longitude),
        clusterManagerId: _clusterManager.clusterManagerId,
        onTap: () => _showPoiBottomSheet(poi),
        icon: await MapMarkerHelper.createCustomMarkerIcon(
          category: poi.primaryCategory,
          size: 120,
        ),
      );
      markers.add(marker);
    }

    setState(() {
      _markers = markers;
      _markerPoiMap = markerPoiMap;
    });
  }

  /// Crée les markers à partir de tous les types de contenus
  Future<void> _createMarkersFromContent(List<Content> contents) async {
    final markers = <Marker>{};
    final markerContentMap = <MarkerId, Content>{};

    for (final content in contents) {
      final markerId = MarkerId('${content.type.name}_${content.id}');
      markerContentMap[markerId] = content;

      // Choisir l'icône selon le type de contenu
      BitmapDescriptor icon;
      switch (content.type) {
        case ContentType.poi:
          icon = await MapMarkerHelper.createCustomMarkerIcon(
            category: content.primaryCategorySlug,
            size: 120,
          );
          break;
        case ContentType.event:
          icon = await _createEventMarkerIcon();
          break;
        case ContentType.activity:
          icon = await _createActivityMarkerIcon();
          break;
        case ContentType.tour:
          icon = await _createTourMarkerIcon();
          break;
      }

      final marker = Marker(
        markerId: markerId,
        position: LatLng(content.latitudeDouble, content.longitudeDouble),
        clusterManagerId: _clusterManager.clusterManagerId,
        onTap: () => _showContentBottomSheet(content),
        icon: icon,
      );
      markers.add(marker);
    }

    setState(() {
      _markers = markers;
      _markerContentMap = markerContentMap;
    });
  }

  /// Crée une icône pour les événements (utilise 'cultural' qui est violet/rose)
  Future<BitmapDescriptor> _createEventMarkerIcon() async {
    return MapMarkerHelper.createCustomMarkerIcon(
      category: 'cultural', // Rose pour les événements
      size: 120,
    );
  }

  /// Crée une icône pour les activités (utilise 'activity' qui est teal/vert)
  Future<BitmapDescriptor> _createActivityMarkerIcon() async {
    return MapMarkerHelper.createCustomMarkerIcon(
      category: 'activity', // Teal pour les activités
      size: 120,
    );
  }

  /// Crée une icône pour les tours (utilise 'adventure' qui est bleu-gris)
  Future<BitmapDescriptor> _createTourMarkerIcon() async {
    return MapMarkerHelper.createCustomMarkerIcon(
      category: 'adventure', // Bleu-gris pour les tours
      size: 120,
    );
  }

  /// Obtient la position de l'utilisateur
  Future<void> _getUserLocation() async {
    setState(() {
      _isLocatingUser = true;
    });

    try {
      final position = await _locationService.getCurrentPosition();

      if (position != null && mounted) {
        setState(() {
          _userPosition = position;
          _isLocatingUser = false;
        });
        print(
          '[MAP] Position utilisateur obtenue: ${position.latitude}, ${position.longitude}',
        );
      } else {
        setState(() {
          _isLocatingUser = false;
        });
      }
    } catch (e) {
      print('[MAP] Erreur lors de l\'obtention de la position: $e');
      setState(() {
        _isLocatingUser = false;
      });
    }
  }

  /// Centre la carte sur la position de l'utilisateur
  Future<void> _centerOnUserLocation() async {
    if (_userPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_userPosition!.latitude, _userPosition!.longitude),
            zoom: 14.0,
          ),
        ),
      );
    } else {
      // Demander la position si non disponible
      await _getUserLocation();

      if (_userPosition != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(_userPosition!.latitude, _userPosition!.longitude),
              zoom: 14.0,
            ),
          ),
        );
      } else {
        // Afficher un message si la position n'est pas disponible
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.mapLocationPermissionDenied,
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  /// Zoom in sur la carte
  Future<void> _zoomIn() async {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.zoomIn());
    }
  }

  /// Zoom out sur la carte
  Future<void> _zoomOut() async {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.zoomOut());
    }
  }

  Future<void> _loadPois() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Utiliser retry automatique
      final response = await RetryHelper.apiCall(
        apiRequest: () => _poiService.getPois(useCache: false),
        maxAttempts: 3,
        operationName: "Chargement POIs sur carte",
      );

      if (response.success && response.data != null) {
        final pois = response.data!.pois;

        // Créer les markers avec clustering natif
        await _createMarkers(pois);

        setState(() {
          _pois = pois;
          _filteredPois = pois;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        throw Exception(
          response.message ?? AppLocalizations.of(context)!.mapErrorLoading,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = RetryHelper.getErrorMessage(e);
      });

      if (mounted) {
        ErrorSnackBar.show(
          context,
          title: AppLocalizations.of(context)!.mapErrorLoading,
          message: RetryHelper.getErrorMessage(e),
          onRetry: _loadPois,
        );
      }
    }
  }

  /// Charge tous les types de contenus (POIs, Events, Activities)
  Future<void> _loadAllContent() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Utiliser retry automatique
      final response = await RetryHelper.apiCall(
        apiRequest: () => _contentService.getMappableContent(useCache: false),
        maxAttempts: 3,
        operationName: "Chargement de tous les contenus sur carte",
      );

      if (response.success && response.data != null) {
        final contents = response.data!;

        // Créer les markers pour tous les contenus
        await _createMarkersFromContent(contents);

        setState(() {
          _allContent = contents;
          _filteredContent = contents;
          _isLoading = false;
          _hasError = false;
        });

        print('[MAP] Contenus chargés: ${contents.length} items');
        print(
          '[MAP] POIs: ${contents.where((c) => c.type == ContentType.poi).length}',
        );
        print(
          '[MAP] Events: ${contents.where((c) => c.type == ContentType.event).length}',
        );
        print(
          '[MAP] Activities: ${contents.where((c) => c.type == ContentType.activity).length}',
        );
      } else {
        throw Exception(
          response.message ?? 'Erreur lors du chargement des contenus',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = RetryHelper.getErrorMessage(e);
      });

      if (mounted) {
        ErrorSnackBar.show(
          context,
          title: 'Erreur de chargement',
          message: RetryHelper.getErrorMessage(e),
          onRetry: _loadAllContent,
        );
      }
    }
  }

  void _navigateToPoiDetail(Poi poi) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PoiDetailPage(poi: poi)),
    );
  }

  void _filterPois(String query) async {
    setState(() {
      if (query.isEmpty) {
        _filteredPois = _pois;
      } else {
        _filteredPois = _pois.where((poi) {
          return (poi.name ?? '').toLowerCase().contains(query.toLowerCase()) ||
              poi.primaryCategory.toLowerCase().contains(query.toLowerCase()) ||
              (poi.shortDescription ?? '').toLowerCase().contains(
                query.toLowerCase(),
              );
        }).toList();
      }
    });

    // Recréer les markers avec les POIs filtrés
    await _createMarkers(_filteredPois);
  }

  /// Filtrer les contenus unifiés (POIs, Events, Activities, Tours)
  void _filterContent(String query) async {
    setState(() {
      if (query.isEmpty) {
        _filteredContent = _allContent;
      } else {
        _filteredContent = _allContent.where((content) {
          final searchQuery = query.toLowerCase();

          // Recherche dans le nom d'affichage
          final matchesName = content.displayName.toLowerCase().contains(
            searchQuery,
          );

          // Recherche dans la description
          final matchesDescription = content.description.toLowerCase().contains(
            searchQuery,
          );

          // Recherche dans la description courte
          final matchesShortDesc = (content.shortDescription ?? '')
              .toLowerCase()
              .contains(searchQuery);

          // Recherche dans la catégorie principale
          final matchesCategory = content.primaryCategory
              .toLowerCase()
              .contains(searchQuery);

          // Recherche dans le type de contenu
          final matchesType = content.typeKey.toLowerCase().contains(
            searchQuery,
          );

          // Recherche dans la localisation (pour les events)
          final matchesLocation = (content.location ?? '')
              .toLowerCase()
              .contains(searchQuery);

          return matchesName ||
              matchesDescription ||
              matchesShortDesc ||
              matchesCategory ||
              matchesType ||
              matchesLocation;
        }).toList();
      }
    });

    // Recréer les markers avec les contenus filtrés
    await _createMarkersFromContent(_filteredContent);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    // Si erreur, afficher widget d'erreur avec retry
    if (_hasError && !_isLoading) {
      return ErrorStateWidget.loading(
        resourceName: "la carte",
        errorDetails: _errorMessage,
        onRetry: _loadPois,
      );
    }

    // Si hors ligne, afficher une vue alternative
    if (_connectivityService.isOffline) {
      return _buildOfflineMapView();
    }

    // Google Maps sur toutes les plateformes
    return _buildGoogleMapView();
  }

  void _showPoiBottomSheet(Poi poi) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: Responsive.all(16),
        padding: Responsive.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: poi.imageUrl.isNotEmpty
                      ? Image.network(
                          poi.imageUrl,
                          width: 60.w,
                          height: 60.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 60.w,
                                height: 60.h,
                                color: const Color(0xFF3860F8).withOpacity(0.1),
                                child: const Icon(
                                  Icons.place,
                                  color: Color(0xFF3860F8),
                                ),
                              ),
                        )
                      : Container(
                          width: 60.w,
                          height: 60.h,
                          color: const Color(0xFF3860F8).withOpacity(0.1),
                          child: const Icon(
                            Icons.place,
                            color: Color(0xFF3860F8),
                          ),
                        ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        poi.name,
                        style: TextStyle(
                          fontSize: ResponsiveConstants.subtitle2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        poi.primaryCategory,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (poi.shortDescription?.isNotEmpty == true)
                        Text(
                          poi.shortDescription!,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToPoiDetail(poi);
                    },
                    icon: const Icon(Icons.info),
                    label: Text(AppLocalizations.of(context)!.mapViewDetails),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3860F8),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDirectionsOptions(poi);
                    },
                    icon: const Icon(Icons.directions),
                    label: Text(AppLocalizations.of(context)!.mapGetDirections),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Affiche le bottom sheet pour un contenu (POI, Event, Activity)
  void _showContentBottomSheet(Content content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: Responsive.all(16),
        padding: Responsive.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: content.imageUrl.isNotEmpty
                      ? Image.network(
                          content.imageUrl,
                          width: 60.w,
                          height: 60.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 60.w,
                                height: 60.h,
                                color: _getContentTypeColor(
                                  content.type,
                                ).withOpacity(0.1),
                                child: Icon(
                                  _getContentTypeIcon(content.type),
                                  color: _getContentTypeColor(content.type),
                                ),
                              ),
                        )
                      : Container(
                          width: 60.w,
                          height: 60.h,
                          color: _getContentTypeColor(
                            content.type,
                          ).withOpacity(0.1),
                          child: Icon(
                            _getContentTypeIcon(content.type),
                            color: _getContentTypeColor(content.type),
                          ),
                        ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge du type de contenu
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getContentTypeColor(
                            content.type,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          content.getLocalizedTypeLabel(context),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: _getContentTypeColor(content.type),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        content.displayName,
                        style: TextStyle(
                          fontSize: ResponsiveConstants.body1,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        content.primaryCategory,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (content.shortDescription?.isNotEmpty == true)
                        Text(
                          content.shortDescription!,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToContentDetail(content);
                    },
                    icon: const Icon(Icons.info),
                    label: Text(
                      AppLocalizations.of(context)!.contentViewDetails,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getContentTypeColor(content.type),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                /* SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDirectionsOptionsForContent(content);
                    },
                    icon: const Icon(Icons.directions),
                    label: Text('Itinéraire'),
                  ),
                ), */
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Retourne la couleur selon le type de contenu
  Color _getContentTypeColor(ContentType type) {
    switch (type) {
      case ContentType.poi:
        return const Color(0xFF3860F8); // Bleu
      case ContentType.event:
        return const Color(0xFFE91E63); // Rose
      case ContentType.activity:
        return const Color(0xFF009688); // Teal
      case ContentType.tour:
        return const Color(0xFF607D8B); // Bleu-gris
    }
  }

  /// Retourne l'icône selon le type de contenu
  IconData _getContentTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.poi:
        return Icons.place;
      case ContentType.event:
        return Icons.event;
      case ContentType.activity:
        return Icons.sports_tennis;
      case ContentType.tour:
        return Icons.hiking;
    }
  }

  /// Navigate vers les détails d'un contenu
  void _navigateToContentDetail(Content content) {
    // Pour le moment, on navigue seulement vers POI detail
    // TODO: Créer des pages de détails pour Event et Activity
    if (content.type == ContentType.poi) {
      // Conversion simplifiée de Content vers Poi (pour les POIs seulement)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ouverture des détails de: ${content.displayName}'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Page de détails ${content.getLocalizedTypeLabel(context)} - Bientôt disponible',
          ),
        ),
      );
    }
  }

  /// Affiche les options de directions pour un Content
  void _showDirectionsOptionsForContent(Content content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: Responsive.all(16),
        padding: Responsive.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.mapGetDirections,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Vers: ${content.displayName}',
              style: const TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(
                Icons.navigation,
                color: _getContentTypeColor(content.type),
              ),
              title: Text(AppLocalizations.of(context)!.mapOpenGoogleMaps),
              subtitle: Text(AppLocalizations.of(context)!.mapNavigationGPS),
              onTap: () async {
                Navigator.pop(context);
                final success = await _directionsService
                    .openGoogleMapsDirections(
                      destination: LatLng(
                        content.latitudeDouble,
                        content.longitudeDouble,
                      ),
                      destinationName: content.displayName,
                    );

                if (!success && mounted) {
                  ErrorSnackBar.show(
                    context,
                    message: AppLocalizations.of(context)!.mapErrorOpenMaps,
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.map,
                color: _getContentTypeColor(content.type),
              ),
              title: Text(AppLocalizations.of(context)!.mapShowOnMap),
              subtitle: Text(AppLocalizations.of(context)!.mapRouteInApp),
              onTap: () async {
                Navigator.pop(context);
                await _showDirectionsOnMapForContent(content);
              },
            ),
            if (_userPosition != null) ...[
              const Divider(),
              Padding(
                padding: Responsive.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Distance: ${_locationService.formatDistance(_locationService.calculateDistance(_userPosition!.latitude, _userPosition!.longitude, content.latitudeDouble, content.longitudeDouble))}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Affiche l'itinéraire sur la carte pour un Content
  Future<void> _showDirectionsOnMapForContent(Content content) async {
    if (_userPosition == null) {
      ErrorSnackBar.showWarning(
        context,
        message: AppLocalizations.of(context)!.mapErrorLocationUnavailable,
        onAction: _getUserLocation,
        actionLabel: AppLocalizations.of(context)!.mapActivate,
      );
      return;
    }

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: Responsive.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text(AppLocalizations.of(context)!.mapCalculatingRoute),
              ],
            ),
          ),
        ),
      ),
    );

    // Obtenir les directions
    final result = await _directionsService.getDirections(
      origin: LatLng(_userPosition!.latitude, _userPosition!.longitude),
      destination: LatLng(content.latitudeDouble, content.longitudeDouble),
    );

    // Fermer le dialog
    if (mounted) {
      Navigator.pop(context);
    }

    if (result != null && mounted) {
      // Créer la polyline
      final polyline = _directionsService.createPolyline(
        id: 'route_to_${content.type.name}_${content.id}',
        points: result.points,
      );

      setState(() {
        _polylines = {polyline};
        _selectedContentForDirections = content;
      });

      // Ajuster la caméra pour afficher tout l'itinéraire
      final bounds = _directionsService.calculateBounds(result.points);
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));

      // Afficher les infos de l'itinéraire
      ErrorSnackBar.showInfo(
        context,
        message: 'Distance: ${result.distance} • Durée: ${result.duration}',
        duration: const Duration(seconds: 10),
      );
    } else if (mounted) {
      ErrorSnackBar.show(
        context,
        message: AppLocalizations.of(context)!.mapErrorCalculatingRoute,
        onRetry: () => _showDirectionsOnMapForContent(content),
      );
    }
  }

  /// Affiche les options de directions pour un POI
  void _showDirectionsOptions(Poi poi) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: Responsive.all(16),
        padding: Responsive.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.mapGetDirections,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Vers: ${poi.name}',
              style: const TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: const Icon(Icons.navigation, color: Color(0xFF3860F8)),
              title: Text(AppLocalizations.of(context)!.mapOpenGoogleMaps),
              subtitle: Text(AppLocalizations.of(context)!.mapNavigationGPS),
              onTap: () async {
                Navigator.pop(context);
                final success = await _directionsService
                    .openGoogleMapsDirections(
                      destination: LatLng(poi.latitude, poi.longitude),
                      destinationName: poi.name,
                    );

                if (!success && mounted) {
                  ErrorSnackBar.show(
                    context,
                    message: AppLocalizations.of(context)!.mapErrorOpenMaps,
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.map, color: Color(0xFF3860F8)),
              title: Text(AppLocalizations.of(context)!.mapShowOnMap),
              subtitle: Text(AppLocalizations.of(context)!.mapRouteInApp),
              onTap: () async {
                Navigator.pop(context);
                await _showDirectionsOnMap(poi);
              },
            ),
            if (_userPosition != null) ...[
              const Divider(),
              Padding(
                padding: Responsive.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Distance: ${_locationService.formatDistance(_locationService.calculateDistance(_userPosition!.latitude, _userPosition!.longitude, poi.latitude, poi.longitude))}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Affiche l'itinéraire sur la carte
  Future<void> _showDirectionsOnMap(Poi poi) async {
    if (_userPosition == null) {
      ErrorSnackBar.showWarning(
        context,
        message: AppLocalizations.of(context)!.mapErrorLocationUnavailable,
        onAction: _getUserLocation,
        actionLabel: AppLocalizations.of(context)!.mapActivate,
      );
      return;
    }

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: Responsive.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text(AppLocalizations.of(context)!.mapCalculatingRoute),
              ],
            ),
          ),
        ),
      ),
    );

    // Obtenir les directions
    final result = await _directionsService.getDirections(
      origin: LatLng(_userPosition!.latitude, _userPosition!.longitude),
      destination: LatLng(poi.latitude, poi.longitude),
    );

    // Fermer le dialog
    if (mounted) {
      Navigator.pop(context);
    }

    if (result != null && mounted) {
      // Créer la polyline
      final polyline = _directionsService.createPolyline(
        id: 'route_to_${poi.id}',
        points: result.points,
      );

      setState(() {
        _polylines = {polyline};
        _selectedPoiForDirections = poi;
      });

      // Ajuster la caméra pour afficher tout l'itinéraire
      final bounds = _directionsService.calculateBounds(result.points);
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));

      // Afficher les infos de l'itinéraire
      ErrorSnackBar.showInfo(
        context,
        message: 'Distance: ${result.distance} • Durée: ${result.duration}',
        duration: const Duration(seconds: 10),
      );

      // Ajouter un bouton pour effacer dans un snackbar séparé ou utiliser le même
      // Note: ErrorSnackBar.showInfo ne supporte pas les actions custom pour le moment
      // On pourrait l'améliorer si nécessaire
    } else if (mounted) {
      ErrorSnackBar.show(
        context,
        message: AppLocalizations.of(context)!.mapErrorCalculatingRoute,
        onRetry: () => _showDirectionsOnMap(poi),
      );
    }
  }

  Widget _buildGoogleMapView() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                onChanged: _showAllContent ? _filterContent : _filterPois,
                decoration: InputDecoration(
                  hintText: MaterialLocalizations.of(context).searchFieldLabel,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              )
            : Text(
                AppLocalizations.of(context)!.mapTitle,
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
          ),
          onPressed: () {
            if (_isSearching) {
              setState(() {
                _isSearching = false;
                _searchController.clear();
                if (_showAllContent) {
                  _filterContent('');
                } else {
                  _filterPois('');
                }
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
                  _searchController.clear();
                  if (_showAllContent) {
                    _filterContent('');
                  } else {
                    _filterPois('');
                  }
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Carte Google Maps avec POIs
          _isLoading
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF006B96).withOpacity(0.3),
                        const Color(0xFFE8D5A3).withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF3860F8),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          AppLocalizations.of(context)!.mapLoading,
                          style: TextStyle(
                            fontSize: ResponsiveConstants.body1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: _initialPosition,
                  markers: _markers,
                  polylines: _polylines,
                  clusterManagers: {_clusterManager},
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                ),

          // Liste des POIs proches (conditionnelle)
          if (_showNearbyList)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height:
                    MediaQuery.of(context).size.height *
                    (isSmallScreen ? 0.45 : 0.4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle pour drag
                    Container(
                      margin: Responsive.symmetric(vertical: 8),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),

                    // Titre
                    Padding(
                      padding: Responsive.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.mapNearbyPois,
                            style: TextStyle(
                              fontSize: ResponsiveConstants.subtitle2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showNearbyList = false;
                              });
                            },
                            child: Text(
                              AppLocalizations.of(context)!.commonClose,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Liste
                    Expanded(
                      child: ListView.builder(
                        padding: Responsive.symmetric(horizontal: 16),
                        itemCount: _filteredPois.length,
                        itemBuilder: (context, index) {
                          final poi = _filteredPois[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(
                                0xFF3860F8,
                              ).withOpacity(0.1),
                              backgroundImage: poi.imageUrl.isNotEmpty
                                  ? NetworkImage(poi.imageUrl)
                                  : null,
                              child: poi.imageUrl.isEmpty
                                  ? const Icon(
                                      Icons.place,
                                      color: Color(0xFF3860F8),
                                    )
                                  : null,
                            ),
                            title: Text(
                              poi.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(poi.primaryCategory),
                            trailing: const Icon(
                              Icons.place,
                              color: Color(0xFF3860F8),
                            ),
                            onTap: () {
                              // Centrer la carte sur le POI
                              _mapController?.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(poi.latitude, poi.longitude),
                                    zoom: 15.0,
                                  ),
                                ),
                              );
                              setState(() {
                                _showNearbyList = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Boutons de contrôle (haut)
          Positioned(
            top: isSmallScreen ? 12 : 16,
            right: isSmallScreen ? 12 : 16,
            child: Column(
              children: [
                // Bouton Ma position
                FloatingActionButton.small(
                  heroTag: 'location',
                  onPressed: _centerOnUserLocation,
                  backgroundColor: _isLocatingUser
                      ? Colors.grey.shade300
                      : Colors.white,
                  foregroundColor: const Color(0xFF3860F8),
                  child: _isLocatingUser
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                ),
                SizedBox(height: 8.h),
                // Bouton Actualiser
                FloatingActionButton.small(
                  heroTag: 'refresh',
                  onPressed: _loadAllContent,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3860F8),
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),

          // Boutons de zoom (bas)
          Positioned(
            bottom: isSmallScreen ? 80 : 100,
            right: isSmallScreen ? 12 : 16,
            child: Column(
              children: [
                // Bouton Zoom In
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: _zoomIn,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3860F8),
                  child: const Icon(Icons.add),
                ),
                SizedBox(height: 8.h),
                // Bouton Zoom Out
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: _zoomOut,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3860F8),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSMapView() {
    return Column(
      children: [
        // Vue de la carte stylisée pour iOS
        Container(
          width: double.infinity,
          height: 200.h,
          margin: Responsive.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF3860F8).withOpacity(0.2),
                const Color(0xFFE8D5A3).withOpacity(0.2),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 48, color: const Color(0xFF3860F8)),
                SizedBox(height: 12.h),
                Text(
                  AppLocalizations.of(context)!.mapTitle,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.subtitle2,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3860F8),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  AppLocalizations.of(context)!.mapDefaultLocation,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body2,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _showAllContent ? _filterContent : _filterPois,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.discoverSearchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        if (_showAllContent) {
                          _filterContent('');
                        } else {
                          _filterPois('');
                        }
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.r),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        // Liste des POIs
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _filteredPois.length,
                  itemBuilder: (context, index) {
                    final poi = _filteredPois[index];
                    return Card(
                      margin: Responsive.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(
                            0xFF3860F8,
                          ).withOpacity(0.1),
                          backgroundImage: poi.imageUrl.isNotEmpty
                              ? NetworkImage(poi.imageUrl)
                              : null,
                          child: poi.imageUrl.isEmpty
                              ? const Icon(
                                  Icons.place,
                                  color: Color(0xFF3860F8),
                                )
                              : null,
                        ),
                        title: Text(
                          poi.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${poi.primaryCategory} • ${poi.latitude.toStringAsFixed(4)}, ${poi.longitude.toStringAsFixed(4)}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _navigateToPoiDetail(poi),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOfflineMapView() {
    return Column(
      children: [
        // Message d'information hors ligne
        Container(
          width: double.infinity,
          padding: Responsive.all(16),
          color: Colors.orange.withOpacity(0.1),
          child: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.orange),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.mapOfflineMessage,
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
        // Liste des POIs disponibles en cache
        Expanded(
          child: FutureBuilder(
            future: _loadCachedPois(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final pois = snapshot.data ?? <Poi>[];

              if (pois.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppLocalizations.of(context)!.mapOfflineNoData,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.mapOfflineConnectToDownload,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: pois.length,
                itemBuilder: (context, index) {
                  final poi = pois[index];
                  return Card(
                    margin: Responsive.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: const Icon(
                        Icons.place,
                        color: Color(0xFF3860F8),
                      ),
                      title: Text(poi.name),
                      subtitle: Text(poi.primaryCategory),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _navigateToPoiDetail(poi),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<Poi>> _loadCachedPois() async {
    final response = await _poiService.getPois(useCache: true);
    if (response.isSuccess && response.data != null) {
      return response.data!.pois;
    }
    return [];
  }
}
