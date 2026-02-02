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

 String get societyName; String? get logoUrl; int get primaryColor;// Default: BoxyArt Yellow
 String get themeMode;// 'system', 'light', 'dark'
 List<int> get customColors;// User-created custom colors (up to 5)
 double get cardTintIntensity;// Card background tint intensity (0.0 to 1.0)
 bool get useCardGradient;// Whether to use gradient on cards
 String get currencySymbol;// Default currency symbol
 String get currencyCode;// Default currency code
 String get groupingStrategy;
/// Create a copy of SocietyConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocietyConfigCopyWith<SocietyConfig> get copyWith => _$SocietyConfigCopyWithImpl<SocietyConfig>(this as SocietyConfig, _$identity);

  /// Serializes this SocietyConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocietyConfig&&(identical(other.societyName, societyName) || other.societyName == societyName)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&const DeepCollectionEquality().equals(other.customColors, customColors)&&(identical(other.cardTintIntensity, cardTintIntensity) || other.cardTintIntensity == cardTintIntensity)&&(identical(other.useCardGradient, useCardGradient) || other.useCardGradient == useCardGradient)&&(identical(other.currencySymbol, currencySymbol) || other.currencySymbol == currencySymbol)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.groupingStrategy, groupingStrategy) || other.groupingStrategy == groupingStrategy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,societyName,logoUrl,primaryColor,themeMode,const DeepCollectionEquality().hash(customColors),cardTintIntensity,useCardGradient,currencySymbol,currencyCode,groupingStrategy);

@override
String toString() {
  return 'SocietyConfig(societyName: $societyName, logoUrl: $logoUrl, primaryColor: $primaryColor, themeMode: $themeMode, customColors: $customColors, cardTintIntensity: $cardTintIntensity, useCardGradient: $useCardGradient, currencySymbol: $currencySymbol, currencyCode: $currencyCode, groupingStrategy: $groupingStrategy)';
}


}

