import 'package:json_annotation/json_annotation.dart';

part 'reservation.g.dart';

@JsonSerializable()
class Reservation {
  final int id;
  @JsonKey(name: 'confirmation_number')
  final String confirmationNumber;
  @JsonKey(name: 'reservable_type') 
  final String reservableType; // 'poi' or 'event'
  @JsonKey(name: 'reservable_id')
  final int reservableId;
  @JsonKey(name: 'reservation_date')
  final String reservationDate;
  @JsonKey(name: 'reservation_time')
  final String? reservationTime;
  @JsonKey(name: 'number_of_people')
  final int numberOfPeople;
  final String? notes;
  final String status; // 'pending', 'confirmed', 'cancelled'
  @JsonKey(name: 'user_name')
  final String? userName;
  @JsonKey(name: 'user_email')
  final String? userEmail;
  @JsonKey(name: 'user_phone')
  final String? userPhone;
  @JsonKey(name: 'reservable_name')
  final String? reservableName;
  @JsonKey(name: 'reservable_location')
  final String? reservableLocation;
  @JsonKey(name: 'reservable_image')
  final String? reservableImage;
  @JsonKey(name: 'total_price')
  final double? totalPrice;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const Reservation({
    required this.id,
    required this.confirmationNumber,
    required this.reservableType,
    required this.reservableId,
    required this.reservationDate,
    this.reservationTime,
    required this.numberOfPeople,
    this.notes,
    required this.status,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.reservableName,
    this.reservableLocation,
    this.reservableImage,
    this.totalPrice,
    this.createdAt,
    this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) => _$ReservationFromJson(json);
  Map<String, dynamic> toJson() => _$ReservationToJson(this);

  // Helper getters
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isPoi => reservableType == 'poi';
  bool get isEvent => reservableType == 'event';
  
  String get statusText {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'cancelled':
        return 'Annulée';
      default:
        return 'Inconnue';
    }
  }

  String get typeText => isPoi ? 'Lieu' : 'Événement';
  
  String get priceText {
    if (totalPrice == null || totalPrice == 0) return 'Gratuit';
    return '${totalPrice!.toStringAsFixed(0)} DJF';
  }
}

@JsonSerializable()
class ReservationRequest {
  @JsonKey(name: 'reservable_type')
  final String reservableType;
  @JsonKey(name: 'reservable_id')
  final int reservableId;
  @JsonKey(name: 'reservation_date')
  final String reservationDate;
  @JsonKey(name: 'reservation_time')
  final String? reservationTime;
  @JsonKey(name: 'number_of_people')
  final int numberOfPeople;
  final String? notes;
  @JsonKey(name: 'user_name')
  final String? userName;
  @JsonKey(name: 'user_email')
  final String? userEmail;
  @JsonKey(name: 'user_phone')
  final String? userPhone;

  const ReservationRequest({
    required this.reservableType,
    required this.reservableId,
    required this.reservationDate,
    this.reservationTime,
    required this.numberOfPeople,
    this.notes,
    this.userName,
    this.userEmail,
    this.userPhone,
  });

  factory ReservationRequest.fromJson(Map<String, dynamic> json) => _$ReservationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ReservationRequestToJson(this);
}

@JsonSerializable()
class ReservationListResponse {
  final List<Reservation> reservations;
  final ReservationPagination pagination;

  const ReservationListResponse({
    required this.reservations,
    required this.pagination,
  });

  factory ReservationListResponse.fromJson(Map<String, dynamic> json) => _$ReservationListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ReservationListResponseToJson(this);
}

@JsonSerializable()
class ReservationPagination {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'last_page')
  final int lastPage;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  const ReservationPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });

  factory ReservationPagination.fromJson(Map<String, dynamic> json) => _$ReservationPaginationFromJson(json);
  Map<String, dynamic> toJson() => _$ReservationPaginationToJson(this);
}