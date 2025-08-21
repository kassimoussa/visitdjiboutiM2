import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/api_response.dart';
import '../models/event.dart';
import '../models/event_list_response.dart';
import '../models/event_registration.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Récupère la liste des événements avec filtres
  Future<ApiResponse<EventListData>> getEvents({
    String? search,
    int? categoryId,
    String? dateFrom,
    String? dateTo,
    String? status, // upcoming, ongoing
    bool? featured,
    String? location,
    String sortBy = 'start_date',
    String sortOrder = 'asc',
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
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParams['date_from'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParams['date_to'] = dateTo;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (featured == true) {
        queryParams['featured'] = '1';
      }

      final response = await _apiClient.dio.get(
        ApiConstants.events,
        queryParameters: queryParams,
      );

      // Parse la réponse API
      final rawData = response.data as Map<String, dynamic>;
      final success = rawData['success'] as bool;
      final message = rawData['message'] as String?;
      
      if (success && rawData.containsKey('data')) {
        final dataSection = rawData['data'] as Map<String, dynamic>;
        
        if (dataSection.containsKey('events')) {
          try {
            final eventListData = EventListData.fromJson(dataSection);
            
            return ApiResponse<EventListData>(
              success: success,
              message: message,
              data: eventListData,
            );
          } catch (e) {
            return ApiResponse<EventListData>(
              success: false,
              message: 'Erreur de parsing des données: $e',
            );
          }
        }
      }
      
      return ApiResponse<EventListData>(
        success: success,
        message: message ?? 'Réponse invalide',
      );
    } on DioException catch (e) {
      return ApiResponse<EventListData>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<EventListData>(
        success: false,
        message: 'Une erreur inattendue s\'est produite',
      );
    }
  }

  /// Récupère les détails d'un événement par ID ou slug
  Future<ApiResponse<Event>> getEventById(dynamic id) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.eventsById(id),
      );

      final eventData = response.data['data']['event'] as Map<String, dynamic>;
      final event = Event.fromJson(eventData);

      return ApiResponse<Event>(
        success: response.data['success'],
        message: response.data['message'],
        data: event,
      );
    } on DioException catch (e) {
      return ApiResponse<Event>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<Event>(
        success: false,
        message: 'Une erreur inattendue s\'est produite',
      );
    }
  }

  /// Enregistre un utilisateur pour un événement
  Future<ApiResponse<EventRegistrationResponse>> registerForEvent(
    int eventId,
    EventRegistrationRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.eventRegistration(eventId),
        data: request.toJson(),
      );

      final registrationData = response.data['data'] as Map<String, dynamic>;
      final registrationResponse = EventRegistrationResponse.fromJson(registrationData);

      return ApiResponse<EventRegistrationResponse>(
        success: response.data['success'],
        message: response.data['message'],
        data: registrationResponse,
      );
    } on DioException catch (e) {
      return ApiResponse<EventRegistrationResponse>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<EventRegistrationResponse>(
        success: false,
        message: 'Une erreur inattendue s\'est produite',
      );
    }
  }

  /// Annule l'inscription à un événement (nécessite authentification)
  Future<ApiResponse<void>> cancelEventRegistration(int eventId) async {
    try {
      final response = await _apiClient.dio.delete(
        ApiConstants.eventRegistrationCancel(eventId),
      );

      return ApiResponse<void>(
        success: response.data['success'],
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Une erreur inattendue s\'est produite',
      );
    }
  }

  /// Récupère les événements populaires/featured
  Future<ApiResponse<EventListData>> getFeaturedEvents({
    int perPage = 10,
  }) async {
    return getEvents(
      featured: true,
      sortBy: 'start_date',
      sortOrder: 'asc',
      perPage: perPage,
    );
  }

  /// Récupère les événements à venir
  Future<ApiResponse<EventListData>> getUpcomingEvents({
    int perPage = 15,
  }) async {
    return getEvents(
      status: 'upcoming',
      sortBy: 'start_date',
      sortOrder: 'asc',
      perPage: perPage,
    );
  }

  /// Récupère les événements en cours
  Future<ApiResponse<EventListData>> getOngoingEvents({
    int perPage = 15,
  }) async {
    return getEvents(
      status: 'ongoing',
      sortBy: 'start_date',
      sortOrder: 'asc',
      perPage: perPage,
    );
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