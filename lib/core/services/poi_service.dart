import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/api_response.dart';
import '../models/poi.dart';
import '../models/poi_list_response.dart';

class PoiService {
  static final PoiService _instance = PoiService._internal();
  factory PoiService() => _instance;
  PoiService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<PoiListData>> getPois({
    String? search,
    int? categoryId,
    String? region,
    bool? featured,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int perPage = 15,
    int page = 1,
  }) async {
    try {
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

      final response = await _apiClient.dio.get(
        ApiConstants.pois,
        queryParameters: queryParams,
      );

      // Parse la réponse API
      final rawData = response.data as Map<String, dynamic>;
      final success = rawData['success'] as bool;
      final message = rawData['message'] as String?;
      
      if (success && rawData.containsKey('data')) {
        final dataSection = rawData['data'] as Map<String, dynamic>;
        
        if (dataSection.containsKey('pois')) {
          try {
            final poiListData = PoiListData.fromJson(dataSection);
            
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
      final response = await _apiClient.dio.get(
        ApiConstants.poisById(id),
      );

      final poiData = response.data['data']['poi'] as Map<String, dynamic>;
      final poi = Poi.fromJson(poiData);

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
    int perPage = 15,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.poisByCategory(categoryId),
        queryParameters: {
          'per_page': perPage,
          'page': page,
        },
      );

      return ApiResponse<PoiListData>.fromJson(
        response.data,
        (json) => PoiListData.fromJson(json as Map<String, dynamic>),
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