import 'package:json_annotation/json_annotation.dart';
import 'tour.dart';

part 'tour_reservation.g.dart';

/// TourReservation - Réservation pour un tour guidé
@JsonSerializable()
class TourReservation {
  final int id;
  @JsonKey(name: 'tour_id')
  final int tourId;

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

  // Détails de la réservation
  @JsonKey(name: 'number_of_people')
  final int numberOfPeople;
  final String? notes;

  // Statut
  final ReservationStatus status;

  // Relation tour (optionnelle, incluse dans certaines réponses)
  // Ignore le parsing car l'objet tour peut avoir des champs incompatibles
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Tour? tour;

  // Timestamps
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  TourReservation({
    required this.id,
    required this.tourId,
    this.appUserId,
    this.guestName,
    this.guestEmail,
    this.guestPhone,
    required this.numberOfPeople,
    this.notes,
    required this.status,
    this.tour,
    this.createdAt,
    this.updatedAt,
  });

  factory TourReservation.fromJson(Map<String, dynamic> json) =>
      _$TourReservationFromJson(json);
  Map<String, dynamic> toJson() => _$TourReservationToJson(this);

  // Getters utiles
  bool get isGuest => appUserId == null;
  bool get isAuthenticated => appUserId != null;
  bool get canCancel => status == ReservationStatus.pending ||
                        status == ReservationStatus.confirmed;
  bool get canUpdate => status == ReservationStatus.pending ||
                        status == ReservationStatus.confirmed;
  String get displayStatus => status.label;
  String get displayName => guestName ?? 'Utilisateur authentifié';
  String get displayEmail => guestEmail ?? '';
}

/// Statuts de réservation
enum ReservationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('cancelled_by_user')
  cancelledByUser,
}

extension ReservationStatusExtension on ReservationStatus {
  String get label {
    switch (this) {
      case ReservationStatus.pending:
        return 'En attente';
      case ReservationStatus.confirmed:
        return 'Confirmée';
      case ReservationStatus.cancelledByUser:
        return 'Annulée';
    }
  }

  String get icon {
    switch (this) {
      case ReservationStatus.pending:
        return '⏳';
      case ReservationStatus.confirmed:
        return '✅';
      case ReservationStatus.cancelledByUser:
        return '❌';
    }
  }
}

/// Réponse API pour une création de réservation
@JsonSerializable()
class TourReservationResponse {
  final bool success;
  final String message;
  final TourReservation reservation;

  TourReservationResponse({
    required this.success,
    required this.message,
    required this.reservation,
  });

  factory TourReservationResponse.fromJson(Map<String, dynamic> json) =>
      _$TourReservationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TourReservationResponseToJson(this);
}

/// Réponse API pour une liste de réservations
@JsonSerializable()
class TourReservationListResponse {
  final bool success;
  final TourReservationListData data;

  TourReservationListResponse({
    required this.success,
    required this.data,
  });

  factory TourReservationListResponse.fromJson(Map<String, dynamic> json) =>
      _$TourReservationListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TourReservationListResponseToJson(this);
}

@JsonSerializable()
class TourReservationListData {
  @JsonKey(name: 'current_page')
  final int currentPage;
  final List<TourReservation> data;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;

  TourReservationListData({
    required this.currentPage,
    required this.data,
    required this.perPage,
    required this.total,
  });

  factory TourReservationListData.fromJson(Map<String, dynamic> json) =>
      _$TourReservationListDataFromJson(json);
  Map<String, dynamic> toJson() => _$TourReservationListDataToJson(this);
}
