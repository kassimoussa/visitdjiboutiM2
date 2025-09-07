import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/api_response.dart';
import '../models/tour_operator.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';

class TourOperatorService {
  static final TourOperatorService _instance = TourOperatorService._internal();
  factory TourOperatorService() => _instance;
  TourOperatorService._internal();

  final ApiClient _apiClient = ApiClient();
  final CacheService _cacheService = CacheService();
  final ConnectivityService _connectivityService = ConnectivityService();

  /// Récupère la liste des opérateurs touristiques
  Future<ApiResponse<List<TourOperator>>> getTourOperators({
    bool? featured,
    bool? verified,
    int perPage = 20,
    int page = 1,
  }) async {
    try {
      // Vérifier le cache d'abord si hors ligne
      final cacheKey = 'tour_operators_${featured}_${verified}_$page';
      if (_connectivityService.isOffline) {
        final cachedData = await _cacheService.getCachedData<List<dynamic>>(cacheKey, allowExpiredIfOffline: true);
        if (cachedData != null) {
          final operators = cachedData.map((item) => TourOperator.fromJson(item)).toList();
          print('[TOUR_OPERATOR] Opérateurs depuis le cache (mode hors ligne)');
          return ApiResponse<List<TourOperator>>(
            success: true,
            message: 'Mode hors ligne - Données depuis le cache',
            data: operators,
          );
        }
        
        return ApiResponse<List<TourOperator>>(
          success: false,
          message: 'Mode hors ligne - Opérateurs touristiques non disponibles. Connectez-vous pour les télécharger.',
        );
      }

      final queryParams = <String, dynamic>{
        'per_page': perPage,
        'page': page,
      };

      if (featured == true) {
        queryParams['featured'] = '1';
      }
      if (verified == true) {
        queryParams['verified'] = '1';
      }

      print('[TOUR OPERATOR SERVICE] Requête vers: ${ApiConstants.baseUrl}/tour-operators');
      print('[TOUR OPERATOR SERVICE] Paramètres: $queryParams');

      final response = await _apiClient.dio.get(
        '/tour-operators', // Endpoint supposé pour les opérateurs
        queryParameters: queryParams,
      );

      // Parse la réponse API
      final rawData = response.data as Map<String, dynamic>;
      final success = rawData['success'] as bool;
      final message = rawData['message'] as String?;

      if (success && rawData.containsKey('data')) {
        try {
          final dataSection = rawData['data'];
          
          List<TourOperator> operators = [];
          
          if (dataSection is List) {
            // Si data est directement une liste
            operators = dataSection
                .map((item) => TourOperator.fromJson(item as Map<String, dynamic>))
                .toList();
          } else if (dataSection is Map && dataSection.containsKey('operators')) {
            // Si data contient un objet avec une clé 'operators'
            final operatorsData = dataSection['operators'] as List;
            operators = operatorsData
                .map((item) => TourOperator.fromJson(item as Map<String, dynamic>))
                .toList();
          }

          // Mettre en cache pour usage hors ligne
          if (operators.isNotEmpty) {
            await _cacheService.cacheData(cacheKey, dataSection is List ? dataSection : dataSection['operators']);
          }

          return ApiResponse<List<TourOperator>>(
            success: success,
            message: message,
            data: operators,
          );
        } catch (e) {
          print('[TOUR OPERATOR SERVICE] Erreur de parsing: $e');
          return ApiResponse<List<TourOperator>>(
            success: false,
            message: 'Erreur de parsing des données: $e',
          );
        }
      }

      return ApiResponse<List<TourOperator>>(
        success: success,
        message: message ?? 'Réponse invalide',
      );
    } on DioException catch (e) {
      return ApiResponse<List<TourOperator>>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<List<TourOperator>>(
        success: false,
        message: 'Erreur inattendue: $e',
      );
    }
  }

  /// Récupère les détails d'un opérateur spécifique
  Future<ApiResponse<TourOperator>> getTourOperator(int operatorId) async {
    try {
      final response = await _apiClient.dio.get('/tour-operators/$operatorId');

      final rawData = response.data as Map<String, dynamic>;
      final success = rawData['success'] as bool;
      final message = rawData['message'] as String?;

      if (success && rawData.containsKey('data')) {
        try {
          final operatorData = rawData['data'] as Map<String, dynamic>;
          final operator = TourOperator.fromJson(operatorData);

          return ApiResponse<TourOperator>(
            success: success,
            message: message,
            data: operator,
          );
        } catch (e) {
          return ApiResponse<TourOperator>(
            success: false,
            message: 'Erreur de parsing: $e',
          );
        }
      }

      return ApiResponse<TourOperator>(
        success: success,
        message: message ?? 'Opérateur non trouvé',
      );
    } on DioException catch (e) {
      return ApiResponse<TourOperator>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<TourOperator>(
        success: false,
        message: 'Erreur inattendue: $e',
      );
    }
  }

  /// Génère des données de test pour les opérateurs
  Future<ApiResponse<List<TourOperator>>> getMockTourOperators() async {
    // Simuler un délai d'API
    await Future.delayed(const Duration(milliseconds: 800));

    final mockOperators = [
      const TourOperator(
        id: 1,
        name: 'Djibouti Adventures',
        description: 'Spécialiste des excursions dans le lac Assal et le désert du Grand Bara.',
        website: 'https://djibouti-adventures.com',
        phones: ['+253 21 35 14 78', '+253 77 85 23 14'],
        firstPhone: '+253 21 35 14 78',
        emails: ['contact@djibouti-adventures.com'],
        firstEmail: 'contact@djibouti-adventures.com',
        address: 'Avenue République, Djibouti Ville',
        latitude: '11.5721',
        longitude: '43.1456',
        isFeatured: true,
      ),
      const TourOperator(
        id: 2,
        name: 'Red Sea Expeditions',
        description: 'Tours de plongée et snorkeling dans les eaux cristallines de la mer Rouge.',
        website: 'https://redsea-djibouti.com',
        phones: ['+253 21 42 18 36'],
        firstPhone: '+253 21 42 18 36',
        emails: ['contact@redsea-djibouti.com'],
        firstEmail: 'contact@redsea-djibouti.com',
        address: 'Port de Djibouti',
        latitude: '11.5945',
        longitude: '43.1467',
        isFeatured: true,
      ),
      const TourOperator(
        id: 3,
        name: 'Afar Cultural Tours',
        description: 'Découverte de la culture Afar et des traditions nomades.',
        phones: ['+253 77 42 18 95'],
        firstPhone: '+253 77 42 18 95',
        emails: ['info@afar-tours.dj'],
        firstEmail: 'info@afar-tours.dj',
        address: 'Quartier Balbala, Djibouti',
        latitude: '11.5430',
        longitude: '43.1390',
        isFeatured: false,
      ),
      const TourOperator(
        id: 4,
        name: 'Tadjourah Bay Tours',
        description: 'Excursions vers la baie de Tadjourah et observation des baleines.',
        website: 'https://tadjourah-tours.dj',
        phones: ['+253 21 89 47 23'],
        firstPhone: '+253 21 89 47 23',
        emails: ['info@tadjourah-tours.dj'],
        firstEmail: 'info@tadjourah-tours.dj',
        address: 'Tadjourah, Djibouti',
        latitude: '11.7844',
        longitude: '42.8847',
        isFeatured: false,
      ),
    ];

    return ApiResponse<List<TourOperator>>(
      success: true,
      message: 'Opérateurs chargés avec succès',
      data: mockOperators,
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