import 'package:json_annotation/json_annotation.dart';

part 'simple_tour.g.dart';

@JsonSerializable()
class SimpleTour {
  final int id;
  final String slug;
  final String title;
  final String type;
  @JsonKey(name: 'type_label')
  final String? typeLabel;
  @JsonKey(name: 'difficulty_level')
  final String difficulty;
  @JsonKey(name: 'difficulty_label')
  final String? difficultyLabel;
  final String price;
  final String currency;
  @JsonKey(name: 'formatted_price')
  final String? formattedPrice;
  @JsonKey(name: 'max_participants')
  final int? maxParticipants;
  @JsonKey(name: 'min_participants')
  final int? minParticipants;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'tour_operator')
  final Map<String, dynamic>? tourOperator;
  @JsonKey(name: 'featured_image')
  final Map<String, dynamic>? featuredImage;
  @JsonKey(name: 'next_available_date')
  final String? nextAvailableDate;
  @JsonKey(name: 'start_date')
  final String? startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;

  SimpleTour({
    required this.id,
    required this.slug,
    required this.title,
    required this.type,
    this.typeLabel,
    required this.difficulty,
    this.difficultyLabel,
    required this.price,
    required this.currency,
    this.formattedPrice,
    this.maxParticipants,
    this.minParticipants,
    required this.isFeatured,
    this.tourOperator,
    this.featuredImage,
    this.nextAvailableDate,
    this.startDate,
    this.endDate,
  });

  factory SimpleTour.fromJson(Map<String, dynamic> json) => _$SimpleTourFromJson(json);
  Map<String, dynamic> toJson() => _$SimpleTourToJson(this);

  // Getters pour compatibilité
  String get displayPrice => formattedPrice ?? '$price $currency';
  String get displayType => typeLabel ?? type;
  String get displayDifficulty => difficultyLabel ?? difficulty;
  bool get hasImages => featuredImage != null;
  String get firstImageUrl => featuredImage?['url'] ?? '';
  String get operatorName => tourOperator?['name'] ?? '';
  String get displayDate {
    if (nextAvailableDate != null) {
      return _formatDate(nextAvailableDate!);
    }

    if (startDate != null && endDate != null) {
      final formattedStart = _formatDate(startDate!);
      final formattedEnd = _formatDate(endDate!);

      if (startDate == endDate) {
        return formattedStart;
      }

      return '$formattedStart - $formattedEnd';
    }

    if (startDate != null) {
      return _formatDate(startDate!);
    }

    return 'Date non disponible';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jui',
        'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

@JsonSerializable()
class SimpleTourListResponse {
  final bool success;
  final SimpleTourData data;

  SimpleTourListResponse({
    required this.success,
    required this.data,
  });

  factory SimpleTourListResponse.fromJson(Map<String, dynamic> json) => _$SimpleTourListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SimpleTourListResponseToJson(this);
}

@JsonSerializable()
class SimpleTourData {
  final List<SimpleTour> tours;

  SimpleTourData({
    required this.tours,
  });

  factory SimpleTourData.fromJson(Map<String, dynamic> json) => _$SimpleTourDataFromJson(json);
  Map<String, dynamic> toJson() => _$SimpleTourDataToJson(this);
}