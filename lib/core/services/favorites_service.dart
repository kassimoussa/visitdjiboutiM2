import 'package:shared_preferences/shared_preferences.dart';
import '../models/poi.dart';
import '../models/event.dart';
import '../models/api_response.dart';
import '../api/api_client.dart';
import 'poi_service.dart';
import 'event_service.dart';
import 'anonymous_auth_service.dart';

enum FavoriteType { poi, event }

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  // Clés de stockage unifiées
  static const String _favoritePoisKey = 'favorite_poi_ids';
  static const String _favoriteEventsKey = 'favorite_event_ids';
  static const String _lastSyncKey = 'favorites_last_sync';
  
  final PoiService _poiService = PoiService();
  final EventService _eventService = EventService();
  final AnonymousAuthService _authService = AnonymousAuthService();
  final ApiClient _apiClient = ApiClient();
  
  // Cache en mémoire pour éviter les appels répétés
  List<int>? _cachedPoiIds;
  List<int>? _cachedEventIds;
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
      }
      
      final prefs = await SharedPreferences.getInstance();
      final key = type == FavoriteType.poi ? _favoritePoisKey : _favoriteEventsKey;
      final favoriteIds = prefs.getStringList(key) ?? [];
      final ids = favoriteIds.map((id) => int.tryParse(id) ?? 0).where((id) => id > 0).toList();
      
      // Mettre à jour le cache
      if (type == FavoriteType.poi) {
        _cachedPoiIds = ids;
      } else {
        _cachedEventIds = ids;
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
      final key = type == FavoriteType.poi ? _favoritePoisKey : _favoriteEventsKey;
      final stringIds = ids.map((id) => id.toString()).toList();
      await prefs.setStringList(key, stringIds);
      
      // Mettre à jour le cache
      if (type == FavoriteType.poi) {
        _cachedPoiIds = ids;
      } else {
        _cachedEventIds = ids;
      }
      _lastCacheUpdate = DateTime.now();
      
      // Synchroniser avec l'API
      await _syncFavoritesWithAPI();
      
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
      favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
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
      favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
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
  
  /// Toggle l'état favori (méthode générique pour compatibilité)
  @Deprecated('Utilisez togglePoiFavorite() ou toggleEventFavorite()')
  Future<bool> toggleFavorite(int poiId) async {
    return await togglePoiFavorite(poiId);
  }

  /// Efface tous les favoris (POIs et Events)
  Future<bool> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritePoisKey);
      await prefs.remove(_favoriteEventsKey);
      
      // Vider le cache
      _cachedPoiIds = null;
      _cachedEventIds = null;
      _lastCacheUpdate = null;
      
      // Synchroniser avec l'API
      await _syncFavoritesWithAPI();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtient le nombre total de favoris (POIs + Events)
  Future<int> getFavoritesCount() async {
    try {
      final poiIds = await _getFavoriteIds(FavoriteType.poi);
      final eventIds = await _getFavoriteIds(FavoriteType.event);
      return poiIds.length + eventIds.length;
    } catch (e) {
      return 0;
    }
  }
  
  /// Obtient les statistiques détaillées des favoris
  Future<Map<String, dynamic>> getFavoritesStats() async {
    try {
      final poiIds = await _getFavoriteIds(FavoriteType.poi);
      final eventIds = await _getFavoriteIds(FavoriteType.event);
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getString(_lastSyncKey);
      
      return {
        'total_favorites': poiIds.length + eventIds.length,
        'poi_favorites': poiIds.length,
        'event_favorites': eventIds.length,
        'last_sync': lastSync,
        'cache_updated': _lastCacheUpdate?.toIso8601String(),
      };
    } catch (e) {
      return {
        'total_favorites': 0,
        'poi_favorites': 0,
        'event_favorites': 0,
        'error': e.toString(),
      };
    }
  }

  /// Exporte les favoris (utile pour backup/restore)
  Future<Map<String, List<int>>> exportFavorites() async {
    try {
      final poiIds = await _getFavoriteIds(FavoriteType.poi);
      final eventIds = await _getFavoriteIds(FavoriteType.event);
      
      return {
        'pois': poiIds,
        'events': eventIds,
      };
    } catch (e) {
      return {
        'pois': [],
        'events': [],
      };
    }
  }

  /// Importe des favoris (utile pour backup/restore)
  Future<bool> importFavorites(Map<String, List<int>> favorites) async {
    try {
      final poiIds = favorites['pois'] ?? [];
      final eventIds = favorites['events'] ?? [];
      
      final validPoiIds = poiIds.where((id) => id > 0).toList();
      final validEventIds = eventIds.where((id) => id > 0).toList();
      
      await _saveFavoriteIds(FavoriteType.poi, validPoiIds);
      await _saveFavoriteIds(FavoriteType.event, validEventIds);
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // NOUVELLES MÉTHODES POUR L'API
  
  /// Appel API pour toggle un favori sur le backend
  Future<void> _toggleFavoriteOnAPI(FavoriteType type, int itemId, bool isAdding) async {
    try {
      final token = _authService.authToken;
      if (token == null) {
        print('Pas de token d\'authentification pour synchroniser les favoris');
        return;
      }
      
      final endpoint = type == FavoriteType.poi 
          ? '/favorites/pois/$itemId'
          : '/favorites/events/$itemId';
      
      if (isAdding) {
        await _apiClient.dio.post(endpoint);
      } else {
        await _apiClient.dio.delete(endpoint);
      }
      
      print('Favori ${isAdding ? 'ajouté' : 'supprimé'} sur l\'API: $type $itemId');
      
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
        print('Pas de token pour synchroniser depuis l\'API');
        return;
      }
      
      // Récupérer tous les favoris depuis l'API
      final response = await _apiClient.dio.get('/favorites');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final poiFavorites = (data['pois'] as List? ?? [])
            .map((item) => item['id'] as int)
            .toList();
        final eventFavorites = (data['events'] as List? ?? [])
            .map((item) => item['id'] as int)
            .toList();
        
        // Sauvegarder localement (sans rappeler l'API)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_favoritePoisKey, poiFavorites.map((id) => id.toString()).toList());
        await prefs.setStringList(_favoriteEventsKey, eventFavorites.map((id) => id.toString()).toList());
        
        // Mettre à jour le cache
        _cachedPoiIds = poiFavorites;
        _cachedEventIds = eventFavorites;
        _lastCacheUpdate = DateTime.now();
        
        print('Synchronisation depuis l\'API terminée: ${poiFavorites.length} POIs, ${eventFavorites.length} Events');
      }
      
    } catch (e) {
      print('Erreur lors de la synchronisation depuis l\'API: $e');
    }
  }
  
  /// Vide le cache pour forcer un rechargement
  void clearCache() {
    _cachedPoiIds = null;
    _cachedEventIds = null;
    _lastCacheUpdate = null;
  }
}