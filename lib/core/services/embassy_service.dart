import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/api_response.dart';
import '../models/embassy.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';

class EmbassyService {
  static final EmbassyService _instance = EmbassyService._internal();
  factory EmbassyService() => _instance;
  EmbassyService._internal();

  final ApiClient _apiClient = ApiClient();
  final CacheService _cacheService = CacheService();
  final ConnectivityService _connectivityService = ConnectivityService();

  Future<ApiResponse<List<Embassy>>> getEmbassies({
    String? type,
    String? search,
    String? countryCode,
    double? latitude,
    double? longitude,
    int? radius,
    int? limit,
  }) async {
    try {
      // Vérifier le cache d'abord si hors ligne
      final cacheKey = 'embassy_service_${type}_${search}_${countryCode}';
      if (_connectivityService.isOffline) {
        final cachedData = await _cacheService.getCachedData<List<dynamic>>(cacheKey, allowExpiredIfOffline: true);
        if (cachedData != null) {
          final embassies = cachedData.map((json) => Embassy.fromJson(json as Map<String, dynamic>)).toList();
          print('[EMBASSY_SERVICE] Ambassades depuis le cache (mode hors ligne)');
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

      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (search != null) queryParams['search'] = search;
      if (countryCode != null) queryParams['country_code'] = countryCode;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (radius != null) queryParams['radius'] = radius;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.dio.get(
        ApiConstants.embassies,
        queryParameters: queryParams,
      );

      final rawData = response.data as Map<String, dynamic>;
      final success = rawData['success'] as bool? ?? false;
      final message = rawData['message'] as String?;

      if (success && rawData.containsKey('data')) {
        final dataSection = rawData['data'] as Map<String, dynamic>;
        if (dataSection.containsKey('embassies')) {
          final List<dynamic> embassiesJson = dataSection['embassies'];
          final List<Embassy> embassies = embassiesJson
              .map((json) => Embassy.fromJson(json as Map<String, dynamic>))
              .toList();
          
          // Mettre en cache pour usage hors ligne
          if (embassies.isNotEmpty) {
            await _cacheService.cacheData(cacheKey, embassiesJson);
          }
          
          return ApiResponse<List<Embassy>>(
            success: true,
            message: message,
            data: embassies,
          );
        }
      }

      return ApiResponse<List<Embassy>>(
        success: false,
        message: message ?? 'Réponse invalide ou données manquantes',
      );
    } on DioException catch (e) {
      return ApiResponse<List<Embassy>>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<List<Embassy>>(
        success: false,
        message: 'Une erreur inattendue s\'est produite: $e',
      );
    }
  }

  String _handleDioError(DioException error) {
    if (error.response != null && error.response!.data != null) {
      if (error.response!.data is Map<String, dynamic>) {
        return error.response!.data['message'] ?? 'Erreur serveur';
      }
      return error.response!.data.toString();
    }
    return error.message ?? 'Erreur réseau inconnue';
  }
}