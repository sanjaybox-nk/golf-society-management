// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'society_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SocietyConfig {
  String get societyName;
  String? get logoUrl;
  int get primaryColor; // Default: BoxyArt Yellow
  int get secondaryColor; // Default: Emerald Green (Action)
  int get dangerousColor; // [NEW] High Alert / Dangerous Action color (Coral)
  int get backgroundColor; // Default: Light Gray/Neutral
  int get statusPublishedColor; // [NEW] Pill Subset (Emerald Green - Lifecycle)
  int get statusConfirmedColor; // [NEW] Pill Subset (Emerald Green - Registration)
  int get statusReservedColor; // [NEW] Pill Subset (Brand Amber)
  int get statusWaitlistColor; // [NEW] Pill Subset (Brand Coral)
  int get statusWithdrawnColor; // [NEW] Pill Subset (Neutral/Slate)
  int get statusDinnerColor; // [NEW] Pill Subset (Purple)
  double get cardRadius; // [NEW] Granular Card Radius
  double get inputRadius; // [NEW] Granular Input Radius
  bool get useShadows; // [NEW] Toggle Shadows
  double get shadowIntensity; // [NEW] Granular Shadow Intensity (0.0 to 2.0)
  bool get useBorders; // [NEW] Toggle Borders
  double get borderWidth; // [NEW] Granular Border Width
  double get pillRadius; // [NEW] Granular Pill Radius
  double get buttonRadius; // [NEW] Granular Button Radius (4.x Default)
  double get heroRadius; // [NEW] Granular Hero Radius (Independent)
  double get accentRadius; // [NEW] Metric & Icon Radius (4.x Default)
  double get accentOpacity; // [NEW] Metric & Icon Background Opacity
  double get shadowSpread; // [NEW] Granular Shadow Spread
  double get shadowOpacity; // [NEW] Granular Shadow Opacity
  double get labelToCardSpacing; // [NEW] Vertical rhythm: Label to Card
  double get cardToLabelSpacing; // [NEW] Vertical rhythm: Card to Label
  double
      get cardToCardSpacing; // [NEW] Vertical rhythm: Card to Card (List Density)
  double get cardVerticalPadding; // [NEW] Global Card Internal Padding
  double get cardHorizontalPadding; // [NEW] Global Card Internal Padding
  int get iconBadgeFillColor; // [NEW] Icon Badge BG (15% Emerald)
  int get iconBadgeIconColor; // [NEW] Icon Badge Glyph (Emerald)
  double get iconBadgeOpacity; // [NEW] Icon Badge background opacity
  double get iconOpacity; // [NEW] Icon Glyph opacity
  double get iconBadgeSize; // [NEW] Tokenized Badge Size
  double get iconBadgeIconSize; // [NEW] Tokenized Badge Glyph Size
  String get themeMode; // 'system', 'light', 'dark'
  List<int> get customColors; // User-created custom colors (up to 5)
  double get cardTintIntensity; // Card background tint intensity (0.0 to 1.0)
  bool get useCardGradient;
  String get currencySymbol; // Default currency symbol
  String get currencyCode; // Default currency code
  String get groupingStrategy; // 'balanced', 'progressive', 'similar', 'random'
  bool get useWhsHandicaps; // Default: Use WHS (Slope/Rating)
  String get distanceUnit; // 'yards' or 'meters'
  HandicapSystem get handicapSystem; // Global provider
  String? get selectedPaletteName;
  bool
      get separateGuestLeaderboard; // Single toggle: ON = Separate, OFF = Hidden
  SocietyCutMode get societyCutMode;
  Map<String, double> get societyCutRules;
  int get societyCutEventLimit; // [NEW] 0 = Rest of Season
  bool
      get societyCutCountPlayedOnly; // [NEW] Toggle: Count all events vs Played only
  bool get societyCutFilterSeason; // [NEW] Cut triggers for Season events
  bool get societyCutFilterInvitational; // [NEW] Cut triggers for Invitationals
  double get globalMarkupPercentage; // Default: 10%
  double get guestMarkupExtra; // Default: £10 extra for guests
  @OptionalTimestampConverter()
  DateTime? get globalMembershipEndDate; // [NEW] Society-wide expiry date
  int get renewalWindowDays; // [NEW] Days before expiry to show home screen alert
  bool
      get isRenewalActive; // [NEW] Admin switch to enable the "Renew Now" button
  @OptionalTimestampConverter()
  DateTime? get renewalLaunchDate; // [NEW] When the "Invoke" happened
  @OptionalTimestampConverter()
  DateTime? get renewalDeadline; // [NEW] Hard cutoff for membership
  @OptionalTimestampConverter()
  DateTime? get renewalPaymentDeadline; // [NEW] Adjustable payment limit
  double get startingBalance; // [NEW] Opening bank balance for the season
  List<FinancialEntry>
      get ledgerEntries; // [NEW] Society-level sponsorships & donations
  List<Sponsor> get sponsors;

  /// Create a copy of SocietyConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SocietyConfigCopyWith<SocietyConfig> get copyWith =>
      _$SocietyConfigCopyWithImpl<SocietyConfig>(
          this as SocietyConfig, _$identity);

  /// Serializes this SocietyConfig to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SocietyConfig &&
            (identical(other.societyName, societyName) ||
                other.societyName == societyName) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.primaryColor, primaryColor) ||
                other.primaryColor == primaryColor) &&
            (identical(other.secondaryColor, secondaryColor) ||
                other.secondaryColor == secondaryColor) &&
            (identical(other.dangerousColor, dangerousColor) ||
                other.dangerousColor == dangerousColor) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.statusPublishedColor, statusPublishedColor) ||
                other.statusPublishedColor == statusPublishedColor) &&
            (identical(other.statusConfirmedColor, statusConfirmedColor) ||
                other.statusConfirmedColor == statusConfirmedColor) &&
            (identical(other.statusReservedColor, statusReservedColor) ||
                other.statusReservedColor == statusReservedColor) &&
            (identical(other.statusWaitlistColor, statusWaitlistColor) ||
                other.statusWaitlistColor == statusWaitlistColor) &&
            (identical(other.statusWithdrawnColor, statusWithdrawnColor) ||
                other.statusWithdrawnColor == statusWithdrawnColor) &&
            (identical(other.statusDinnerColor, statusDinnerColor) ||
                other.statusDinnerColor == statusDinnerColor) &&
            (identical(other.cardRadius, cardRadius) ||
                other.cardRadius == cardRadius) &&
            (identical(other.inputRadius, inputRadius) ||
                other.inputRadius == inputRadius) &&
            (identical(other.useShadows, useShadows) ||
                other.useShadows == useShadows) &&
            (identical(other.shadowIntensity, shadowIntensity) ||
                other.shadowIntensity == shadowIntensity) &&
            (identical(other.useBorders, useBorders) ||
                other.useBorders == useBorders) &&
            (identical(other.borderWidth, borderWidth) ||
                other.borderWidth == borderWidth) &&
            (identical(other.pillRadius, pillRadius) ||
                other.pillRadius == pillRadius) &&
            (identical(other.buttonRadius, buttonRadius) ||
                other.buttonRadius == buttonRadius) &&
            (identical(other.heroRadius, heroRadius) ||
                other.heroRadius == heroRadius) &&
            (identical(other.accentRadius, accentRadius) ||
                other.accentRadius == accentRadius) &&
            (identical(other.accentOpacity, accentOpacity) ||
                other.accentOpacity == accentOpacity) &&
            (identical(other.shadowSpread, shadowSpread) ||
                other.shadowSpread == shadowSpread) &&
            (identical(other.shadowOpacity, shadowOpacity) ||
                other.shadowOpacity == shadowOpacity) &&
            (identical(other.labelToCardSpacing, labelToCardSpacing) ||
                other.labelToCardSpacing == labelToCardSpacing) &&
            (identical(other.cardToLabelSpacing, cardToLabelSpacing) ||
                other.cardToLabelSpacing == cardToLabelSpacing) &&
            (identical(other.cardToCardSpacing, cardToCardSpacing) ||
                other.cardToCardSpacing == cardToCardSpacing) &&
            (identical(other.cardVerticalPadding, cardVerticalPadding) ||
                other.cardVerticalPadding == cardVerticalPadding) &&
            (identical(other.cardHorizontalPadding, cardHorizontalPadding) ||
                other.cardHorizontalPadding == cardHorizontalPadding) &&
            (identical(other.iconBadgeFillColor, iconBadgeFillColor) ||
                other.iconBadgeFillColor == iconBadgeFillColor) &&
            (identical(other.iconBadgeIconColor, iconBadgeIconColor) ||
                other.iconBadgeIconColor == iconBadgeIconColor) &&
            (identical(other.iconBadgeOpacity, iconBadgeOpacity) ||
                other.iconBadgeOpacity == iconBadgeOpacity) &&
            (identical(other.iconOpacity, iconOpacity) ||
                other.iconOpacity == iconOpacity) &&
            (identical(other.iconBadgeSize, iconBadgeSize) ||
                other.iconBadgeSize == iconBadgeSize) &&
            (identical(other.iconBadgeIconSize, iconBadgeIconSize) ||
                other.iconBadgeIconSize == iconBadgeIconSize) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            const DeepCollectionEquality()
                .equals(other.customColors, customColors) &&
            (identical(other.cardTintIntensity, cardTintIntensity) ||
                other.cardTintIntensity == cardTintIntensity) &&
            (identical(other.useCardGradient, useCardGradient) ||
                other.useCardGradient == useCardGradient) &&
            (identical(other.currencySymbol, currencySymbol) ||
                other.currencySymbol == currencySymbol) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.groupingStrategy, groupingStrategy) ||
                other.groupingStrategy == groupingStrategy) &&
            (identical(other.useWhsHandicaps, useWhsHandicaps) ||
                other.useWhsHandicaps == useWhsHandicaps) &&
            (identical(other.distanceUnit, distanceUnit) || other.distanceUnit == distanceUnit) &&
            (identical(other.handicapSystem, handicapSystem) || other.handicapSystem == handicapSystem) &&
            (identical(other.selectedPaletteName, selectedPaletteName) || other.selectedPaletteName == selectedPaletteName) &&
            (identical(other.separateGuestLeaderboard, separateGuestLeaderboard) || other.separateGuestLeaderboard == separateGuestLeaderboard) &&
            (identical(other.societyCutMode, societyCutMode) || other.societyCutMode == societyCutMode) &&
            const DeepCollectionEquality().equals(other.societyCutRules, societyCutRules) &&
            (identical(other.societyCutEventLimit, societyCutEventLimit) || other.societyCutEventLimit == societyCutEventLimit) &&
            (identical(other.societyCutCountPlayedOnly, societyCutCountPlayedOnly) || other.societyCutCountPlayedOnly == societyCutCountPlayedOnly) &&
            (identical(other.societyCutFilterSeason, societyCutFilterSeason) || other.societyCutFilterSeason == societyCutFilterSeason) &&
            (identical(other.societyCutFilterInvitational, societyCutFilterInvitational) || other.societyCutFilterInvitational == societyCutFilterInvitational) &&
            (identical(other.globalMarkupPercentage, globalMarkupPercentage) || other.globalMarkupPercentage == globalMarkupPercentage) &&
            (identical(other.guestMarkupExtra, guestMarkupExtra) || other.guestMarkupExtra == guestMarkupExtra) &&
            (identical(other.globalMembershipEndDate, globalMembershipEndDate) || other.globalMembershipEndDate == globalMembershipEndDate) &&
            (identical(other.renewalWindowDays, renewalWindowDays) || other.renewalWindowDays == renewalWindowDays) &&
            (identical(other.isRenewalActive, isRenewalActive) || other.isRenewalActive == isRenewalActive) &&
            (identical(other.renewalLaunchDate, renewalLaunchDate) || other.renewalLaunchDate == renewalLaunchDate) &&
            (identical(other.renewalDeadline, renewalDeadline) || other.renewalDeadline == renewalDeadline) &&
            (identical(other.renewalPaymentDeadline, renewalPaymentDeadline) || other.renewalPaymentDeadline == renewalPaymentDeadline) &&
            (identical(other.startingBalance, startingBalance) || other.startingBalance == startingBalance) &&
            const DeepCollectionEquality().equals(other.ledgerEntries, ledgerEntries) &&
            const DeepCollectionEquality().equals(other.sponsors, sponsors));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        societyName,
        logoUrl,
        primaryColor,
        secondaryColor,
        dangerousColor,
        backgroundColor,
        statusPublishedColor,
        statusConfirmedColor,
        statusReservedColor,
        statusWaitlistColor,
        statusWithdrawnColor,
        statusDinnerColor,
        cardRadius,
        inputRadius,
        useShadows,
        shadowIntensity,
        useBorders,
        borderWidth,
        pillRadius,
        buttonRadius,
        heroRadius,
        accentRadius,
        accentOpacity,
        shadowSpread,
        shadowOpacity,
        labelToCardSpacing,
        cardToLabelSpacing,
        cardToCardSpacing,
        cardVerticalPadding,
        cardHorizontalPadding,
        iconBadgeFillColor,
        iconBadgeIconColor,
        iconBadgeOpacity,
        iconOpacity,
        iconBadgeSize,
        iconBadgeIconSize,
        themeMode,
        const DeepCollectionEquality().hash(customColors),
        cardTintIntensity,
        useCardGradient,
        currencySymbol,
        currencyCode,
        groupingStrategy,
        useWhsHandicaps,
        distanceUnit,
        handicapSystem,
        selectedPaletteName,
        separateGuestLeaderboard,
        societyCutMode,
        const DeepCollectionEquality().hash(societyCutRules),
        societyCutEventLimit,
        societyCutCountPlayedOnly,
        societyCutFilterSeason,
        societyCutFilterInvitational,
        globalMarkupPercentage,
        guestMarkupExtra,
        globalMembershipEndDate,
        renewalWindowDays,
        isRenewalActive,
        renewalLaunchDate,
        renewalDeadline,
        renewalPaymentDeadline,
        startingBalance,
        const DeepCollectionEquality().hash(ledgerEntries),
        const DeepCollectionEquality().hash(sponsors)
      ]);

  @override
  String toString() {
    return 'SocietyConfig(societyName: $societyName, logoUrl: $logoUrl, primaryColor: $primaryColor, secondaryColor: $secondaryColor, dangerousColor: $dangerousColor, backgroundColor: $backgroundColor, statusPublishedColor: $statusPublishedColor, statusConfirmedColor: $statusConfirmedColor, statusReservedColor: $statusReservedColor, statusWaitlistColor: $statusWaitlistColor, statusWithdrawnColor: $statusWithdrawnColor, statusDinnerColor: $statusDinnerColor, cardRadius: $cardRadius, inputRadius: $inputRadius, useShadows: $useShadows, shadowIntensity: $shadowIntensity, useBorders: $useBorders, borderWidth: $borderWidth, pillRadius: $pillRadius, buttonRadius: $buttonRadius, heroRadius: $heroRadius, accentRadius: $accentRadius, accentOpacity: $accentOpacity, shadowSpread: $shadowSpread, shadowOpacity: $shadowOpacity, labelToCardSpacing: $labelToCardSpacing, cardToLabelSpacing: $cardToLabelSpacing, cardToCardSpacing: $cardToCardSpacing, cardVerticalPadding: $cardVerticalPadding, cardHorizontalPadding: $cardHorizontalPadding, iconBadgeFillColor: $iconBadgeFillColor, iconBadgeIconColor: $iconBadgeIconColor, iconBadgeOpacity: $iconBadgeOpacity, iconOpacity: $iconOpacity, iconBadgeSize: $iconBadgeSize, iconBadgeIconSize: $iconBadgeIconSize, themeMode: $themeMode, customColors: $customColors, cardTintIntensity: $cardTintIntensity, useCardGradient: $useCardGradient, currencySymbol: $currencySymbol, currencyCode: $currencyCode, groupingStrategy: $groupingStrategy, useWhsHandicaps: $useWhsHandicaps, distanceUnit: $distanceUnit, handicapSystem: $handicapSystem, selectedPaletteName: $selectedPaletteName, separateGuestLeaderboard: $separateGuestLeaderboard, societyCutMode: $societyCutMode, societyCutRules: $societyCutRules, societyCutEventLimit: $societyCutEventLimit, societyCutCountPlayedOnly: $societyCutCountPlayedOnly, societyCutFilterSeason: $societyCutFilterSeason, societyCutFilterInvitational: $societyCutFilterInvitational, globalMarkupPercentage: $globalMarkupPercentage, guestMarkupExtra: $guestMarkupExtra, globalMembershipEndDate: $globalMembershipEndDate, renewalWindowDays: $renewalWindowDays, isRenewalActive: $isRenewalActive, renewalLaunchDate: $renewalLaunchDate, renewalDeadline: $renewalDeadline, renewalPaymentDeadline: $renewalPaymentDeadline, startingBalance: $startingBalance, ledgerEntries: $ledgerEntries, sponsors: $sponsors)';
  }
}

