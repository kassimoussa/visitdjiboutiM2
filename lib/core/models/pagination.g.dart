// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
  currentPage: Pagination._parseInt(json['current_page']),
  lastPage: Pagination._parseInt(json['last_page']),
  perPage: Pagination._parseInt(json['per_page']),
  total: Pagination._parseInt(json['total']),
  from: Pagination._parseInt(json['from']),
  to: Pagination._parseInt(json['to']),
);

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'last_page': instance.lastPage,
      'per_page': instance.perPage,
      'total': instance.total,
      'from': instance.from,
      'to': instance.to,
    };
