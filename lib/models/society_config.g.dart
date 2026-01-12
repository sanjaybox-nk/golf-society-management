// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'society_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SocietyConfig _$SocietyConfigFromJson(Map<String, dynamic> json) =>
    _SocietyConfig(
      primaryColor: (json['primaryColor'] as num?)?.toInt() ?? 0xFFF7D354,
      themeMode: json['themeMode'] as String? ?? 'system',
      customColors:
          (json['customColors'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      cardTintIntensity: (json['cardTintIntensity'] as num?)?.toDouble() ?? 0.1,
      useCardGradient: json['useCardGradient'] as bool? ?? true,
    );

Map<String, dynamic> _$SocietyConfigToJson(_SocietyConfig instance) =>
    <String, dynamic>{
      'primaryColor': instance.primaryColor,
      'themeMode': instance.themeMode,
      'customColors': instance.customColors,
      'cardTintIntensity': instance.cardTintIntensity,
      'useCardGradient': instance.useCardGradient,
    };