/// @nodoc
abstract mixin class $SocietyConfigCopyWith<$Res> {
  factory $SocietyConfigCopyWith(
          SocietyConfig value, $Res Function(SocietyConfig) _then) =
      _$SocietyConfigCopyWithImpl;
  @useResult
  $Res call(
      {String societyName,
      String? logoUrl,
      int primaryColor,
      int secondaryColor,
      int dangerousColor,
      int backgroundColor,
      int statusPublishedColor,
      int statusConfirmedColor,
      int statusReservedColor,
      int statusWaitlistColor,
      int statusWithdrawnColor,
      int statusDinnerColor,
      double cardRadius,
      double inputRadius,
      bool useShadows,
      double shadowIntensity,
      bool useBorders,
      double borderWidth,
      double pillRadius,
      double buttonRadius,
      double heroRadius,
      double accentRadius,
      double accentOpacity,
      double shadowSpread,
      double shadowOpacity,
      double labelToCardSpacing,
      double cardToLabelSpacing,
      double cardToCardSpacing,
      double cardVerticalPadding,
      double cardHorizontalPadding,
      int iconBadgeFillColor,
      int iconBadgeIconColor,
      double iconBadgeOpacity,
      double iconOpacity,
      double iconBadgeSize,
      double iconBadgeIconSize,
      String themeMode,
      List<int> customColors,
      double cardTintIntensity,
      bool useCardGradient,
      String currencySymbol,
      String currencyCode,
      String groupingStrategy,
      bool useWhsHandicaps,
      String distanceUnit,
      HandicapSystem handicapSystem,
      String? selectedPaletteName,
      bool separateGuestLeaderboard,
      SocietyCutMode societyCutMode,
      Map<String, double> societyCutRules,
      int societyCutEventLimit,
      bool societyCutCountPlayedOnly,
      bool societyCutFilterSeason,
      bool societyCutFilterInvitational,
      double globalMarkupPercentage,
      double guestMarkupExtra,
      @OptionalTimestampConverter() DateTime? globalMembershipEndDate,
      int renewalWindowDays,
      bool isRenewalActive,
      @OptionalTimestampConverter() DateTime? renewalLaunchDate,
      @OptionalTimestampConverter() DateTime? renewalDeadline,
      @OptionalTimestampConverter() DateTime? renewalPaymentDeadline,
      double startingBalance,
      List<FinancialEntry> ledgerEntries,
      List<Sponsor> sponsors});
}

