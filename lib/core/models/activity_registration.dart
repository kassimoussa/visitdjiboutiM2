import 'package:json_annotation/json_annotation.dart';
import 'activity.dart';

part 'activity_registration.g.dart';

/// ActivityRegistration - Inscription à une activité
@JsonSerializable()
class ActivityRegistration {
  final int id;
  @JsonKey(name: 'activity_id')
  final int activityId;

  // Utilisateur authentifié (nullable si invité)
  @JsonKey(name: 'app_user_id')
  final int? appUserId;

  // Informations invité (si appUserId est null)
  @JsonKey(name: 'guest_name')
  final String? guestName;
  @JsonKey(name: 'guest_email')
  final String? guestEmail;
  @JsonKey(name: 'guest_phone')
  final String? guestPhone;

  // Détails de l'inscription
  @JsonKey(name: 'number_of_people')
  final int numberOfPeople;
  @JsonKey(name: 'preferred_date')
  final String? preferredDate;
  @JsonKey(name: 'special_requirements')
  final String? specialRequirements;
  @JsonKey(name: 'medical_conditions')
  final String? medicalConditions;

  // Statut
  final RegistrationStatus status;
  @JsonKey(name: 'status_label')
  final String? statusLabel;

  // Statut de paiement
  @JsonKey(name: 'payment_status')
  final PaymentStatus? paymentStatus;
  @JsonKey(name: 'payment_status_label')
  final String? paymentStatusLabel;

  // Prix
  @JsonKey(name: 'total_price')
  final double totalPrice;

  // Activité (relation optionnelle) - Removed from JSON in fromJson factory
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Activity? activity;

  // Raison d'annulation
  @JsonKey(name: 'cancellation_reason')
  final String? cancellationReason;

  // Timestamps
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'confirmed_at')
  final String? confirmedAt;
  @JsonKey(name: 'completed_at')
  final String? completedAt;
  @JsonKey(name: 'cancelled_at')
  final String? cancelledAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  ActivityRegistration({
    required this.id,
    required this.activityId,
    this.appUserId,
    this.guestName,
    this.guestEmail,
    this.guestPhone,
    required this.numberOfPeople,
    this.preferredDate,
    this.specialRequirements,
    this.medicalConditions,
    required this.status,
    this.statusLabel,
    this.paymentStatus,
    this.paymentStatusLabel,
    required this.totalPrice,
    this.activity,
    this.cancellationReason,
    this.createdAt,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
    this.updatedAt,
  });

  factory ActivityRegistration.fromJson(Map<String, dynamic> json) {
    // Remove the activity field to prevent parsing errors
    final cleanJson = Map<String, dynamic>.from(json);
    cleanJson.remove('activity');
    return _$ActivityRegistrationFromJson(cleanJson);
  }
  Map<String, dynamic> toJson() => _$ActivityRegistrationToJson(this);

  // Getters utiles
  bool get isGuest => appUserId == null;
  bool get isAuthenticated => appUserId != null;
  bool get canCancel => status == RegistrationStatus.pending ||
      status == RegistrationStatus.confirmed;
  String get displayStatus => statusLabel ?? status.label;
  String get displayPaymentStatus => paymentStatusLabel ?? paymentStatus?.label ?? 'Inconnu';
  String get displayName => guestName ?? 'Utilisateur authentifié';
  String get displayEmail => guestEmail ?? '';
  String get displayPrice => '${totalPrice.toInt()} DJF';
}

/// Statuts d'inscription
enum RegistrationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled_by_user')
  cancelledByUser,
  @JsonValue('cancelled_by_operator')
  cancelledByOperator,
}

extension RegistrationStatusExtension on RegistrationStatus {
  String get label {
    switch (this) {
      case RegistrationStatus.pending:
        return 'En attente';
      case RegistrationStatus.confirmed:
        return 'Confirmé';
      case RegistrationStatus.completed:
        return 'Terminé';
      case RegistrationStatus.cancelledByUser:
        return 'Annulé par vous';
      case RegistrationStatus.cancelledByOperator:
        return 'Annulé par l\'opérateur';
    }
  }

  String get icon {
    switch (this) {
      case RegistrationStatus.pending:
        return '⏳';
      case RegistrationStatus.confirmed:
        return '✅';
      case RegistrationStatus.completed:
        return '🎉';
      case RegistrationStatus.cancelledByUser:
      case RegistrationStatus.cancelledByOperator:
        return '❌';
    }
  }
}

/// Statuts de paiement
enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('paid')
  paid,
  @JsonValue('refunded')
  refunded,
}

extension PaymentStatusExtension on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.paid:
        return 'Payé';
      case PaymentStatus.refunded:
        return 'Remboursé';
    }
  }

  String get icon {
    switch (this) {
      case PaymentStatus.pending:
        return '⏰';
      case PaymentStatus.paid:
        return '💳';
      case PaymentStatus.refunded:
        return '↩️';
    }
  }
}

/// Réponse API pour une création d'inscription
@JsonSerializable()
class ActivityRegistrationResponse {
  final bool success;
  final String message;
  final ActivityRegistration data;

  ActivityRegistrationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ActivityRegistrationResponse.fromJson(Map<String, dynamic> json) =>
      _$ActivityRegistrationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityRegistrationResponseToJson(this);
}

/// Réponse API pour une liste d'inscriptions
@JsonSerializable()
class ActivityRegistrationListResponse {
  final bool success;
  final List<ActivityRegistration> data;
  final ActivityRegistrationMeta? meta;

  ActivityRegistrationListResponse({
    required this.success,
    required this.data,
    this.meta,
  });

  factory ActivityRegistrationListResponse.fromJson(
          Map<String, dynamic> json) =>
      _$ActivityRegistrationListResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      _$ActivityRegistrationListResponseToJson(this);
}

@JsonSerializable()
class ActivityRegistrationMeta {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'last_page')
  final int lastPage;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;

  ActivityRegistrationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ActivityRegistrationMeta.fromJson(Map<String, dynamic> json) =>
      _$ActivityRegistrationMetaFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityRegistrationMetaToJson(this);
}
