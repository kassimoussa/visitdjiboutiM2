import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/activity.dart';
import '../models/simple_activity.dart';
import '../models/activity_registration.dart';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Récupérer la liste des activités avec filtres
  Future<ActivityListResponse> getActivities({
    String? search,
    String? region,
    ActivityDifficulty? difficulty,
    int? minPrice,
    int? maxPrice,
    bool? hasSpots,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int perPage = 15,
    int page = 1,
  }) async {
    print('[ACTIVITY SERVICE] Requête API vers: ${ApiConstants.activities}');

    final queryParameters = <String, dynamic>{
      'sort_by': sortBy,
      'sort_order': sortOrder,
      'per_page': perPage,
      'page': page,
    };

    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }
    if (region != null && region.isNotEmpty) {
      queryParameters['region'] = region;
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
    if (hasSpots != null) {
      queryParameters['has_spots'] = hasSpots ? 1 : 0;
    }

    print('[ACTIVITY SERVICE] Paramètres: $queryParameters');

    try {
      final response = await _apiClient.get(
        ApiConstants.activities,
        queryParameters: queryParameters,
      );

      print('[ACTIVITY SERVICE] Statut réponse: ${response.statusCode}');

      if (response.statusCode == 200) {
        final activityListResponse = ActivityListResponse.fromJson(response.data);
        print('[ACTIVITY SERVICE] Activités parsées: ${activityListResponse.data.length}');
        return activityListResponse;
      } else {
        throw Exception('Erreur lors du chargement des activités: ${response.statusCode}');
      }
    } catch (e) {
      print('[ACTIVITY SERVICE] Erreur: $e');
      rethrow;
    }
  }

  /// Récupérer les détails d'une activité
  Future<Activity> getActivityDetails(dynamic id) async {
    print('[ACTIVITY SERVICE] Récupération détails activité: $id');

    try {
      final response = await _apiClient.get(ApiConstants.activityById(id));

      print('[ACTIVITY SERVICE] Statut réponse détails: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;

        print('[ACTIVITY SERVICE] Activity data keys: ${data.keys.toList()}');

        final activity = Activity.fromJson(data);
        print('[ACTIVITY SERVICE] Détails activité parsés: ${activity.title}');
        return activity;
      } else {
        throw Exception('Activité non trouvée: ${response.statusCode}');
      }
    } catch (e) {
      print('[ACTIVITY SERVICE] Erreur lors du chargement des détails: $e');
      rethrow;
    }
  }

  /// Récupérer les activités à proximité (GPS)
  Future<List<Activity>> getNearbyActivities({
    required double latitude,
    required double longitude,
    int radius = 50,
    int perPage = 15,
  }) async {
    print('[ACTIVITY SERVICE] Récupération activités à proximité');

    final queryParameters = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'per_page': perPage,
    };

    try {
      final response = await _apiClient.get(
        ApiConstants.activitiesNearby,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final activities = data.map((item) => Activity.fromJson(item)).toList();
        print('[ACTIVITY SERVICE] Activités à proximité: ${activities.length}');
        return activities;
      } else {
        throw Exception('Erreur lors du chargement des activités à proximité');
      }
    } catch (e) {
      print('[ACTIVITY SERVICE] Erreur: $e');
      rethrow;
    }
  }

  /// Récupérer les activités mises en avant (pour page d'accueil)
  Future<List<SimpleActivity>> getFeaturedActivities({int limit = 5}) async {
    print('[ACTIVITY SERVICE] Récupération activités mises en avant');

    try {
      final response = await _apiClient.get(
        ApiConstants.activities,
        queryParameters: {
          'featured': 1,
          'per_page': limit,
        },
      );

      print('[ACTIVITY SERVICE] Response status: ${response.statusCode}');
      print('[ACTIVITY SERVICE] Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        print('[ACTIVITY SERVICE] Nombre d\'activités dans data: ${data.length}');

        if (data.isNotEmpty) {
          print('[ACTIVITY SERVICE] Premier item structure: ${data.first.keys}');
          print('[ACTIVITY SERVICE] Premier item complet: ${data.first}');
        }

        final activities = data.map((item) {
          try {
            return SimpleActivity.fromJson(item);
          } catch (e, stackTrace) {
            print('[ACTIVITY SERVICE] Erreur parsing activité individuelle: $e');
            print('[ACTIVITY SERVICE] Item qui a échoué: $item');
            print('[ACTIVITY SERVICE] StackTrace: $stackTrace');
            rethrow;
          }
        }).toList();

        print('[ACTIVITY SERVICE] Activités featured parsées avec succès: ${activities.length}');
        return activities;
      } else {
        print('[ACTIVITY SERVICE] Status code non-200: ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      print('[ACTIVITY SERVICE] Erreur chargement featured: $e');
      print('[ACTIVITY SERVICE] StackTrace: $stackTrace');
      return [];
    }
  }

  /// S'inscrire à une activité
  Future<ActivityRegistrationResponse> registerToActivity({
    required int activityId,
    required int numberOfPeople,
    String? preferredDate,
    String? specialRequirements,
    String? medicalConditions,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
  }) async {
    print('[ACTIVITY SERVICE] Inscription à l\'activité: $activityId');

    final body = <String, dynamic>{
      'number_of_people': numberOfPeople,
    };

    if (preferredDate != null && preferredDate.isNotEmpty) {
      body['preferred_date'] = preferredDate;
    }
    if (specialRequirements != null && specialRequirements.isNotEmpty) {
      body['special_requirements'] = specialRequirements;
    }
    if (medicalConditions != null && medicalConditions.isNotEmpty) {
      body['medical_conditions'] = medicalConditions;
    }
    if (guestName != null && guestName.isNotEmpty) {
      body['guest_name'] = guestName;
    }
    if (guestEmail != null && guestEmail.isNotEmpty) {
      body['guest_email'] = guestEmail;
    }
    if (guestPhone != null && guestPhone.isNotEmpty) {
      body['guest_phone'] = guestPhone;
    }

    print('[ACTIVITY SERVICE] Body inscription: $body');

    try {
      final response = await _apiClient.post(
        ApiConstants.activityRegister(activityId),
        data: body,
      );

      print('[ACTIVITY SERVICE] Statut inscription: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final registrationResponse = ActivityRegistrationResponse.fromJson(response.data);
        print('[ACTIVITY SERVICE] Inscription créée: ID ${registrationResponse.data.id}');
        return registrationResponse;
      } else {
        throw Exception('Erreur lors de l\'inscription: ${response.statusCode}');
      }
    } catch (e) {
      print('[ACTIVITY SERVICE] Erreur inscription: $e');
      rethrow;
    }
  }

  /// Récupérer mes inscriptions
  Future<ActivityRegistrationListResponse> getMyRegistrations({
    String? status,
    int perPage = 15,
    int page = 1,
  }) async {
    print('[ACTIVITY SERVICE] Récupération de mes inscriptions');

    final queryParameters = <String, dynamic>{
      'per_page': perPage,
      'page': page,
    };

    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }

    try {
      final response = await _apiClient.get(
        ApiConstants.activityRegistrations,
        queryParameters: queryParameters,
      );

      print('[ACTIVITY SERVICE] Statut réponse inscriptions: ${response.statusCode}');

      if (response.statusCode == 200) {
        final registrationListResponse = ActivityRegistrationListResponse.fromJson(response.data);
        print('[ACTIVITY SERVICE] Inscriptions récupérées: ${registrationListResponse.data.length}');
        return registrationListResponse;
      } else {
        throw Exception('Erreur lors du chargement des inscriptions');
      }
    } catch (e) {
      print('[ACTIVITY SERVICE] Erreur: $e');
      rethrow;
    }
  }

  /// Annuler une inscription
  Future<bool> cancelRegistration({
    required int registrationId,
    String? reason,
  }) async {
    print('[ACTIVITY SERVICE] Annulation inscription: $registrationId');

    final body = <String, dynamic>{};
    if (reason != null && reason.isNotEmpty) {
      body['reason'] = reason;
    }

    try {
      final response = await _apiClient.patch(
        ApiConstants.activityRegistrationCancel(registrationId),
        data: body,
      );

      print('[ACTIVITY SERVICE] Statut annulation: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('[ACTIVITY SERVICE] Inscription annulée avec succès');
        return true;
      } else {
        throw Exception('Erreur lors de l\'annulation');
      }
    } catch (e) {
      print('[ACTIVITY SERVICE] Erreur annulation: $e');
      rethrow;
    }
  }

  /// Supprimer une inscription définitivement
  Future<bool> deleteRegistrationPermanently({
    required int registrationId,
  }) async {
    print('[ACTIVITY SERVICE] Suppression définitive inscription: $registrationId');

    try {
      final response = await _apiClient.delete(
        ApiConstants.activityRegistrationDelete(registrationId),
      );

      print('[ACTIVITY SERVICE] Statut suppression définitive: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('[ACTIVITY SERVICE] Inscription supprimée définitivement avec succès');
        return true;
      } else {
        throw Exception('Erreur lors de la suppression définitive');
      }
    } catch (e) {
      print('[ACTIVITY SERVICE] Erreur suppression définitive: $e');
      rethrow;
    }
  }
}