/// @nodoc
class _$SocietyConfigCopyWithImpl<$Res>
    implements $SocietyConfigCopyWith<$Res> {
  _$SocietyConfigCopyWithImpl(this._self, this._then);

  final SocietyConfig _self;
  final $Res Function(SocietyConfig) _then;

  /// Create a copy of SocietyConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? societyName = null,
    Object? logoUrl = freezed,
    Object? primaryColor = null,
    Object? secondaryColor = null,
    Object? dangerousColor = null,
    Object? backgroundColor = null,
    Object? statusPublishedColor = null,
    Object? statusConfirmedColor = null,
    Object? statusReservedColor = null,
    Object? statusWaitlistColor = null,
    Object? statusWithdrawnColor = null,
    Object? statusDinnerColor = null,
    Object? cardRadius = null,
    Object? inputRadius = null,
    Object? useShadows = null,
    Object? shadowIntensity = null,
    Object? useBorders = null,
    Object? borderWidth = null,
    Object? pillRadius = null,
    Object? buttonRadius = null,
    Object? heroRadius = null,
    Object? accentRadius = null,
    Object? accentOpacity = null,
    Object? shadowSpread = null,
    Object? shadowOpacity = null,
    Object? labelToCardSpacing = null,
    Object? cardToLabelSpacing = null,
    Object? cardToCardSpacing = null,
    Object? cardVerticalPadding = null,
    Object? cardHorizontalPadding = null,
    Object? iconBadgeFillColor = null,
    Object? iconBadgeIconColor = null,
    Object? iconBadgeOpacity = null,
    Object? iconOpacity = null,
    Object? iconBadgeSize = null,
    Object? iconBadgeIconSize = null,
    Object? themeMode = null,
    Object? customColors = null,
    Object? cardTintIntensity = null,
    Object? useCardGradient = null,
    Object? currencySymbol = null,
    Object? currencyCode = null,
    Object? groupingStrategy = null,
    Object? useWhsHandicaps = null,
    Object? distanceUnit = null,
    Object? handicapSystem = null,
    Object? selectedPaletteName = freezed,
    Object? separateGuestLeaderboard = null,
    Object? societyCutMode = null,
    Object? societyCutRules = null,
    Object? societyCutEventLimit = null,
    Object? societyCutCountPlayedOnly = null,
    Object? societyCutFilterSeason = null,
    Object? societyCutFilterInvitational = null,
    Object? globalMarkupPercentage = null,
    Object? guestMarkupExtra = null,
    Object? globalMembershipEndDate = freezed,
    Object? renewalWindowDays = null,
    Object? isRenewalActive = null,
    Object? renewalLaunchDate = freezed,
    Object? renewalDeadline = freezed,
    Object? renewalPaymentDeadline = freezed,
    Object? startingBalance = null,
    Object? ledgerEntries = null,
    Object? sponsors = null,
  }) {
    return _then(_self.copyWith(
      societyName: null == societyName
          ? _self.societyName
          : societyName // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _self.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryColor: null == primaryColor
          ? _self.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as int,
      secondaryColor: null == secondaryColor
          ? _self.secondaryColor
          : secondaryColor // ignore: cast_nullable_to_non_nullable
              as int,
      dangerousColor: null == dangerousColor
          ? _self.dangerousColor
          : dangerousColor // ignore: cast_nullable_to_non_nullable
              as int,
      backgroundColor: null == backgroundColor
          ? _self.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as int,
      statusPublishedColor: null == statusPublishedColor
          ? _self.statusPublishedColor
          : statusPublishedColor // ignore: cast_nullable_to_non_nullable
              as int,
      statusConfirmedColor: null == statusConfirmedColor
          ? _self.statusConfirmedColor
          : statusConfirmedColor // ignore: cast_nullable_to_non_nullable
              as int,
      statusReservedColor: null == statusReservedColor
          ? _self.statusReservedColor
          : statusReservedColor // ignore: cast_nullable_to_non_nullable
              as int,
      statusWaitlistColor: null == statusWaitlistColor
          ? _self.statusWaitlistColor
          : statusWaitlistColor // ignore: cast_nullable_to_non_nullable
              as int,
      statusWithdrawnColor: null == statusWithdrawnColor
          ? _self.statusWithdrawnColor
          : statusWithdrawnColor // ignore: cast_nullable_to_non_nullable
              as int,
      statusDinnerColor: null == statusDinnerColor
          ? _self.statusDinnerColor
          : statusDinnerColor // ignore: cast_nullable_to_non_nullable
              as int,
      cardRadius: null == cardRadius
          ? _self.cardRadius
          : cardRadius // ignore: cast_nullable_to_non_nullable
              as double,
      inputRadius: null == inputRadius
          ? _self.inputRadius
          : inputRadius // ignore: cast_nullable_to_non_nullable
              as double,
      useShadows: null == useShadows
          ? _self.useShadows
          : useShadows // ignore: cast_nullable_to_non_nullable
              as bool,
      shadowIntensity: null == shadowIntensity
          ? _self.shadowIntensity
          : shadowIntensity // ignore: cast_nullable_to_non_nullable
              as double,
      useBorders: null == useBorders
          ? _self.useBorders
          : useBorders // ignore: cast_nullable_to_non_nullable
              as bool,
      borderWidth: null == borderWidth
          ? _self.borderWidth
          : borderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      pillRadius: null == pillRadius
          ? _self.pillRadius
          : pillRadius // ignore: cast_nullable_to_non_nullable
              as double,
      buttonRadius: null == buttonRadius
          ? _self.buttonRadius
          : buttonRadius // ignore: cast_nullable_to_non_nullable
              as double,
      heroRadius: null == heroRadius
          ? _self.heroRadius
          : heroRadius // ignore: cast_nullable_to_non_nullable
              as double,
      accentRadius: null == accentRadius
          ? _self.accentRadius
          : accentRadius // ignore: cast_nullable_to_non_nullable
              as double,
      accentOpacity: null == accentOpacity
          ? _self.accentOpacity
          : accentOpacity // ignore: cast_nullable_to_non_nullable
              as double,
      shadowSpread: null == shadowSpread
          ? _self.shadowSpread
          : shadowSpread // ignore: cast_nullable_to_non_nullable
              as double,
      shadowOpacity: null == shadowOpacity
          ? _self.shadowOpacity
          : shadowOpacity // ignore: cast_nullable_to_non_nullable
              as double,
      labelToCardSpacing: null == labelToCardSpacing
          ? _self.labelToCardSpacing
          : labelToCardSpacing // ignore: cast_nullable_to_non_nullable
              as double,
      cardToLabelSpacing: null == cardToLabelSpacing
          ? _self.cardToLabelSpacing
          : cardToLabelSpacing // ignore: cast_nullable_to_non_nullable
              as double,
      cardToCardSpacing: null == cardToCardSpacing
          ? _self.cardToCardSpacing
          : cardToCardSpacing // ignore: cast_nullable_to_non_nullable
              as double,
      cardVerticalPadding: null == cardVerticalPadding
          ? _self.cardVerticalPadding
          : cardVerticalPadding // ignore: cast_nullable_to_non_nullable
              as double,
      cardHorizontalPadding: null == cardHorizontalPadding
          ? _self.cardHorizontalPadding
          : cardHorizontalPadding // ignore: cast_nullable_to_non_nullable
              as double,
      iconBadgeFillColor: null == iconBadgeFillColor
          ? _self.iconBadgeFillColor
          : iconBadgeFillColor // ignore: cast_nullable_to_non_nullable
              as int,
      iconBadgeIconColor: null == iconBadgeIconColor
          ? _self.iconBadgeIconColor
          : iconBadgeIconColor // ignore: cast_nullable_to_non_nullable
              as int,
      iconBadgeOpacity: null == iconBadgeOpacity
          ? _self.iconBadgeOpacity
          : iconBadgeOpacity // ignore: cast_nullable_to_non_nullable
              as double,
      iconOpacity: null == iconOpacity
          ? _self.iconOpacity
          : iconOpacity // ignore: cast_nullable_to_non_nullable
              as double,
      iconBadgeSize: null == iconBadgeSize
          ? _self.iconBadgeSize
          : iconBadgeSize // ignore: cast_nullable_to_non_nullable
              as double,
      iconBadgeIconSize: null == iconBadgeIconSize
          ? _self.iconBadgeIconSize
          : iconBadgeIconSize // ignore: cast_nullable_to_non_nullable
              as double,
      themeMode: null == themeMode
          ? _self.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as String,
      customColors: null == customColors
          ? _self.customColors
          : customColors // ignore: cast_nullable_to_non_nullable
              as List<int>,
      cardTintIntensity: null == cardTintIntensity
          ? _self.cardTintIntensity
          : cardTintIntensity // ignore: cast_nullable_to_non_nullable
              as double,
      useCardGradient: null == useCardGradient
          ? _self.useCardGradient
          : useCardGradient // ignore: cast_nullable_to_non_nullable
              as bool,
      currencySymbol: null == currencySymbol
          ? _self.currencySymbol
          : currencySymbol // ignore: cast_nullable_to_non_nullable
              as String,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      groupingStrategy: null == groupingStrategy
          ? _self.groupingStrategy
          : groupingStrategy // ignore: cast_nullable_to_non_nullable
              as String,
      useWhsHandicaps: null == useWhsHandicaps
          ? _self.useWhsHandicaps
          : useWhsHandicaps // ignore: cast_nullable_to_non_nullable
              as bool,
      distanceUnit: null == distanceUnit
          ? _self.distanceUnit
          : distanceUnit // ignore: cast_nullable_to_non_nullable
              as String,
      handicapSystem: null == handicapSystem
          ? _self.handicapSystem
          : handicapSystem // ignore: cast_nullable_to_non_nullable
              as HandicapSystem,
      selectedPaletteName: freezed == selectedPaletteName
          ? _self.selectedPaletteName
          : selectedPaletteName // ignore: cast_nullable_to_non_nullable
              as String?,
      separateGuestLeaderboard: null == separateGuestLeaderboard
          ? _self.separateGuestLeaderboard
          : separateGuestLeaderboard // ignore: cast_nullable_to_non_nullable
              as bool,
      societyCutMode: null == societyCutMode
          ? _self.societyCutMode
          : societyCutMode // ignore: cast_nullable_to_non_nullable
              as SocietyCutMode,
      societyCutRules: null == societyCutRules
          ? _self.societyCutRules
          : societyCutRules // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      societyCutEventLimit: null == societyCutEventLimit
          ? _self.societyCutEventLimit
          : societyCutEventLimit // ignore: cast_nullable_to_non_nullable
              as int,
      societyCutCountPlayedOnly: null == societyCutCountPlayedOnly
          ? _self.societyCutCountPlayedOnly
          : societyCutCountPlayedOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      societyCutFilterSeason: null == societyCutFilterSeason
          ? _self.societyCutFilterSeason
          : societyCutFilterSeason // ignore: cast_nullable_to_non_nullable
              as bool,
      societyCutFilterInvitational: null == societyCutFilterInvitational
          ? _self.societyCutFilterInvitational
          : societyCutFilterInvitational // ignore: cast_nullable_to_non_nullable
              as bool,
      globalMarkupPercentage: null == globalMarkupPercentage
          ? _self.globalMarkupPercentage
          : globalMarkupPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      guestMarkupExtra: null == guestMarkupExtra
          ? _self.guestMarkupExtra
          : guestMarkupExtra // ignore: cast_nullable_to_non_nullable
              as double,
      globalMembershipEndDate: freezed == globalMembershipEndDate
          ? _self.globalMembershipEndDate
          : globalMembershipEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      renewalWindowDays: null == renewalWindowDays
          ? _self.renewalWindowDays
          : renewalWindowDays // ignore: cast_nullable_to_non_nullable
              as int,
      isRenewalActive: null == isRenewalActive
          ? _self.isRenewalActive
          : isRenewalActive // ignore: cast_nullable_to_non_nullable
              as bool,
      renewalLaunchDate: freezed == renewalLaunchDate
          ? _self.renewalLaunchDate
          : renewalLaunchDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      renewalDeadline: freezed == renewalDeadline
          ? _self.renewalDeadline
          : renewalDeadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      renewalPaymentDeadline: freezed == renewalPaymentDeadline
          ? _self.renewalPaymentDeadline
          : renewalPaymentDeadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startingBalance: null == startingBalance
          ? _self.startingBalance
          : startingBalance // ignore: cast_nullable_to_non_nullable
              as double,
      ledgerEntries: null == ledgerEntries
          ? _self.ledgerEntries
          : ledgerEntries // ignore: cast_nullable_to_non_nullable
              as List<FinancialEntry>,
      sponsors: null == sponsors
          ? _self.sponsors
          : sponsors // ignore: cast_nullable_to_non_nullable
              as List<Sponsor>,
    ));
  }
}

