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
      groupingStrategy: json['groupingStrategy'] as String? ?? 'balanced',
      useWhsHandicaps: json['useWhsHandicaps'] as bool? ?? true,
      distanceUnit: json['distanceUnit'] as String? ?? 'yards',
      handicapSystem:
          $enumDecodeNullable(
            _$HandicapSystemEnumMap,
            json['handicapSystem'],
          ) ??
          HandicapSystem.igolf,
      selectedPaletteName: json['selectedPaletteName'] as String?,
      enableSocietyCuts: json['enableSocietyCuts'] as bool? ?? false,
      societyCutRules:
          (json['societyCutRules'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {'1st': 2.0, '2nd': 1.0, '3rd': 0.5},
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
      'groupingStrategy': instance.groupingStrategy,
      'useWhsHandicaps': instance.useWhsHandicaps,
      'distanceUnit': instance.distanceUnit,
      'handicapSystem': _$HandicapSystemEnumMap[instance.handicapSystem]!,
      'selectedPaletteName': instance.selectedPaletteName,
      'enableSocietyCuts': instance.enableSocietyCuts,
      'societyCutRules': instance.societyCutRules,
    };

const _$HandicapSystemEnumMap = {
  HandicapSystem.igolf: 'igolf',
  HandicapSystem.ghin: 'ghin',
  HandicapSystem.golfIreland: 'golfIreland',
  HandicapSystem.golfLink: 'golfLink',
  HandicapSystem.whs: 'whs',
};
