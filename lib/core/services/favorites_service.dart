import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/poi.dart';
import '../models/event.dart';
import '../models/tour.dart';
import '../models/activity.dart';
import '../api/api_client.dart';
import 'poi_service.dart';
import 'event_service.dart';
import 'tour_service.dart';
import 'activity_service.dart';
import 'anonymous_auth_service.dart';
import 'connectivity_service.dart';
import 'cache_service.dart';

enum FavoriteType { poi, event, tour, activity }

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  // StreamController to broadcast changes to favorites
  final _favoritesController = StreamController<void>.broadcast();
  Stream<void> get favoritesStream => _favoritesController.stream;

  // Clés de stockage unifiées
  static const String _favoritePoisKey = 'favorite_poi_ids';
  static const String _favoriteEventsKey = 'favorite_event_ids';
  static const String _favoriteToursKey = 'favorite_tour_ids';
  static const String _favoriteActivitiesKey = 'favorite_activity_ids';
  static const String _lastSyncKey = 'favorites_last_sync';

  final PoiService _poiService = PoiService();
  final EventService _eventService = EventService();
  final TourService _tourService = TourService();
  final ActivityService _activityService = ActivityService();
  final AnonymousAuthService _authService = AnonymousAuthService();
  final ApiClient _apiClient = ApiClient();
  final ConnectivityService _connectivityService = ConnectivityService();
  final CacheService _cacheService = CacheService();

  // Cache en mémoire pour éviter les appels répétés
  List<int>? _cachedPoiIds;
  List<int>? _cachedEventIds;
  List<int>? _cachedTourIds;
  List<int>? _cachedActivityIds;
  DateTime? _lastCacheUpdate;

  /// Obtient la liste des IDs favoris depuis SharedPreferences avec cache
  Future<List<int>> _getFavoriteIds(FavoriteType type) async {
    try {
      // Vérifier le cache
      if (_lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!).inMinutes < 5) {
        if (type == FavoriteType.poi && _cachedPoiIds != null) {
          return _cachedPoiIds!;
        }
        if (type == FavoriteType.event && _cachedEventIds != null) {
          return _cachedEventIds!;
        }
        if (type == FavoriteType.tour && _cachedTourIds != null) {
          return _cachedTourIds!;
        }
        if (type == FavoriteType.activity && _cachedActivityIds != null) {
          return _cachedActivityIds!;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      String key;
      switch (type) {
        case FavoriteType.poi:
          key = _favoritePoisKey;
          break;
        case FavoriteType.event:
          key = _favoriteEventsKey;
          break;
        case FavoriteType.tour:
          key = _favoriteToursKey;
          break;
        case FavoriteType.activity:
          key = _favoriteActivitiesKey;
          break;
      }
      final favoriteIds = prefs.getStringList(key) ?? [];
      final ids = favoriteIds
          .map((id) => int.tryParse(id) ?? 0)
          .where((id) => id > 0)
          .toList();

      // Mettre à jour le cache
      if (type == FavoriteType.poi) {
        _cachedPoiIds = ids;
      } else if (type == FavoriteType.event) {
        _cachedEventIds = ids;
      } else if (type == FavoriteType.tour) {
        _cachedTourIds = ids;
      } else if (type == FavoriteType.activity) {
        _cachedActivityIds = ids;
      }
      _lastCacheUpdate = DateTime.now();

      return ids;
    } catch (e) {
      return [];
    }
  }

  /// Sauvegarde les IDs favoris localement ET sur l'API
  Future<void> _saveFavoriteIds(FavoriteType type, List<int> ids) async {
    try {
      // Sauvegarder localement
      final prefs = await SharedPreferences.getInstance();
      String key;
      switch (type) {
        case FavoriteType.poi:
          key = _favoritePoisKey;
          break;
        case FavoriteType.event:
          key = _favoriteEventsKey;
          break;
        case FavoriteType.tour:
          key = _favoriteToursKey;
          break;
        case FavoriteType.activity:
          key = _favoriteActivitiesKey;
          break;
      }
      final stringIds = ids.map((id) => id.toString()).toList();
      await prefs.setStringList(key, stringIds);

      // Mettre à jour le cache
      if (type == FavoriteType.poi) {
        _cachedPoiIds = ids;
      } else if (type == FavoriteType.event) {
        _cachedEventIds = ids;
      } else if (type == FavoriteType.tour) {
        _cachedTourIds = ids;
      } else if (type == FavoriteType.activity) {
        _cachedActivityIds = ids;
      }
      _lastCacheUpdate = DateTime.now();

      // Synchroniser avec l'API
      await _syncFavoritesWithAPI();

      // Notify listeners that the favorites have changed
      _favoritesController.add(null);
    } catch (e) {
      print('Erreur lors de la sauvegarde des favoris: $e');
    }
  }

  /// Obtient la liste complète des POIs favoris avec leurs données
  Future<List<Poi>> getFavoritePois() async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.poi);
      final List<Poi> favorites = [];

      // Récupérer les détails de chaque POI favori
      for (final id in favoriteIds) {
        final response = await _poiService.getPoiById(id);
        if (response.isSuccess && response.hasData) {
          favorites.add(response.data!);
        }
      }

      // Trier par date d'ajout en favori (les plus récents en premier)
      favorites.sort((a, b) {
        final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
        final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

      return favorites;
    } catch (e) {
      return [];
    }
  }

  /// Obtient la liste complète des Events favoris avec leurs données
  Future<List<Event>> getFavoriteEvents() async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.event);
      final List<Event> favorites = [];

      // Récupérer les détails de chaque Event favori
      for (final id in favoriteIds) {
        final response = await _eventService.getEventById(id);
        if (response.isSuccess && response.hasData) {
          favorites.add(response.data!);
        }
      }

      // Trier par date d'ajout en favori (les plus récents en premier)
      favorites.sort((a, b) {
        final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
        final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

      return favorites;
    } catch (e) {
      return [];
    }
  }

  /// Obtient la liste complète des Tours favoris avec leurs données
  Future<List<Tour>> getFavoriteTours() async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.tour);
      final List<Tour> favorites = [];

      // Récupérer les détails de chaque Tour favori
      for (final id in favoriteIds) {
        try {
          final tour = await _tourService.getTourDetails(id);
          favorites.add(tour);
        } catch (e) {
          print('Erreur lors du chargement du tour $id: $e');
        }
      }

      // Trier par date d'ajout en favori (les plus récents en premier)
      favorites.sort((a, b) {
        final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
        final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

      return favorites;
    } catch (e) {
      return [];
    }
  }

  /// Obtient la liste complète des Activities favoris avec leurs données
  Future<List<Activity>> getFavoriteActivities() async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.activity);
      final List<Activity> favorites = [];

      // Récupérer les détails de chaque Activity favori
      for (final id in favoriteIds) {
        try {
          final activity = await _activityService.getActivityDetails(id);
          favorites.add(activity);
        } catch (e) {
          print('Erreur lors du chargement de l\'activité $id: $e');
        }
      }

      // Trier par date d'ajout en favori (les plus récents en premier)
      favorites.sort((a, b) {
        final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
        final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

      return favorites;
    } catch (e) {
      return [];
    }
  }

  /// Obtient tous les favoris (POIs + Events) pour compatibilité
  @Deprecated('Utilisez getFavoritePois() et getFavoriteEvents() séparément')
  Future<List<Poi>> getFavorites() async {
    return await getFavoritePois();
  }

  /// Ajoute un POI aux favoris (local + API)
  Future<bool> addPoiToFavorites(int poiId) async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.poi);

      if (!favoriteIds.contains(poiId)) {
        favoriteIds.add(poiId);
        await _saveFavoriteIds(FavoriteType.poi, favoriteIds);

        // Appel API pour synchroniser
        await _toggleFavoriteOnAPI(FavoriteType.poi, poiId, true);

        // Incrémenter le compteur pour les triggers de conversion
        await _authService.incrementFavoritesCount();

        return true;
      }
      return false; // Déjà en favori
    } catch (e) {
      print('Erreur lors de l\'ajout POI aux favoris: $e');
      return false;
    }
  }

  /// Ajoute un Event aux favoris (local + API)
  Future<bool> addEventToFavorites(int eventId) async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.event);

      if (!favoriteIds.contains(eventId)) {
        favoriteIds.add(eventId);
        await _saveFavoriteIds(FavoriteType.event, favoriteIds);

        // Appel API pour synchroniser
        await _toggleFavoriteOnAPI(FavoriteType.event, eventId, true);

        // Incrémenter le compteur pour les triggers de conversion
        await _authService.incrementFavoritesCount();

        return true;
      }
      return false; // Déjà en favori
    } catch (e) {
      print('Erreur lors de l\'ajout Event aux favoris: $e');
      return false;
    }
  }

  /// Ajoute un tour aux favoris (local + API)
  Future<bool> addTourToFavorites(int tourId) async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.tour);

      if (!favoriteIds.contains(tourId)) {
        favoriteIds.add(tourId);
        await _saveFavoriteIds(FavoriteType.tour, favoriteIds);

        // Appel API pour synchroniser
        await _toggleFavoriteOnAPI(FavoriteType.tour, tourId, true);

        // Incrémenter le compteur pour les triggers de conversion
        await _authService.incrementFavoritesCount();

        return true;
      }
      return false; // Déjà en favori
    } catch (e) {
      print('Erreur lors de l\'ajout Tour aux favoris: $e');
      return false;
    }
  }

  /// Ajoute une activité aux favoris (local + API)
  Future<bool> addActivityToFavorites(int activityId) async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.activity);

      if (!favoriteIds.contains(activityId)) {
        favoriteIds.add(activityId);
        await _saveFavoriteIds(FavoriteType.activity, favoriteIds);

        // Appel API pour synchroniser
        await _toggleFavoriteOnAPI(FavoriteType.activity, activityId, true);

        // Incrémenter le compteur pour les triggers de conversion
        await _authService.incrementFavoritesCount();

        return true;
      }
      return false; // Déjà en favori
    } catch (e) {
      print('Erreur lors de l\'ajout Activity aux favoris: $e');
      return false;
    }
  }

  /// Ajoute un item aux favoris (méthode générique pour compatibilité)
  @Deprecated('Utilisez addPoiToFavorites() ou addEventToFavorites()')
  Future<bool> addToFavorites(int poiId) async {
    return await addPoiToFavorites(poiId);
  }

  /// Supprime un POI des favoris (local + API)
  Future<bool> removePoiFromFavorites(int poiId) async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.poi);

      if (favoriteIds.contains(poiId)) {
        favoriteIds.remove(poiId);
        await _saveFavoriteIds(FavoriteType.poi, favoriteIds);

        // Appel API pour synchroniser
        await _toggleFavoriteOnAPI(FavoriteType.poi, poiId, false);

        // Décrémenter le compteur pour les triggers de conversion
        await _authService.decrementFavoritesCount();

        return true;
      }
      return false; // N'était pas en favori
    } catch (e) {
      print('Erreur lors de la suppression POI des favoris: $e');
      return false;
    }
  }

  /// Supprime un Event des favoris (local + API)
  Future<bool> removeEventFromFavorites(int eventId) async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.event);

      if (favoriteIds.contains(eventId)) {
        favoriteIds.remove(eventId);
        await _saveFavoriteIds(FavoriteType.event, favoriteIds);

        // Appel API pour synchroniser
        await _toggleFavoriteOnAPI(FavoriteType.event, eventId, false);

        // Décrémenter le compteur pour les triggers de conversion
        await _authService.decrementFavoritesCount();

        return true;
      }
      return false; // N'était pas en favori
    } catch (e) {
      print('Erreur lors de la suppression Event des favoris: $e');
      return false;
    }
  }

  /// Supprime un Tour des favoris (local + API)
  Future<bool> removeTourFromFavorites(int tourId) async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.tour);

      if (favoriteIds.contains(tourId)) {
        favoriteIds.remove(tourId);
        await _saveFavoriteIds(FavoriteType.tour, favoriteIds);

        // Appel API pour synchroniser
        await _toggleFavoriteOnAPI(FavoriteType.tour, tourId, false);

        // Décrémenter le compteur pour les triggers de conversion
        await _authService.decrementFavoritesCount();

        return true;
      }
      return false; // N'était pas en favori
    } catch (e) {
      print('Erreur lors de la suppression Tour des favoris: $e');
      return false;
    }
  }

  /// Supprime une activité des favoris (local + API)
  Future<bool> removeActivityFromFavorites(int activityId) async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.activity);

      if (favoriteIds.contains(activityId)) {
        favoriteIds.remove(activityId);
        await _saveFavoriteIds(FavoriteType.activity, favoriteIds);

        // Appel API pour synchroniser
        await _toggleFavoriteOnAPI(FavoriteType.activity, activityId, false);

        // Décrémenter le compteur pour les triggers de conversion
        await _authService.decrementFavoritesCount();

        return true;
      }
      return false; // N'était pas en favori
    } catch (e) {
      print('Erreur lors de la suppression Activity des favoris: $e');
      return false;
    }
  }

  /// Supprime un item des favoris (méthode générique pour compatibilité)
  @Deprecated('Utilisez removePoiFromFavorites() ou removeEventFromFavorites()')
  Future<bool> removeFromFavorites(int poiId) async {
    return await removePoiFromFavorites(poiId);
  }

  /// Vérifie si un POI est en favori
  Future<bool> isPoiFavorite(int poiId) async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.poi);
      return favoriteIds.contains(poiId);
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si un Event est en favori
  Future<bool> isEventFavorite(int eventId) async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.event);
      return favoriteIds.contains(eventId);
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si un item est en favori (méthode générique pour compatibilité)
  @Deprecated('Utilisez isPoiFavorite() ou isEventFavorite()')
  Future<bool> isFavorite(int poiId) async {
    return await isPoiFavorite(poiId);
  }

  /// Toggle l'état favori d'un POI
  Future<bool> togglePoiFavorite(int poiId) async {
    try {
      final isCurrentlyFavorite = await isPoiFavorite(poiId);

      if (isCurrentlyFavorite) {
        return await removePoiFromFavorites(poiId);
      } else {
        return await addPoiToFavorites(poiId);
      }
    } catch (e) {
      return false;
    }
  }

  /// Toggle l'état favori d'un Event
  Future<bool> toggleEventFavorite(int eventId) async {
    try {
      final isCurrentlyFavorite = await isEventFavorite(eventId);

      if (isCurrentlyFavorite) {
        return await removeEventFromFavorites(eventId);
      } else {
        return await addEventToFavorites(eventId);
      }
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si un tour est en favori
  Future<bool> isTourFavorite(int tourId) async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.tour);
      return favoriteIds.contains(tourId);
    } catch (e) {
      return false;
    }
  }

  /// Toggle l'état favori d'un Tour
  Future<bool> toggleTourFavorite(int tourId) async {
    try {
      final isCurrentlyFavorite = await isTourFavorite(tourId);

      if (isCurrentlyFavorite) {
        return await removeTourFromFavorites(tourId);
      } else {
        return await addTourToFavorites(tourId);
      }
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si une activité est en favori
  Future<bool> isActivityFavorite(int activityId) async {
    try {
      final favoriteIds = await _getFavoriteIds(FavoriteType.activity);
      return favoriteIds.contains(activityId);
    } catch (e) {
      return false;
    }
  }

  /// Toggle l'état favori d'une activité
  Future<bool> toggleActivityFavorite(int activityId) async {
    try {
      final isCurrentlyFavorite = await isActivityFavorite(activityId);

      if (isCurrentlyFavorite) {
        return await removeActivityFromFavorites(activityId);
      } else {
        return await addActivityToFavorites(activityId);
      }
    } catch (e) {
      return false;
    }
  }

  /// Toggle l'état favori (méthode générique pour compatibilité)
  @Deprecated('Utilisez togglePoiFavorite() ou toggleEventFavorite()')
  Future<bool> toggleFavorite(int poiId) async {
    return await togglePoiFavorite(poiId);
  }

  /// Efface tous les favoris (POIs, Events, Tours et Activities)
  Future<bool> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritePoisKey);
      await prefs.remove(_favoriteEventsKey);
      await prefs.remove(_favoriteToursKey);
      await prefs.remove(_favoriteActivitiesKey);

      // Vider le cache
      _cachedPoiIds = null;
      _cachedEventIds = null;
      _cachedTourIds = null;
      _cachedActivityIds = null;
      _lastCacheUpdate = null;

      // Synchroniser avec l'API
      await _syncFavoritesWithAPI();

      // Notify listeners
      _favoritesController.add(null);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtient le nombre total de favoris (POIs + Events + Tours + Activities)
  Future<int> getFavoritesCount() async {
    try {
      final poiIds = await _getFavoriteIds(FavoriteType.poi);
      final eventIds = await _getFavoriteIds(FavoriteType.event);
      final tourIds = await _getFavoriteIds(FavoriteType.tour);
      final activityIds = await _getFavoriteIds(FavoriteType.activity);
      return poiIds.length +
          eventIds.length +
          tourIds.length +
          activityIds.length;
    } catch (e) {
      return 0;
    }
  }

  /// Obtient les statistiques détaillées des favoris
  Future<Map<String, dynamic>> getFavoritesStats() async {
    try {
      final poiIds = await _getFavoriteIds(FavoriteType.poi);
      final eventIds = await _getFavoriteIds(FavoriteType.event);
      final tourIds = await _getFavoriteIds(FavoriteType.tour);
      final activityIds = await _getFavoriteIds(FavoriteType.activity);
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getString(_lastSyncKey);

      return {
        'total_favorites':
            poiIds.length +
            eventIds.length +
            tourIds.length +
            activityIds.length,
        'poi_favorites': poiIds.length,
        'event_favorites': eventIds.length,
        'tour_favorites': tourIds.length,
        'activity_favorites': activityIds.length,
        'last_sync': lastSync,
        'cache_updated': _lastCacheUpdate?.toIso8601String(),
      };
    } catch (e) {
      return {
        'total_favorites': 0,
        'poi_favorites': 0,
        'event_favorites': 0,
        'tour_favorites': 0,
        'activity_favorites': 0,
        'error': e.toString(),
      };
    }
  }

  /// Exporte les favoris (utile pour backup/restore)
  Future<Map<String, List<int>>> exportFavorites() async {
    try {
      final poiIds = await _getFavoriteIds(FavoriteType.poi);
      final eventIds = await _getFavoriteIds(FavoriteType.event);
      final tourIds = await _getFavoriteIds(FavoriteType.tour);
      final activityIds = await _getFavoriteIds(FavoriteType.activity);

      return {
        'pois': poiIds,
        'events': eventIds,
        'tours': tourIds,
        'activities': activityIds,
      };
    } catch (e) {
      return {'pois': [], 'events': [], 'tours': [], 'activities': []};
    }
  }

  /// Importe des favoris (utile pour backup/restore)
  Future<bool> importFavorites(Map<String, List<int>> favorites) async {
    try {
      final poiIds = favorites['pois'] ?? [];
      final eventIds = favorites['events'] ?? [];
      final tourIds = favorites['tours'] ?? [];
      final activityIds = favorites['activities'] ?? [];

      final validPoiIds = poiIds.where((id) => id > 0).toList();
      final validEventIds = eventIds.where((id) => id > 0).toList();
      final validTourIds = tourIds.where((id) => id > 0).toList();
      final validActivityIds = activityIds.where((id) => id > 0).toList();

      await _saveFavoriteIds(FavoriteType.poi, validPoiIds);
      await _saveFavoriteIds(FavoriteType.event, validEventIds);
      await _saveFavoriteIds(FavoriteType.tour, validTourIds);
      await _saveFavoriteIds(FavoriteType.activity, validActivityIds);

      // Notify listeners
      _favoritesController.add(null);

      return true;
    } catch (e) {
      return false;
    }
  }

  // NOUVELLES MÉTHODES POUR L'API

  /// Appel API pour toggle un favori sur le backend
  Future<void> _toggleFavoriteOnAPI(
    FavoriteType type,
    int itemId,
    bool isAdding,
  ) async {
    try {
      final token = _authService.authToken;
      if (token == null) {
        print('Pas de token d\'authentification pour synchroniser les favoris');
        return;
      }

      String endpoint;
      switch (type) {
        case FavoriteType.poi:
          endpoint = '/favorites/pois/$itemId';
          break;
        case FavoriteType.event:
          endpoint = '/favorites/events/$itemId';
          break;
        case FavoriteType.tour:
          endpoint = '/favorites/tours/$itemId';
          break;
        case FavoriteType.activity:
          endpoint = '/favorites/activities/$itemId';
          break;
      }

      if (isAdding) {
        await _apiClient.dio.post(endpoint);
      } else {
        await _apiClient.dio.delete(endpoint);
      }

      print(
        'Favori ${isAdding ? 'ajouté' : 'supprimé'} sur l\'API: $type $itemId',
      );
    } catch (e) {
      print('Erreur lors de la synchronisation API des favoris: $e');
      // Ne pas faire échouer l'opération locale si l'API échoue
    }
  }

  /// Synchronise les favoris locaux avec l'API
  Future<void> _syncFavoritesWithAPI() async {
    try {
      final token = _authService.authToken;
      if (token == null) {
        print('Pas de token d\'authentification pour synchroniser');
        return;
      }

      // Marquer la date de dernière sync
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

      print('Synchronisation des favoris avec l\'API terminée');
    } catch (e) {
      print('Erreur lors de la synchronisation API: $e');
    }
  }

  /// Synchronise depuis l'API vers le local (à appeler au démarrage)
  Future<void> syncFromAPI() async {
    try {
      final token = _authService.authToken;
      if (token == null) {
        print('[FAVORITES] Pas de token pour synchroniser depuis l\'API');
        return;
      }

      print('[FAVORITES] Synchronisation depuis l\'API en cours...');

      final List<int> poiFavorites = [];
      final List<int> eventFavorites = [];
      final List<int> tourFavorites = [];
      final List<int> activityFavorites = [];

      // Essayer d'abord l'endpoint principal /favorites
      try {
        print('[FAVORITES] Appel de l\'endpoint principal /favorites...');
        final response = await _apiClient.dio.get('/favorites');
        print('[FAVORITES] Status: ${response.statusCode}');

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          print('[FAVORITES] Data keys: ${data.keys}');

          // Structure réelle: {data: {favorites: [{id, type, ...}, ...], total, pois_count, ...}}
          if (data.containsKey('data') && data['data'] is Map) {
            final dataMap = data['data'] as Map<String, dynamic>;
            print('[FAVORITES] DataMap keys: ${dataMap.keys}');

            // Extraire la liste de favoris
            if (dataMap.containsKey('favorites') && dataMap['favorites'] is List) {
              final favorites = dataMap['favorites'] as List;
              print('[FAVORITES] Trouvé ${favorites.length} favoris au total');

              // Parcourir et séparer par type
              for (var item in favorites) {
                final type = item['type'] as String?;
                final id = item['id'] as int;

                switch (type) {
                  case 'Poi':
                    poiFavorites.add(id);
                    break;
                  case 'Event':
                    eventFavorites.add(id);
                    break;
                  case 'Tour':
                    tourFavorites.add(id);
                    break;
                  case 'Activity':
                    activityFavorites.add(id);
                    break;
                  default:
                    print('[FAVORITES] Type inconnu: $type pour id=$id');
                }
              }

              print('[FAVORITES] Trouvé ${poiFavorites.length} POIs favoris');
              print('[FAVORITES] Trouvé ${eventFavorites.length} Events favoris');
              print('[FAVORITES] Trouvé ${tourFavorites.length} Tours favoris');
              print('[FAVORITES] Trouvé ${activityFavorites.length} Activities favoris');
            }
          }
        }
      } catch (e) {
        print('[FAVORITES] Erreur avec endpoint /favorites: $e');
        print('[FAVORITES] Fallback vers /favorites/pois...');

        // Fallback: essayer l'endpoint /favorites/pois si /favorites échoue
        try {
          final poisResponse = await _apiClient.dio.get('/favorites/pois');
          if (poisResponse.statusCode == 200 && poisResponse.data != null) {
            final poisData = poisResponse.data;
            if (poisData is Map && poisData.containsKey('data')) {
              final dataMap = poisData['data'] as Map;
              if (dataMap.containsKey('pois')) {
                final pois = dataMap['pois'] as List;
                poiFavorites.addAll(pois.map((p) => p['id'] as int));
                print('[FAVORITES] Trouvé ${poiFavorites.length} POIs favoris (via fallback)');
              }
            }
          }
        } catch (e2) {
          print('[FAVORITES] Erreur fallback POIs: $e2');
        }
      }

      // Sauvegarder localement (sans rappeler l'API)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _favoritePoisKey,
        poiFavorites.map((id) => id.toString()).toList(),
      );
      await prefs.setStringList(
        _favoriteEventsKey,
        eventFavorites.map((id) => id.toString()).toList(),
      );
      await prefs.setStringList(
        _favoriteToursKey,
        tourFavorites.map((id) => id.toString()).toList(),
      );
      await prefs.setStringList(
        _favoriteActivitiesKey,
        activityFavorites.map((id) => id.toString()).toList(),
      );

      // Mettre à jour le cache
      _cachedPoiIds = poiFavorites;
      _cachedEventIds = eventFavorites;
      _cachedTourIds = tourFavorites;
      _cachedActivityIds = activityFavorites;
      _lastCacheUpdate = DateTime.now();

      // Notify listeners that the favorites have changed
      _favoritesController.add(null);

      print(
        '[FAVORITES] Synchronisation terminée: ${poiFavorites.length} POIs, ${eventFavorites.length} Events, ${tourFavorites.length} Tours, ${activityFavorites.length} Activities',
      );
    } catch (e) {
      print('[FAVORITES] Erreur lors de la synchronisation depuis l\'API: $e');
    }
  }

  /// Vide le cache pour forcer un rechargement
  void clearCache() {
    _cachedPoiIds = null;
    _cachedEventIds = null;
    _cachedTourIds = null;
    _cachedActivityIds = null;
    _lastCacheUpdate = null;
  }
}