/// Adds pattern-matching-related methods to [SocietyConfig].
extension SocietyConfigPatterns on SocietyConfig {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SocietyConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SocietyConfig() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SocietyConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SocietyConfig():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SocietyConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SocietyConfig() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String societyName,
            String? logoUrl,
            int primaryColor,
            int secondaryColor,
            int dangerousColor,
            int backgroundColor,
            int statusPublishedColor,
            int statusConfirmedColor,
            int statusReservedColor,
            int statusWaitlistColor,
            int statusWithdrawnColor,
            int statusDinnerColor,
            double cardRadius,
            double inputRadius,
            bool useShadows,
            double shadowIntensity,
            bool useBorders,
            double borderWidth,
            double pillRadius,
            double buttonRadius,
            double heroRadius,
            double accentRadius,
            double accentOpacity,
            double shadowSpread,
            double shadowOpacity,
            double labelToCardSpacing,
            double cardToLabelSpacing,
            double cardToCardSpacing,
            double cardVerticalPadding,
            double cardHorizontalPadding,
            int iconBadgeFillColor,
            int iconBadgeIconColor,
            double iconBadgeOpacity,
            double iconOpacity,
            double iconBadgeSize,
            double iconBadgeIconSize,
            String themeMode,
            List<int> customColors,
            double cardTintIntensity,
            bool useCardGradient,
            String currencySymbol,
            String currencyCode,
            String groupingStrategy,
            bool useWhsHandicaps,
            String distanceUnit,
            HandicapSystem handicapSystem,
            String? selectedPaletteName,
            bool separateGuestLeaderboard,
            SocietyCutMode societyCutMode,
            Map<String, double> societyCutRules,
            int societyCutEventLimit,
            bool societyCutCountPlayedOnly,
            bool societyCutFilterSeason,
            bool societyCutFilterInvitational,
            double globalMarkupPercentage,
            double guestMarkupExtra,
            @OptionalTimestampConverter() DateTime? globalMembershipEndDate,
            int renewalWindowDays,
            bool isRenewalActive,
            @OptionalTimestampConverter() DateTime? renewalLaunchDate,
            @OptionalTimestampConverter() DateTime? renewalDeadline,
            @OptionalTimestampConverter() DateTime? renewalPaymentDeadline,
            double startingBalance,
            List<FinancialEntry> ledgerEntries,
            List<Sponsor> sponsors)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SocietyConfig() when $default != null:
        return $default(
            _that.societyName,
            _that.logoUrl,
            _that.primaryColor,
            _that.secondaryColor,
            _that.dangerousColor,
            _that.backgroundColor,
            _that.statusPublishedColor,
            _that.statusConfirmedColor,
            _that.statusReservedColor,
            _that.statusWaitlistColor,
            _that.statusWithdrawnColor,
            _that.statusDinnerColor,
            _that.cardRadius,
            _that.inputRadius,
            _that.useShadows,
            _that.shadowIntensity,
            _that.useBorders,
            _that.borderWidth,
            _that.pillRadius,
            _that.buttonRadius,
            _that.heroRadius,
            _that.accentRadius,
            _that.accentOpacity,
            _that.shadowSpread,
            _that.shadowOpacity,
            _that.labelToCardSpacing,
            _that.cardToLabelSpacing,
            _that.cardToCardSpacing,
            _that.cardVerticalPadding,
            _that.cardHorizontalPadding,
            _that.iconBadgeFillColor,
            _that.iconBadgeIconColor,
            _that.iconBadgeOpacity,
            _that.iconOpacity,
            _that.iconBadgeSize,
            _that.iconBadgeIconSize,
            _that.themeMode,
            _that.customColors,
            _that.cardTintIntensity,
            _that.useCardGradient,
            _that.currencySymbol,
            _that.currencyCode,
            _that.groupingStrategy,
            _that.useWhsHandicaps,
            _that.distanceUnit,
            _that.handicapSystem,
            _that.selectedPaletteName,
            _that.separateGuestLeaderboard,
            _that.societyCutMode,
            _that.societyCutRules,
            _that.societyCutEventLimit,
            _that.societyCutCountPlayedOnly,
            _that.societyCutFilterSeason,
            _that.societyCutFilterInvitational,
            _that.globalMarkupPercentage,
            _that.guestMarkupExtra,
            _that.globalMembershipEndDate,
            _that.renewalWindowDays,
            _that.isRenewalActive,
            _that.renewalLaunchDate,
            _that.renewalDeadline,
            _that.renewalPaymentDeadline,
            _that.startingBalance,
            _that.ledgerEntries,
            _that.sponsors);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String societyName,
            String? logoUrl,
            int primaryColor,
            int secondaryColor,
            int dangerousColor,
            int backgroundColor,
            int statusPublishedColor,
            int statusConfirmedColor,
            int statusReservedColor,
            int statusWaitlistColor,
            int statusWithdrawnColor,
            int statusDinnerColor,
            double cardRadius,
            double inputRadius,
            bool useShadows,
            double shadowIntensity,
            bool useBorders,
            double borderWidth,
            double pillRadius,
            double buttonRadius,
            double heroRadius,
            double accentRadius,
            double accentOpacity,
            double shadowSpread,
            double shadowOpacity,
            double labelToCardSpacing,
            double cardToLabelSpacing,
            double cardToCardSpacing,
            double cardVerticalPadding,
            double cardHorizontalPadding,
            int iconBadgeFillColor,
            int iconBadgeIconColor,
            double iconBadgeOpacity,
            double iconOpacity,
            double iconBadgeSize,
            double iconBadgeIconSize,
            String themeMode,
            List<int> customColors,
            double cardTintIntensity,
            bool useCardGradient,
            String currencySymbol,
            String currencyCode,
            String groupingStrategy,
            bool useWhsHandicaps,
            String distanceUnit,
            HandicapSystem handicapSystem,
            String? selectedPaletteName,
            bool separateGuestLeaderboard,
            SocietyCutMode societyCutMode,
            Map<String, double> societyCutRules,
            int societyCutEventLimit,
            bool societyCutCountPlayedOnly,
            bool societyCutFilterSeason,
            bool societyCutFilterInvitational,
            double globalMarkupPercentage,
            double guestMarkupExtra,
            @OptionalTimestampConverter() DateTime? globalMembershipEndDate,
            int renewalWindowDays,
            bool isRenewalActive,
            @OptionalTimestampConverter() DateTime? renewalLaunchDate,
            @OptionalTimestampConverter() DateTime? renewalDeadline,
            @OptionalTimestampConverter() DateTime? renewalPaymentDeadline,
            double startingBalance,
            List<FinancialEntry> ledgerEntries,
            List<Sponsor> sponsors)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SocietyConfig():
        return $default(
            _that.societyName,
            _that.logoUrl,
            _that.primaryColor,
            _that.secondaryColor,
            _that.dangerousColor,
            _that.backgroundColor,
            _that.statusPublishedColor,
            _that.statusConfirmedColor,
            _that.statusReservedColor,
            _that.statusWaitlistColor,
            _that.statusWithdrawnColor,
            _that.statusDinnerColor,
            _that.cardRadius,
            _that.inputRadius,
            _that.useShadows,
            _that.shadowIntensity,
            _that.useBorders,
            _that.borderWidth,
            _that.pillRadius,
            _that.buttonRadius,
            _that.heroRadius,
            _that.accentRadius,
            _that.accentOpacity,
            _that.shadowSpread,
            _that.shadowOpacity,
            _that.labelToCardSpacing,
            _that.cardToLabelSpacing,
            _that.cardToCardSpacing,
            _that.cardVerticalPadding,
            _that.cardHorizontalPadding,
            _that.iconBadgeFillColor,
            _that.iconBadgeIconColor,
            _that.iconBadgeOpacity,
            _that.iconOpacity,
            _that.iconBadgeSize,
            _that.iconBadgeIconSize,
            _that.themeMode,
            _that.customColors,
            _that.cardTintIntensity,
            _that.useCardGradient,
            _that.currencySymbol,
            _that.currencyCode,
            _that.groupingStrategy,
            _that.useWhsHandicaps,
            _that.distanceUnit,
            _that.handicapSystem,
            _that.selectedPaletteName,
            _that.separateGuestLeaderboard,
            _that.societyCutMode,
            _that.societyCutRules,
            _that.societyCutEventLimit,
            _that.societyCutCountPlayedOnly,
            _that.societyCutFilterSeason,
            _that.societyCutFilterInvitational,
            _that.globalMarkupPercentage,
            _that.guestMarkupExtra,
            _that.globalMembershipEndDate,
            _that.renewalWindowDays,
            _that.isRenewalActive,
            _that.renewalLaunchDate,
            _that.renewalDeadline,
            _that.renewalPaymentDeadline,
            _that.startingBalance,
            _that.ledgerEntries,
            _that.sponsors);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String societyName,
            String? logoUrl,
            int primaryColor,
            int secondaryColor,
            int dangerousColor,
            int backgroundColor,
            int statusPublishedColor,
            int statusConfirmedColor,
            int statusReservedColor,
            int statusWaitlistColor,
            int statusWithdrawnColor,
            int statusDinnerColor,
            double cardRadius,
            double inputRadius,
            bool useShadows,
            double shadowIntensity,
            bool useBorders,
            double borderWidth,
            double pillRadius,
            double buttonRadius,
            double heroRadius,
            double accentRadius,
            double accentOpacity,
            double shadowSpread,
            double shadowOpacity,
            double labelToCardSpacing,
            double cardToLabelSpacing,
            double cardToCardSpacing,
            double cardVerticalPadding,
            double cardHorizontalPadding,
            int iconBadgeFillColor,
            int iconBadgeIconColor,
            double iconBadgeOpacity,
            double iconOpacity,
            double iconBadgeSize,
            double iconBadgeIconSize,
            String themeMode,
            List<int> customColors,
            double cardTintIntensity,
            bool useCardGradient,
            String currencySymbol,
            String currencyCode,
            String groupingStrategy,
            bool useWhsHandicaps,
            String distanceUnit,
            HandicapSystem handicapSystem,
            String? selectedPaletteName,
            bool separateGuestLeaderboard,
            SocietyCutMode societyCutMode,
            Map<String, double> societyCutRules,
            int societyCutEventLimit,
            bool societyCutCountPlayedOnly,
            bool societyCutFilterSeason,
            bool societyCutFilterInvitational,
            double globalMarkupPercentage,
            double guestMarkupExtra,
            @OptionalTimestampConverter() DateTime? globalMembershipEndDate,
            int renewalWindowDays,
            bool isRenewalActive,
            @OptionalTimestampConverter() DateTime? renewalLaunchDate,
            @OptionalTimestampConverter() DateTime? renewalDeadline,
            @OptionalTimestampConverter() DateTime? renewalPaymentDeadline,
            double startingBalance,
            List<FinancialEntry> ledgerEntries,
            List<Sponsor> sponsors)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SocietyConfig() when $default != null:
        return $default(
            _that.societyName,
            _that.logoUrl,
            _that.primaryColor,
            _that.secondaryColor,
            _that.dangerousColor,
            _that.backgroundColor,
            _that.statusPublishedColor,
            _that.statusConfirmedColor,
            _that.statusReservedColor,
            _that.statusWaitlistColor,
            _that.statusWithdrawnColor,
            _that.statusDinnerColor,
            _that.cardRadius,
            _that.inputRadius,
            _that.useShadows,
            _that.shadowIntensity,
            _that.useBorders,
            _that.borderWidth,
            _that.pillRadius,
            _that.buttonRadius,
            _that.heroRadius,
            _that.accentRadius,
            _that.accentOpacity,
            _that.shadowSpread,
            _that.shadowOpacity,
            _that.labelToCardSpacing,
            _that.cardToLabelSpacing,
            _that.cardToCardSpacing,
            _that.cardVerticalPadding,
            _that.cardHorizontalPadding,
            _that.iconBadgeFillColor,
            _that.iconBadgeIconColor,
            _that.iconBadgeOpacity,
            _that.iconOpacity,
            _that.iconBadgeSize,
            _that.iconBadgeIconSize,
            _that.themeMode,
            _that.customColors,
            _that.cardTintIntensity,
            _that.useCardGradient,
            _that.currencySymbol,
            _that.currencyCode,
            _that.groupingStrategy,
            _that.useWhsHandicaps,
            _that.distanceUnit,
            _that.handicapSystem,
            _that.selectedPaletteName,
            _that.separateGuestLeaderboard,
            _that.societyCutMode,
            _that.societyCutRules,
            _that.societyCutEventLimit,
            _that.societyCutCountPlayedOnly,
            _that.societyCutFilterSeason,
            _that.societyCutFilterInvitational,
            _that.globalMarkupPercentage,
            _that.guestMarkupExtra,
            _that.globalMembershipEndDate,
            _that.renewalWindowDays,
            _that.isRenewalActive,
            _that.renewalLaunchDate,
            _that.renewalDeadline,
            _that.renewalPaymentDeadline,
            _that.startingBalance,
            _that.ledgerEntries,
            _that.sponsors);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SocietyConfig implements SocietyConfig {
  const _SocietyConfig(
      {this.societyName = 'Golf Society',
      this.logoUrl,
      this.primaryColor = 0xFFF7D354,
      this.secondaryColor = 0xFF4ADE80,
      this.dangerousColor = 0xFFFF5533,
      this.backgroundColor = 0xFFEFEFED,
      this.statusPublishedColor = 0xFF4ADE80,
      this.statusConfirmedColor = 0xFF4ADE80,
      this.statusReservedColor = 0xFFFFAA00,
      this.statusWaitlistColor = 0xFFFF5533,
      this.statusWithdrawnColor = 0xFF6B7280,
      this.statusDinnerColor = 0xFF673AB7,
      this.cardRadius = 18.0,
      this.inputRadius = 12.0,
      this.useShadows = true,
      this.shadowIntensity = 1.0,
      this.useBorders = true,
      this.borderWidth = 1.5,
      this.pillRadius = 30.0,
      this.buttonRadius = 16.0,
      this.heroRadius = 28.0,
      this.accentRadius = 8.0,
      this.accentOpacity = 0.15,
      this.shadowSpread = 0.0,
      this.shadowOpacity = 0.12,
      this.labelToCardSpacing = 8.0,
      this.cardToLabelSpacing = 16.0,
      this.cardToCardSpacing = 16.0,
      this.cardVerticalPadding = 16.0,
      this.cardHorizontalPadding = 16.0,
      this.iconBadgeFillColor = 0x264ADE80,
      this.iconBadgeIconColor = 0xFF4ADE80,
      this.iconBadgeOpacity = 1.0,
      this.iconOpacity = 1.0,
      this.iconBadgeSize = 38.0,
      this.iconBadgeIconSize = 18.0,
      this.themeMode = 'system',
      final List<int> customColors = const <int>[],
      this.cardTintIntensity = 0.1,
      this.useCardGradient = false,
      this.currencySymbol = '£',
      this.currencyCode = 'GBP',
      this.groupingStrategy = 'balanced',
      this.useWhsHandicaps = true,
      this.distanceUnit = 'yards',
      this.handicapSystem = HandicapSystem.igolf,
      this.selectedPaletteName,
      this.separateGuestLeaderboard = true,
      this.societyCutMode = SocietyCutMode.off,
      final Map<String, double> societyCutRules = const {
        '1st': 2.0,
        '2nd': 1.0,
        '3rd': 0.5
      },
      this.societyCutEventLimit = 0,
      this.societyCutCountPlayedOnly = true,
      this.societyCutFilterSeason = true,
      this.societyCutFilterInvitational = false,
      this.globalMarkupPercentage = 0.10,
      this.guestMarkupExtra = 10.0,
      @OptionalTimestampConverter() this.globalMembershipEndDate,
      this.renewalWindowDays = 30,
      this.isRenewalActive = false,
      @OptionalTimestampConverter() this.renewalLaunchDate,
      @OptionalTimestampConverter() this.renewalDeadline,
      @OptionalTimestampConverter() this.renewalPaymentDeadline,
      this.startingBalance = 0.0,
      final List<FinancialEntry> ledgerEntries = const <FinancialEntry>[],
      final List<Sponsor> sponsors = const <Sponsor>[]})
      : _customColors = customColors,
        _societyCutRules = societyCutRules,
        _ledgerEntries = ledgerEntries,
        _sponsors = sponsors;
  factory _SocietyConfig.fromJson(Map<String, dynamic> json) =>
      _$SocietyConfigFromJson(json);

  @override
  @JsonKey()
  final String societyName;
  @override
  final String? logoUrl;
  @override
  @JsonKey()
  final int primaryColor;
// Default: BoxyArt Yellow
  @override
  @JsonKey()
  final int secondaryColor;
// Default: Emerald Green (Action)
  @override
  @JsonKey()
  final int dangerousColor;
// [NEW] High Alert / Dangerous Action color (Coral)
  @override
  @JsonKey()
  final int backgroundColor;
// Default: Light Gray/Neutral
  @override
  @JsonKey()
  final int statusPublishedColor;
// [NEW] Pill Subset (Emerald Green - Lifecycle)
  @override
  @JsonKey()
  final int statusConfirmedColor;
// [NEW] Pill Subset (Emerald Green - Registration)
  @override
  @JsonKey()
  final int statusReservedColor;
// [NEW] Pill Subset (Brand Amber)
  @override
  @JsonKey()
  final int statusWaitlistColor;
// [NEW] Pill Subset (Brand Coral)
  @override
  @JsonKey()
  final int statusWithdrawnColor;
// [NEW] Pill Subset (Neutral/Slate)
  @override
  @JsonKey()
  final int statusDinnerColor;
// [NEW] Pill Subset (Purple)
  @override
  @JsonKey()
  final double cardRadius;
// [NEW] Granular Card Radius
  @override
  @JsonKey()
  final double inputRadius;
// [NEW] Granular Input Radius
  @override
  @JsonKey()
  final bool useShadows;
// [NEW] Toggle Shadows
  @override
  @JsonKey()
  final double shadowIntensity;
// [NEW] Granular Shadow Intensity (0.0 to 2.0)
  @override
  @JsonKey()
  final bool useBorders;
// [NEW] Toggle Borders
  @override
  @JsonKey()
  final double borderWidth;
// [NEW] Granular Border Width
  @override
  @JsonKey()
  final double pillRadius;
// [NEW] Granular Pill Radius
  @override
  @JsonKey()
  final double buttonRadius;
// [NEW] Granular Button Radius (4.x Default)
  @override
  @JsonKey()
  final double heroRadius;
// [NEW] Granular Hero Radius (Independent)
  @override
  @JsonKey()
  final double accentRadius;
// [NEW] Metric & Icon Radius (4.x Default)
  @override
  @JsonKey()
  final double accentOpacity;
// [NEW] Metric & Icon Background Opacity
  @override
  @JsonKey()
  final double shadowSpread;
// [NEW] Granular Shadow Spread
  @override
  @JsonKey()
  final double shadowOpacity;
// [NEW] Granular Shadow Opacity
  @override
  @JsonKey()
  final double labelToCardSpacing;
// [NEW] Vertical rhythm: Label to Card
  @override
  @JsonKey()
  final double cardToLabelSpacing;
// [NEW] Vertical rhythm: Card to Label
  @override
  @JsonKey()
  final double cardToCardSpacing;
// [NEW] Vertical rhythm: Card to Card (List Density)
  @override
  @JsonKey()
  final double cardVerticalPadding;
// [NEW] Global Card Internal Padding
  @override
  @JsonKey()
  final double cardHorizontalPadding;
// [NEW] Global Card Internal Padding
  @override
  @JsonKey()
  final int iconBadgeFillColor;
// [NEW] Icon Badge BG (15% Emerald)
  @override
  @JsonKey()
  final int iconBadgeIconColor;
// [NEW] Icon Badge Glyph (Emerald)
  @override
  @JsonKey()
  final double iconBadgeOpacity;
// [NEW] Icon Badge background opacity
  @override
  @JsonKey()
  final double iconOpacity;
// [NEW] Icon Glyph opacity
  @override
  @JsonKey()
  final double iconBadgeSize;
// [NEW] Tokenized Badge Size
  @override
  @JsonKey()
  final double iconBadgeIconSize;
// [NEW] Tokenized Badge Glyph Size
  @override
  @JsonKey()
  final String themeMode;
// 'system', 'light', 'dark'
  final List<int> _customColors;
// 'system', 'light', 'dark'
  @override
  @JsonKey()
  List<int> get customColors {
    if (_customColors is EqualUnmodifiableListView) return _customColors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customColors);
  }

