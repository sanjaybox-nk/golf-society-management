// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audience_filter_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AudienceFilterRule {

 AudienceProperty get property; FilterOperator get operator; String get value;
/// Create a copy of AudienceFilterRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudienceFilterRuleCopyWith<AudienceFilterRule> get copyWith => _$AudienceFilterRuleCopyWithImpl<AudienceFilterRule>(this as AudienceFilterRule, _$identity);

  /// Serializes this AudienceFilterRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudienceFilterRule&&(identical(other.property, property) || other.property == property)&&(identical(other.operator, operator) || other.operator == operator)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,operator,value);

@override
String toString() {
  return 'AudienceFilterRule(property: $property, operator: $operator, value: $value)';
}


}

/// @nodoc
abstract mixin class $AudienceFilterRuleCopyWith<$Res>  {
  factory $AudienceFilterRuleCopyWith(AudienceFilterRule value, $Res Function(AudienceFilterRule) _then) = _$AudienceFilterRuleCopyWithImpl;
@useResult
$Res call({
 AudienceProperty property, FilterOperator operator, String value
});




}
/// @nodoc
class _$AudienceFilterRuleCopyWithImpl<$Res>
    implements $AudienceFilterRuleCopyWith<$Res> {
  _$AudienceFilterRuleCopyWithImpl(this._self, this._then);

  final AudienceFilterRule _self;
  final $Res Function(AudienceFilterRule) _then;

/// Create a copy of AudienceFilterRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? property = null,Object? operator = null,Object? value = null,}) {
  return _then(_self.copyWith(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as AudienceProperty,operator: null == operator ? _self.operator : operator // ignore: cast_nullable_to_non_nullable
as FilterOperator,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AudienceFilterRule].
extension AudienceFilterRulePatterns on AudienceFilterRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AudienceFilterRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AudienceFilterRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AudienceFilterRule value)  $default,){
final _that = this;
switch (_that) {
case _AudienceFilterRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AudienceFilterRule value)?  $default,){
final _that = this;
switch (_that) {
case _AudienceFilterRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AudienceProperty property,  FilterOperator operator,  String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AudienceFilterRule() when $default != null:
return $default(_that.property,_that.operator,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AudienceProperty property,  FilterOperator operator,  String value)  $default,) {final _that = this;
switch (_that) {
case _AudienceFilterRule():
return $default(_that.property,_that.operator,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AudienceProperty property,  FilterOperator operator,  String value)?  $default,) {final _that = this;
switch (_that) {
case _AudienceFilterRule() when $default != null:
return $default(_that.property,_that.operator,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AudienceFilterRule implements AudienceFilterRule {
  const _AudienceFilterRule({required this.property, required this.operator, required this.value});
  factory _AudienceFilterRule.fromJson(Map<String, dynamic> json) => _$AudienceFilterRuleFromJson(json);

@override final  AudienceProperty property;
@override final  FilterOperator operator;
@override final  String value;

/// Create a copy of AudienceFilterRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AudienceFilterRuleCopyWith<_AudienceFilterRule> get copyWith => __$AudienceFilterRuleCopyWithImpl<_AudienceFilterRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AudienceFilterRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AudienceFilterRule&&(identical(other.property, property) || other.property == property)&&(identical(other.operator, operator) || other.operator == operator)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,property,operator,value);

@override
String toString() {
  return 'AudienceFilterRule(property: $property, operator: $operator, value: $value)';
}


}

/// @nodoc
abstract mixin class _$AudienceFilterRuleCopyWith<$Res> implements $AudienceFilterRuleCopyWith<$Res> {
  factory _$AudienceFilterRuleCopyWith(_AudienceFilterRule value, $Res Function(_AudienceFilterRule) _then) = __$AudienceFilterRuleCopyWithImpl;
@override @useResult
$Res call({
 AudienceProperty property, FilterOperator operator, String value
});




}
/// @nodoc
class __$AudienceFilterRuleCopyWithImpl<$Res>
    implements _$AudienceFilterRuleCopyWith<$Res> {
  __$AudienceFilterRuleCopyWithImpl(this._self, this._then);

  final _AudienceFilterRule _self;
  final $Res Function(_AudienceFilterRule) _then;

/// Create a copy of AudienceFilterRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? property = null,Object? operator = null,Object? value = null,}) {
  return _then(_AudienceFilterRule(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as AudienceProperty,operator: null == operator ? _self.operator : operator // ignore: cast_nullable_to_non_nullable
as FilterOperator,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
