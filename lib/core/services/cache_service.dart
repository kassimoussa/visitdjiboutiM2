import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';
import '../utils/cache_keys.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const Duration _defaultCacheDuration = Duration(minutes: 15);
  static const Duration _offlineCacheDuration = Duration(days: 7); // Cache plus long pour mode hors ligne

  // Configuration LRU (Least Recently Used)
  static const int _maxCacheItems = 100; // Nombre maximum d'items en cache
  static const String _lruMetadataKey = '_cache_lru_metadata';

  final ConnectivityService _connectivityService = ConnectivityService();

  // ========== Gestion LRU (Least Recently Used) ==========

  /// Récupère les métadonnées LRU (clé -> lastAccessTime)
  Future<Map<String, int>> _getLRUMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final metadataString = prefs.getString(_lruMetadataKey);

    if (metadataString == null) return {};

    try {
      final decoded = jsonDecode(metadataString) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      print('[CACHE LRU] Erreur lecture metadata: $e');
      return {};
    }
  }

  /// Sauvegarde les métadonnées LRU
  Future<void> _saveLRUMetadata(Map<String, int> metadata) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lruMetadataKey, jsonEncode(metadata));
  }

  /// Met à jour le timestamp de dernier accès pour une clé
  Future<void> _updateLastAccess(String key) async {
    final metadata = await _getLRUMetadata();
    metadata[key] = DateTime.now().millisecondsSinceEpoch;
    await _saveLRUMetadata(metadata);
  }

  /// Éviction LRU: supprime les items les moins récemment utilisés
  Future<void> _evictLRU() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys().toList();

    // Filtrer seulement les clés de cache valides (exclure metadata et préférences)
    final cacheKeys = allKeys.where((key) =>
        key != _lruMetadataKey &&
        !key.startsWith('_') && // Exclure les clés internes
        CacheKeys.isValidCacheKey(key)
    ).toList();

    // Si on n'a pas dépassé la limite, ne rien faire
    if (cacheKeys.length <= _maxCacheItems) {
      return;
    }

    print('[CACHE LRU] Éviction nécessaire: ${cacheKeys.length}/$_maxCacheItems items');

    final metadata = await _getLRUMetadata();

    // Créer une liste de (clé, lastAccessTime)
    final cacheItemsWithAccess = cacheKeys.map((key) {
      final lastAccess = metadata[key] ?? 0; // 0 si jamais accédé
      return MapEntry(key, lastAccess);
    }).toList();

    // Trier par lastAccessTime (les plus anciens en premier)
    cacheItemsWithAccess.sort((a, b) => a.value.compareTo(b.value));

    // Calculer combien d'items supprimer
    final itemsToEvict = cacheKeys.length - _maxCacheItems;

    // Supprimer les items les moins récemment utilisés
    for (int i = 0; i < itemsToEvict; i++) {
      final keyToRemove = cacheItemsWithAccess[i].key;

      // Ne pas supprimer les données offline
      final cachedString = prefs.getString(keyToRemove);
      if (cachedString != null) {
        try {
          final cacheItem = jsonDecode(cachedString);
          final isOfflineData = cacheItem['isOfflineData'] == true;

          if (!isOfflineData) {
            await prefs.remove(keyToRemove);
            metadata.remove(keyToRemove);
            print('[CACHE LRU] Éviction: $keyToRemove (type: ${CacheKeys.getDataType(keyToRemove)})');
          }
        } catch (e) {
          // Supprimer les items corrompus
          await prefs.remove(keyToRemove);
          metadata.remove(keyToRemove);
        }
      }
    }

    // Sauvegarder les métadonnées mises à jour
    await _saveLRUMetadata(metadata);

    print('[CACHE LRU] Éviction terminée: ${cacheKeys.length - itemsToEvict} items restants');
  }

  // ========== Stockage et récupération ==========

  /// Stockage avec timestamp pour expiration et support hors ligne
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

    // Mettre à jour le timestamp LRU
    await _updateLastAccess(key);

    // Éviction LRU si nécessaire
    await _evictLRU();

    print('[CACHE] Données mises en cache: $key (${isOfflineData ? "hors ligne" : "normale"}, type: ${CacheKeys.getDataType(key)})');
  }

  /// Récupération avec vérification d'expiration et support hors ligne
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
          // Mettre à jour lastAccess même pour données expirées hors ligne
          await _updateLastAccess(key);
          return cacheItem['data'] as T;
        }

        // Sinon, supprimer le cache expiré
        await prefs.remove(key);
        return null;
      }

      // Mettre à jour le timestamp LRU pour indiquer que cette clé a été accédée
      await _updateLastAccess(key);

      return cacheItem['data'] as T;
    } catch (e) {
      // Supprimer le cache corrompu
      await prefs.remove(key);
      return null;
    }
  }

  // ========== Méthodes de cache spécifiques ==========

  /// Cache des POIs par région
  Future<void> cachePois(String region, List<dynamic> pois) async {
    await cacheData(
      CacheKeys.poisByRegion(region),
      pois,
      cacheDuration: const Duration(hours: 2),
    );
  }

  /// Récupère les POIs mis en cache pour une région
  Future<List<dynamic>?> getCachedPois(String region) async {
    return getCachedData<List<dynamic>>(CacheKeys.poisByRegion(region));
  }

  /// Cache des événements
  Future<void> cacheEvents(List<dynamic> events, {String? languageCode}) async {
    await cacheData(
      CacheKeys.events(languageCode: languageCode),
      events,
      cacheDuration: const Duration(minutes: 30),
    );
  }

  /// Récupère les événements mis en cache
  Future<List<dynamic>?> getCachedEvents({String? languageCode}) async {
    return getCachedData<List<dynamic>>(
      CacheKeys.events(languageCode: languageCode),
    );
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
    await cacheForOffline(CacheKeys.offlineFavorites, favorites);
  }

  /// Récupère les favoris en mode hors ligne
  Future<List<dynamic>?> getOfflineFavorites() async {
    return getCachedData<List<dynamic>>(
      CacheKeys.offlineFavorites,
      allowExpiredIfOffline: true,
    );
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

        final dataType = CacheKeys.getDataType(key);
        if (dataType == 'POIs') {
          poisCount++;
        } else if (dataType == 'Events') {
          eventsCount++;
        } else if (dataType == 'Favorites') {
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

  /// Obtient des statistiques LRU complètes
  Future<Map<String, dynamic>> getLRUStats() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys().toList();

    // Filtrer les clés de cache valides
    final cacheKeys = allKeys.where((key) =>
        key != _lruMetadataKey &&
        !key.startsWith('_') &&
        CacheKeys.isValidCacheKey(key)
    ).toList();

    final metadata = await _getLRUMetadata();

    // Calculer la taille totale
    int totalSize = 0;
    for (final key in cacheKeys) {
      final value = prefs.getString(key);
      if (value != null) {
        totalSize += value.length;
      }
    }

    // Trouver l'item le plus ancien et le plus récent
    int? oldestAccess;
    int? newestAccess;
    String? oldestKey;
    String? newestKey;

    for (final key in cacheKeys) {
      final accessTime = metadata[key];
      if (accessTime != null) {
        if (oldestAccess == null || accessTime < oldestAccess) {
          oldestAccess = accessTime;
          oldestKey = key;
        }
        if (newestAccess == null || accessTime > newestAccess) {
          newestAccess = accessTime;
          newestKey = key;
        }
      }
    }

    return {
      'totalItems': cacheKeys.length,
      'maxItems': _maxCacheItems,
      'percentageFull': ((cacheKeys.length / _maxCacheItems) * 100).toStringAsFixed(1),
      'totalSizeKB': (totalSize / 1024).toStringAsFixed(1),
      'oldestAccessKey': oldestKey,
      'oldestAccessTime': oldestAccess != null
          ? DateTime.fromMillisecondsSinceEpoch(oldestAccess).toIso8601String()
          : null,
      'newestAccessKey': newestKey,
      'newestAccessTime': newestAccess != null
          ? DateTime.fromMillisecondsSinceEpoch(newestAccess).toIso8601String()
          : null,
      'itemsByType': _countItemsByType(cacheKeys),
    };
  }

  /// Compte les items par type
  Map<String, int> _countItemsByType(List<String> keys) {
    final counts = <String, int>{};
    for (final key in keys) {
      final type = CacheKeys.getDataType(key);
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
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