// User-created custom colors (up to 5)
  @override
  @JsonKey()
  final double cardTintIntensity;
// Card background tint intensity (0.0 to 1.0)
  @override
  @JsonKey()
  final bool useCardGradient;
  @override
  @JsonKey()
  final String currencySymbol;
// Default currency symbol
  @override
  @JsonKey()
  final String currencyCode;
// Default currency code
  @override
  @JsonKey()
  final String groupingStrategy;
// 'balanced', 'progressive', 'similar', 'random'
  @override
  @JsonKey()
  final bool useWhsHandicaps;
// Default: Use WHS (Slope/Rating)
  @override
  @JsonKey()
  final String distanceUnit;
// 'yards' or 'meters'
  @override
  @JsonKey()
  final HandicapSystem handicapSystem;
// Global provider
  @override
  final String? selectedPaletteName;
  @override
  @JsonKey()
  final bool separateGuestLeaderboard;
// Single toggle: ON = Separate, OFF = Hidden
  @override
  @JsonKey()
  final SocietyCutMode societyCutMode;
  final Map<String, double> _societyCutRules;
  @override
  @JsonKey()
  Map<String, double> get societyCutRules {
    if (_societyCutRules is EqualUnmodifiableMapView) return _societyCutRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_societyCutRules);
  }

  @override
  @JsonKey()
  final int societyCutEventLimit;
// [NEW] 0 = Rest of Season
  @override
  @JsonKey()
  final bool societyCutCountPlayedOnly;
// [NEW] Toggle: Count all events vs Played only
  @override
  @JsonKey()
  final bool societyCutFilterSeason;
// [NEW] Cut triggers for Season events
  @override
  @JsonKey()
  final bool societyCutFilterInvitational;
// [NEW] Cut triggers for Invitationals
  @override
  @JsonKey()
  final double globalMarkupPercentage;
// Default: 10%
  @override
  @JsonKey()
  final double guestMarkupExtra;
// Default: £10 extra for guests
  @override
  @OptionalTimestampConverter()
  final DateTime? globalMembershipEndDate;
// [NEW] Society-wide expiry date
  @override
  @JsonKey()
  final int renewalWindowDays;
// [NEW] Days before expiry to show home screen alert
  @override
  @JsonKey()
  final bool isRenewalActive;
// [NEW] Admin switch to enable the "Renew Now" button
  @override
  @OptionalTimestampConverter()
  final DateTime? renewalLaunchDate;
// [NEW] When the "Invoke" happened
  @override
  @OptionalTimestampConverter()
  final DateTime? renewalDeadline;
// [NEW] Hard cutoff for membership
  @override
  @OptionalTimestampConverter()
  final DateTime? renewalPaymentDeadline;
// [NEW] Adjustable payment limit
  @override
  @JsonKey()
  final double startingBalance;
// [NEW] Opening bank balance for the season
  final List<FinancialEntry> _ledgerEntries;
// [NEW] Opening bank balance for the season
  @override
  @JsonKey()
  List<FinancialEntry> get ledgerEntries {
    if (_ledgerEntries is EqualUnmodifiableListView) return _ledgerEntries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ledgerEntries);
  }

// [NEW] Society-level sponsorships & donations
  final List<Sponsor> _sponsors;