/// @nodoc
abstract mixin class $SocietyConfigCopyWith<$Res>  {
  factory $SocietyConfigCopyWith(SocietyConfig value, $Res Function(SocietyConfig) _then) = _$SocietyConfigCopyWithImpl;
@useResult
$Res call({
 String societyName, String? logoUrl, int primaryColor, String themeMode, List<int> customColors, double cardTintIntensity, bool useCardGradient, String currencySymbol, String currencyCode, String groupingStrategy
});




}
/// @nodoc
class _$SocietyConfigCopyWithImpl<$Res>
    implements $SocietyConfigCopyWith<$Res> {
  _$SocietyConfigCopyWithImpl(this._self, this._then);

  final SocietyConfig _self;
  final $Res Function(SocietyConfig) _then;

/// Create a copy of SocietyConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? societyName = null,Object? logoUrl = freezed,Object? primaryColor = null,Object? themeMode = null,Object? customColors = null,Object? cardTintIntensity = null,Object? useCardGradient = null,Object? currencySymbol = null,Object? currencyCode = null,Object? groupingStrategy = null,}) {
  return _then(_self.copyWith(
societyName: null == societyName ? _self.societyName : societyName // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as int,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,customColors: null == customColors ? _self.customColors : customColors // ignore: cast_nullable_to_non_nullable
as List<int>,cardTintIntensity: null == cardTintIntensity ? _self.cardTintIntensity : cardTintIntensity // ignore: cast_nullable_to_non_nullable
as double,useCardGradient: null == useCardGradient ? _self.useCardGradient : useCardGradient // ignore: cast_nullable_to_non_nullable
as bool,currencySymbol: null == currencySymbol ? _self.currencySymbol : currencySymbol // ignore: cast_nullable_to_non_nullable
as String,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,groupingStrategy: null == groupingStrategy ? _self.groupingStrategy : groupingStrategy // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocietyConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocietyConfig() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocietyConfig value)  $default,){
final _that = this;
switch (_that) {
case _SocietyConfig():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocietyConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SocietyConfig() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String societyName,  String? logoUrl,  int primaryColor,  String themeMode,  List<int> customColors,  double cardTintIntensity,  bool useCardGradient,  String currencySymbol,  String currencyCode,  String groupingStrategy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocietyConfig() when $default != null:
return $default(_that.societyName,_that.logoUrl,_that.primaryColor,_that.themeMode,_that.customColors,_that.cardTintIntensity,_that.useCardGradient,_that.currencySymbol,_that.currencyCode,_that.groupingStrategy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String societyName,  String? logoUrl,  int primaryColor,  String themeMode,  List<int> customColors,  double cardTintIntensity,  bool useCardGradient,  String currencySymbol,  String currencyCode,  String groupingStrategy)  $default,) {final _that = this;
switch (_that) {
case _SocietyConfig():
return $default(_that.societyName,_that.logoUrl,_that.primaryColor,_that.themeMode,_that.customColors,_that.cardTintIntensity,_that.useCardGradient,_that.currencySymbol,_that.currencyCode,_that.groupingStrategy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String societyName,  String? logoUrl,  int primaryColor,  String themeMode,  List<int> customColors,  double cardTintIntensity,  bool useCardGradient,  String currencySymbol,  String currencyCode,  String groupingStrategy)?  $default,) {final _that = this;
switch (_that) {
case _SocietyConfig() when $default != null:
return $default(_that.societyName,_that.logoUrl,_that.primaryColor,_that.themeMode,_that.customColors,_that.cardTintIntensity,_that.useCardGradient,_that.currencySymbol,_that.currencyCode,_that.groupingStrategy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocietyConfig implements SocietyConfig {
  const _SocietyConfig({this.societyName = 'Golf Society', this.logoUrl, this.primaryColor = 0xFFF7D354, this.themeMode = 'system', final  List<int> customColors = const [], this.cardTintIntensity = 0.1, this.useCardGradient = true, this.currencySymbol = '£', this.currencyCode = 'GBP', this.groupingStrategy = 'balanced'}): _customColors = customColors;
  factory _SocietyConfig.fromJson(Map<String, dynamic> json) => _$SocietyConfigFromJson(json);

@override@JsonKey() final  String societyName;
@override final  String? logoUrl;
@override@JsonKey() final  int primaryColor;
// Default: BoxyArt Yellow
@override@JsonKey() final  String themeMode;
// 'system', 'light', 'dark'
 final  List<int> _customColors;
// 'system', 'light', 'dark'
@override@JsonKey() List<int> get customColors {
  if (_customColors is EqualUnmodifiableListView) return _customColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_customColors);
}

// User-created custom colors (up to 5)
@override@JsonKey() final  double cardTintIntensity;
// Card background tint intensity (0.0 to 1.0)
@override@JsonKey() final  bool useCardGradient;
// Whether to use gradient on cards
@override@JsonKey() final  String currencySymbol;
// Default currency symbol
@override@JsonKey() final  String currencyCode;
// Default currency code
@override@JsonKey() final  String groupingStrategy;

/// Create a copy of SocietyConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocietyConfigCopyWith<_SocietyConfig> get copyWith => __$SocietyConfigCopyWithImpl<_SocietyConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocietyConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocietyConfig&&(identical(other.societyName, societyName) || other.societyName == societyName)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&const DeepCollectionEquality().equals(other._customColors, _customColors)&&(identical(other.cardTintIntensity, cardTintIntensity) || other.cardTintIntensity == cardTintIntensity)&&(identical(other.useCardGradient, useCardGradient) || other.useCardGradient == useCardGradient)&&(identical(other.currencySymbol, currencySymbol) || other.currencySymbol == currencySymbol)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.groupingStrategy, groupingStrategy) || other.groupingStrategy == groupingStrategy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,societyName,logoUrl,primaryColor,themeMode,const DeepCollectionEquality().hash(_customColors),cardTintIntensity,useCardGradient,currencySymbol,currencyCode,groupingStrategy);

@override
String toString() {
  return 'SocietyConfig(societyName: $societyName, logoUrl: $logoUrl, primaryColor: $primaryColor, themeMode: $themeMode, customColors: $customColors, cardTintIntensity: $cardTintIntensity, useCardGradient: $useCardGradient, currencySymbol: $currencySymbol, currencyCode: $currencyCode, groupingStrategy: $groupingStrategy)';
}


}

/// @nodoc
abstract mixin class _$SocietyConfigCopyWith<$Res> implements $SocietyConfigCopyWith<$Res> {
  factory _$SocietyConfigCopyWith(_SocietyConfig value, $Res Function(_SocietyConfig) _then) = __$SocietyConfigCopyWithImpl;
@override @useResult
$Res call({
 String societyName, String? logoUrl, int primaryColor, String themeMode, List<int> customColors, double cardTintIntensity, bool useCardGradient, String currencySymbol, String currencyCode, String groupingStrategy
});




}
/// @nodoc
class __$SocietyConfigCopyWithImpl<$Res>
    implements _$SocietyConfigCopyWith<$Res> {
  __$SocietyConfigCopyWithImpl(this._self, this._then);

  final _SocietyConfig _self;
  final $Res Function(_SocietyConfig) _then;

/// Create a copy of SocietyConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? societyName = null,Object? logoUrl = freezed,Object? primaryColor = null,Object? themeMode = null,Object? customColors = null,Object? cardTintIntensity = null,Object? useCardGradient = null,Object? currencySymbol = null,Object? currencyCode = null,Object? groupingStrategy = null,}) {
  return _then(_SocietyConfig(
societyName: null == societyName ? _self.societyName : societyName // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as int,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,customColors: null == customColors ? _self._customColors : customColors // ignore: cast_nullable_to_non_nullable
as List<int>,cardTintIntensity: null == cardTintIntensity ? _self.cardTintIntensity : cardTintIntensity // ignore: cast_nullable_to_non_nullable
as double,useCardGradient: null == useCardGradient ? _self.useCardGradient : useCardGradient // ignore: cast_nullable_to_non_nullable
as bool,currencySymbol: null == currencySymbol ? _self.currencySymbol : currencySymbol // ignore: cast_nullable_to_non_nullable
as String,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,groupingStrategy: null == groupingStrategy ? _self.groupingStrategy : groupingStrategy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
