import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

/// Comment - Commentaire pour administration/opérateurs
@JsonSerializable()
class Comment {
  final int id;
  final CommentAuthor author;
  final String comment;
  @JsonKey(name: 'commentable_type', includeIfNull: false)
  final String? commentableType; // 'poi', 'event', 'tour', 'activity', 'tour_operator'
  @JsonKey(name: 'commentable_id', includeIfNull: false)
  final int? commentableId;
  @JsonKey(name: 'likes_count', defaultValue: 0)
  final int? likesCount;
  @JsonKey(name: 'is_liked', defaultValue: false)
  final bool isLiked;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'parent_id')
  final int? parentId;
  final List<Comment>? replies;

  Comment({
    required this.id,
    required this.author,
    required this.comment,
    this.commentableType,
    this.commentableId,
    this.likesCount,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
    this.parentId,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  // Getters utiles
  bool get hasReplies => replies != null && replies!.isNotEmpty;
  bool get isReply => parentId != null;
}

/// CommentAuthor - Auteur d'un commentaire
@JsonSerializable()
class CommentAuthor {
  final String name;
  @JsonKey(name: 'is_me', defaultValue: false)
  final bool isMe;

  CommentAuthor({
    required this.name,
    required this.isMe,
  });

  factory CommentAuthor.fromJson(Map<String, dynamic> json) =>
      _$CommentAuthorFromJson(json);
  Map<String, dynamic> toJson() => _$CommentAuthorToJson(this);
}

/// CommentListResponse - Réponse API pour une liste de commentaires
@JsonSerializable()
class CommentListResponse {
  final bool success;
  final List<Comment> data;
  final CommentMeta? meta;

  CommentListResponse({
    required this.success,
    required this.data,
    this.meta,
  });

  factory CommentListResponse.fromJson(Map<String, dynamic> json) =>
      _$CommentListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CommentListResponseToJson(this);
}

/// CommentMeta - Métadonnées de pagination pour les commentaires
@JsonSerializable()
class CommentMeta {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'last_page')
  final int lastPage;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;

  CommentMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory CommentMeta.fromJson(Map<String, dynamic> json) =>
      _$CommentMetaFromJson(json);
  Map<String, dynamic> toJson() => _$CommentMetaToJson(this);

  bool get hasMorePages => currentPage < lastPage;
}

/// CommentResponse - Réponse API pour un commentaire unique
@JsonSerializable()
class CommentResponse {
  final bool success;
  final String message;
  final Comment data;

  CommentResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) =>
      _$CommentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CommentResponseToJson(this);
}

/// Types de ressources commentables
enum CommentableType {
  poi,
  event,
  tour,
  @JsonValue('tour_operator')
  tourOperator,
  activity,
}

extension CommentableTypeExtension on CommentableType {
  String get value {
    switch (this) {
      case CommentableType.poi:
        return 'poi';
      case CommentableType.event:
        return 'event';
      case CommentableType.tour:
        return 'tour';
      case CommentableType.tourOperator:
        return 'tour_operator';
      case CommentableType.activity:
        return 'activity';
    }
  }
}
