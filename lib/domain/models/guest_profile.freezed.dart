// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guest_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GuestProfile {

 String get id; String get name; String get email; double get handicap;@OptionalTimestampConverter() DateTime? get firstPlayedAt;@OptionalTimestampConverter() DateTime? get lastPlayedAt; int get eventCount;
/// Create a copy of GuestProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuestProfileCopyWith<GuestProfile> get copyWith => _$GuestProfileCopyWithImpl<GuestProfile>(this as GuestProfile, _$identity);

  /// Serializes this GuestProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuestProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.handicap, handicap) || other.handicap == handicap)&&(identical(other.firstPlayedAt, firstPlayedAt) || other.firstPlayedAt == firstPlayedAt)&&(identical(other.lastPlayedAt, lastPlayedAt) || other.lastPlayedAt == lastPlayedAt)&&(identical(other.eventCount, eventCount) || other.eventCount == eventCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,handicap,firstPlayedAt,lastPlayedAt,eventCount);

@override
String toString() {
  return 'GuestProfile(id: $id, name: $name, email: $email, handicap: $handicap, firstPlayedAt: $firstPlayedAt, lastPlayedAt: $lastPlayedAt, eventCount: $eventCount)';
}


}

/// @nodoc
abstract mixin class $GuestProfileCopyWith<$Res>  {
  factory $GuestProfileCopyWith(GuestProfile value, $Res Function(GuestProfile) _then) = _$GuestProfileCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, double handicap,@OptionalTimestampConverter() DateTime? firstPlayedAt,@OptionalTimestampConverter() DateTime? lastPlayedAt, int eventCount
});




}
/// @nodoc
class _$GuestProfileCopyWithImpl<$Res>
    implements $GuestProfileCopyWith<$Res> {
  _$GuestProfileCopyWithImpl(this._self, this._then);

  final GuestProfile _self;
  final $Res Function(GuestProfile) _then;

/// Create a copy of GuestProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? handicap = null,Object? firstPlayedAt = freezed,Object? lastPlayedAt = freezed,Object? eventCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,handicap: null == handicap ? _self.handicap : handicap // ignore: cast_nullable_to_non_nullable
as double,firstPlayedAt: freezed == firstPlayedAt ? _self.firstPlayedAt : firstPlayedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPlayedAt: freezed == lastPlayedAt ? _self.lastPlayedAt : lastPlayedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,eventCount: null == eventCount ? _self.eventCount : eventCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GuestProfile].
extension GuestProfilePatterns on GuestProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuestProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuestProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuestProfile value)  $default,){
final _that = this;
switch (_that) {
case _GuestProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuestProfile value)?  $default,){
final _that = this;
switch (_that) {
case _GuestProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  double handicap, @OptionalTimestampConverter()  DateTime? firstPlayedAt, @OptionalTimestampConverter()  DateTime? lastPlayedAt,  int eventCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuestProfile() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.handicap,_that.firstPlayedAt,_that.lastPlayedAt,_that.eventCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  double handicap, @OptionalTimestampConverter()  DateTime? firstPlayedAt, @OptionalTimestampConverter()  DateTime? lastPlayedAt,  int eventCount)  $default,) {final _that = this;
switch (_that) {
case _GuestProfile():
return $default(_that.id,_that.name,_that.email,_that.handicap,_that.firstPlayedAt,_that.lastPlayedAt,_that.eventCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  double handicap, @OptionalTimestampConverter()  DateTime? firstPlayedAt, @OptionalTimestampConverter()  DateTime? lastPlayedAt,  int eventCount)?  $default,) {final _that = this;
switch (_that) {
case _GuestProfile() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.handicap,_that.firstPlayedAt,_that.lastPlayedAt,_that.eventCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuestProfile extends GuestProfile {
  const _GuestProfile({required this.id, required this.name, required this.email, this.handicap = 28.0, @OptionalTimestampConverter() this.firstPlayedAt, @OptionalTimestampConverter() this.lastPlayedAt, this.eventCount = 0}): super._();
  factory _GuestProfile.fromJson(Map<String, dynamic> json) => _$GuestProfileFromJson(json);

@override final  String id;
@override final  String name;
@override final  String email;
@override@JsonKey() final  double handicap;
@override@OptionalTimestampConverter() final  DateTime? firstPlayedAt;
@override@OptionalTimestampConverter() final  DateTime? lastPlayedAt;
@override@JsonKey() final  int eventCount;

/// Create a copy of GuestProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestProfileCopyWith<_GuestProfile> get copyWith => __$GuestProfileCopyWithImpl<_GuestProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuestProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.handicap, handicap) || other.handicap == handicap)&&(identical(other.firstPlayedAt, firstPlayedAt) || other.firstPlayedAt == firstPlayedAt)&&(identical(other.lastPlayedAt, lastPlayedAt) || other.lastPlayedAt == lastPlayedAt)&&(identical(other.eventCount, eventCount) || other.eventCount == eventCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,handicap,firstPlayedAt,lastPlayedAt,eventCount);

@override
String toString() {
  return 'GuestProfile(id: $id, name: $name, email: $email, handicap: $handicap, firstPlayedAt: $firstPlayedAt, lastPlayedAt: $lastPlayedAt, eventCount: $eventCount)';
}


}

/// @nodoc
abstract mixin class _$GuestProfileCopyWith<$Res> implements $GuestProfileCopyWith<$Res> {
  factory _$GuestProfileCopyWith(_GuestProfile value, $Res Function(_GuestProfile) _then) = __$GuestProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, double handicap,@OptionalTimestampConverter() DateTime? firstPlayedAt,@OptionalTimestampConverter() DateTime? lastPlayedAt, int eventCount
});




}
/// @nodoc
class __$GuestProfileCopyWithImpl<$Res>
    implements _$GuestProfileCopyWith<$Res> {
  __$GuestProfileCopyWithImpl(this._self, this._then);

  final _GuestProfile _self;
  final $Res Function(_GuestProfile) _then;

/// Create a copy of GuestProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? handicap = null,Object? firstPlayedAt = freezed,Object? lastPlayedAt = freezed,Object? eventCount = null,}) {
  return _then(_GuestProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,handicap: null == handicap ? _self.handicap : handicap // ignore: cast_nullable_to_non_nullable
as double,firstPlayedAt: freezed == firstPlayedAt ? _self.firstPlayedAt : firstPlayedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPlayedAt: freezed == lastPlayedAt ? _self.lastPlayedAt : lastPlayedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,eventCount: null == eventCount ? _self.eventCount : eventCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
