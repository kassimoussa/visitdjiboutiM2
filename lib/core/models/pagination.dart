import 'package:json_annotation/json_annotation.dart';

part 'pagination.g.dart';

@JsonSerializable()
class Pagination {
  @JsonKey(name: 'current_page', fromJson: _parseInt)
  final int currentPage;
  
  @JsonKey(name: 'last_page', fromJson: _parseInt)
  final int lastPage;
  
  @JsonKey(name: 'per_page', fromJson: _parseInt)
  final int perPage;
  
  @JsonKey(fromJson: _parseInt)
  final int total;
  @JsonKey(fromJson: _parseInt)
  final int from;
  @JsonKey(fromJson: _parseInt)
  final int to;

  const Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value) ?? 0;
    } else if (value is double) {
      return value.toInt();
    }
    return 0; // Default value for null or unparseable data
  }
}