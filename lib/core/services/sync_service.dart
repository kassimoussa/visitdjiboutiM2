import 'dart:async';
import 'package:flutter/foundation.dart';
import 'connectivity_service.dart';
import 'cache_service.dart';
import 'poi_service.dart';
import 'event_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  final CacheService _cacheService = CacheService();
  final PoiService _poiService = PoiService();
  final EventService _eventService = EventService();

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  final StreamController<SyncStatus> _syncController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStream => _syncController.stream;

  late StreamSubscription _connectivitySubscription;

  /// Initialise le service de synchronisation
  Future<void> initialize() async {
    // Écouter les changements de connectivité
    _connectivitySubscription = _connectivityService.connectivityStream.listen((isOnline) {
      if (isOnline) {
        _triggerAutoSync();
      }
    });

    print('[SYNC] Service de synchronisation initialisé');
  }

  /// Déclenche automatiquement la synchronisation quand la connexion revient
  void _triggerAutoSync() async {
    await Future.delayed(const Duration(seconds: 2)); // Attendre que la connexion soit stable
    if (_connectivityService.isOnline && !_isSyncing) {
      await syncData();
    }
  }

  /// Synchronise toutes les données
  Future<SyncResult> syncData({bool forceSync = false}) async {
    if (_isSyncing && !forceSync) {
      return SyncResult(success: false, message: 'Synchronisation déjà en cours');
    }

    if (_connectivityService.isOffline) {
      return SyncResult(success: false, message: 'Mode hors ligne - Synchronisation impossible');
    }

    _isSyncing = true;
    _syncController.add(SyncStatus.syncing);
    print('[SYNC] Début de la synchronisation');

    final syncResult = SyncResult();
    
    try {
      // 1. Synchroniser les POIs
      await _syncPois(syncResult);
      
      // 2. Synchroniser les événements
      await _syncEvents(syncResult);
      
      // 3. Synchroniser les favoris (si l'utilisateur est connecté)
      await _syncFavorites(syncResult);

      // 4. Nettoyer les anciennes données du cache
      await _cleanupOldCache();

      _syncController.add(SyncStatus.completed);
      print('[SYNC] Synchronisation terminée avec succès');
      
      return syncResult;
      
    } catch (e) {
      _syncController.add(SyncStatus.error);
      print('[SYNC] Erreur lors de la synchronisation: $e');
      
      return SyncResult(
        success: false, 
        message: 'Erreur de synchronisation: $e',
        syncedItems: syncResult.syncedItems,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Synchronise les POIs
  Future<void> _syncPois(SyncResult result) async {
    try {
      print('[SYNC] Synchronisation des POIs...');
      
      // Récupérer les POIs depuis l'API
      final response = await _poiService.getPois(perPage: 100, useCache: false);
      
      if (response.isSuccess && response.hasData) {
        final pois = response.data!.pois;
        
        // Mettre en cache pour le mode hors ligne
        await _cacheService.cacheForOffline('offline_pois_all', pois.map((poi) => poi.toJson()).toList());
        
        result.syncedItems['pois'] = pois.length;
        print('[SYNC] ${pois.length} POIs synchronisés');
      }
    } catch (e) {
      print('[SYNC] Erreur synchronisation POIs: $e');
      result.errors.add('POIs: $e');
    }
  }

  /// Synchronise les événements
  Future<void> _syncEvents(SyncResult result) async {
    try {
      print('[SYNC] Synchronisation des événements...');
      
      // Récupérer les événements depuis l'API
      final response = await _eventService.getEvents(perPage: 50);
      
      if (response.isSuccess && response.hasData) {
        final events = response.data!.events;
        
        // Mettre en cache pour le mode hors ligne
        await _cacheService.cacheForOffline('offline_events_all', events.map((event) => event.toJson()).toList());
        
        result.syncedItems['events'] = events.length;
        print('[SYNC] ${events.length} événements synchronisés');
      }
    } catch (e) {
      print('[SYNC] Erreur synchronisation événements: $e');
      result.errors.add('Événements: $e');
    }
  }

  /// Synchronise les favoris
  Future<void> _syncFavorites(SyncResult result) async {
    try {
      print('[SYNC] Synchronisation des favoris...');
      // Cette partie sera implémentée quand le système d'authentification sera complet
      result.syncedItems['favorites'] = 0;
    } catch (e) {
      print('[SYNC] Erreur synchronisation favoris: $e');
      result.errors.add('Favoris: $e');
    }
  }

  /// Nettoie les anciennes données du cache
  Future<void> _cleanupOldCache() async {
    try {
      await _cacheService.clearExpiredCache();
      print('[SYNC] Nettoyage du cache terminé');
    } catch (e) {
      print('[SYNC] Erreur nettoyage cache: $e');
    }
  }

  /// Télécharge les données critiques pour le mode hors ligne
  Future<SyncResult> downloadForOffline({List<String>? regions}) async {
    if (_connectivityService.isOffline) {
      return SyncResult(success: false, message: 'Connexion requise pour télécharger');
    }

    _isSyncing = true;
    _syncController.add(SyncStatus.downloading);
    
    final syncResult = SyncResult();
    
    try {
      print('[SYNC] Téléchargement pour mode hors ligne...');
      
      // Télécharger les POIs par région
      final regionsToDownload = regions ?? ['Djibouti', 'Ali-Sabieh', 'Dikhil', 'Tadjourah', 'Obock', 'Arta'];
      
      for (final region in regionsToDownload) {
        try {
          final response = await _poiService.getPois(region: region, perPage: 100, useCache: false);
          if (response.isSuccess && response.hasData) {
            final pois = response.data!.pois;
            await _cacheService.cacheForOffline('offline_pois_$region', pois.map((poi) => poi.toJson()).toList());
            syncResult.syncedItems['pois_$region'] = pois.length;
          }
        } catch (e) {
          print('[SYNC] Erreur téléchargement région $region: $e');
        }
      }
      
      // Télécharger les événements
      await _syncEvents(syncResult);
      
      _syncController.add(SyncStatus.completed);
      print('[SYNC] Téléchargement hors ligne terminé');
      
      return syncResult;
      
    } catch (e) {
      _syncController.add(SyncStatus.error);
      return SyncResult(success: false, message: 'Erreur téléchargement: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Obtient les statistiques de synchronisation
  Future<Map<String, dynamic>> getSyncStats() async {
    final cacheStats = await _cacheService.getOfflineCacheStats();
    
    return {
      ...cacheStats,
      'lastSyncTime': 'Non disponible', // Sera implémenté plus tard
      'isOnline': _connectivityService.isOnline,
      'isSyncing': _isSyncing,
    };
  }

  /// Nettoie les ressources
  void dispose() {
    _connectivitySubscription.cancel();
    _syncController.close();
  }
}

enum SyncStatus {
  idle,
  syncing,
  downloading,
  completed,
  error,
}

class SyncResult {
  final bool success;
  final String? message;
  final Map<String, int> syncedItems;
  final List<String> errors;

  SyncResult({
    this.success = true,
    this.message,
    Map<String, int>? syncedItems,
    List<String>? errors,
  }) : syncedItems = syncedItems ?? {},
       errors = errors ?? [];

  int get totalSyncedItems => syncedItems.values.fold(0, (sum, count) => sum + count);
  bool get hasErrors => errors.isNotEmpty;
}