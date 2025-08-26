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

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  preferredLanguage: json['preferred_language'] as String,
  dateOfBirth: json['date_of_birth'] as String?,
  gender: json['gender'] as String?,
  provider: json['provider'] as String,
  isActive: json['is_active'] as bool,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  lastLoginAt: json['last_login_at'] as String?,
  lastLoginIp: json['last_login_ip'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  age: (json['age'] as num?)?.toInt(),
  isSocialUser: json['is_social_user'] as bool,
  displayName: json['display_name'] as String,
  uniqueIdentifier: json['unique_identifier'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'preferred_language': instance.preferredLanguage,
  'date_of_birth': instance.dateOfBirth,
  'gender': instance.gender,
  'provider': instance.provider,
  'is_active': instance.isActive,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'last_login_at': instance.lastLoginAt,
  'last_login_ip': instance.lastLoginIp,
  'avatar_url': instance.avatarUrl,
  'age': instance.age,
  'is_social_user': instance.isSocialUser,
  'display_name': instance.displayName,
  'unique_identifier': instance.uniqueIdentifier,
};

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  token: json['token'] as String?,
  tokenType: json['token_type'] as String?,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'user': instance.user,
      'token': instance.token,
      'token_type': instance.tokenType,
    };
