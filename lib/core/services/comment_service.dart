import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/comment.dart';

class CommentService {
  static final CommentService _instance = CommentService._internal();
  factory CommentService() => _instance;
  CommentService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Envoyer un message/commentaire à l'administration/opérateur
  /// Ce commentaire ne sera PAS affiché dans l'application mobile
  Future<CommentResponse> sendMessage({
    required String commentableType,
    required int commentableId,
    required String comment,
    String? guestName,
    String? guestEmail,
  }) async {
    print('[COMMENT SERVICE] Envoi message pour $commentableType:$commentableId');

    final requestData = <String, dynamic>{
      'commentable_type': commentableType,
      'commentable_id': commentableId,
      'comment': comment,
    };

    // Pour utilisateurs non authentifiés (invités)
    if (guestName != null) {
      requestData['guest_name'] = guestName;
    }
    if (guestEmail != null) {
      requestData['guest_email'] = guestEmail;
    }

    print('[COMMENT SERVICE] Données: $requestData');

    try {
      final response = await _apiClient.post(
        ApiConstants.comments,
        data: requestData,
      );

      print('[COMMENT SERVICE] Statut: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final commentResponse = CommentResponse.fromJson(response.data);
        print('[COMMENT SERVICE] Message envoyé avec succès: ID ${commentResponse.data.id}');
        return commentResponse;
      } else {
        throw Exception('Erreur lors de l\'envoi du message: ${response.statusCode}');
      }
    } catch (e) {
      print('[COMMENT SERVICE] Erreur: $e');
      rethrow;
    }
  }

  /// Récupérer les commentaires d'une ressource (pour usage futur si nécessaire)
  Future<CommentListResponse> getComments({
    required String commentableType,
    required int commentableId,
    int page = 1,
    int perPage = 20,
  }) async {
    print('[COMMENT SERVICE] Récupération commentaires $commentableType:$commentableId');

    final queryParameters = <String, dynamic>{
      'commentable_type': commentableType,
      'commentable_id': commentableId,
      'page': page,
      'per_page': perPage,
    };

    try {
      final response = await _apiClient.get(
        ApiConstants.comments,
        queryParameters: queryParameters,
      );

      print('[COMMENT SERVICE] Statut: ${response.statusCode}');

      if (response.statusCode == 200) {
        final commentListResponse = CommentListResponse.fromJson(response.data);
        print('[COMMENT SERVICE] ${commentListResponse.data.length} commentaires chargés');
        return commentListResponse;
      } else {
        throw Exception('Erreur lors du chargement des commentaires: ${response.statusCode}');
      }
    } catch (e) {
      print('[COMMENT SERVICE] Erreur: $e');
      rethrow;
    }
  }

  /// Modifier un commentaire (pour usage futur si nécessaire)
  Future<CommentResponse> updateComment({
    required int commentId,
    required String comment,
  }) async {
    print('[COMMENT SERVICE] Modification commentaire: $commentId');

    final requestData = <String, dynamic>{
      'comment': comment,
    };

    try {
      final response = await _apiClient.put(
        '${ApiConstants.comments}/$commentId',
        data: requestData,
      );

      print('[COMMENT SERVICE] Statut modification: ${response.statusCode}');

      if (response.statusCode == 200) {
        final commentResponse = CommentResponse.fromJson(response.data);
        print('[COMMENT SERVICE] Commentaire modifié avec succès');
        return commentResponse;
      } else {
        throw Exception('Erreur lors de la modification: ${response.statusCode}');
      }
    } catch (e) {
      print('[COMMENT SERVICE] Erreur modification: $e');
      rethrow;
    }
  }

  /// Supprimer un commentaire (pour usage futur si nécessaire)
  Future<bool> deleteComment({required int commentId}) async {
    print('[COMMENT SERVICE] Suppression commentaire: $commentId');

    try {
      final response = await _apiClient.delete(
        '${ApiConstants.comments}/$commentId',
      );

      print('[COMMENT SERVICE] Statut suppression: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('[COMMENT SERVICE] Commentaire supprimé avec succès');
        return true;
      } else {
        throw Exception('Erreur lors de la suppression: ${response.statusCode}');
      }
    } catch (e) {
      print('[COMMENT SERVICE] Erreur suppression: $e');
      rethrow;
    }
  }

  /// Mes commentaires (pour usage futur si nécessaire)
  Future<CommentListResponse> getMyComments({
    int page = 1,
    int perPage = 20,
  }) async {
    print('[COMMENT SERVICE] Récupération de mes commentaires');

    final queryParameters = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    try {
      final response = await _apiClient.get(
        '${ApiConstants.comments}/my-comments',
        queryParameters: queryParameters,
      );

      print('[COMMENT SERVICE] Statut: ${response.statusCode}');

      if (response.statusCode == 200) {
        final commentListResponse = CommentListResponse.fromJson(response.data);
        print('[COMMENT SERVICE] ${commentListResponse.data.length} de mes commentaires chargés');
        return commentListResponse;
      } else {
        throw Exception('Erreur lors du chargement: ${response.statusCode}');
      }
    } catch (e) {
      print('[COMMENT SERVICE] Erreur: $e');
      rethrow;
    }
  }
}
