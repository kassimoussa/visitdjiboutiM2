import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/tour.dart';
import '../models/simple_tour.dart';
import '../models/tour_booking.dart';
import '../models/api_response.dart';

class TourService {
  static final TourService _instance = TourService._internal();
  factory TourService() => _instance;
  TourService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<TourListResponse> getTours({
    String? search,
    int? operatorId,
    TourType? type,
    TourDifficulty? difficulty,
    int? minPrice,
    int? maxPrice,
    int? maxDurationHours,
    String? dateFrom,
    bool? featured,
    double? latitude,
    double? longitude,
    int? radius,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int perPage = 15,
    int page = 1,
  }) async {
    print('[TOUR SERVICE] Requête API vers: ${ApiConstants.tours}');

    final queryParameters = <String, dynamic>{
      'sort_by': sortBy,
      'sort_order': sortOrder,
      'per_page': perPage,
      'page': page,
    };

    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }
    if (operatorId != null) {
      queryParameters['operator_id'] = operatorId;
    }
    if (type != null) {
      queryParameters['type'] = type.name;
    }
    if (difficulty != null) {
      queryParameters['difficulty'] = difficulty.name;
    }
    if (minPrice != null) {
      queryParameters['min_price'] = minPrice;
    }
    if (maxPrice != null) {
      queryParameters['max_price'] = maxPrice;
    }
    if (maxDurationHours != null) {
      queryParameters['max_duration_hours'] = maxDurationHours;
    }
    if (dateFrom != null) {
      queryParameters['date_from'] = dateFrom;
    }
    if (featured != null) {
      queryParameters['featured'] = featured ? 1 : 0;
    }
    if (latitude != null) {
      queryParameters['latitude'] = latitude;
    }
    if (longitude != null) {
      queryParameters['longitude'] = longitude;
    }
    if (radius != null) {
      queryParameters['radius'] = radius;
    }

    print('[TOUR SERVICE] Paramètres: $queryParameters');

