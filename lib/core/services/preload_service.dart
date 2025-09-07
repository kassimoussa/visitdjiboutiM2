import 'dart:async';
import 'poi_service.dart';
import 'event_service.dart';
import 'cache_service.dart';
import 'localization_service.dart';

class PreloadService {
  static final PreloadService _instance = PreloadService._internal();
  factory PreloadService() => _instance;
  PreloadService._internal();

  final PoiService _poiService = PoiService();
  final EventService _eventService = EventService();
  final CacheService _cacheService = CacheService();
  final LocalizationService _localizationService = LocalizationService();

  bool _isPreloading = false;
  final List<String> _criticalRegions = ['Djibouti', 'Tadjourah', 'Ali Sabieh'];

  /// Précharge les données critiques au démarrage de l'app
  Future<void> preloadCriticalData({bool forceRefresh = false}) async {
    if (_isPreloading) return;
    
    _isPreloading = true;
    print('[PRELOAD] Démarrage du préchargement des données critiques...');

    try {
      // Précharger en parallèle pour optimiser les performances
      await Future.wait([
        _preloadMainPageData(forceRefresh: forceRefresh),
        _preloadCriticalRegions(forceRefresh: forceRefresh),
        _preloadUpcomingEvents(forceRefresh: forceRefresh),
      ], eagerError: false); // Continue même si une requête échoue

      print('[PRELOAD] Préchargement terminé avec succès');
    } catch (e) {
      print('[PRELOAD] Erreur lors du préchargement: $e');
    } finally {
      _isPreloading = false;
    }
  }

  /// Précharge les données de la page d'accueil
  Future<void> _preloadMainPageData({bool forceRefresh = false}) async {
    try {
      // POIs populaires pour l'écran d'accueil
      await _poiService.getPois(
        featured: true,
        perPage: 10,
        useCache: !forceRefresh,
      );
      print('[PRELOAD] POIs populaires préchargés');
    } catch (e) {
      print('[PRELOAD] Échec préchargement POIs populaires: $e');
    }
  }

  /// Précharge les régions les plus importantes
  Future<void> _preloadCriticalRegions({bool forceRefresh = false}) async {
    final futures = _criticalRegions.map((region) async {
      try {
        await _poiService.getPois(
          region: region,
          perPage: 15,
          useCache: !forceRefresh,
        );
        print('[PRELOAD] Région $region préchargée');
      } catch (e) {
        print('[PRELOAD] Échec préchargement région $region: $e');
      }
    });

    await Future.wait(futures, eagerError: false);
  }

  /// Précharge les événements à venir
  Future<void> _preloadUpcomingEvents({bool forceRefresh = false}) async {
    try {
      await _eventService.getEvents(
        status: 'upcoming',
        perPage: 10,
        sortBy: 'start_date',
        sortOrder: 'asc',
        useCache: !forceRefresh,
      );
      print('[PRELOAD] Événements à venir préchargés');
    } catch (e) {
      print('[PRELOAD] Échec préchargement événements: $e');
    }
  }

  /// Précharge une région spécifique (appelée quand l'utilisateur navigue)
  Future<void> preloadRegionOnDemand(String region) async {
    if (_criticalRegions.contains(region)) return; // Déjà préchargé
    
    try {
      print('[PRELOAD] Préchargement à la demande: $region');
      await _poiService.getPois(
        region: region,
        perPage: 20,
        useCache: true,
      );
    } catch (e) {
      print('[PRELOAD] Échec préchargement à la demande $region: $e');
    }
  }

  /// Nettoie le cache expiré en arrière-plan
  void backgroundCacheCleanup() {
    Timer.periodic(const Duration(hours: 4), (timer) async {
      try {
        await _cacheService.clearExpiredCache();
        print('[PRELOAD] Nettoyage automatique du cache effectué');
      } catch (e) {
        print('[PRELOAD] Erreur nettoyage cache: $e');
      }
    });
  }

  /// Précharge intelligente basée sur l'utilisation
  Future<void> smartPreload(List<String> userFavoriteRegions) async {
    final regionsToPreload = userFavoriteRegions
        .where((region) => !_criticalRegions.contains(region))
        .take(3) // Limiter à 3 régions supplémentaires
        .toList();

    if (regionsToPreload.isEmpty) return;

    print('[PRELOAD] Préchargement intelligent pour: $regionsToPreload');
    
    for (final region in regionsToPreload) {
      await preloadRegionOnDemand(region);
      // Petite pause pour éviter de surcharger le réseau
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Initialise le service de préchargement
  void initialize() {
    // Démarrer le nettoyage automatique du cache
    backgroundCacheCleanup();
    
    // Écouter les changements de langue pour recharger automatiquement
    _localizationService.addListener(_onLanguageChanged);
    
    // Précharger les données critiques après un court délai
    Future.delayed(const Duration(seconds: 2), () {
      preloadCriticalData();
    });
  }
  
  /// Callback appelé quand la langue change
  void _onLanguageChanged() {
    print('[PRELOAD] Langue changée détectée - rechargement des données');
    // Recharger en arrière-plan sans bloquer
    Future.delayed(const Duration(milliseconds: 500), () {
      reloadForLanguageChange();
    });
  }

  /// Obtient le statut du préchargement
  bool get isPreloading => _isPreloading;

  /// Recharge les données critiques dans une nouvelle langue
  Future<void> reloadForLanguageChange() async {
    print('[PRELOAD] Rechargement des données pour changement de langue...');
    
    // Forcer le rechargement même si déjà en cours
    _isPreloading = false;
    
    // Relancer le préchargement des données critiques avec forceRefresh
    await preloadCriticalData(forceRefresh: true);
    
    print('[PRELOAD] Rechargement terminé pour la nouvelle langue');
  }
}