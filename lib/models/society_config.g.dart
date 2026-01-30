// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'society_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SocietyConfig _$SocietyConfigFromJson(Map<String, dynamic> json) =>
    _SocietyConfig(
      societyName: json['societyName'] as String? ?? 'Golf Society',
      logoUrl: json['logoUrl'] as String?,
      primaryColor: (json['primaryColor'] as num?)?.toInt() ?? 0xFFF7D354,
      themeMode: json['themeMode'] as String? ?? 'system',
      customColors:
          (json['customColors'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      cardTintIntensity: (json['cardTintIntensity'] as num?)?.toDouble() ?? 0.1,
      useCardGradient: json['useCardGradient'] as bool? ?? true,
      currencySymbol: json['currencySymbol'] as String? ?? '£',
      currencyCode: json['currencyCode'] as String? ?? 'GBP',
    );

Map<String, dynamic> _$SocietyConfigToJson(_SocietyConfig instance) =>
    <String, dynamic>{
      'societyName': instance.societyName,
      'logoUrl': instance.logoUrl,
      'primaryColor': instance.primaryColor,
      'themeMode': instance.themeMode,
      'customColors': instance.customColors,
      'cardTintIntensity': instance.cardTintIntensity,
      'useCardGradient': instance.useCardGradient,
      'currencySymbol': instance.currencySymbol,
      'currencyCode': instance.currencyCode,
    };
