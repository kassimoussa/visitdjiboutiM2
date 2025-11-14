import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/review.dart';
import 'package:dio/dio.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Extraire le message d'erreur convivial de l'API
  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      // Essayer d'extraire le message de l'API
      if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map<String, dynamic>) {
          // Chercher le message dans les formats courants
          if (data.containsKey('message')) {
            return data['message'] as String;
          }
          if (data.containsKey('error')) {
            return data['error'] as String;
          }
          if (data.containsKey('errors')) {
            final errors = data['errors'];
            if (errors is Map) {
              // Concaténer tous les messages d'erreur
              return errors.values.map((e) => e.toString()).join(', ');
            } else if (errors is String) {
              return errors;
            }
          }
        }
      }

      // Messages par défaut selon le code d'erreur
      switch (error.response?.statusCode) {
        case 400:
          return 'Requête invalide';
        case 401:
          return 'Non autorisé';
        case 403:
          return 'Accès refusé';
        case 404:
          return 'Ressource non trouvée';
        case 422:
          return 'Données invalides';
        case 500:
          return 'Erreur serveur';
        default:
          return 'Erreur de connexion';
      }
    }
    return error.toString();
  }

  /// Récupérer les avis d'un POI avec statistiques
  Future<ReviewListResponse> getPoiReviews({
    required int poiId,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int? rating,
    int perPage = 15,
    int page = 1,
  }) async {
    print('[REVIEW SERVICE] Récupération avis POI: $poiId');

    final queryParameters = <String, dynamic>{
      'sort_by': sortBy,
      'sort_order': sortOrder,
      'per_page': perPage,
      'page': page,
    };

    if (rating != null && rating >= 1 && rating <= 5) {
      queryParameters['rating'] = rating;
    }

    print('[REVIEW SERVICE] Paramètres: $queryParameters');

    try {
      final response = await _apiClient.get(
        ApiConstants.poiReviews(poiId),
        queryParameters: queryParameters,
      );

      print('[REVIEW SERVICE] Statut réponse: ${response.statusCode}');

      if (response.statusCode == 200) {
        final reviewListResponse = ReviewListResponse.fromJson(response.data);
        print('[REVIEW SERVICE] Avis récupérés: ${reviewListResponse.data.length}');
        if (reviewListResponse.statistics != null) {
          print('[REVIEW SERVICE] Note moyenne: ${reviewListResponse.statistics!.displayAverageRating}');
        }
        return reviewListResponse;
      } else {
        throw Exception('Erreur lors du chargement des avis: ${response.statusCode}');
      }
    } catch (e) {
      print('[REVIEW SERVICE] Erreur: $e');
      final errorMessage = _extractErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  /// Créer un avis pour un POI
  Future<ReviewResponse> createReview({
    required int poiId,
    required int rating,
    String? title,
    String? comment,
  }) async {
    print('[REVIEW SERVICE] Création avis POI: $poiId, note: $rating');

    // Validation
    if (rating < 1 || rating > 5) {
      throw Exception('La note doit être entre 1 et 5 étoiles');
    }

    final body = <String, dynamic>{
      'rating': rating,
    };

    if (title != null && title.isNotEmpty) {
      body['title'] = title;
    }
    if (comment != null && comment.isNotEmpty) {
      body['comment'] = comment;
    }

    print('[REVIEW SERVICE] Body création: $body');

    try {
      final response = await _apiClient.post(
        ApiConstants.poiReviewCreate(poiId),
        data: body,
      );

      print('[REVIEW SERVICE] Statut création: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final reviewResponse = ReviewResponse.fromJson(response.data);
        print('[REVIEW SERVICE] Avis créé: ID ${reviewResponse.data.id}');
        return reviewResponse;
      } else {
        throw Exception('Erreur lors de la création de l\'avis: ${response.statusCode}');
      }
    } catch (e) {
      print('[REVIEW SERVICE] Erreur création: $e');
      final errorMessage = _extractErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  /// Modifier un avis existant
  Future<ReviewResponse> updateReview({
    required int poiId,
    required int reviewId,
    required int rating,
    String? title,
    String? comment,
  }) async {
    print('[REVIEW SERVICE] Modification avis: $reviewId, POI: $poiId');

    // Validation
    if (rating < 1 || rating > 5) {
      throw Exception('La note doit être entre 1 et 5 étoiles');
    }

    final body = <String, dynamic>{
      'rating': rating,
    };

    if (title != null && title.isNotEmpty) {
      body['title'] = title;
    }
    if (comment != null && comment.isNotEmpty) {
      body['comment'] = comment;
    }

    print('[REVIEW SERVICE] Body modification: $body');

    try {
      final response = await _apiClient.put(
        ApiConstants.poiReviewUpdate(poiId, reviewId),
        data: body,
      );

      print('[REVIEW SERVICE] Statut modification: ${response.statusCode}');

      if (response.statusCode == 200) {
        final reviewResponse = ReviewResponse.fromJson(response.data);
        print('[REVIEW SERVICE] Avis modifié: ID ${reviewResponse.data.id}');
        return reviewResponse;
      } else {
        throw Exception('Erreur lors de la modification de l\'avis: ${response.statusCode}');
      }
    } catch (e) {
      print('[REVIEW SERVICE] Erreur modification: $e');
      final errorMessage = _extractErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  /// Supprimer un avis
  Future<bool> deleteReview({
    required int poiId,
    required int reviewId,
  }) async {
    print('[REVIEW SERVICE] Suppression avis: $reviewId, POI: $poiId');

    try {
      final response = await _apiClient.delete(
        ApiConstants.poiReviewDelete(poiId, reviewId),
      );

      print('[REVIEW SERVICE] Statut suppression: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('[REVIEW SERVICE] Avis supprimé avec succès');
        return true;
      } else {
        throw Exception('Erreur lors de la suppression de l\'avis: ${response.statusCode}');
      }
    } catch (e) {
      print('[REVIEW SERVICE] Erreur suppression: $e');
      final errorMessage = _extractErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  /// Voter "utile" pour un avis
  Future<ReviewResponse> voteHelpful({
    required int poiId,
    required int reviewId,
  }) async {
    print('[REVIEW SERVICE] Vote utile pour avis: $reviewId, POI: $poiId');

    try {
      final response = await _apiClient.post(
        ApiConstants.poiReviewVoteHelpful(poiId, reviewId),
      );

      print('[REVIEW SERVICE] Statut vote: ${response.statusCode}');

      if (response.statusCode == 200) {
        final reviewResponse = ReviewResponse.fromJson(response.data);
        print('[REVIEW SERVICE] Vote enregistré. Nombre de votes: ${reviewResponse.data.helpfulCount}');
        return reviewResponse;
      } else {
        throw Exception('Erreur lors du vote: ${response.statusCode}');
      }
    } catch (e) {
      print('[REVIEW SERVICE] Erreur vote: $e');
      final errorMessage = _extractErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  /// Récupérer mes avis
  Future<ReviewListResponse> getMyReviews({
    int perPage = 15,
    int page = 1,
  }) async {
    print('[REVIEW SERVICE] Récupération de mes avis');

    final queryParameters = <String, dynamic>{
      'per_page': perPage,
      'page': page,
    };

    try {
      final response = await _apiClient.get(
        ApiConstants.myReviews,
        queryParameters: queryParameters,
      );

      print('[REVIEW SERVICE] Statut réponse mes avis: ${response.statusCode}');

      if (response.statusCode == 200) {
        final reviewListResponse = ReviewListResponse.fromJson(response.data);
        print('[REVIEW SERVICE] Mes avis récupérés: ${reviewListResponse.data.length}');
        return reviewListResponse;
      } else {
        throw Exception('Erreur lors du chargement de mes avis: ${response.statusCode}');
      }
    } catch (e) {
      print('[REVIEW SERVICE] Erreur: $e');
      final errorMessage = _extractErrorMessage(e);
      throw Exception(errorMessage);
    }
  }
}
