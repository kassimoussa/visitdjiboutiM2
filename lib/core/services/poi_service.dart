import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/api_response.dart';
import '../models/poi.dart';
import '../models/poi_list_response.dart';
import '../models/pagination.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';
import 'localization_service.dart';

class PoiService {
  static final PoiService _instance = PoiService._internal();
  factory PoiService() => _instance;
  PoiService._internal();

  final ApiClient _apiClient = ApiClient();
  final CacheService _cacheService = CacheService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final LocalizationService _localizationService = LocalizationService();

  Future<ApiResponse<PoiListData>> getPois({
    String? search,
    int? categoryId,
    String? region,
    bool? featured,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int perPage = 50,
    int page = 1,
    bool useCache = true,
  }) async {
    try {
      // Vérifier le cache d'abord si hors ligne, ou si cache activé pour requête simple
      final currentLang = _localizationService.currentLanguageCode;
      final cacheKey = region != null ? 'pois_${region}_$currentLang' : 'pois_all_$currentLang';
      final shouldUseCache = _connectivityService.isOffline || (useCache && search == null && categoryId == null && page == 1);
      
      if (shouldUseCache) {
        final cachedData = await _cacheService.getCachedData<List<dynamic>>(cacheKey, allowExpiredIfOffline: true);
        
        if (cachedData != null) {
          try {
            final pois = <Poi>[];
            for (final json in cachedData) {
              if (json is Map<String, dynamic>) {
                pois.add(Poi.fromJson(json));
              }
            }
            
            if (pois.isNotEmpty) {
              final poiListData = PoiListData(
                pois: pois,
                pagination: Pagination(
                  currentPage: 1,
                  lastPage: 1,
                  perPage: pois.length,
                  total: pois.length,
                  from: 1,
                  to: pois.length,
                ),
                filters: PoiFilters(
                  regions: region != null ? [region] : [],
                  categories: [],
                ),
              );
              
              final cacheMessage = _connectivityService.isOffline ? 'Mode hors ligne - Données depuis le cache' : 'Données chargées depuis le cache';
              print('[CACHE HIT] $cacheMessage pour $cacheKey (${pois.length} items)');
              return ApiResponse<PoiListData>(
                success: true,
                message: cacheMessage,
                data: poiListData,
              );
            }
          } catch (e) {
            print('[CACHE ERROR] Erreur lors du parsing du cache: $e');
            // Supprimer le cache corrompu
            await _cacheService.getCachedData(cacheKey); // This will auto-remove invalid cache
          }
        }
      }
      
      // Si hors ligne et pas de cache, retourner erreur spécifique
      if (_connectivityService.isOffline) {
        return ApiResponse<PoiListData>(
          success: false,
          message: 'Mode hors ligne - Aucune donnée en cache disponible. Connectez-vous pour télécharger les données.',
        );
      }
      
      final queryParams = <String, dynamic>{
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'per_page': perPage,
        'page': page,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (categoryId != null) {
        queryParams['category_id'] = categoryId;
      }
      if (region != null && region.isNotEmpty) {
        queryParams['region'] = region;
      }
      if (featured == true) {
        queryParams['featured'] = '1';
      }

      print('[POI SERVICE] Requête API vers: ${ApiConstants.baseUrl}${ApiConstants.pois}');
      print('[POI SERVICE] Paramètres: $queryParams');
      
      final response = await _apiClient.dio.get(
        ApiConstants.pois,
        queryParameters: queryParams,
      );
      
      print('[POI SERVICE] Statut réponse: ${response.statusCode}');
      print('[POI SERVICE] Données reçues: ${response.data}');

      // Parse la réponse API
      final rawData = response.data as Map<String, dynamic>;
      final success = rawData['success'] as bool;
      final message = rawData['message'] as String?;
      
      if (success && rawData.containsKey('data')) {
        final dataSection = rawData['data'] as Map<String, dynamic>;
        
        if (dataSection.containsKey('pois')) {
          try {
            print('[POI SERVICE] Section data trouvée: $dataSection');
            final poiListData = PoiListData.fromJson(dataSection);
            print('[POI SERVICE] POIs parsés avec succès: ${poiListData.pois.length} POIs');
            
            // Mettre en cache les données si c'est une requête cacheable
            if (useCache && search == null && categoryId == null && page == 1) {
              final currentLang = _localizationService.currentLanguageCode;
              final cacheKey = region != null ? 'pois_${region}_$currentLang' : 'pois_all_$currentLang';
              final poisJson = poiListData.pois.map((poi) => poi.toJson()).toList();
              await _cacheService.cacheData(cacheKey, poisJson, 
                cacheDuration: const Duration(hours: 2));
              print('[CACHE STORE] Données POIs mises en cache pour $cacheKey');
            }
            
            return ApiResponse<PoiListData>(
              success: success,
              message: message,
              data: poiListData,
            );
          } catch (e) {
            return ApiResponse<PoiListData>(
              success: false,
              message: 'Erreur de parsing des données: $e',
            );
          }
        }
      }
      
      return ApiResponse<PoiListData>(
        success: success,
        message: message ?? 'Réponse invalide',
      );
    } on DioException catch (e) {
      return ApiResponse<PoiListData>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<PoiListData>(
        success: false,
        message: 'Une erreur inattendue s\'est produite',
      );
    }
  }

  Future<ApiResponse<Poi>> getPoiById(dynamic id) async {
    try {
      // Vérifier le cache d'abord si hors ligne
      final currentLang = _localizationService.currentLanguageCode;
      final cacheKey = 'poi_detail_${id}_$currentLang';
      if (_connectivityService.isOffline) {
        final cachedData = await _cacheService.getCachedData<Map<String, dynamic>>(cacheKey, allowExpiredIfOffline: true);
        if (cachedData != null) {
          final poi = Poi.fromJson(cachedData);
          print('[POI_SERVICE] Détail POI $id chargé depuis le cache (mode hors ligne)');
          return ApiResponse<Poi>(
            success: true,
            message: 'Mode hors ligne - Données depuis le cache',
            data: poi,
          );
        }
        
        // Pas de cache et hors ligne - erreur
        return ApiResponse<Poi>(
          success: false,
          message: 'Mode hors ligne - Détails du POI non disponibles. Connectez-vous pour les télécharger.',
        );
      }

      final response = await _apiClient.dio.get(
        ApiConstants.poisById(id),
      );

      final poiData = response.data['data']['poi'] as Map<String, dynamic>;
      final poi = Poi.fromJson(poiData);
      
      // Mettre en cache pour usage hors ligne
      await _cacheService.cacheData(cacheKey, poiData);

      return ApiResponse<Poi>(
        success: response.data['success'],
        message: response.data['message'],
        data: poi,
      );
    } on DioException catch (e) {
      return ApiResponse<Poi>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<Poi>(
        success: false,
        message: 'Une erreur inattendue s\'est produite',
      );
    }
  }

  Future<ApiResponse<List<Poi>>> getNearbyPois({
    required double latitude,
    required double longitude,
    int radius = 10,
    int limit = 20,
  }) async {
    try {
      // Vérifier le cache si hors ligne
      final currentLang = _localizationService.currentLanguageCode;
      final cacheKey = 'nearby_pois_${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}_${radius}_$currentLang';
      if (_connectivityService.isOffline) {
        final cachedData = await _cacheService.getCachedData<List<dynamic>>(cacheKey, allowExpiredIfOffline: true);
        if (cachedData != null) {
          final pois = cachedData.map((poi) => Poi.fromJson(poi)).toList();
          print('[POI_SERVICE] POIs à proximité chargés depuis le cache (mode hors ligne)');
          return ApiResponse<List<Poi>>(
            success: true,
            message: 'Mode hors ligne - Données depuis le cache',
            data: pois,
          );
        }
        
        return ApiResponse<List<Poi>>(
          success: false,
          message: 'Mode hors ligne - POIs à proximité non disponibles. Connectez-vous pour les télécharger.',
        );
      }

      final response = await _apiClient.dio.get(
        ApiConstants.poisNearby,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
          'limit': limit,
        },
      );

      final poisData = response.data['data']['pois'] as List;
      final pois = poisData.map((poi) => Poi.fromJson(poi)).toList();
      
      // Mettre en cache
      await _cacheService.cacheData(cacheKey, poisData);

      return ApiResponse<List<Poi>>(
        success: response.data['success'],
        message: response.data['message'],
        data: pois,
      );
    } on DioException catch (e) {
      return ApiResponse<List<Poi>>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<List<Poi>>(
        success: false,
        message: 'Une erreur inattendue s\'est produite',
      );
    }
  }