// [NEW] Society-level sponsorships & donations
  @override
  @JsonKey()
  List<Sponsor> get sponsors {
    if (_sponsors is EqualUnmodifiableListView) return _sponsors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sponsors);
  }

  /// Create a copy of SocietyConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SocietyConfigCopyWith<_SocietyConfig> get copyWith =>
      __$SocietyConfigCopyWithImpl<_SocietyConfig>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SocietyConfigToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SocietyConfig &&
            (identical(other.societyName, societyName) ||
                other.societyName == societyName) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.primaryColor, primaryColor) ||
                other.primaryColor == primaryColor) &&
            (identical(other.secondaryColor, secondaryColor) ||
                other.secondaryColor == secondaryColor) &&
            (identical(other.dangerousColor, dangerousColor) ||
                other.dangerousColor == dangerousColor) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.statusPublishedColor, statusPublishedColor) ||
                other.statusPublishedColor == statusPublishedColor) &&
            (identical(other.statusConfirmedColor, statusConfirmedColor) ||
                other.statusConfirmedColor == statusConfirmedColor) &&
            (identical(other.statusReservedColor, statusReservedColor) ||
                other.statusReservedColor == statusReservedColor) &&
            (identical(other.statusWaitlistColor, statusWaitlistColor) ||
                other.statusWaitlistColor == statusWaitlistColor) &&
            (identical(other.statusWithdrawnColor, statusWithdrawnColor) ||
                other.statusWithdrawnColor == statusWithdrawnColor) &&
            (identical(other.statusDinnerColor, statusDinnerColor) ||
                other.statusDinnerColor == statusDinnerColor) &&
            (identical(other.cardRadius, cardRadius) ||
                other.cardRadius == cardRadius) &&
            (identical(other.inputRadius, inputRadius) ||
                other.inputRadius == inputRadius) &&
            (identical(other.useShadows, useShadows) ||
                other.useShadows == useShadows) &&
            (identical(other.shadowIntensity, shadowIntensity) ||
                other.shadowIntensity == shadowIntensity) &&
            (identical(other.useBorders, useBorders) ||
                other.useBorders == useBorders) &&
            (identical(other.borderWidth, borderWidth) ||
                other.borderWidth == borderWidth) &&
            (identical(other.pillRadius, pillRadius) ||
                other.pillRadius == pillRadius) &&
            (identical(other.buttonRadius, buttonRadius) ||
                other.buttonRadius == buttonRadius) &&
            (identical(other.heroRadius, heroRadius) ||
                other.heroRadius == heroRadius) &&
            (identical(other.accentRadius, accentRadius) ||
                other.accentRadius == accentRadius) &&
            (identical(other.accentOpacity, accentOpacity) ||
                other.accentOpacity == accentOpacity) &&
            (identical(other.shadowSpread, shadowSpread) ||
                other.shadowSpread == shadowSpread) &&
            (identical(other.shadowOpacity, shadowOpacity) ||
                other.shadowOpacity == shadowOpacity) &&
            (identical(other.labelToCardSpacing, labelToCardSpacing) ||
                other.labelToCardSpacing == labelToCardSpacing) &&
            (identical(other.cardToLabelSpacing, cardToLabelSpacing) ||
                other.cardToLabelSpacing == cardToLabelSpacing) &&
            (identical(other.cardToCardSpacing, cardToCardSpacing) ||
                other.cardToCardSpacing == cardToCardSpacing) &&
            (identical(other.cardVerticalPadding, cardVerticalPadding) ||
                other.cardVerticalPadding == cardVerticalPadding) &&
            (identical(other.cardHorizontalPadding, cardHorizontalPadding) ||
                other.cardHorizontalPadding == cardHorizontalPadding) &&
            (identical(other.iconBadgeFillColor, iconBadgeFillColor) ||
                other.iconBadgeFillColor == iconBadgeFillColor) &&
            (identical(other.iconBadgeIconColor, iconBadgeIconColor) ||
                other.iconBadgeIconColor == iconBadgeIconColor) &&
            (identical(other.iconBadgeOpacity, iconBadgeOpacity) ||
                other.iconBadgeOpacity == iconBadgeOpacity) &&
            (identical(other.iconOpacity, iconOpacity) ||
                other.iconOpacity == iconOpacity) &&
            (identical(other.iconBadgeSize, iconBadgeSize) ||
                other.iconBadgeSize == iconBadgeSize) &&
            (identical(other.iconBadgeIconSize, iconBadgeIconSize) ||
                other.iconBadgeIconSize == iconBadgeIconSize) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            const DeepCollectionEquality()
                .equals(other._customColors, _customColors) &&
            (identical(other.cardTintIntensity, cardTintIntensity) ||
                other.cardTintIntensity == cardTintIntensity) &&
            (identical(other.useCardGradient, useCardGradient) ||
                other.useCardGradient == useCardGradient) &&
            (identical(other.currencySymbol, currencySymbol) ||
                other.currencySymbol == currencySymbol) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.groupingStrategy, groupingStrategy) ||
                other.groupingStrategy == groupingStrategy) &&
            (identical(other.useWhsHandicaps, useWhsHandicaps) ||
                other.useWhsHandicaps == useWhsHandicaps) &&
            (identical(other.distanceUnit, distanceUnit) || other.distanceUnit == distanceUnit) &&
            (identical(other.handicapSystem, handicapSystem) || other.handicapSystem == handicapSystem) &&
            (identical(other.selectedPaletteName, selectedPaletteName) || other.selectedPaletteName == selectedPaletteName) &&
            (identical(other.separateGuestLeaderboard, separateGuestLeaderboard) || other.separateGuestLeaderboard == separateGuestLeaderboard) &&
            (identical(other.societyCutMode, societyCutMode) || other.societyCutMode == societyCutMode) &&
            const DeepCollectionEquality().equals(other._societyCutRules, _societyCutRules) &&
            (identical(other.societyCutEventLimit, societyCutEventLimit) || other.societyCutEventLimit == societyCutEventLimit) &&
            (identical(other.societyCutCountPlayedOnly, societyCutCountPlayedOnly) || other.societyCutCountPlayedOnly == societyCutCountPlayedOnly) &&
            (identical(other.societyCutFilterSeason, societyCutFilterSeason) || other.societyCutFilterSeason == societyCutFilterSeason) &&
            (identical(other.societyCutFilterInvitational, societyCutFilterInvitational) || other.societyCutFilterInvitational == societyCutFilterInvitational) &&
            (identical(other.globalMarkupPercentage, globalMarkupPercentage) || other.globalMarkupPercentage == globalMarkupPercentage) &&
            (identical(other.guestMarkupExtra, guestMarkupExtra) || other.guestMarkupExtra == guestMarkupExtra) &&
            (identical(other.globalMembershipEndDate, globalMembershipEndDate) || other.globalMembershipEndDate == globalMembershipEndDate) &&
            (identical(other.renewalWindowDays, renewalWindowDays) || other.renewalWindowDays == renewalWindowDays) &&
            (identical(other.isRenewalActive, isRenewalActive) || other.isRenewalActive == isRenewalActive) &&
            (identical(other.renewalLaunchDate, renewalLaunchDate) || other.renewalLaunchDate == renewalLaunchDate) &&
            (identical(other.renewalDeadline, renewalDeadline) || other.renewalDeadline == renewalDeadline) &&
            (identical(other.renewalPaymentDeadline, renewalPaymentDeadline) || other.renewalPaymentDeadline == renewalPaymentDeadline) &&
            (identical(other.startingBalance, startingBalance) || other.startingBalance == startingBalance) &&
            const DeepCollectionEquality().equals(other._ledgerEntries, _ledgerEntries) &&
            const DeepCollectionEquality().equals(other._sponsors, _sponsors));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        societyName,
        logoUrl,
        primaryColor,
        secondaryColor,
        dangerousColor,
        backgroundColor,
        statusPublishedColor,
        statusConfirmedColor,
        statusReservedColor,
        statusWaitlistColor,
        statusWithdrawnColor,
        statusDinnerColor,
        cardRadius,
        inputRadius,
        useShadows,
        shadowIntensity,
        useBorders,
        borderWidth,
        pillRadius,
        buttonRadius,
        heroRadius,
        accentRadius,
        accentOpacity,
        shadowSpread,
        shadowOpacity,
        labelToCardSpacing,
        cardToLabelSpacing,
        cardToCardSpacing,
        cardVerticalPadding,
        cardHorizontalPadding,
        iconBadgeFillColor,
        iconBadgeIconColor,
        iconBadgeOpacity,
        iconOpacity,
        iconBadgeSize,
        iconBadgeIconSize,
        themeMode,
        const DeepCollectionEquality().hash(_customColors),
        cardTintIntensity,
        useCardGradient,
        currencySymbol,
        currencyCode,
        groupingStrategy,
        useWhsHandicaps,
        distanceUnit,
        handicapSystem,
        selectedPaletteName,
        separateGuestLeaderboard,
        societyCutMode,
        const DeepCollectionEquality().hash(_societyCutRules),
        societyCutEventLimit,
        societyCutCountPlayedOnly,
        societyCutFilterSeason,
        societyCutFilterInvitational,
        globalMarkupPercentage,
        guestMarkupExtra,
        globalMembershipEndDate,
        renewalWindowDays,
        isRenewalActive,
        renewalLaunchDate,
        renewalDeadline,
        renewalPaymentDeadline,
        startingBalance,
        const DeepCollectionEquality().hash(_ledgerEntries),
        const DeepCollectionEquality().hash(_sponsors)
      ]);

  @override
  String toString() {
    return 'SocietyConfig(societyName: $societyName, logoUrl: $logoUrl, primaryColor: $primaryColor, secondaryColor: $secondaryColor, dangerousColor: $dangerousColor, backgroundColor: $backgroundColor, statusPublishedColor: $statusPublishedColor, statusConfirmedColor: $statusConfirmedColor, statusReservedColor: $statusReservedColor, statusWaitlistColor: $statusWaitlistColor, statusWithdrawnColor: $statusWithdrawnColor, statusDinnerColor: $statusDinnerColor, cardRadius: $cardRadius, inputRadius: $inputRadius, useShadows: $useShadows, shadowIntensity: $shadowIntensity, useBorders: $useBorders, borderWidth: $borderWidth, pillRadius: $pillRadius, buttonRadius: $buttonRadius, heroRadius: $heroRadius, accentRadius: $accentRadius, accentOpacity: $accentOpacity, shadowSpread: $shadowSpread, shadowOpacity: $shadowOpacity, labelToCardSpacing: $labelToCardSpacing, cardToLabelSpacing: $cardToLabelSpacing, cardToCardSpacing: $cardToCardSpacing, cardVerticalPadding: $cardVerticalPadding, cardHorizontalPadding: $cardHorizontalPadding, iconBadgeFillColor: $iconBadgeFillColor, iconBadgeIconColor: $iconBadgeIconColor, iconBadgeOpacity: $iconBadgeOpacity, iconOpacity: $iconOpacity, iconBadgeSize: $iconBadgeSize, iconBadgeIconSize: $iconBadgeIconSize, themeMode: $themeMode, customColors: $customColors, cardTintIntensity: $cardTintIntensity, useCardGradient: $useCardGradient, currencySymbol: $currencySymbol, currencyCode: $currencyCode, groupingStrategy: $groupingStrategy, useWhsHandicaps: $useWhsHandicaps, distanceUnit: $distanceUnit, handicapSystem: $handicapSystem, selectedPaletteName: $selectedPaletteName, separateGuestLeaderboard: $separateGuestLeaderboard, societyCutMode: $societyCutMode, societyCutRules: $societyCutRules, societyCutEventLimit: $societyCutEventLimit, societyCutCountPlayedOnly: $societyCutCountPlayedOnly, societyCutFilterSeason: $societyCutFilterSeason, societyCutFilterInvitational: $societyCutFilterInvitational, globalMarkupPercentage: $globalMarkupPercentage, guestMarkupExtra: $guestMarkupExtra, globalMembershipEndDate: $globalMembershipEndDate, renewalWindowDays: $renewalWindowDays, isRenewalActive: $isRenewalActive, renewalLaunchDate: $renewalLaunchDate, renewalDeadline: $renewalDeadline, renewalPaymentDeadline: $renewalPaymentDeadline, startingBalance: $startingBalance, ledgerEntries: $ledgerEntries, sponsors: $sponsors)';
  }
}

/// @nodoc
abstract mixin class _$SocietyConfigCopyWith<$Res>
    implements $SocietyConfigCopyWith<$Res> {
  factory _$SocietyConfigCopyWith(
          _SocietyConfig value, $Res Function(_SocietyConfig) _then) =
      __$SocietyConfigCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String societyName,
      String? logoUrl,
      int primaryColor,
      int secondaryColor,
      int dangerousColor,
      int backgroundColor,
      int statusPublishedColor,
      int statusConfirmedColor,
      int statusReservedColor,
      int statusWaitlistColor,
      int statusWithdrawnColor,
      int statusDinnerColor,
      double cardRadius,
      double inputRadius,
      bool useShadows,
      double shadowIntensity,
      bool useBorders,
      double borderWidth,
      double pillRadius,
      double buttonRadius,
      double heroRadius,
      double accentRadius,
      double accentOpacity,
      double shadowSpread,
      double shadowOpacity,
      double labelToCardSpacing,
      double cardToLabelSpacing,
      double cardToCardSpacing,
      double cardVerticalPadding,
      double cardHorizontalPadding,
      int iconBadgeFillColor,
      int iconBadgeIconColor,
      double iconBadgeOpacity,
      double iconOpacity,
      double iconBadgeSize,
      double iconBadgeIconSize,
      String themeMode,
      List<int> customColors,
      double cardTintIntensity,
      bool useCardGradient,
      String currencySymbol,
      String currencyCode,
      String groupingStrategy,
      bool useWhsHandicaps,
      String distanceUnit,
      HandicapSystem handicapSystem,
      String? selectedPaletteName,
      bool separateGuestLeaderboard,
      SocietyCutMode societyCutMode,
      Map<String, double> societyCutRules,
      int societyCutEventLimit,
      bool societyCutCountPlayedOnly,
      bool societyCutFilterSeason,
      bool societyCutFilterInvitational,
      double globalMarkupPercentage,
      double guestMarkupExtra,
      @OptionalTimestampConverter() DateTime? globalMembershipEndDate,
      int renewalWindowDays,
      bool isRenewalActive,
      @OptionalTimestampConverter() DateTime? renewalLaunchDate,
      @OptionalTimestampConverter() DateTime? renewalDeadline,
      @OptionalTimestampConverter() DateTime? renewalPaymentDeadline,
      double startingBalance,
      List<FinancialEntry> ledgerEntries,
      List<Sponsor> sponsors});
}

