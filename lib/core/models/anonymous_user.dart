import 'package:json_annotation/json_annotation.dart';

part 'anonymous_user.g.dart';

@JsonSerializable()
class AnonymousUser {
  @JsonKey(name: 'anonymous_id')
  final String anonymousId;
  @JsonKey(name: 'device_id')
  final String deviceId;
  final String token;
  final Map<String, dynamic>? preferences;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  const AnonymousUser({
    required this.anonymousId,
    required this.deviceId,
    required this.token,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnonymousUser.fromJson(Map<String, dynamic> json) => _$AnonymousUserFromJson(json);
  Map<String, dynamic> toJson() => _$AnonymousUserToJson(this);
}

@JsonSerializable()
class AnonymousUserRequest {
  @JsonKey(name: 'device_id')
  final String deviceId;
  @JsonKey(name: 'device_info')
  final Map<String, dynamic>? deviceInfo;
  final Map<String, dynamic>? preferences;

  const AnonymousUserRequest({
    required this.deviceId,
    this.deviceInfo,
    this.preferences,
  });

  factory AnonymousUserRequest.fromJson(Map<String, dynamic> json) => _$AnonymousUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AnonymousUserRequestToJson(this);
}

@JsonSerializable()
class AnonymousUserResponse {
  final bool success;
  final String message;
  final AnonymousUser? user;

  const AnonymousUserResponse({
    required this.success,
    required this.message,
    this.user,
  });

  factory AnonymousUserResponse.fromJson(Map<String, dynamic> json) => _$AnonymousUserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AnonymousUserResponseToJson(this);
}

@JsonSerializable()
class ConvertAnonymousRequest {
  final String name;
  final String email;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;
  @JsonKey(name: 'preserve_data', defaultValue: true)
  final bool preserveData;

  const ConvertAnonymousRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.preserveData = true,
  });

  factory ConvertAnonymousRequest.fromJson(Map<String, dynamic> json) => _$ConvertAnonymousRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ConvertAnonymousRequestToJson(this);
}

@JsonSerializable()
class UserPreferences {
  final String language;
  @JsonKey(name: 'push_notifications')
  final bool pushNotifications;
  @JsonKey(name: 'email_notifications')
  final bool emailNotifications;
  @JsonKey(name: 'favorite_categories')
  final List<int> favoriteCategories;
  @JsonKey(name: 'preferred_regions')
  final List<String> preferredRegions;

  const UserPreferences({
    required this.language,
    required this.pushNotifications,
    required this.emailNotifications,
    required this.favoriteCategories,
    required this.preferredRegions,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  factory UserPreferences.defaultPreferences() {
    return const UserPreferences(
      language: 'fr',
      pushNotifications: true,
      emailNotifications: false,
      favoriteCategories: [],
      preferredRegions: [],
    );
  }

  UserPreferences copyWith({
    String? language,
    bool? pushNotifications,
    bool? emailNotifications,
    List<int>? favoriteCategories,
    List<String>? preferredRegions,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      preferredRegions: preferredRegions ?? this.preferredRegions,
    );
  }
}

// Énumération des moments de conversion
enum ConversionTrigger {
  afterFavorites,     // Après 3-5 favoris
  beforeReservation,  // Avant réservation d'événement
  beforeExport,       // Avant export d'itinéraire
  afterWeekUsage,     // Après 7 jours d'utilisation
  manual,             // Déclenchement manuel
}

extension ConversionTriggerExtension on ConversionTrigger {
  String get message {
    switch (this) {
      case ConversionTrigger.afterFavorites:
        return 'Sauvegardez vos découvertes !';
      case ConversionTrigger.beforeReservation:
        return 'Finalisez votre inscription';
      case ConversionTrigger.beforeExport:
        return 'Recevez votre itinéraire par email';
      case ConversionTrigger.afterWeekUsage:
        return 'Créez votre profil voyageur';
      case ConversionTrigger.manual:
        return 'Créer un compte complet';
    }
  }

  String get description {
    switch (this) {
      case ConversionTrigger.afterFavorites:
        return 'Créez votre compte pour synchroniser vos favoris sur tous vos appareils';
      case ConversionTrigger.beforeReservation:
        return 'Un compte est requis pour finaliser votre réservation d\'événement';
      case ConversionTrigger.beforeExport:
        return 'Créez votre compte pour recevoir votre itinéraire personnalisé par email';
      case ConversionTrigger.afterWeekUsage:
        return 'Après une semaine d\'exploration, créez votre profil pour une expérience personnalisée';
      case ConversionTrigger.manual:
        return 'Accédez à toutes les fonctionnalités avec un compte complet';
    }
  }

  String get buttonText {
    switch (this) {
      case ConversionTrigger.afterFavorites:
        return 'Sauvegarder mes favoris';
      case ConversionTrigger.beforeReservation:
        return 'Créer un compte';
      case ConversionTrigger.beforeExport:
        return 'Recevoir par email';
      case ConversionTrigger.afterWeekUsage:
        return 'Créer mon profil';
      case ConversionTrigger.manual:
        return 'Créer un compte';
    }
  }
}

// Modèles pour les utilisateurs complets
@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  @JsonKey(name: 'preferred_language', defaultValue: 'fr')
  final String preferredLanguage;
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  final String? gender;
  @JsonKey(defaultValue: 'local')
  final String provider;
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'last_login_at')
  final String? lastLoginAt;
  @JsonKey(name: 'last_login_ip')
  final String? lastLoginIp;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final int? age;
  @JsonKey(name: 'is_social_user', defaultValue: false)
  final bool isSocialUser;
  @JsonKey(name: 'display_name')
  final String? displayName;
  @JsonKey(name: 'unique_identifier')
  final String? uniqueIdentifier;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.preferredLanguage = 'fr',
    this.dateOfBirth,
    this.gender,
    this.provider = 'local',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.lastLoginIp,
    this.avatarUrl,
    this.age,
    this.isSocialUser = false,
    this.displayName,
    this.uniqueIdentifier,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return _$UserFromJson(json);
    } catch (e) {
      // Fallback avec parsing manuel pour éviter les erreurs de type casting
      return User(
        id: _parseInt(json['id']) ?? 0,
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString(),
        preferredLanguage: json['preferred_language']?.toString() ?? 'fr',
        dateOfBirth: json['date_of_birth']?.toString(),
        gender: json['gender']?.toString(),
        provider: json['provider']?.toString() ?? 'local',
        isActive: _parseBool(json['is_active']) ?? true,
        createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        updatedAt: json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
        lastLoginAt: json['last_login_at']?.toString(),
        lastLoginIp: json['last_login_ip']?.toString(),
        avatarUrl: json['avatar_url']?.toString(),
        age: _parseInt(json['age']),
        isSocialUser: _parseBool(json['is_social_user']) ?? false,
        displayName: json['display_name']?.toString(),
        uniqueIdentifier: json['unique_identifier']?.toString(),
      );
    }
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Fonctions utilitaires pour le parsing sécurisé
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return null;
  }
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final bool success;
  final String message;
  final User? user;
  final String? token;
  @JsonKey(name: 'token_type')
  final String? tokenType;

  const AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
    this.tokenType,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}