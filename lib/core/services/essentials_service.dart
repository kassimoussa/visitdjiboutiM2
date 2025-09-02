import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/api_response.dart';
import '../models/organization.dart';
import '../models/external_link.dart';
import '../models/embassy.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';

class EssentialsService {
  static final EssentialsService _instance = EssentialsService._internal();
  factory EssentialsService() => _instance;
  EssentialsService._internal();

  final ApiClient _apiClient = ApiClient();
  final CacheService _cacheService = CacheService();
  final ConnectivityService _connectivityService = ConnectivityService();

  /// Récupère les informations de l'organisation
  Future<ApiResponse<Organization>> getOrganization() async {
    try {
      // Vérifier le cache d'abord si hors ligne
      const cacheKey = 'organization_info';
      if (_connectivityService.isOffline) {
        final cachedData = await _cacheService.getCachedData<Map<String, dynamic>>(cacheKey, allowExpiredIfOffline: true);
        if (cachedData != null) {
          final organization = Organization.fromJson(cachedData);
          print('[ESSENTIALS] Informations organisation depuis le cache (mode hors ligne)');
          return ApiResponse<Organization>(
            success: true,
            message: 'Mode hors ligne - Données depuis le cache',
            data: organization,
          );
        }
        
        return ApiResponse<Organization>(
          success: false,
          message: 'Mode hors ligne - Informations organisation non disponibles. Connectez-vous pour les télécharger.',
        );
      }

      final response = await _apiClient.dio.get('/organization');
      final rawData = response.data as Map<String, dynamic>;
      
      if (rawData['success'] == true && rawData.containsKey('data')) {
        final orgData = rawData['data']['organization'] as Map<String, dynamic>;
        final organization = Organization.fromJson(orgData);
        
        // Mettre en cache
        await _cacheService.cacheData(cacheKey, orgData);
        
        return ApiResponse<Organization>(
          success: true,
          data: organization,
        );
      }
      
      return ApiResponse<Organization>(
        success: false,
        message: 'Erreur lors de la récupération des données organisation',
      );
    } on DioException catch (e) {
      return ApiResponse<Organization>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<Organization>(
        success: false,
        message: 'Erreur inattendue: $e',
      );
    }
  }

  /// Récupère la liste des liens externes
  Future<ApiResponse<List<ExternalLink>>> getExternalLinks() async {
    try {
      // Vérifier le cache d'abord si hors ligne
      const cacheKey = 'external_links';
      if (_connectivityService.isOffline) {
        final cachedData = await _cacheService.getCachedData<List<dynamic>>(cacheKey, allowExpiredIfOffline: true);
        if (cachedData != null) {
          final links = cachedData
              .map((item) => ExternalLink.fromJson(item as Map<String, dynamic>))
              .toList();
          print('[ESSENTIALS] Liens externes depuis le cache (mode hors ligne)');
          return ApiResponse<List<ExternalLink>>(
            success: true,
            message: 'Mode hors ligne - Données depuis le cache',
            data: links,
          );
        }
        
        return ApiResponse<List<ExternalLink>>(
          success: false,
          message: 'Mode hors ligne - Liens externes non disponibles. Connectez-vous pour les télécharger.',
        );
      }

      final response = await _apiClient.dio.get('/external-links');
      final rawData = response.data as Map<String, dynamic>;
      
      if (rawData['success'] == true && rawData.containsKey('data')) {
        final linksData = rawData['data']['links'] as List;
        final links = linksData
            .map((item) => ExternalLink.fromJson(item as Map<String, dynamic>))
            .toList();
        
        // Mettre en cache
        await _cacheService.cacheData(cacheKey, linksData);
        
        return ApiResponse<List<ExternalLink>>(
          success: true,
          data: links,
        );
      }
      
      return ApiResponse<List<ExternalLink>>(
        success: false,
        message: 'Erreur lors de la récupération des liens externes',
      );
    } on DioException catch (e) {
      return ApiResponse<List<ExternalLink>>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<List<ExternalLink>>(
        success: false,
        message: 'Erreur inattendue: $e',
      );
    }
  }

  /// Récupère la liste des ambassades
  Future<ApiResponse<List<Embassy>>> getEmbassies({String? type}) async {
    try {
      // Vérifier le cache d'abord si hors ligne
      final cacheKey = 'embassies${type != null ? "_$type" : ""}';
      if (_connectivityService.isOffline) {
        final cachedData = await _cacheService.getCachedData<List<dynamic>>(cacheKey, allowExpiredIfOffline: true);
        if (cachedData != null) {
          final embassies = cachedData
              .map((item) => Embassy.fromJson(item as Map<String, dynamic>))
              .toList();
          print('[ESSENTIALS] Ambassades depuis le cache (mode hors ligne)');
          return ApiResponse<List<Embassy>>(
            success: true,
            message: 'Mode hors ligne - Données depuis le cache',
            data: embassies,
          );
        }
        
        return ApiResponse<List<Embassy>>(
          success: false,
          message: 'Mode hors ligne - Ambassades non disponibles. Connectez-vous pour les télécharger.',
        );
      }

      String endpoint = '/embassies';
      Map<String, dynamic> queryParams = {};
      
      if (type != null) {
        queryParams['type'] = type;
      }
      
      final response = await _apiClient.dio.get(endpoint, queryParameters: queryParams);
      final rawData = response.data as Map<String, dynamic>;
      
      if (rawData['success'] == true && rawData.containsKey('data')) {
        final embassiesData = rawData['data']['embassies'] as List;
        final embassies = embassiesData
            .map((item) => Embassy.fromJson(item as Map<String, dynamic>))
            .toList();
        
        // Mettre en cache
        await _cacheService.cacheData(cacheKey, embassiesData);
        
        return ApiResponse<List<Embassy>>(
          success: true,
          data: embassies,
        );
      }
      
      return ApiResponse<List<Embassy>>(
        success: false,
        message: 'Erreur lors de la récupération des ambassades',
      );
    } on DioException catch (e) {
      return ApiResponse<List<Embassy>>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<List<Embassy>>(
        success: false,
        message: 'Erreur inattendue: $e',
      );
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connexion lente. Veuillez réessayer.';
      case DioExceptionType.badResponse:
        return 'Erreur serveur (${e.response?.statusCode})';
      case DioExceptionType.cancel:
        return 'Requête annulée';
      default:
        return 'Erreur de connexion. Vérifiez votre internet.';
    }
  }
}