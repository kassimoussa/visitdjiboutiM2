import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/api_response.dart';
import '../models/content.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';
import 'localization_service.dart';

/// Service pour gérer tous les types de contenus (POIs, Events, Activities, Tours)
class ContentService {
  static final ContentService _instance = ContentService._internal();
  factory ContentService() => _instance;
  ContentService._internal();

  final ApiClient _apiClient = ApiClient();
  final CacheService _cacheService = CacheService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final LocalizationService _localizationService = LocalizationService();

  /// Récupère tous les contenus (POIs + Events + Activities + Tours)
  Future<ApiResponse<ContentListResponse>> getAllContent({
    bool useCache = true,
  }) async {
    try {
      // Vérifier le cache d'abord si hors ligne ou si cache activé
      final currentLang = _localizationService.currentLanguageCode;
      final cacheKey = 'content_all_$currentLang';
      final shouldUseCache = _connectivityService.isOffline || useCache;

      if (shouldUseCache) {
        final cachedData = await _cacheService.getCachedData<Map<String, dynamic>>(
          cacheKey,
          allowExpiredIfOffline: true,
        );

        if (cachedData != null) {
          try {
            final contentListResponse = ContentListResponse.fromJson(cachedData);

            final cacheMessage = _connectivityService.isOffline
                ? 'Mode hors ligne - Données depuis le cache'
                : 'Données chargées depuis le cache';
            print('[CACHE HIT] $cacheMessage pour $cacheKey (${contentListResponse.total} items)');

            return ApiResponse<ContentListResponse>(
              success: true,
              message: cacheMessage,
              data: contentListResponse,
            );
          } catch (e) {
            print('[CACHE ERROR] Erreur lors du parsing du cache: $e');
            // Le cache corrompu sera ignoré et rechargé depuis l'API
          }
        }
      }

      // Si hors ligne et pas de cache, retourner erreur spécifique
      if (_connectivityService.isOffline) {
        return ApiResponse<ContentListResponse>(
          success: false,
          message: 'Mode hors ligne - Aucune donnée en cache disponible. Connectez-vous pour télécharger les données.',
        );
      }

      print('[CONTENT SERVICE] Requête API vers: ${ApiConstants.baseUrl}${ApiConstants.contentAll}');

      final response = await _apiClient.dio.get(
        ApiConstants.contentAll,
      );

      print('[CONTENT SERVICE] Statut réponse: ${response.statusCode}');

      // Parse la réponse API
      final rawData = response.data as Map<String, dynamic>;
      final success = rawData['success'] as bool;
      final message = rawData['message'] as String?;

      if (success && rawData.containsKey('data')) {
        final dataSection = rawData['data'] as Map<String, dynamic>;

        try {
          print('[CONTENT SERVICE] Section data trouvée: ${dataSection.keys}');
          final contentListResponse = ContentListResponse.fromJson(dataSection);
          print('[CONTENT SERVICE] Contenus parsés avec succès: ${contentListResponse.total} items');

          // Mettre en cache les données
          if (useCache) {
            await _cacheService.cacheData(
              cacheKey,
              dataSection,
              cacheDuration: const Duration(hours: 2),
            );
            print('[CACHE STORE] Données content mises en cache pour $cacheKey');
          }

          return ApiResponse<ContentListResponse>(
            success: success,
            message: message,
            data: contentListResponse,
          );
        } catch (e, stackTrace) {
          print('[CONTENT SERVICE] Erreur lors du parsing des contenus: $e');
          print('[CONTENT SERVICE] StackTrace: $stackTrace');
          return ApiResponse<ContentListResponse>(
            success: false,
            message: 'Erreur lors du parsing des données: ${e.toString()}',
          );
        }
      } else {
        return ApiResponse<ContentListResponse>(
          success: false,
          message: message ?? 'Erreur lors de la récupération des contenus',
        );
      }
    } catch (e) {
      print('[CONTENT SERVICE] Erreur lors de la requête: $e');
      return ApiResponse<ContentListResponse>(
        success: false,
        message: 'Erreur réseau: ${e.toString()}',
      );
    }
  }

  /// Récupère seulement les contenus avec coordonnées GPS valides (pour la carte)
  Future<ApiResponse<List<Content>>> getMappableContent({
    bool useCache = true,
  }) async {
    final response = await getAllContent(useCache: useCache);

    if (response.success && response.data != null) {
      // Filtrer les contenus avec coordonnées valides
      final mappableContent = response.data!.content.where((content) {
        return content.hasValidCoordinates;
      }).toList();

      print('[CONTENT SERVICE] Contenus cartographiables: ${mappableContent.length} / ${response.data!.total}');

      return ApiResponse<List<Content>>(
        success: true,
        message: response.message,
        data: mappableContent,
      );
    } else {
      return ApiResponse<List<Content>>(
        success: false,
        message: response.message,
      );
    }
  }

  /// Récupère les contenus filtrés par type
  Future<ApiResponse<List<Content>>> getContentByType({
    required ContentType type,
    bool useCache = true,
  }) async {
    final response = await getAllContent(useCache: useCache);

    if (response.success && response.data != null) {
      final filteredContent = response.data!.content.where((content) {
        return content.type == type;
      }).toList();

      print('[CONTENT SERVICE] Contenus de type $type: ${filteredContent.length}');

      return ApiResponse<List<Content>>(
        success: true,
        message: response.message,
        data: filteredContent,
      );
    } else {
      return ApiResponse<List<Content>>(
        success: false,
        message: response.message,
      );
    }
  }

  /// Récupère les contenus filtrés par région
  Future<ApiResponse<List<Content>>> getContentByRegion({
    required String region,
    bool useCache = true,
  }) async {
    final response = await getAllContent(useCache: useCache);

    if (response.success && response.data != null) {
      final filteredContent = response.data!.content.where((content) {
        return content.region?.toLowerCase() == region.toLowerCase();
      }).toList();

      print('[CONTENT SERVICE] Contenus pour la région $region: ${filteredContent.length}');

      return ApiResponse<List<Content>>(
        success: true,
        message: response.message,
        data: filteredContent,
      );
    } else {
      return ApiResponse<List<Content>>(
        success: false,
        message: response.message,
      );
    }
  }
}
