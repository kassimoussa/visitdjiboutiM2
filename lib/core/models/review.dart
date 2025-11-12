import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

/// Review - Avis sur un POI
@JsonSerializable()
class Review {
  final int id;
  @JsonKey(name: 'poi_id', includeIfNull: false)
  final int? poiId;
  final ReviewAuthor author;
  final int rating; // 1-5 étoiles
  final String? title;
  final String? comment;
  @JsonKey(name: 'helpful_count', defaultValue: 0)
  final int? helpfulCount;
  @JsonKey(name: 'is_helpful', defaultValue: false)
  final bool isHelpful;
  @JsonKey(name: 'operator_response')
  final OperatorResponse? operatorResponse;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  Review({
    required this.id,
    this.poiId,
    required this.author,
    required this.rating,
    this.title,
    this.comment,
    this.helpfulCount,
    required this.isHelpful,
    this.operatorResponse,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  // Getters utiles
  bool get hasTitle => title != null && title!.isNotEmpty;
  bool get hasComment => comment != null && comment!.isNotEmpty;
  bool get hasOperatorResponse => operatorResponse != null;
  String get displayRating => '$rating/5';
}

/// ReviewAuthor - Auteur d'un avis
@JsonSerializable()
class ReviewAuthor {
  final String name;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'is_me')
  final bool isMe;

  ReviewAuthor({
    required this.name,
    required this.isVerified,
    required this.isMe,
  });

  factory ReviewAuthor.fromJson(Map<String, dynamic> json) =>
      _$ReviewAuthorFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewAuthorToJson(this);
}

/// OperatorResponse - Réponse de l'opérateur à un avis
@JsonSerializable()
class OperatorResponse {
  final String text;
  final String date;

  OperatorResponse({
    required this.text,
    required this.date,
  });

  factory OperatorResponse.fromJson(Map<String, dynamic> json) =>
      _$OperatorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OperatorResponseToJson(this);
}

/// ReviewStatistics - Statistiques des avis
@JsonSerializable()
class ReviewStatistics {
  @JsonKey(name: 'average_rating')
  final double averageRating;
  @JsonKey(name: 'total_reviews')
  final int totalReviews;
  @JsonKey(name: 'rating_distribution')
  final Map<String, int> ratingDistribution;

  ReviewStatistics({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ReviewStatistics.fromJson(Map<String, dynamic> json) {
    // Convertir les clés en String si elles ne le sont pas déjà
    final Map<String, dynamic> distribution =
        json['rating_distribution'] as Map<String, dynamic>;
    final Map<String, int> convertedDistribution = {};

    distribution.forEach((key, value) {
      convertedDistribution[key.toString()] = value as int;
    });

    return ReviewStatistics(
      averageRating: (json['average_rating'] as num).toDouble(),
      totalReviews: json['total_reviews'] as int,
      ratingDistribution: convertedDistribution,
    );
  }

  Map<String, dynamic> toJson() => _$ReviewStatisticsToJson(this);

  // Getters utiles
  int getCountForRating(int rating) {
    return ratingDistribution[rating.toString()] ?? 0;
  }

  double getPercentageForRating(int rating) {
    if (totalReviews == 0) return 0.0;
    final count = getCountForRating(rating);
    return (count / totalReviews) * 100;
  }

  String get displayAverageRating => averageRating.toStringAsFixed(1);
}

/// ReviewListResponse - Réponse API pour une liste d'avis
@JsonSerializable()
class ReviewListResponse {
  final bool success;
  final List<Review> data;
  final ReviewMeta? meta;
  final ReviewStatistics? statistics;

  ReviewListResponse({
    required this.success,
    required this.data,
    this.meta,
    this.statistics,
  });

  factory ReviewListResponse.fromJson(Map<String, dynamic> json) =>
      _$ReviewListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewListResponseToJson(this);
}

/// ReviewMeta - Métadonnées de pagination pour les avis
@JsonSerializable()
class ReviewMeta {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'last_page')
  final int lastPage;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;

  ReviewMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ReviewMeta.fromJson(Map<String, dynamic> json) =>
      _$ReviewMetaFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewMetaToJson(this);

  bool get hasMorePages => currentPage < lastPage;
}

/// ReviewResponse - Réponse API pour un avis unique
@JsonSerializable()
class ReviewResponse {
  final bool success;
  final String message;
  final Review data;

  ReviewResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) =>
      _$ReviewResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewResponseToJson(this);
}
