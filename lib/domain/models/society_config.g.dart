// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'society_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SocietyConfig _$SocietyConfigFromJson(
  Map<String, dynamic> json,
) => _SocietyConfig(
  societyName: json['societyName'] as String? ?? 'Golf Society',
  logoUrl: json['logoUrl'] as String?,
  primaryColor: (json['primaryColor'] as num?)?.toInt() ?? 0xFFF7D354,
  secondaryColor: (json['secondaryColor'] as num?)?.toInt() ?? 0xFF4ADE80,
  backgroundColor: (json['backgroundColor'] as num?)?.toInt() ?? 0xFFEFEFED,
  statusPublishedColor:
      (json['statusPublishedColor'] as num?)?.toInt() ?? 0xFF4ADE80,
  statusConfirmedColor:
      (json['statusConfirmedColor'] as num?)?.toInt() ?? 0xFF4ADE80,
  statusReservedColor:
      (json['statusReservedColor'] as num?)?.toInt() ?? 0xFFFFAA00,
  statusWaitlistColor:
      (json['statusWaitlistColor'] as num?)?.toInt() ?? 0xFFFF5533,
  statusWithdrawnColor:
      (json['statusWithdrawnColor'] as num?)?.toInt() ?? 0xFF6B7280,
  statusDinnerColor: (json['statusDinnerColor'] as num?)?.toInt() ?? 0xFF673AB7,
  cardRadius: (json['cardRadius'] as num?)?.toDouble() ?? 18.0,
  inputRadius: (json['inputRadius'] as num?)?.toDouble() ?? 12.0,
  useShadows: json['useShadows'] as bool? ?? true,
  shadowIntensity: (json['shadowIntensity'] as num?)?.toDouble() ?? 1.0,
  useBorders: json['useBorders'] as bool? ?? true,
  borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1.5,
  pillRadius: (json['pillRadius'] as num?)?.toDouble() ?? 30.0,
  buttonRadius: (json['buttonRadius'] as num?)?.toDouble() ?? 16.0,
  heroRadius: (json['heroRadius'] as num?)?.toDouble() ?? 28.0,
  accentRadius: (json['accentRadius'] as num?)?.toDouble() ?? 8.0,
  accentOpacity: (json['accentOpacity'] as num?)?.toDouble() ?? 0.15,
  shadowSpread: (json['shadowSpread'] as num?)?.toDouble() ?? 0.0,
  shadowOpacity: (json['shadowOpacity'] as num?)?.toDouble() ?? 0.12,
  labelToCardSpacing: (json['labelToCardSpacing'] as num?)?.toDouble() ?? 8.0,
  cardToLabelSpacing: (json['cardToLabelSpacing'] as num?)?.toDouble() ?? 16.0,
  cardToCardSpacing: (json['cardToCardSpacing'] as num?)?.toDouble() ?? 16.0,
  cardVerticalPadding:
      (json['cardVerticalPadding'] as num?)?.toDouble() ?? 16.0,
  cardHorizontalPadding:
      (json['cardHorizontalPadding'] as num?)?.toDouble() ?? 16.0,
  iconBadgeFillColor:
      (json['iconBadgeFillColor'] as num?)?.toInt() ?? 0x264ADE80,
  iconBadgeIconColor:
      (json['iconBadgeIconColor'] as num?)?.toInt() ?? 0xFF4ADE80,
  iconBadgeOpacity: (json['iconBadgeOpacity'] as num?)?.toDouble() ?? 1.0,
  iconOpacity: (json['iconOpacity'] as num?)?.toDouble() ?? 1.0,
  themeMode: json['themeMode'] as String? ?? 'system',
  customColors:
      (json['customColors'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  cardTintIntensity: (json['cardTintIntensity'] as num?)?.toDouble() ?? 0.1,
  useCardGradient: json['useCardGradient'] as bool? ?? false,
  currencySymbol: json['currencySymbol'] as String? ?? '£',
  currencyCode: json['currencyCode'] as String? ?? 'GBP',
  groupingStrategy: json['groupingStrategy'] as String? ?? 'balanced',
  useWhsHandicaps: json['useWhsHandicaps'] as bool? ?? true,
  distanceUnit: json['distanceUnit'] as String? ?? 'yards',
  handicapSystem:
      $enumDecodeNullable(_$HandicapSystemEnumMap, json['handicapSystem']) ??
      HandicapSystem.igolf,
  selectedPaletteName: json['selectedPaletteName'] as String?,
  separateGuestLeaderboard: json['separateGuestLeaderboard'] as bool? ?? true,
  societyCutMode:
      $enumDecodeNullable(_$SocietyCutModeEnumMap, json['societyCutMode']) ??
      SocietyCutMode.off,
  societyCutRules:
      (json['societyCutRules'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {'1st': 2.0, '2nd': 1.0, '3rd': 0.5},
  globalMarkupPercentage:
      (json['globalMarkupPercentage'] as num?)?.toDouble() ?? 0.10,
  guestMarkupExtra: (json['guestMarkupExtra'] as num?)?.toDouble() ?? 10.0,
  globalMembershipEndDate: const OptionalTimestampConverter().fromJson(
    json['globalMembershipEndDate'],
  ),
  renewalWindowDays: (json['renewalWindowDays'] as num?)?.toInt() ?? 30,
  isRenewalActive: json['isRenewalActive'] as bool? ?? false,
  renewalLaunchDate: const OptionalTimestampConverter().fromJson(
    json['renewalLaunchDate'],
  ),
  renewalDeadline: const OptionalTimestampConverter().fromJson(
    json['renewalDeadline'],
  ),
  renewalPaymentDeadline: const OptionalTimestampConverter().fromJson(
    json['renewalPaymentDeadline'],
  ),
  startingBalance: (json['startingBalance'] as num?)?.toDouble() ?? 0.0,
  ledgerEntries:
      (json['ledgerEntries'] as List<dynamic>?)
          ?.map((e) => FinancialEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <FinancialEntry>[],
  sponsors:
      (json['sponsors'] as List<dynamic>?)
          ?.map((e) => Sponsor.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Sponsor>[],
);

Map<String, dynamic> _$SocietyConfigToJson(_SocietyConfig instance) =>
    <String, dynamic>{
      'societyName': instance.societyName,
      'logoUrl': instance.logoUrl,
      'primaryColor': instance.primaryColor,
      'secondaryColor': instance.secondaryColor,
      'backgroundColor': instance.backgroundColor,
      'statusPublishedColor': instance.statusPublishedColor,
      'statusConfirmedColor': instance.statusConfirmedColor,
      'statusReservedColor': instance.statusReservedColor,
      'statusWaitlistColor': instance.statusWaitlistColor,
      'statusWithdrawnColor': instance.statusWithdrawnColor,
      'statusDinnerColor': instance.statusDinnerColor,
      'cardRadius': instance.cardRadius,
      'inputRadius': instance.inputRadius,
      'useShadows': instance.useShadows,
      'shadowIntensity': instance.shadowIntensity,
      'useBorders': instance.useBorders,
      'borderWidth': instance.borderWidth,
      'pillRadius': instance.pillRadius,
      'buttonRadius': instance.buttonRadius,
      'heroRadius': instance.heroRadius,
      'accentRadius': instance.accentRadius,
      'accentOpacity': instance.accentOpacity,
      'shadowSpread': instance.shadowSpread,
      'shadowOpacity': instance.shadowOpacity,
      'labelToCardSpacing': instance.labelToCardSpacing,
      'cardToLabelSpacing': instance.cardToLabelSpacing,
      'cardToCardSpacing': instance.cardToCardSpacing,
      'cardVerticalPadding': instance.cardVerticalPadding,
      'cardHorizontalPadding': instance.cardHorizontalPadding,
      'iconBadgeFillColor': instance.iconBadgeFillColor,
      'iconBadgeIconColor': instance.iconBadgeIconColor,
      'iconBadgeOpacity': instance.iconBadgeOpacity,
      'iconOpacity': instance.iconOpacity,
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
      'separateGuestLeaderboard': instance.separateGuestLeaderboard,
      'societyCutMode': _$SocietyCutModeEnumMap[instance.societyCutMode]!,
      'societyCutRules': instance.societyCutRules,
      'globalMarkupPercentage': instance.globalMarkupPercentage,
      'guestMarkupExtra': instance.guestMarkupExtra,
      'globalMembershipEndDate': const OptionalTimestampConverter().toJson(
        instance.globalMembershipEndDate,
      ),
      'renewalWindowDays': instance.renewalWindowDays,
      'isRenewalActive': instance.isRenewalActive,
      'renewalLaunchDate': const OptionalTimestampConverter().toJson(
        instance.renewalLaunchDate,
      ),
      'renewalDeadline': const OptionalTimestampConverter().toJson(
        instance.renewalDeadline,
      ),
      'renewalPaymentDeadline': const OptionalTimestampConverter().toJson(
        instance.renewalPaymentDeadline,
      ),
      'startingBalance': instance.startingBalance,
      'ledgerEntries': instance.ledgerEntries.map((e) => e.toJson()).toList(),
      'sponsors': instance.sponsors.map((e) => e.toJson()).toList(),
    };

const _$HandicapSystemEnumMap = {
  HandicapSystem.igolf: 'igolf',
  HandicapSystem.ghin: 'ghin',
  HandicapSystem.golfIreland: 'golfIreland',
  HandicapSystem.golfLink: 'golfLink',
  HandicapSystem.whs: 'whs',
};

const _$SocietyCutModeEnumMap = {
  SocietyCutMode.off: 'off',
  SocietyCutMode.global: 'global',
  SocietyCutMode.manual: 'manual',
};

_FinancialEntry _$FinancialEntryFromJson(Map<String, dynamic> json) =>
    _FinancialEntry(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'Sponsorship',
      source: json['source'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      scope: json['scope'] as String?,
      eventId: json['eventId'] as String?,
      sponsorId: json['sponsorId'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: const TimestampConverter().fromJson(json['date']),
      isPaid: json['isPaid'] as bool? ?? true,
    );

Map<String, dynamic> _$FinancialEntryToJson(_FinancialEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'source': instance.source,
      'description': instance.description,
      'logoUrl': instance.logoUrl,
      'scope': instance.scope,
      'eventId': instance.eventId,
      'sponsorId': instance.sponsorId,
      'amount': instance.amount,
      'date': const TimestampConverter().toJson(instance.date),
      'isPaid': instance.isPaid,
    };

_Sponsor _$SponsorFromJson(Map<String, dynamic> json) => _Sponsor(
  id: json['id'] as String,
  name: json['name'] as String,
  logoUrl: json['logoUrl'] as String?,
  websiteUrl: json['websiteUrl'] as String?,
  description: json['description'] as String?,
  tier:
      $enumDecodeNullable(_$SponsorTierEnumMap, json['tier']) ??
      SponsorTier.silver,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$SponsorToJson(_Sponsor instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'logoUrl': instance.logoUrl,
  'websiteUrl': instance.websiteUrl,
  'description': instance.description,
  'tier': _$SponsorTierEnumMap[instance.tier]!,
  'isActive': instance.isActive,
};

const _$SponsorTierEnumMap = {
  SponsorTier.gold: 'gold',
  SponsorTier.silver: 'silver',
  SponsorTier.bronze: 'bronze',
  SponsorTier.standard: 'standard',
};
