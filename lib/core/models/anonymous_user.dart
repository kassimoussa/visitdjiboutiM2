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