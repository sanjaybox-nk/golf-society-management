// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuditActivity {

 String get id; String get message; ActivityType get type;@TimestampConverter() DateTime get timestamp; String? get userId; String? get userName; String? get relatedId;
/// Create a copy of AuditActivity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditActivityCopyWith<AuditActivity> get copyWith => _$AuditActivityCopyWithImpl<AuditActivity>(this as AuditActivity, _$identity);

  /// Serializes this AuditActivity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message)&&(identical(other.type, type) || other.type == type)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.relatedId, relatedId) || other.relatedId == relatedId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,message,type,timestamp,userId,userName,relatedId);

@override
String toString() {
  return 'AuditActivity(id: $id, message: $message, type: $type, timestamp: $timestamp, userId: $userId, userName: $userName, relatedId: $relatedId)';
}


}

/// @nodoc
abstract mixin class $AuditActivityCopyWith<$Res>  {
  factory $AuditActivityCopyWith(AuditActivity value, $Res Function(AuditActivity) _then) = _$AuditActivityCopyWithImpl;
@useResult
$Res call({
 String id, String message, ActivityType type,@TimestampConverter() DateTime timestamp, String? userId, String? userName, String? relatedId
});




}
/// @nodoc
class _$AuditActivityCopyWithImpl<$Res>
    implements $AuditActivityCopyWith<$Res> {
  _$AuditActivityCopyWithImpl(this._self, this._then);

  final AuditActivity _self;
  final $Res Function(AuditActivity) _then;

/// Create a copy of AuditActivity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? message = null,Object? type = null,Object? timestamp = null,Object? userId = freezed,Object? userName = freezed,Object? relatedId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ActivityType,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,relatedId: freezed == relatedId ? _self.relatedId : relatedId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditActivity].
extension AuditActivityPatterns on AuditActivity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditActivity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditActivity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditActivity value)  $default,){
final _that = this;
switch (_that) {
case _AuditActivity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditActivity value)?  $default,){
final _that = this;
switch (_that) {
case _AuditActivity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String message,  ActivityType type, @TimestampConverter()  DateTime timestamp,  String? userId,  String? userName,  String? relatedId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditActivity() when $default != null:
return $default(_that.id,_that.message,_that.type,_that.timestamp,_that.userId,_that.userName,_that.relatedId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String message,  ActivityType type, @TimestampConverter()  DateTime timestamp,  String? userId,  String? userName,  String? relatedId)  $default,) {final _that = this;
switch (_that) {
case _AuditActivity():
return $default(_that.id,_that.message,_that.type,_that.timestamp,_that.userId,_that.userName,_that.relatedId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String message,  ActivityType type, @TimestampConverter()  DateTime timestamp,  String? userId,  String? userName,  String? relatedId)?  $default,) {final _that = this;
switch (_that) {
case _AuditActivity() when $default != null:
return $default(_that.id,_that.message,_that.type,_that.timestamp,_that.userId,_that.userName,_that.relatedId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditActivity implements AuditActivity {
  const _AuditActivity({required this.id, required this.message, required this.type, @TimestampConverter() required this.timestamp, this.userId, this.userName, this.relatedId});
  factory _AuditActivity.fromJson(Map<String, dynamic> json) => _$AuditActivityFromJson(json);

@override final  String id;
@override final  String message;
@override final  ActivityType type;
@override@TimestampConverter() final  DateTime timestamp;
@override final  String? userId;
@override final  String? userName;
@override final  String? relatedId;

/// Create a copy of AuditActivity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditActivityCopyWith<_AuditActivity> get copyWith => __$AuditActivityCopyWithImpl<_AuditActivity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message)&&(identical(other.type, type) || other.type == type)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.relatedId, relatedId) || other.relatedId == relatedId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,message,type,timestamp,userId,userName,relatedId);

@override
String toString() {
  return 'AuditActivity(id: $id, message: $message, type: $type, timestamp: $timestamp, userId: $userId, userName: $userName, relatedId: $relatedId)';
}


}

/// @nodoc
abstract mixin class _$AuditActivityCopyWith<$Res> implements $AuditActivityCopyWith<$Res> {
  factory _$AuditActivityCopyWith(_AuditActivity value, $Res Function(_AuditActivity) _then) = __$AuditActivityCopyWithImpl;
@override @useResult
$Res call({
 String id, String message, ActivityType type,@TimestampConverter() DateTime timestamp, String? userId, String? userName, String? relatedId
});




}
/// @nodoc
class __$AuditActivityCopyWithImpl<$Res>
    implements _$AuditActivityCopyWith<$Res> {
  __$AuditActivityCopyWithImpl(this._self, this._then);

  final _AuditActivity _self;
  final $Res Function(_AuditActivity) _then;

/// Create a copy of AuditActivity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? message = null,Object? type = null,Object? timestamp = null,Object? userId = freezed,Object? userName = freezed,Object? relatedId = freezed,}) {
  return _then(_AuditActivity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ActivityType,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,relatedId: freezed == relatedId ? _self.relatedId : relatedId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