/// @nodoc
class __$SocietyConfigCopyWithImpl<$Res>
    implements _$SocietyConfigCopyWith<$Res> {
  __$SocietyConfigCopyWithImpl(this._self, this._then);

  final _SocietyConfig _self;
  final $Res Function(_SocietyConfig) _then;

  /// Create a copy of SocietyConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? societyName = null,
    Object? logoUrl = freezed,
    Object? primaryColor = null,
    Object? secondaryColor = null,
    Object? dangerousColor = null,
    Object? backgroundColor = null,
    Object? statusPublishedColor = null,
    Object? statusConfirmedColor = null,
    Object? statusReservedColor = null,
    Object? statusWaitlistColor = null,
    Object? statusWithdrawnColor = null,
    Object? statusDinnerColor = null,
    Object? cardRadius = null,
    Object? inputRadius = null,
    Object? useShadows = null,
    Object? shadowIntensity = null,
    Object? useBorders = null,
    Object? borderWidth = null,
    Object? pillRadius = null,
    Object? buttonRadius = null,
    Object? heroRadius = null,
    Object? accentRadius = null,
    Object? accentOpacity = null,
    Object? shadowSpread = null,
    Object? shadowOpacity = null,
    Object? labelToCardSpacing = null,
    Object? cardToLabelSpacing = null,
    Object? cardToCardSpacing = null,
    Object? cardVerticalPadding = null,
    Object? cardHorizontalPadding = null,
    Object? iconBadgeFillColor = null,
    Object? iconBadgeIconColor = null,
    Object? iconBadgeOpacity = null,
    Object? iconOpacity = null,
    Object? iconBadgeSize = null,
    Object? iconBadgeIconSize = null,
    Object? themeMode = null,
    Object? customColors = null,
    Object? cardTintIntensity = null,
    Object? useCardGradient = null,
    Object? currencySymbol = null,
    Object? currencyCode = null,
    Object? groupingStrategy = null,
    Object? useWhsHandicaps = null,
    Object? distanceUnit = null,
    Object? handicapSystem = null,
    Object? selectedPaletteName = freezed,
    Object? separateGuestLeaderboard = null,
    Object? societyCutMode = null,
    Object? societyCutRules = null,
    Object? societyCutEventLimit = null,
    Object? societyCutCountPlayedOnly = null,
    Object? societyCutFilterSeason = null,
    Object? societyCutFilterInvitational = null,
    Object? globalMarkupPercentage = null,
    Object? guestMarkupExtra = null,
    Object? globalMembershipEndDate = freezed,
    Object? renewalWindowDays = null,
    Object? isRenewalActive = null,
    Object? renewalLaunchDate = freezed,
    Object? renewalDeadline = freezed,
    Object? renewalPaymentDeadline = freezed,
    Object? startingBalance = null,
    Object? ledgerEntries = null,
    Object? sponsors = null,
  }) {
    return _then(_SocietyConfig(
      societyName: null == societyName
          ? _self.societyName
          : societyName // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _self.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryColor: null == primaryColor
          ? _self.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as int,
      secondaryColor: null == secondaryColor
          ? _self.secondaryColor
          : secondaryColor // ignore: cast_nullable_to_non_nullable
              as int,
      dangerousColor: null == dangerousColor
          ? _self.dangerousColor
          : dangerousColor // ignore: cast_nullable_to_non_nullable
              as int,
      backgroundColor: null == backgroundColor
          ? _self.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as int,
      statusPublishedColor: null == statusPublishedColor
          ? _self.statusPublishedColor
          : statusPublishedColor // ignore: cast_nullable_to_non_nullable
              as int,
      statusConfirmedColor: null == statusConfirmedColor
          ? _self.statusConfirmedColor
          : statusConfirmedColor // ignore: cast_nullable_to_non_nullable
              as int,
      statusReservedColor: null == statusReservedColor
          ? _self.statusReservedColor
          : statusReservedColor // ignore: cast_nullable_to_non_nullable
              as int,
      statusWaitlistColor: null == statusWaitlistColor
          ? _self.statusWaitlistColor
          : statusWaitlistColor // ignore: cast_nullable_to_non_nullable
              as int,
      statusWithdrawnColor: null == statusWithdrawnColor
          ? _self.statusWithdrawnColor
          : statusWithdrawnColor // ignore: cast_nullable_to_non_nullable
              as int,
      statusDinnerColor: null == statusDinnerColor
          ? _self.statusDinnerColor
          : statusDinnerColor // ignore: cast_nullable_to_non_nullable
              as int,
      cardRadius: null == cardRadius
          ? _self.cardRadius
          : cardRadius // ignore: cast_nullable_to_non_nullable
              as double,
      inputRadius: null == inputRadius
          ? _self.inputRadius
          : inputRadius // ignore: cast_nullable_to_non_nullable
              as double,
      useShadows: null == useShadows
          ? _self.useShadows
          : useShadows // ignore: cast_nullable_to_non_nullable
              as bool,
      shadowIntensity: null == shadowIntensity
          ? _self.shadowIntensity
          : shadowIntensity // ignore: cast_nullable_to_non_nullable
              as double,
      useBorders: null == useBorders
          ? _self.useBorders
          : useBorders // ignore: cast_nullable_to_non_nullable
              as bool,
      borderWidth: null == borderWidth
          ? _self.borderWidth
          : borderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      pillRadius: null == pillRadius
          ? _self.pillRadius
          : pillRadius // ignore: cast_nullable_to_non_nullable
              as double,
      buttonRadius: null == buttonRadius
          ? _self.buttonRadius
          : buttonRadius // ignore: cast_nullable_to_non_nullable
              as double,
      heroRadius: null == heroRadius
          ? _self.heroRadius
          : heroRadius // ignore: cast_nullable_to_non_nullable
              as double,
      accentRadius: null == accentRadius
          ? _self.accentRadius
          : accentRadius // ignore: cast_nullable_to_non_nullable
              as double,
      accentOpacity: null == accentOpacity
          ? _self.accentOpacity
          : accentOpacity // ignore: cast_nullable_to_non_nullable
              as double,
      shadowSpread: null == shadowSpread
          ? _self.shadowSpread
          : shadowSpread // ignore: cast_nullable_to_non_nullable
              as double,
      shadowOpacity: null == shadowOpacity
          ? _self.shadowOpacity
          : shadowOpacity // ignore: cast_nullable_to_non_nullable
              as double,
      labelToCardSpacing: null == labelToCardSpacing
          ? _self.labelToCardSpacing
          : labelToCardSpacing // ignore: cast_nullable_to_non_nullable
              as double,
      cardToLabelSpacing: null == cardToLabelSpacing
          ? _self.cardToLabelSpacing
          : cardToLabelSpacing // ignore: cast_nullable_to_non_nullable
              as double,
      cardToCardSpacing: null == cardToCardSpacing
          ? _self.cardToCardSpacing
          : cardToCardSpacing // ignore: cast_nullable_to_non_nullable
              as double,
      cardVerticalPadding: null == cardVerticalPadding
          ? _self.cardVerticalPadding
          : cardVerticalPadding // ignore: cast_nullable_to_non_nullable
              as double,
      cardHorizontalPadding: null == cardHorizontalPadding
          ? _self.cardHorizontalPadding
          : cardHorizontalPadding // ignore: cast_nullable_to_non_nullable
              as double,
      iconBadgeFillColor: null == iconBadgeFillColor
          ? _self.iconBadgeFillColor
          : iconBadgeFillColor // ignore: cast_nullable_to_non_nullable
              as int,
      iconBadgeIconColor: null == iconBadgeIconColor
          ? _self.iconBadgeIconColor
          : iconBadgeIconColor // ignore: cast_nullable_to_non_nullable
              as int,
      iconBadgeOpacity: null == iconBadgeOpacity
          ? _self.iconBadgeOpacity
          : iconBadgeOpacity // ignore: cast_nullable_to_non_nullable
              as double,
      iconOpacity: null == iconOpacity
          ? _self.iconOpacity
          : iconOpacity // ignore: cast_nullable_to_non_nullable
              as double,
      iconBadgeSize: null == iconBadgeSize
          ? _self.iconBadgeSize
          : iconBadgeSize // ignore: cast_nullable_to_non_nullable
              as double,
      iconBadgeIconSize: null == iconBadgeIconSize
          ? _self.iconBadgeIconSize
          : iconBadgeIconSize // ignore: cast_nullable_to_non_nullable
              as double,
      themeMode: null == themeMode
          ? _self.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as String,
      customColors: null == customColors
          ? _self._customColors
          : customColors // ignore: cast_nullable_to_non_nullable
              as List<int>,
      cardTintIntensity: null == cardTintIntensity
          ? _self.cardTintIntensity
          : cardTintIntensity // ignore: cast_nullable_to_non_nullable
              as double,
      useCardGradient: null == useCardGradient
          ? _self.useCardGradient
          : useCardGradient // ignore: cast_nullable_to_non_nullable
              as bool,
      currencySymbol: null == currencySymbol
          ? _self.currencySymbol
          : currencySymbol // ignore: cast_nullable_to_non_nullable
              as String,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      groupingStrategy: null == groupingStrategy
          ? _self.groupingStrategy
          : groupingStrategy // ignore: cast_nullable_to_non_nullable
              as String,
      useWhsHandicaps: null == useWhsHandicaps
          ? _self.useWhsHandicaps
          : useWhsHandicaps // ignore: cast_nullable_to_non_nullable
              as bool,
      distanceUnit: null == distanceUnit
          ? _self.distanceUnit
          : distanceUnit // ignore: cast_nullable_to_non_nullable
              as String,
      handicapSystem: null == handicapSystem
          ? _self.handicapSystem
          : handicapSystem // ignore: cast_nullable_to_non_nullable
              as HandicapSystem,
      selectedPaletteName: freezed == selectedPaletteName
          ? _self.selectedPaletteName
          : selectedPaletteName // ignore: cast_nullable_to_non_nullable
              as String?,
      separateGuestLeaderboard: null == separateGuestLeaderboard
          ? _self.separateGuestLeaderboard
          : separateGuestLeaderboard // ignore: cast_nullable_to_non_nullable
              as bool,
      societyCutMode: null == societyCutMode
          ? _self.societyCutMode
          : societyCutMode // ignore: cast_nullable_to_non_nullable
              as SocietyCutMode,
      societyCutRules: null == societyCutRules
          ? _self._societyCutRules
          : societyCutRules // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      societyCutEventLimit: null == societyCutEventLimit
          ? _self.societyCutEventLimit
          : societyCutEventLimit // ignore: cast_nullable_to_non_nullable
              as int,
      societyCutCountPlayedOnly: null == societyCutCountPlayedOnly
          ? _self.societyCutCountPlayedOnly
          : societyCutCountPlayedOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      societyCutFilterSeason: null == societyCutFilterSeason
          ? _self.societyCutFilterSeason
          : societyCutFilterSeason // ignore: cast_nullable_to_non_nullable
              as bool,
      societyCutFilterInvitational: null == societyCutFilterInvitational
          ? _self.societyCutFilterInvitational
          : societyCutFilterInvitational // ignore: cast_nullable_to_non_nullable
              as bool,
      globalMarkupPercentage: null == globalMarkupPercentage
          ? _self.globalMarkupPercentage
          : globalMarkupPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      guestMarkupExtra: null == guestMarkupExtra
          ? _self.guestMarkupExtra
          : guestMarkupExtra // ignore: cast_nullable_to_non_nullable
              as double,
      globalMembershipEndDate: freezed == globalMembershipEndDate
          ? _self.globalMembershipEndDate
          : globalMembershipEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      renewalWindowDays: null == renewalWindowDays
          ? _self.renewalWindowDays
          : renewalWindowDays // ignore: cast_nullable_to_non_nullable
              as int,
      isRenewalActive: null == isRenewalActive
          ? _self.isRenewalActive
          : isRenewalActive // ignore: cast_nullable_to_non_nullable
              as bool,
      renewalLaunchDate: freezed == renewalLaunchDate
          ? _self.renewalLaunchDate
          : renewalLaunchDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      renewalDeadline: freezed == renewalDeadline
          ? _self.renewalDeadline
          : renewalDeadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      renewalPaymentDeadline: freezed == renewalPaymentDeadline
          ? _self.renewalPaymentDeadline
          : renewalPaymentDeadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startingBalance: null == startingBalance
          ? _self.startingBalance
          : startingBalance // ignore: cast_nullable_to_non_nullable
              as double,
      ledgerEntries: null == ledgerEntries
          ? _self._ledgerEntries
          : ledgerEntries // ignore: cast_nullable_to_non_nullable
              as List<FinancialEntry>,
      sponsors: null == sponsors
          ? _self._sponsors
          : sponsors // ignore: cast_nullable_to_non_nullable
              as List<Sponsor>,
    ));
  }
}