    try {
      final response = await _apiClient.get(
        ApiConstants.tours,
        queryParameters: queryParameters,
      );

      print('[TOUR SERVICE] Statut réponse: ${response.statusCode}');
      print('[TOUR SERVICE] Données reçues: ${response.data}');

      if (response.statusCode == 200) {
        final tourListResponse = TourListResponse.fromJson(response.data);
        print('[TOUR SERVICE] Tours parsés avec succès: ${tourListResponse.data.tours.length} tours');
        return tourListResponse;
      } else {
        throw Exception('Erreur lors du chargement des tours: ${response.statusCode}');
      }
    } catch (e) {
      print('[TOUR SERVICE] Erreur: $e');
      rethrow;
    }
  }

  Future<Tour> getTourDetails(dynamic id) async {
    print('[TOUR SERVICE] Récupération détails tour: $id');

    try {
      final response = await _apiClient.get('${ApiConstants.tours}/$id');

      print('[TOUR SERVICE] Statut réponse détails: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final tourData = data['tour'] as Map<String, dynamic>;

        // Debug: afficher les données reçues
        print('[TOUR SERVICE] Tour data keys: ${tourData.keys.toList()}');
        print('[TOUR SERVICE] featured_image: ${tourData['featured_image']}');
        print('[TOUR SERVICE] tour_operator: ${tourData['tour_operator']}');
        print('[TOUR SERVICE] meeting_point: ${tourData['meeting_point']}');
        print('[TOUR SERVICE] duration: ${tourData['duration']}');
        print('[TOUR SERVICE] media: ${tourData['media']}');
        print('[TOUR SERVICE] upcoming_schedules: ${tourData['upcoming_schedules']}');
        print('[TOUR SERVICE] age_restrictions: ${tourData['age_restrictions']}');

        try {
          final tour = Tour.fromJson(tourData);
          print('[TOUR SERVICE] Détails tour parsés: ${tour.title}');
          return tour;
        } catch (e, stackTrace) {
          print('[TOUR SERVICE] Erreur parsing détaillée: $e');
          print('[TOUR SERVICE] Stack trace: $stackTrace');
          rethrow;
        }
      } else {
        throw Exception('Tour non trouvé: ${response.statusCode}');
      }
    } catch (e) {
      print('[TOUR SERVICE] Erreur lors du chargement des détails: $e');
      print('[TOUR SERVICE] Type erreur: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<TourBookingResponse> bookTour({
    required int scheduleId,
    required int participantsCount,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? specialRequirements,
  }) async {
    print('[TOUR SERVICE] Réservation tour schedule: $scheduleId');

    final requestData = <String, dynamic>{
      'participants_count': participantsCount,
    };

    if (specialRequirements != null && specialRequirements.isNotEmpty) {
      requestData['special_requirements'] = specialRequirements;
    }

    // Pour utilisateurs non authentifiés
    if (userName != null) {
      requestData['user_name'] = userName;
    }
    if (userEmail != null) {
      requestData['user_email'] = userEmail;
    }
    if (userPhone != null) {
      requestData['user_phone'] = userPhone;
    }

    print('[TOUR SERVICE] Données réservation: $requestData');

    try {
      final response = await _apiClient.post(
        '${ApiConstants.tours}/schedules/$scheduleId/book',
        data: requestData,
      );

      print('[TOUR SERVICE] Statut réservation: ${response.statusCode}');
      print('[TOUR SERVICE] Réponse réservation: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final bookingResponse = TourBookingResponse.fromJson(response.data);
        print('[TOUR SERVICE] Réservation créée: ${bookingResponse.data.reservation.confirmationNumber}');
        return bookingResponse;
      } else {
        throw Exception('Erreur lors de la réservation: ${response.statusCode}');
      }
    } catch (e) {
      print('[TOUR SERVICE] Erreur réservation: $e');
      rethrow;
    }
  }

  Future<TourBookingListResponse> getMyBookings({
    BookingStatus? status,
    int page = 1,
    int perPage = 20,
  }) async {
    print('[TOUR SERVICE] Récupération mes réservations tours');

    final queryParameters = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (status != null) {
      queryParameters['status'] = status.name;
    }

    try {
      final response = await _apiClient.get(
        '${ApiConstants.tours}/my-bookings',
        queryParameters: queryParameters,
      );

      print('[TOUR SERVICE] Statut mes réservations: ${response.statusCode}');

      if (response.statusCode == 200) {
        final bookingListResponse = TourBookingListResponse.fromJson(response.data);
        print('[TOUR SERVICE] Réservations chargées: ${bookingListResponse.data.bookings.length}');
        return bookingListResponse;
      } else {
        throw Exception('Erreur lors du chargement des réservations: ${response.statusCode}');
      }
    } catch (e) {
      print('[TOUR SERVICE] Erreur mes réservations: $e');
      rethrow;
    }
  }

  Future<ApiResponse> cancelBooking(int bookingId) async {
    print('[TOUR SERVICE] Annulation réservation: $bookingId');

    try {
      final response = await _apiClient.delete(
        '${ApiConstants.tours}/bookings/$bookingId',
      );

      print('[TOUR SERVICE] Statut annulation: ${response.statusCode}');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<dynamic>.fromJson(response.data, (json) => json);
        print('[TOUR SERVICE] Réservation annulée avec succès');
        return apiResponse;
      } else {
        throw Exception('Erreur lors de l\'annulation: ${response.statusCode}');
      }
    } catch (e) {
      print('[TOUR SERVICE] Erreur annulation: $e');
      rethrow;
    }
  }

  Future<List<SimpleTour>> getFeaturedTours({int limit = 5}) async {
    print('[TOUR SERVICE] Récupération tours vedettes');

    try {
      final response = await _apiClient.get(
        ApiConstants.tours,
        queryParameters: {
          'sort_by': 'created_at',
          'sort_order': 'desc',
          'per_page': limit,
          'page': 1,
        },
      );

      print('[TOUR SERVICE] Statut réponse: ${response.statusCode}');

      if (response.statusCode == 200) {
        final tourListResponse = SimpleTourListResponse.fromJson(response.data);
        print('[TOUR SERVICE] Tours parsés avec succès: ${tourListResponse.data.tours.length} tours');
        return tourListResponse.data.tours;
      } else {
        throw Exception('Erreur lors du chargement des tours: ${response.statusCode}');
      }
    } catch (e) {
      print('[TOUR SERVICE] Erreur tours vedettes: $e');
      return [];
    }
  }

  Future<List<Tour>> getToursByOperator(int operatorId, {int limit = 10}) async {
    print('[TOUR SERVICE] Récupération tours opérateur: $operatorId');

    try {
      final response = await getTours(
        operatorId: operatorId,
        perPage: limit,
      );

      print('[TOUR SERVICE] Réponse reçue - success: ${response.success}');
      print('[TOUR SERVICE] Nombre de tours: ${response.data.tours.length}');

      return response.data.tours;
    } catch (e) {
      print('[TOUR SERVICE] Erreur tours opérateur: $e');
      return [];
    }
  }

  Future<List<Tour>> searchTours(String query) async {
    print('[TOUR SERVICE] Recherche tours: $query');

    try {
      final response = await getTours(
        search: query,
        perPage: 50,
      );

      return response.data.tours;
    } catch (e) {
      print('[TOUR SERVICE] Erreur recherche tours: $e');
      return [];
    }
  }
}