// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: (json['id'] as num).toInt(),
  poiId: (json['poi_id'] as num).toInt(),
  author: ReviewAuthor.fromJson(json['author'] as Map<String, dynamic>),
  rating: (json['rating'] as num).toInt(),
  title: json['title'] as String?,
  comment: json['comment'] as String?,
  helpfulCount: (json['helpful_count'] as num).toInt(),
  isHelpful: json['is_helpful'] as bool,
  operatorResponse: json['operator_response'] == null
      ? null
      : OperatorResponse.fromJson(
          json['operator_response'] as Map<String, dynamic>,
        ),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'poi_id': instance.poiId,
  'author': instance.author,
  'rating': instance.rating,
  'title': instance.title,
  'comment': instance.comment,
  'helpful_count': instance.helpfulCount,
  'is_helpful': instance.isHelpful,
  'operator_response': instance.operatorResponse,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

ReviewAuthor _$ReviewAuthorFromJson(Map<String, dynamic> json) => ReviewAuthor(
  name: json['name'] as String,
  isVerified: json['is_verified'] as bool,
  isMe: json['is_me'] as bool,
);

Map<String, dynamic> _$ReviewAuthorToJson(ReviewAuthor instance) =>
    <String, dynamic>{
      'name': instance.name,
      'is_verified': instance.isVerified,
      'is_me': instance.isMe,
    };

OperatorResponse _$OperatorResponseFromJson(Map<String, dynamic> json) =>
    OperatorResponse(
      text: json['text'] as String,
      date: json['date'] as String,
    );

Map<String, dynamic> _$OperatorResponseToJson(OperatorResponse instance) =>
    <String, dynamic>{'text': instance.text, 'date': instance.date};

ReviewStatistics _$ReviewStatisticsFromJson(Map<String, dynamic> json) =>
    ReviewStatistics(
      averageRating: (json['average_rating'] as num).toDouble(),
      totalReviews: (json['total_reviews'] as num).toInt(),
      ratingDistribution: Map<String, int>.from(
        json['rating_distribution'] as Map,
      ),
    );

Map<String, dynamic> _$ReviewStatisticsToJson(ReviewStatistics instance) =>
    <String, dynamic>{
      'average_rating': instance.averageRating,
      'total_reviews': instance.totalReviews,
      'rating_distribution': instance.ratingDistribution,
    };

ReviewListResponse _$ReviewListResponseFromJson(Map<String, dynamic> json) =>
    ReviewListResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] == null
          ? null
          : ReviewMeta.fromJson(json['meta'] as Map<String, dynamic>),
      statistics: json['statistics'] == null
          ? null
          : ReviewStatistics.fromJson(
              json['statistics'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ReviewListResponseToJson(ReviewListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'meta': instance.meta,
      'statistics': instance.statistics,
    };

ReviewMeta _$ReviewMetaFromJson(Map<String, dynamic> json) => ReviewMeta(
  currentPage: (json['current_page'] as num).toInt(),
  lastPage: (json['last_page'] as num).toInt(),
  perPage: (json['per_page'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$ReviewMetaToJson(ReviewMeta instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'last_page': instance.lastPage,
      'per_page': instance.perPage,
      'total': instance.total,
    };

ReviewResponse _$ReviewResponseFromJson(Map<String, dynamic> json) =>
    ReviewResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: Review.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReviewResponseToJson(ReviewResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