/// @nodoc
mixin _$FinancialEntry {
  String get id;
  String get type; // 'Sponsorship', 'Donation', 'Other'
  String get source;
  String? get description; // [NEW] Optional detail for display
  String? get logoUrl; // [NEW] Optional logo image URL
  String? get scope; // [NEW] 'season' or 'event'
  String? get eventId; // [NEW] Targeted event if scope is 'event'
  String? get sponsorId; // [NEW] Link to a central Sponsor if applicable
  double get amount;
  @TimestampConverter()
  DateTime get date;
  bool get isPaid;

  /// Create a copy of FinancialEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FinancialEntryCopyWith<FinancialEntry> get copyWith =>
      _$FinancialEntryCopyWithImpl<FinancialEntry>(
          this as FinancialEntry, _$identity);

  /// Serializes this FinancialEntry to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FinancialEntry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.scope, scope) || other.scope == scope) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.sponsorId, sponsorId) ||
                other.sponsorId == sponsorId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.isPaid, isPaid) || other.isPaid == isPaid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, source, description,
      logoUrl, scope, eventId, sponsorId, amount, date, isPaid);

  @override
  String toString() {
    return 'FinancialEntry(id: $id, type: $type, source: $source, description: $description, logoUrl: $logoUrl, scope: $scope, eventId: $eventId, sponsorId: $sponsorId, amount: $amount, date: $date, isPaid: $isPaid)';
  }
}

/// @nodoc
abstract mixin class $FinancialEntryCopyWith<$Res> {
  factory $FinancialEntryCopyWith(
          FinancialEntry value, $Res Function(FinancialEntry) _then) =
      _$FinancialEntryCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String type,
      String source,
      String? description,
      String? logoUrl,
      String? scope,
      String? eventId,
      String? sponsorId,
      double amount,
      @TimestampConverter() DateTime date,
      bool isPaid});
}

/// @nodoc
class _$FinancialEntryCopyWithImpl<$Res>
    implements $FinancialEntryCopyWith<$Res> {
  _$FinancialEntryCopyWithImpl(this._self, this._then);

  final FinancialEntry _self;
  final $Res Function(FinancialEntry) _then;

  /// Create a copy of FinancialEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? source = null,
    Object? description = freezed,
    Object? logoUrl = freezed,
    Object? scope = freezed,
    Object? eventId = freezed,
    Object? sponsorId = freezed,
    Object? amount = null,
    Object? date = null,
    Object? isPaid = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _self.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      scope: freezed == scope
          ? _self.scope
          : scope // ignore: cast_nullable_to_non_nullable
              as String?,
      eventId: freezed == eventId
          ? _self.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String?,
      sponsorId: freezed == sponsorId
          ? _self.sponsorId
          : sponsorId // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isPaid: null == isPaid
          ? _self.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [FinancialEntry].
extension FinancialEntryPatterns on FinancialEntry {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_FinancialEntry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FinancialEntry() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_FinancialEntry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FinancialEntry():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_FinancialEntry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FinancialEntry() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String type,
            String source,
            String? description,
            String? logoUrl,
            String? scope,
            String? eventId,
            String? sponsorId,
            double amount,
            @TimestampConverter() DateTime date,
            bool isPaid)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FinancialEntry() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.source,
            _that.description,
            _that.logoUrl,
            _that.scope,
            _that.eventId,
            _that.sponsorId,
            _that.amount,
            _that.date,
            _that.isPaid);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String type,
            String source,
            String? description,
            String? logoUrl,
            String? scope,
            String? eventId,
            String? sponsorId,
            double amount,
            @TimestampConverter() DateTime date,
            bool isPaid)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FinancialEntry():
        return $default(
            _that.id,
            _that.type,
            _that.source,
            _that.description,
            _that.logoUrl,
            _that.scope,
            _that.eventId,
            _that.sponsorId,
            _that.amount,
            _that.date,
            _that.isPaid);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String type,
            String source,
            String? description,
            String? logoUrl,
            String? scope,
            String? eventId,
            String? sponsorId,
            double amount,
            @TimestampConverter() DateTime date,
            bool isPaid)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FinancialEntry() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.source,
            _that.description,
            _that.logoUrl,
            _that.scope,
            _that.eventId,
            _that.sponsorId,
            _that.amount,
            _that.date,
            _that.isPaid);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _FinancialEntry implements FinancialEntry {
  const _FinancialEntry(
      {required this.id,
      this.type = 'Sponsorship',
      required this.source,
      this.description,
      this.logoUrl,
      this.scope,
      this.eventId,
      this.sponsorId,
      this.amount = 0.0,
      @TimestampConverter() required this.date,
      this.isPaid = true});
  factory _FinancialEntry.fromJson(Map<String, dynamic> json) =>
      _$FinancialEntryFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String type;
// 'Sponsorship', 'Donation', 'Other'
  @override
  final String source;
  @override
  final String? description;
// [NEW] Optional detail for display
  @override
  final String? logoUrl;
// [NEW] Optional logo image URL
  @override
  final String? scope;
// [NEW] 'season' or 'event'
  @override
  final String? eventId;
// [NEW] Targeted event if scope is 'event'
  @override
  final String? sponsorId;
// [NEW] Link to a central Sponsor if applicable
  @override
  @JsonKey()
  final double amount;
  @override
  @TimestampConverter()
  final DateTime date;
  @override
  @JsonKey()
  final bool isPaid;

  /// Create a copy of FinancialEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FinancialEntryCopyWith<_FinancialEntry> get copyWith =>
      __$FinancialEntryCopyWithImpl<_FinancialEntry>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$FinancialEntryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FinancialEntry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.scope, scope) || other.scope == scope) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.sponsorId, sponsorId) ||
                other.sponsorId == sponsorId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.isPaid, isPaid) || other.isPaid == isPaid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, source, description,
      logoUrl, scope, eventId, sponsorId, amount, date, isPaid);

  @override
  String toString() {
    return 'FinancialEntry(id: $id, type: $type, source: $source, description: $description, logoUrl: $logoUrl, scope: $scope, eventId: $eventId, sponsorId: $sponsorId, amount: $amount, date: $date, isPaid: $isPaid)';
  }
}

/// @nodoc
abstract mixin class _$FinancialEntryCopyWith<$Res>
    implements $FinancialEntryCopyWith<$Res> {
  factory _$FinancialEntryCopyWith(
          _FinancialEntry value, $Res Function(_FinancialEntry) _then) =
      __$FinancialEntryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String source,
      String? description,
      String? logoUrl,
      String? scope,
      String? eventId,
      String? sponsorId,
      double amount,
      @TimestampConverter() DateTime date,
      bool isPaid});
}

/// @nodoc
class __$FinancialEntryCopyWithImpl<$Res>
    implements _$FinancialEntryCopyWith<$Res> {
  __$FinancialEntryCopyWithImpl(this._self, this._then);

  final _FinancialEntry _self;
  final $Res Function(_FinancialEntry) _then;

  /// Create a copy of FinancialEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? source = null,
    Object? description = freezed,
    Object? logoUrl = freezed,
    Object? scope = freezed,
    Object? eventId = freezed,
    Object? sponsorId = freezed,
    Object? amount = null,
    Object? date = null,
    Object? isPaid = null,
  }) {
    return _then(_FinancialEntry(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _self.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      scope: freezed == scope
          ? _self.scope
          : scope // ignore: cast_nullable_to_non_nullable
              as String?,
      eventId: freezed == eventId
          ? _self.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String?,
      sponsorId: freezed == sponsorId
          ? _self.sponsorId
          : sponsorId // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isPaid: null == isPaid
          ? _self.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$Sponsor {
  String get id;
  String get name;
  String? get logoUrl;
  String? get websiteUrl;
  String? get description;
  SponsorTier get tier;
  bool get isActive;

  /// Create a copy of Sponsor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SponsorCopyWith<Sponsor> get copyWith =>
      _$SponsorCopyWithImpl<Sponsor>(this as Sponsor, _$identity);

  /// Serializes this Sponsor to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Sponsor &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.websiteUrl, websiteUrl) ||
                other.websiteUrl == websiteUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, logoUrl, websiteUrl, description, tier, isActive);

  @override
  String toString() {
    return 'Sponsor(id: $id, name: $name, logoUrl: $logoUrl, websiteUrl: $websiteUrl, description: $description, tier: $tier, isActive: $isActive)';
  }
}

/// @nodoc
abstract mixin class $SponsorCopyWith<$Res> {
  factory $SponsorCopyWith(Sponsor value, $Res Function(Sponsor) _then) =
      _$SponsorCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String? logoUrl,
      String? websiteUrl,
      String? description,
      SponsorTier tier,
      bool isActive});
}

/// @nodoc
class _$SponsorCopyWithImpl<$Res> implements $SponsorCopyWith<$Res> {
  _$SponsorCopyWithImpl(this._self, this._then);

  final Sponsor _self;
  final $Res Function(Sponsor) _then;

  /// Create a copy of Sponsor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? logoUrl = freezed,
    Object? websiteUrl = freezed,
    Object? description = freezed,
    Object? tier = null,
    Object? isActive = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _self.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      websiteUrl: freezed == websiteUrl
          ? _self.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      tier: null == tier
          ? _self.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as SponsorTier,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [Sponsor].
extension SponsorPatterns on Sponsor {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Sponsor value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Sponsor() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Sponsor value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Sponsor():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Sponsor value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Sponsor() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String? logoUrl,
            String? websiteUrl,
            String? description,
            SponsorTier tier,
            bool isActive)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Sponsor() when $default != null:
        return $default(_that.id, _that.name, _that.logoUrl, _that.websiteUrl,
            _that.description, _that.tier, _that.isActive);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String? logoUrl,
            String? websiteUrl,
            String? description,
            SponsorTier tier,
            bool isActive)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Sponsor():
        return $default(_that.id, _that.name, _that.logoUrl, _that.websiteUrl,
            _that.description, _that.tier, _that.isActive);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String name,
            String? logoUrl,
            String? websiteUrl,
            String? description,
            SponsorTier tier,
            bool isActive)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Sponsor() when $default != null:
        return $default(_that.id, _that.name, _that.logoUrl, _that.websiteUrl,
            _that.description, _that.tier, _that.isActive);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Sponsor implements Sponsor {
  const _Sponsor(
      {required this.id,
      required this.name,
      this.logoUrl,
      this.websiteUrl,
      this.description,
      this.tier = SponsorTier.silver,
      this.isActive = true});
  factory _Sponsor.fromJson(Map<String, dynamic> json) =>
      _$SponsorFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? logoUrl;
  @override
  final String? websiteUrl;
  @override
  final String? description;
  @override
  @JsonKey()
  final SponsorTier tier;
  @override
  @JsonKey()
  final bool isActive;

  /// Create a copy of Sponsor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SponsorCopyWith<_Sponsor> get copyWith =>
      __$SponsorCopyWithImpl<_Sponsor>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SponsorToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Sponsor &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.websiteUrl, websiteUrl) ||
                other.websiteUrl == websiteUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, logoUrl, websiteUrl, description, tier, isActive);

  @override
  String toString() {
    return 'Sponsor(id: $id, name: $name, logoUrl: $logoUrl, websiteUrl: $websiteUrl, description: $description, tier: $tier, isActive: $isActive)';
  }
}

/// @nodoc
abstract mixin class _$SponsorCopyWith<$Res> implements $SponsorCopyWith<$Res> {
  factory _$SponsorCopyWith(_Sponsor value, $Res Function(_Sponsor) _then) =
      __$SponsorCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? logoUrl,
      String? websiteUrl,
      String? description,
      SponsorTier tier,
      bool isActive});
}

/// @nodoc
class __$SponsorCopyWithImpl<$Res> implements _$SponsorCopyWith<$Res> {
  __$SponsorCopyWithImpl(this._self, this._then);

  final _Sponsor _self;
  final $Res Function(_Sponsor) _then;

  /// Create a copy of Sponsor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? logoUrl = freezed,
    Object? websiteUrl = freezed,
    Object? description = freezed,
    Object? tier = null,
    Object? isActive = null,
  }) {
    return _then(_Sponsor(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _self.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      websiteUrl: freezed == websiteUrl
          ? _self.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      tier: null == tier
          ? _self.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as SponsorTier,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
