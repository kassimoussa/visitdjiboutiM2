import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:dio/dio.dart';
import 'poi_service.dart';
import 'event_service.dart';

class ImagePreloaderService {
  static final ImagePreloaderService _instance = ImagePreloaderService._internal();
  factory ImagePreloaderService() => _instance;
  ImagePreloaderService._internal();

  final PoiService _poiService = PoiService();
  final EventService _eventService = EventService();
  final Dio _dio = Dio();
  
  bool _isPreloading = false;
  final Set<String> _preloadedImages = {};
  final Set<String> _failedImages = {};

  /// Démarre le préchargement de toutes les images critiques
  Future<void> startPreloading(BuildContext context) async {
    if (_isPreloading) return;
    
    _isPreloading = true;
    print('[IMAGE PRELOADER] Début du préchargement des images...');
    
    try {
      // Précharger les images des POIs
      await _preloadPoiImages(context);
      
      // Précharger les images des événements
      await _preloadEventImages(context);
      
      print('[IMAGE PRELOADER] Préchargement terminé. Images préchargées: ${_preloadedImages.length}');
    } catch (e) {
      print('[IMAGE PRELOADER] Erreur lors du préchargement: $e');
    } finally {
      _isPreloading = false;
    }
  }

  /// Précharge les images des POIs
  Future<void> _preloadPoiImages(BuildContext context) async {
    try {
      // Charger les POIs depuis l'API
      final response = await _poiService.getPois(perPage: 50);
      
      if (response.isSuccess && response.hasData) {
        final pois = response.data!.pois;
        print('[IMAGE PRELOADER] Préchargement de ${pois.length} images de POIs...');
        
        // Précharger en lots pour éviter de surcharger
        await _preloadImagesInBatches(context, pois.map((poi) => poi.imageUrl).where((url) => url.isNotEmpty).toList());
      }
    } catch (e) {
      print('[IMAGE PRELOADER] Erreur lors du préchargement des POIs: $e');
    }
  }

  /// Précharge les images des événements
  Future<void> _preloadEventImages(BuildContext context) async {
    try {
      // Charger les événements depuis l'API
      final response = await _eventService.getEvents(perPage: 20);
      
      if (response.isSuccess && response.hasData) {
        final events = response.data!.events;
        print('[IMAGE PRELOADER] Préchargement de ${events.length} images d\'événements...');
        
        // Précharger en lots
        await _preloadImagesInBatches(context, events.map((event) => event.imageUrl).where((url) => url.isNotEmpty).toList());
      }
    } catch (e) {
      print('[IMAGE PRELOADER] Erreur lors du préchargement des événements: $e');
    }
  }

  /// Précharge les images par lots pour optimiser les performances
  Future<void> _preloadImagesInBatches(BuildContext context, List<String> imageUrls) async {
    const batchSize = 5; // Précharger 5 images à la fois
    
    for (int i = 0; i < imageUrls.length; i += batchSize) {
      final batch = imageUrls.skip(i).take(batchSize);
      
      // Précharger le lot actuel en parallèle
      await Future.wait(
        batch.map((url) => _preloadSingleImage(context, url)),
        eagerError: false, // Continue même si certaines images échouent
      );
      
      // Petite pause entre les lots pour ne pas surcharger
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Précharge une image individuelle
  Future<void> _preloadSingleImage(BuildContext context, String imageUrl) async {
    if (imageUrl.isEmpty || _preloadedImages.contains(imageUrl) || _failedImages.contains(imageUrl)) {
      return;
    }

    try {
      // Utiliser cached_network_image pour précharger et mettre en cache
      final imageProvider = CachedNetworkImageProvider(imageUrl);
      
      // Précharger l'image dans le cache Flutter
      await precacheImage(imageProvider, context);
      
      _preloadedImages.add(imageUrl);
      print('[IMAGE PRELOADER] ✓ Image préchargée: ${imageUrl.split('/').last}');
      
    } catch (e) {
      _failedImages.add(imageUrl);
      print('[IMAGE PRELOADER] ✗ Échec du préchargement: ${imageUrl.split('/').last} - $e');
    }
  }

  /// Précharge une image spécifique (utilisé pour les nouvelles images)
  Future<void> preloadImage(BuildContext context, String imageUrl) async {
    if (imageUrl.isNotEmpty && !_preloadedImages.contains(imageUrl) && !_failedImages.contains(imageUrl)) {
      await _preloadSingleImage(context, imageUrl);
    }
  }

  /// Vérifie si une image a été préchargée
  bool isImagePreloaded(String imageUrl) {
    return _preloadedImages.contains(imageUrl);
  }

  /// Obtient les statistiques de préchargement
  Map<String, int> getPreloadingStats() {
    return {
      'preloaded': _preloadedImages.length,
      'failed': _failedImages.length,
      'total': _preloadedImages.length + _failedImages.length,
    };
  }

  /// Vide le cache d'images (pour économiser l'espace)
  Future<void> clearImageCache() async {
    try {
      await DefaultCacheManager().emptyCache();
      _preloadedImages.clear();
      _failedImages.clear();
      print('[IMAGE PRELOADER] Cache d\'images vidé');
    } catch (e) {
      print('[IMAGE PRELOADER] Erreur lors du vidage du cache: $e');
    }
  }

  /// Obtient la taille du cache d'images
  Future<String> getCacheSize() async {
    try {
      // La méthode getTemporaryDirectory n'existe pas dans cette version de flutter_cache_manager
      // Retourner une valeur par défaut
      return 'Cache actif';
    } catch (e) {
      return 'Erreur';
    }
  }
}