  Future<ApiResponse<PoiListData>> getPoisByCategory(
    int categoryId, {
    int perPage = 50,
    int page = 1,
  }) async {
    try {
      // Vérifier le cache si hors ligne
      final currentLang = _localizationService.currentLanguageCode;
      final cacheKey = 'pois_category_${categoryId}_page_${page}_$currentLang';
      if (_connectivityService.isOffline) {
        final cachedData = await _cacheService.getCachedData<Map<String, dynamic>>(cacheKey, allowExpiredIfOffline: true);
        if (cachedData != null) {
          final poiListData = PoiListData.fromJson(cachedData);
          print('[POI_SERVICE] POIs catégorie $categoryId chargés depuis le cache (mode hors ligne)');
          return ApiResponse<PoiListData>(
            success: true,
            message: 'Mode hors ligne - Données depuis le cache',
            data: poiListData,
          );
        }
        
        return ApiResponse<PoiListData>(
          success: false,
          message: 'Mode hors ligne - POIs de cette catégorie non disponibles. Connectez-vous pour les télécharger.',
        );
      }

      final response = await _apiClient.dio.get(
        ApiConstants.poisByCategory(categoryId),
        queryParameters: {
          'per_page': perPage,
          'page': page,
        },
      );

      final result = ApiResponse<PoiListData>.fromJson(
        response.data,
        (json) => PoiListData.fromJson(json as Map<String, dynamic>),
      );
      
      // Mettre en cache si succès
      if (result.isSuccess && result.data != null) {
        await _cacheService.cacheData(cacheKey, response.data['data']);
      }

      return result;
    } on DioException catch (e) {
      return ApiResponse<PoiListData>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<PoiListData>(
        success: false,
        message: 'Une erreur inattendue s\'est produite',
      );
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Délai de connexion dépassé. Vérifiez votre connexion internet.';
      case DioExceptionType.connectionError:
        return 'Problème de connexion. Vérifiez votre connexion internet.';
      case DioExceptionType.badResponse:
        if (error.response?.data is Map<String, dynamic>) {
          final data = error.response!.data as Map<String, dynamic>;
          return data['message'] ?? 'Erreur serveur ${error.response?.statusCode}';
        }
        return 'Erreur serveur ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Requête annulée';
      case DioExceptionType.unknown:
      default:
        return 'Erreur de connexion. Vérifiez votre connexion internet.';
    }
  }
}