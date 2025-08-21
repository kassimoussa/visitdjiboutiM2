// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anonymous_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnonymousUser _$AnonymousUserFromJson(Map<String, dynamic> json) =>
    AnonymousUser(
      anonymousId: json['anonymous_id'] as String,
      deviceId: json['device_id'] as String,
      token: json['token'] as String,
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$AnonymousUserToJson(AnonymousUser instance) =>
    <String, dynamic>{
      'anonymous_id': instance.anonymousId,
      'device_id': instance.deviceId,
      'token': instance.token,
      'preferences': instance.preferences,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

AnonymousUserRequest _$AnonymousUserRequestFromJson(
  Map<String, dynamic> json,
) => AnonymousUserRequest(
  deviceId: json['device_id'] as String,
  deviceInfo: json['device_info'] as Map<String, dynamic>?,
  preferences: json['preferences'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AnonymousUserRequestToJson(
  AnonymousUserRequest instance,
) => <String, dynamic>{
  'device_id': instance.deviceId,
  'device_info': instance.deviceInfo,
  'preferences': instance.preferences,
};

AnonymousUserResponse _$AnonymousUserResponseFromJson(
  Map<String, dynamic> json,
) => AnonymousUserResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  user: json['user'] == null
      ? null
      : AnonymousUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AnonymousUserResponseToJson(
  AnonymousUserResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'user': instance.user,
};

ConvertAnonymousRequest _$ConvertAnonymousRequestFromJson(
  Map<String, dynamic> json,
) => ConvertAnonymousRequest(
  name: json['name'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  passwordConfirmation: json['password_confirmation'] as String,
  preserveData: json['preserve_data'] as bool? ?? true,
);

Map<String, dynamic> _$ConvertAnonymousRequestToJson(
  ConvertAnonymousRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'password': instance.password,
  'password_confirmation': instance.passwordConfirmation,
  'preserve_data': instance.preserveData,
};

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      language: json['language'] as String,
      pushNotifications: json['push_notifications'] as bool,
      emailNotifications: json['email_notifications'] as bool,
      favoriteCategories: (json['favorite_categories'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      preferredRegions: (json['preferred_regions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'language': instance.language,
      'push_notifications': instance.pushNotifications,
      'email_notifications': instance.emailNotifications,
      'favorite_categories': instance.favoriteCategories,
      'preferred_regions': instance.preferredRegions,
    };
