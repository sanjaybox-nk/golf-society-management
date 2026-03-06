// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TeeConfig _$TeeConfigFromJson(Map<String, dynamic> json) => _TeeConfig(
  name: json['name'] as String,
  rating: (json['rating'] as num).toDouble(),
  slope: (json['slope'] as num).toInt(),
  holePars: (json['holePars'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  holeSIs: (json['holeSIs'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  yardages: (json['yardages'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$TeeConfigToJson(_TeeConfig instance) =>
    <String, dynamic>{
      'name': instance.name,
      'rating': instance.rating,
      'slope': instance.slope,
      'holePars': instance.holePars,
      'holeSIs': instance.holeSIs,
      'yardages': instance.yardages,
    };

_CourseHole _$CourseHoleFromJson(Map<String, dynamic> json) => _CourseHole(
  hole: (json['hole'] as num).toInt(),
  par: (json['par'] as num).toInt(),
  si: (json['si'] as num).toInt(),
  yardage: (json['yardage'] as num?)?.toInt(),
);

Map<String, dynamic> _$CourseHoleToJson(_CourseHole instance) =>
    <String, dynamic>{
      'hole': instance.hole,
      'par': instance.par,
      'si': instance.si,
      'yardage': instance.yardage,
    };

_CourseConfig _$CourseConfigFromJson(Map<String, dynamic> json) =>
    _CourseConfig(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      tees:
          (json['tees'] as List<dynamic>?)
              ?.map((e) => TeeConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      holes:
          (json['holes'] as List<dynamic>?)
              ?.map((e) => CourseHole.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      rating: (json['rating'] as num?)?.toDouble(),
      slope: (json['slope'] as num?)?.toInt(),
      par: (json['par'] as num?)?.toInt(),
      selectedTeeName: json['selectedTeeName'] as String?,
      isGlobal: json['isGlobal'] as bool? ?? true,
    );

Map<String, dynamic> _$CourseConfigToJson(_CourseConfig instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'tees': instance.tees.map((e) => e.toJson()).toList(),
      'holes': instance.holes.map((e) => e.toJson()).toList(),
      'rating': instance.rating,
      'slope': instance.slope,
      'par': instance.par,
      'selectedTeeName': instance.selectedTeeName,
      'isGlobal': instance.isGlobal,
    };
