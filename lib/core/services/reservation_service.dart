import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/api_response.dart';
import '../models/reservation.dart';
import '../models/poi.dart';
import '../models/event.dart';

class ReservationService {
  static final ReservationService _instance = ReservationService._internal();
  factory ReservationService() => _instance;
  ReservationService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Récupère la liste des réservations de l'utilisateur
  Future<ApiResponse<ReservationListResponse>> getReservations({
    int page = 1,
    int perPage = 15,
    String? status,
    String? type,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'per_page': perPage,
      };

      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;

      final response = await _apiClient.dio.get(
        '/reservations',
        queryParameters: queryParams,
      );
      
      final rawData = response.data as Map<String, dynamic>;
      
      if (rawData['success'] == true && rawData.containsKey('data')) {
        final reservationData = ReservationListResponse.fromJson(rawData['data']);
        
        return ApiResponse<ReservationListResponse>(
          success: true,
          data: reservationData,
        );
      }
      
      return ApiResponse<ReservationListResponse>(
        success: false,
        message: 'Erreur lors de la récupération des réservations',
      );
    } on DioException catch (e) {
      return ApiResponse<ReservationListResponse>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<ReservationListResponse>(
        success: false,
        message: 'Erreur inattendue: $e',
      );
    }
  }

  /// Crée une nouvelle réservation pour un POI
  Future<ApiResponse<Reservation>> createPoiReservation({
    required int poiId,
    required String reservationDate,
    String? reservationTime,
    required int numberOfPeople,
    String? notes,
    String? userName,
    String? userEmail,
    String? userPhone,
  }) async {
    return _createReservation(ReservationRequest(
      reservableType: 'poi',
      reservableId: poiId,
      reservationDate: reservationDate,
      reservationTime: reservationTime,
      numberOfPeople: numberOfPeople,
      notes: notes,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
    ));
  }

  /// Crée une nouvelle réservation pour un événement
  Future<ApiResponse<Reservation>> createEventReservation({
    required int eventId,
    required String reservationDate,
    String? reservationTime,
    required int numberOfPeople,
    String? notes,
    String? userName,
    String? userEmail,
    String? userPhone,
  }) async {
    return _createReservation(ReservationRequest(
      reservableType: 'event',
      reservableId: eventId,
      reservationDate: reservationDate,
      reservationTime: reservationTime,
      numberOfPeople: numberOfPeople,
      notes: notes,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
    ));
  }

  /// Crée une réservation générique
  Future<ApiResponse<Reservation>> _createReservation(ReservationRequest request) async {
    try {
      print('[RESERVATION] Sending request: ${request.toJson()}');
      
      final response = await _apiClient.dio.post(
        '/reservations',
        data: request.toJson(),
      );
      
      print('[RESERVATION] Response status: ${response.statusCode}');
      final rawData = response.data as Map<String, dynamic>;
      print('[RESERVATION] Raw response: $rawData');
      
      if (rawData['success'] == true && rawData.containsKey('data')) {
        print('[RESERVATION] Parsing reservation data...');
        final reservationData = rawData['data']['reservation'] as Map<String, dynamic>;
        print('[RESERVATION] Reservation data: $reservationData');
        
        final reservation = Reservation.fromJson(reservationData);
        print('[RESERVATION] Reservation parsed successfully: ${reservation.confirmationNumber}');
        
        return ApiResponse<Reservation>(
          success: true,
          data: reservation,
          message: rawData['message'],
        );
      }
      
      print('[RESERVATION] Response format unexpected');
      return ApiResponse<Reservation>(
        success: false,
        message: rawData['message'] ?? 'Erreur lors de la création de la réservation',
      );
    } on DioException catch (e) {
      print('[RESERVATION] DioException: ${e.message}');
      return ApiResponse<Reservation>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      print('[RESERVATION] Exception: $e');
      return ApiResponse<Reservation>(
        success: false,
        message: 'Erreur inattendue: $e',
      );
    }
  }

  /// Annule une réservation en utilisant le confirmation_number
  Future<ApiResponse<void>> cancelReservation(String confirmationNumber) async {
    try {
      print('[RESERVATION] Cancelling reservation $confirmationNumber');
      final response = await _apiClient.dio.patch('/reservations/$confirmationNumber/cancel');
      
      print('[RESERVATION] Cancel response status: ${response.statusCode}');
      final rawData = response.data as Map<String, dynamic>;
      print('[RESERVATION] Cancel response: $rawData');
      
      if (rawData['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: rawData['message'] ?? 'Réservation annulée avec succès',
        );
      }
      
      return ApiResponse<void>(
        success: false,
        message: rawData['message'] ?? 'Erreur lors de l\'annulation',
      );
    } on DioException catch (e) {
      print('[RESERVATION] Cancel DioException: ${e.message}');
      return ApiResponse<void>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      print('[RESERVATION] Cancel Exception: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Erreur inattendue: $e',
      );
    }
  }

  /// Récupère les détails d'une réservation en utilisant le confirmation_number
  Future<ApiResponse<Reservation>> getReservationDetails(String confirmationNumber) async {
    try {
      final response = await _apiClient.dio.get('/reservations/$confirmationNumber');
      
      final rawData = response.data as Map<String, dynamic>;
      
      if (rawData['success'] == true && rawData.containsKey('data')) {
        final reservation = Reservation.fromJson(rawData['data']['reservation']);
        
        return ApiResponse<Reservation>(
          success: true,
          data: reservation,
        );
      }
      
      return ApiResponse<Reservation>(
        success: false,
        message: 'Réservation introuvable',
      );
    } on DioException catch (e) {
      return ApiResponse<Reservation>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      return ApiResponse<Reservation>(
        success: false,
        message: 'Erreur inattendue: $e',
      );
    }
  }

  /// Helper pour créer une réservation POI avec validation
  Future<ApiResponse<Reservation>> reservePoi(
    Poi poi, {
    required String date,
    String? time,
    required int people,
    String? notes,
    String? userName,
    String? userEmail,
    String? userPhone,
  }) async {
    // Validation des données du POI
    if (!poi.allowReservations) {
      return ApiResponse<Reservation>(
        success: false,
        message: 'Ce lieu n\'accepte pas les réservations',
      );
    }

    return createPoiReservation(
      poiId: poi.id,
      reservationDate: date,
      reservationTime: time,
      numberOfPeople: people,
      notes: notes,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
    );
  }

  /// Helper pour créer une réservation événement avec validation
  Future<ApiResponse<Reservation>> reserveEvent(
    Event event, {
    required String date,
    String? time,
    required int people,
    String? notes,
    String? userName,
    String? userEmail,
    String? userPhone,
  }) async {
    // Validation des données de l'événement
    if (!event.canRegister) {
      return ApiResponse<Reservation>(
        success: false,
        message: 'Cet événement n\'accepte plus d\'inscriptions',
      );
    }

    if (event.maxParticipants != null && 
        (event.currentParticipants + people) > event.maxParticipants!) {
      return ApiResponse<Reservation>(
        success: false,
        message: 'Pas assez de places disponibles (${event.availableSpots} restantes)',
      );
    }

    return createEventReservation(
      eventId: event.id,
      reservationDate: date,
      reservationTime: time,
      numberOfPeople: people,
      notes: notes,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
    );
  }

  /// Supprime définitivement une réservation annulée
  Future<ApiResponse<void>> deleteReservation(String confirmationNumber) async {
    try {
      print('[RESERVATION] Deleting reservation $confirmationNumber');
      final response = await _apiClient.dio.delete('/reservations/$confirmationNumber');
      
      print('[RESERVATION] Delete response status: ${response.statusCode}');
      final rawData = response.data as Map<String, dynamic>;
      print('[RESERVATION] Delete response: $rawData');
      
      if (rawData['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: rawData['message'] ?? 'Réservation supprimée avec succès',
        );
      }
      
      return ApiResponse<void>(
        success: false,
        message: rawData['message'] ?? 'Erreur lors de la suppression',
      );
    } on DioException catch (e) {
      print('[RESERVATION] Delete DioException: ${e.message}');
      return ApiResponse<void>(
        success: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      print('[RESERVATION] Delete Exception: $e');
      return ApiResponse<void>(
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
        if (e.response?.statusCode == 422) {
          // Erreurs de validation
          final errorData = e.response?.data;
          if (errorData is Map<String, dynamic> && errorData.containsKey('errors')) {
            final errors = errorData['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            }
          }
          return 'Données invalides';
        }
        return 'Erreur serveur (${e.response?.statusCode})';
      case DioExceptionType.cancel:
        return 'Requête annulée';
      default:
        return 'Erreur de connexion. Vérifiez votre internet.';
    }
  }
}