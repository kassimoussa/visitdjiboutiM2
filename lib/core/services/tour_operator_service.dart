import 'package:dio/dio.dart';
import '../models/tour_operator.dart';
import '../models/api_response.dart';
import '../api/api_client.dart';

/// Service pour gérer les opérateurs touristiques
class TourOperatorService {
  final ApiClient _apiClient = ApiClient();

  /// Récupère tous les opérateurs touristiques
  Future<ApiResponse<List<TourOperator>>> getTourOperators() async {
    try {
      final response = await _apiClient.dio.get('/tour-operators');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<TourOperator> operators = [];
        
        for (var json in data) {
          try {
            final operator = TourOperator.fromJson(json as Map<String, dynamic>);
            operators.add(operator);
          } catch (e) {
            // Ignorer les opérateurs avec des données invalides
            print('Erreur parsing tour operator: $e');
            continue;
          }
        }

        return ApiResponse<List<TourOperator>>(
          success: true,
          data: operators,
          message: 'Opérateurs chargés avec succès',
        );
      } else {
        return ApiResponse<List<TourOperator>>(
          success: false,
          message: 'Erreur lors du chargement des opérateurs',
        );
      }
    } on DioException catch (e) {
      return ApiResponse<List<TourOperator>>(
        success: false,
        message: _handleDioError(e),
      );
    }
  }

  /// Récupère un opérateur par son ID
  Future<ApiResponse<TourOperator>> getTourOperatorById(int id) async {
    try {
      final response = await _apiClient.dio.get('/tour-operators/$id');

      if (response.statusCode == 200) {
        print('[TOUR OPERATOR SERVICE] Raw response data: ${response.data}');
        final data = response.data['data'];
        print('[TOUR OPERATOR SERVICE] Operator data: $data');
        print('[TOUR OPERATOR SERVICE] Tours in data: ${data['tours']}');

        final operator = TourOperator.fromJson(data);
        print('[TOUR OPERATOR SERVICE] Parsed operator tours: ${operator.tours?.length ?? 0}');

        if (operator.tours != null) {
          for (var tour in operator.tours!) {
            print('[TOUR OPERATOR SERVICE] Tour: ${tour.title} (${tour.id})');
          }
        }

        return ApiResponse<TourOperator>(
          success: true,
          data: operator,
          message: 'Opérateur chargé avec succès',
        );
      } else {
        return ApiResponse<TourOperator>(
          success: false,
          message: 'Opérateur non trouvé',
        );
      }
    } on DioException catch (e) {
      return ApiResponse<TourOperator>(
        success: false,
        message: _handleDioError(e),
      );
    }
  }

  /// Génère des données de test vides (plus de données factices)
  Future<ApiResponse<List<TourOperator>>> getMockTourOperators() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    return ApiResponse<List<TourOperator>>(
      success: true,
      message: 'Opérateurs disponibles via les POIs',
      data: [],
    );
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