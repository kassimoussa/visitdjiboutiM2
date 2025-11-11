import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/tour.dart';
import '../models/simple_tour.dart';
import '../models/tour_reservation.dart';

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
        print('[ TOUR SERVICE] tour_operator: ${tourData['tour_operator']}');
        print('[ TOUR SERVICE] meeting_point: ${tourData['meeting_point']}');
        print('[ TOUR SERVICE] duration: ${tourData['duration']}');
        print('[ TOUR SERVICE] media: ${tourData['media']}');
        print('[ TOUR SERVICE] upcoming_schedules: ${tourData['upcoming_schedules']}');
        print('[ TOUR SERVICE] age_restrictions: ${tourData['age_restrictions']}');

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
      print('[ TOUR SERVICE] Type erreur: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Récupérer les tours mis en avant (featured)
  Future<TourListResponse> getFeaturedTours({
    int limit = 10,
    int page = 1,
  }) async {
    print('[TOUR SERVICE] Récupération tours featured (limit: $limit)');

    return getTours(
      featured: true,
      perPage: limit,
      page: page,
      sortBy: 'created_at',
      sortOrder: 'desc',
    );
  }

  /// Créer une réservation pour un tour
  Future<TourReservationResponse> createReservation({
    required int tourId,
    required int numberOfPeople,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    String? notes,
  }) async {
    print('[TOUR SERVICE] Création réservation tour: $tourId');

    final requestData = <String, dynamic>{
      'number_of_people': numberOfPeople,
    };

    if (notes != null && notes.isNotEmpty) {
      requestData['notes'] = notes;
    }

    // Pour utilisateurs non authentifiés (invités)
    if (guestName != null) {
      requestData['guest_name'] = guestName;
    }
    if (guestEmail != null) {
      requestData['guest_email'] = guestEmail;
    }
    if (guestPhone != null) {
      requestData['guest_phone'] = guestPhone;
    }

    print('[TOUR SERVICE] Données réservation: $requestData');

    try {
      final response = await _apiClient.post(
        ApiConstants.tourReservationCreate(tourId),
        data: requestData,
      );

      print('[TOUR SERVICE] Statut réservation: ${response.statusCode}');
      print('[ TOUR SERVICE] Réponse réservation: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final reservationResponse = TourReservationResponse.fromJson(response.data);
        print('[ TOUR SERVICE] Réservation créée: ID ${reservationResponse.reservation.id}');
        return reservationResponse;
      } else {
        throw Exception('Erreur lors de la réservation: ${response.statusCode}');
      }
    } catch (e) {
      print('[ TOUR SERVICE] Erreur réservation: $e');
      rethrow;
    }
  }

  /// Récupérer la liste de mes réservations
  Future<TourReservationListResponse> getMyReservations({
    ReservationStatus? status,
    int page = 1,
    int perPage = 20,
  }) async {
    print('[ TOUR SERVICE] Récupération mes réservations tours');

    final queryParameters = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (status != null) {
      queryParameters['status'] = status.name;
    }

    try {
      final response = await _apiClient.get(
        ApiConstants.tourReservations,
        queryParameters: queryParameters,
      );

      print('[ TOUR SERVICE] Statut mes réservations: ${response.statusCode}');

      if (response.statusCode == 200) {
        final reservationListResponse = TourReservationListResponse.fromJson(response.data);
        print('[ TOUR SERVICE] Réservations chargées: ${reservationListResponse.data.data.length}');
        return reservationListResponse;
      }
      else {
        throw Exception('Erreur lors du chargement des réservations: ${response.statusCode}');
      }
    } catch (e) {
      print('[ TOUR SERVICE] Erreur mes réservations: $e');
      rethrow;
    }
  }

  /// Récupérer les détails d'une réservation
  Future<TourReservation> getReservationDetails(int reservationId) async {
    print('[ TOUR SERVICE] Récupération détails réservation: $reservationId');

    try {
      final response = await _apiClient.get(
        ApiConstants.tourReservationById(reservationId),
      );

      print('[ TOUR SERVICE] Statut détails réservation: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final reservation = TourReservation.fromJson(data);
        print('[ TOUR SERVICE] Détails réservation chargés: ID ${reservation.id}');
        return reservation;
      } else {
        throw Exception('Réservation non trouvée: ${response.statusCode}');
      }
    } catch (e) {
      print('[ TOUR SERVICE] Erreur détails réservation: $e');
      rethrow;
    }
  }

  /// Mettre à jour une réservation
  Future<TourReservationResponse> updateReservation({
    required int reservationId,
    int? numberOfPeople,
    String? notes,
  }) async {
    print('[ TOUR SERVICE] Modification réservation: $reservationId');

    final requestData = <String, dynamic>{};

    if (numberOfPeople != null) {
      requestData['number_of_people'] = numberOfPeople;
    }
    if (notes != null) {
      requestData['notes'] = notes;
    }

    print('[ TOUR SERVICE] Données modification: $requestData');

    try {
      final response = await _apiClient.patch(
        ApiConstants.tourReservationUpdate(reservationId),
        data: requestData,
      );

      print('[ TOUR SERVICE] Statut modification: ${response.statusCode}');

      if (response.statusCode == 200) {
        final reservationResponse = TourReservationResponse.fromJson(response.data);
        print('[ TOUR SERVICE] Réservation modifiée avec succès');
        return reservationResponse;
      } else {
        throw Exception('Erreur lors de la modification: ${response.statusCode}');
      }
    } catch (e) {
      print('[ TOUR SERVICE] Erreur modification: $e');
      rethrow;
    }
  }

  /// Annuler une réservation
  Future<TourReservationResponse> cancelReservation(int reservationId) async {
    print('[ TOUR SERVICE] Annulation réservation: $reservationId');

    try {
      final response = await _apiClient.patch(
        ApiConstants.tourReservationCancel(reservationId),
      );

      print('[ TOUR SERVICE] Statut annulation: ${response.statusCode}');

      if (response.statusCode == 200) {
        final reservationResponse = TourReservationResponse.fromJson(response.data);
        print('[ TOUR SERVICE] Réservation annulée avec succès');
        return reservationResponse;
      } else {
        throw Exception('Erreur lors de l\annulation: ${response.statusCode}');
      }
    } catch (e) {
      print('[ TOUR SERVICE] Erreur annulation: $e');
      rethrow;
    }
  }

  /// Supprimer une réservation définitivement
  Future<bool> deleteReservationPermanently({
    required int reservationId,
  }) async {
    print('[ TOUR SERVICE] Suppression définitive réservation: $reservationId');

    try {
      final response = await _apiClient.delete(
        ApiConstants.tourReservationById(reservationId),
      );

      print('[ TOUR SERVICE] Statut suppression définitive: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('[ TOUR SERVICE] Réservation supprimée définitivement avec succès');
        return true;
      }
      else {
        throw Exception('Erreur lors de la suppression définitive');
      }
    } catch (e) {
      print('[ TOUR SERVICE] Erreur suppression définitive: $e');
      rethrow;
    }
  }
}