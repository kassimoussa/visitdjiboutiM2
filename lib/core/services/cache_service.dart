import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const Duration _defaultCacheDuration = Duration(minutes: 15);
  static const Duration _offlineCacheDuration = Duration(days: 7); // Cache plus long pour mode hors ligne
  
  final ConnectivityService _connectivityService = ConnectivityService();
  
  // Stockage avec timestamp pour expiration et support hors ligne
  Future<void> cacheData(String key, dynamic data, {Duration? cacheDuration, bool isOfflineData = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveDuration = isOfflineData ? _offlineCacheDuration : (cacheDuration ?? _defaultCacheDuration);
    
    final cacheItem = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'duration': effectiveDuration.inMilliseconds,
      'isOfflineData': isOfflineData,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    await prefs.setString(key, jsonEncode(cacheItem));
    print('[CACHE] Données mises en cache: $key (${isOfflineData ? "hors ligne" : "normale"})');
  }

  // Récupération avec vérification d'expiration et support hors ligne
  Future<T?> getCachedData<T>(String key, {bool allowExpiredIfOffline = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(key);
    
    if (cachedString == null) return null;
    
    try {
      final cacheItem = jsonDecode(cachedString);
      final timestamp = cacheItem['timestamp'] as int;
      final duration = cacheItem['duration'] as int;
      final isOfflineData = cacheItem['isOfflineData'] as bool? ?? false;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Vérifier si le cache a expiré
      final isExpired = now - timestamp > duration;
      
      if (isExpired) {
        // Si hors ligne et que les données expirées sont autorisées, les retourner quand même
        if (allowExpiredIfOffline && _connectivityService.isOffline) {
          print('[CACHE] Données expirées utilisées en mode hors ligne: $key');
          return cacheItem['data'] as T;
        }
        
        // Sinon, supprimer le cache expiré
        await prefs.remove(key);
        return null;
      }
      
      return cacheItem['data'] as T;
    } catch (e) {
      // Supprimer le cache corrompu
      await prefs.remove(key);
      return null;
    }
  }

  // Cache spécifique pour les POIs
  Future<void> cachePois(String region, List<dynamic> pois) async {
    await cacheData('pois_$region', pois, cacheDuration: const Duration(hours: 2));
  }

  Future<List<dynamic>?> getCachedPois(String region) async {
    return getCachedData<List<dynamic>>('pois_$region');
  }

  // Cache pour les événements
  Future<void> cacheEvents(List<dynamic> events, {String? languageCode}) async {
    final cacheKey = languageCode != null ? 'events_$languageCode' : 'events';
    await cacheData(cacheKey, events, cacheDuration: const Duration(minutes: 30));
  }

  Future<List<dynamic>?> getCachedEvents({String? languageCode}) async {
    final cacheKey = languageCode != null ? 'events_$languageCode' : 'events';
    return getCachedData<List<dynamic>>(cacheKey);
  }

  // Nettoyage du cache
  Future<void> clearExpiredCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => 
      key.startsWith('pois_') || key.startsWith('events')).toList();
    
    for (final key in keys) {
      await getCachedData(key); // This will auto-remove expired items
    }
  }
  
  // Vider tout le cache POI
  Future<void> clearPoiCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('pois_')).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
    print('[CACHE] Cache POI vidé complètement');
  }

  // Préchargement des données critiques
  Future<void> preloadCriticalData() async {
    print('[CACHE] Vérification des données critiques pour le mode hors ligne');
  }

  void _preloadRegionData(String region) async {
    // Cette méthode sera utilisée par les services pour précharger
    print('[CACHE] Préchargement des données pour $region');
  }

  // Nouvelles méthodes pour le mode hors ligne

  /// Cache des données spécifiquement pour le mode hors ligne avec durée prolongée
  Future<void> cacheForOffline(String key, dynamic data) async {
    await cacheData(key, data, isOfflineData: true);
  }

  /// Vérifie si des données sont disponibles localement
  Future<bool> hasOfflineData(String key) async {
    final data = await getCachedData(key, allowExpiredIfOffline: true);
    return data != null;
  }

  /// Obtient toutes les clés de données mises en cache pour le mode hors ligne
  Future<List<String>> getOfflineCacheKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList();
    
    final offlineKeys = <String>[];
    for (final key in keys) {
      final cachedString = prefs.getString(key);
      if (cachedString != null) {
        try {
          final cacheItem = jsonDecode(cachedString);
          if (cacheItem['isOfflineData'] == true) {
            offlineKeys.add(key);
          }
        } catch (e) {
          // Ignorer les éléments non valides
        }
      }
    }
    
    return offlineKeys;
  }

  /// Cache les données favoris pour le mode hors ligne
  Future<void> cacheFavorites(List<dynamic> favorites) async {
    await cacheForOffline('offline_favorites', favorites);
  }

  /// Récupère les favoris en mode hors ligne
  Future<List<dynamic>?> getOfflineFavorites() async {
    return getCachedData<List<dynamic>>('offline_favorites', allowExpiredIfOffline: true);
  }

  /// Obtient des statistiques sur le cache hors ligne
  Future<Map<String, dynamic>> getOfflineCacheStats() async {
    final offlineKeys = await getOfflineCacheKeys();
    final prefs = await SharedPreferences.getInstance();
    
    int totalSize = 0;
    int poisCount = 0;
    int eventsCount = 0;
    int favoritesCount = 0;
    
    for (final key in offlineKeys) {
      final cachedString = prefs.getString(key);
      if (cachedString != null) {
        totalSize += cachedString.length;
        
        if (key.startsWith('pois_')) {
          poisCount++;
        } else if (key.contains('events')) {
          eventsCount++;
        } else if (key.contains('favorites')) {
          favoritesCount++;
        }
      }
    }
    
    return {
      'totalItems': offlineKeys.length,
      'totalSize': totalSize,
      'poisCount': poisCount,
      'eventsCount': eventsCount,
      'favoritesCount': favoritesCount,
      'sizeInKB': (totalSize / 1024).toStringAsFixed(1),
    };
  }

  /// Synchronise les données avec le serveur quand la connexion revient
  Future<void> syncOfflineData() async {
    if (_connectivityService.isOffline) {
      print('[CACHE] Impossible de synchroniser - Mode hors ligne');
      return;
    }
    
    print('[CACHE] Début de la synchronisation des données hors ligne');
    
    // Cette méthode sera étendue quand le service de synchronisation sera créé
    final offlineKeys = await getOfflineCacheKeys();
    print('[CACHE] ${offlineKeys.length} éléments à synchroniser');
  }

  /// Vide tout le cache (sauf les données de mode hors ligne)
  Future<void> clearCache({bool clearOfflineData = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().toList();
      
      for (final key in keys) {
        final cachedString = prefs.getString(key);
        if (cachedString != null) {
          try {
            final cacheItem = jsonDecode(cachedString);
            final isOfflineData = cacheItem['isOfflineData'] == true;
            
            // Ne supprimer les données hors ligne que si explicitement demandé
            if (!isOfflineData || clearOfflineData) {
              await prefs.remove(key);
            }
          } catch (e) {
            // Supprimer les éléments non valides
            await prefs.remove(key);
          }
        }
      }
      
      print('[CACHE] Cache vidé (clearOfflineData: $clearOfflineData)');
    } catch (e) {
      print('[CACHE] Erreur lors du vidage du cache: $e');
    }
  }

  /// Vide le cache pour une langue spécifique (utilisé lors du changement de langue)
  Future<void> clearLanguageCache() async {
    await clearCache(clearOfflineData: false);
    print('[CACHE] Cache de langue vidé - les données seront rechargées');
  }

  /// Vide ABSOLUMENT TOUS les caches pour un redémarrage complet
  Future<void> clearAllCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Obtenir toutes les clés
      final keys = prefs.getKeys().toList();
      
      // Supprimer toutes les clés liées aux données (garder seulement les préférences utilisateur)
      final keysToRemove = keys.where((key) => 
        key.startsWith('pois_') ||
        key.startsWith('events_') ||
        key.startsWith('event_detail_') ||
        key.startsWith('poi_detail_') ||
        key.startsWith('nearby_') ||
        key.startsWith('category_') ||
        key.startsWith('cache_') ||
        key.contains('cached_') ||
        key == 'events' ||
        key == 'featured_pois' ||
        key.contains('_cache')
      ).toList();
      
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      
      print('[CACHE] TOUS les caches vidés complètement (${keysToRemove.length} clés supprimées)');
      print('[CACHE] Clés supprimées: $keysToRemove');
    } catch (e) {
      print('[CACHE] Erreur lors du vidage complet: $e');
    }
  }
}