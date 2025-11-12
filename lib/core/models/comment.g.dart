// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: (json['id'] as num).toInt(),
  author: CommentAuthor.fromJson(json['author'] as Map<String, dynamic>),
  comment: json['comment'] as String,
  commentableType: json['commentable_type'] as String?,
  commentableId: (json['commentable_id'] as num?)?.toInt(),
  likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
  isLiked: json['is_liked'] as bool? ?? false,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  parentId: (json['parent_id'] as num?)?.toInt(),
  replies: (json['replies'] as List<dynamic>?)
      ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'author': instance.author,
  'comment': instance.comment,
  'commentable_type': ?instance.commentableType,
  'commentable_id': ?instance.commentableId,
  'likes_count': instance.likesCount,
  'is_liked': instance.isLiked,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'parent_id': instance.parentId,
  'replies': instance.replies,
};

CommentAuthor _$CommentAuthorFromJson(Map<String, dynamic> json) =>
    CommentAuthor(
      name: json['name'] as String,
      isMe: json['is_me'] as bool? ?? false,
    );

Map<String, dynamic> _$CommentAuthorToJson(CommentAuthor instance) =>
    <String, dynamic>{'name': instance.name, 'is_me': instance.isMe};

CommentListResponse _$CommentListResponseFromJson(Map<String, dynamic> json) =>
    CommentListResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] == null
          ? null
          : CommentMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommentListResponseToJson(
  CommentListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'meta': instance.meta,
};

CommentMeta _$CommentMetaFromJson(Map<String, dynamic> json) => CommentMeta(
  currentPage: (json['current_page'] as num).toInt(),
  lastPage: (json['last_page'] as num).toInt(),
  perPage: (json['per_page'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$CommentMetaToJson(CommentMeta instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'last_page': instance.lastPage,
      'per_page': instance.perPage,
      'total': instance.total,
    };

CommentResponse _$CommentResponseFromJson(Map<String, dynamic> json) =>
    CommentResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: Comment.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommentResponseToJson(CommentResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
