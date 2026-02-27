// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'campaign.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Campaign {

 String get id; String get title; String get message; String get category;// Urgent, Event, News
 String get targetType;// All Members, Groups, Individual
 int get recipientCount; DateTime get timestamp; String? get sentByUserId;// Admin ID who sent it
 String? get actionUrl; String? get targetDescription;
/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CampaignCopyWith<Campaign> get copyWith => _$CampaignCopyWithImpl<Campaign>(this as Campaign, _$identity);

  /// Serializes this Campaign to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Campaign&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.category, category) || other.category == category)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.recipientCount, recipientCount) || other.recipientCount == recipientCount)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.sentByUserId, sentByUserId) || other.sentByUserId == sentByUserId)&&(identical(other.actionUrl, actionUrl) || other.actionUrl == actionUrl)&&(identical(other.targetDescription, targetDescription) || other.targetDescription == targetDescription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,message,category,targetType,recipientCount,timestamp,sentByUserId,actionUrl,targetDescription);

@override
String toString() {
  return 'Campaign(id: $id, title: $title, message: $message, category: $category, targetType: $targetType, recipientCount: $recipientCount, timestamp: $timestamp, sentByUserId: $sentByUserId, actionUrl: $actionUrl, targetDescription: $targetDescription)';
}


}

/// @nodoc
abstract mixin class $CampaignCopyWith<$Res>  {
  factory $CampaignCopyWith(Campaign value, $Res Function(Campaign) _then) = _$CampaignCopyWithImpl;
@useResult
$Res call({
 String id, String title, String message, String category, String targetType, int recipientCount, DateTime timestamp, String? sentByUserId, String? actionUrl, String? targetDescription
});




}
/// @nodoc
class _$CampaignCopyWithImpl<$Res>
    implements $CampaignCopyWith<$Res> {
  _$CampaignCopyWithImpl(this._self, this._then);

  final Campaign _self;
  final $Res Function(Campaign) _then;

/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? message = null,Object? category = null,Object? targetType = null,Object? recipientCount = null,Object? timestamp = null,Object? sentByUserId = freezed,Object? actionUrl = freezed,Object? targetDescription = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,recipientCount: null == recipientCount ? _self.recipientCount : recipientCount // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,sentByUserId: freezed == sentByUserId ? _self.sentByUserId : sentByUserId // ignore: cast_nullable_to_non_nullable
as String?,actionUrl: freezed == actionUrl ? _self.actionUrl : actionUrl // ignore: cast_nullable_to_non_nullable
as String?,targetDescription: freezed == targetDescription ? _self.targetDescription : targetDescription // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Campaign].
extension CampaignPatterns on Campaign {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Campaign value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Campaign() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Campaign value)  $default,){
final _that = this;
switch (_that) {
case _Campaign():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Campaign value)?  $default,){
final _that = this;
switch (_that) {
case _Campaign() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String message,  String category,  String targetType,  int recipientCount,  DateTime timestamp,  String? sentByUserId,  String? actionUrl,  String? targetDescription)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Campaign() when $default != null:
return $default(_that.id,_that.title,_that.message,_that.category,_that.targetType,_that.recipientCount,_that.timestamp,_that.sentByUserId,_that.actionUrl,_that.targetDescription);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String message,  String category,  String targetType,  int recipientCount,  DateTime timestamp,  String? sentByUserId,  String? actionUrl,  String? targetDescription)  $default,) {final _that = this;
switch (_that) {
case _Campaign():
return $default(_that.id,_that.title,_that.message,_that.category,_that.targetType,_that.recipientCount,_that.timestamp,_that.sentByUserId,_that.actionUrl,_that.targetDescription);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String message,  String category,  String targetType,  int recipientCount,  DateTime timestamp,  String? sentByUserId,  String? actionUrl,  String? targetDescription)?  $default,) {final _that = this;
switch (_that) {
case _Campaign() when $default != null:
return $default(_that.id,_that.title,_that.message,_that.category,_that.targetType,_that.recipientCount,_that.timestamp,_that.sentByUserId,_that.actionUrl,_that.targetDescription);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Campaign extends Campaign {
  const _Campaign({required this.id, required this.title, required this.message, required this.category, required this.targetType, required this.recipientCount, required this.timestamp, this.sentByUserId, this.actionUrl, this.targetDescription}): super._();
  factory _Campaign.fromJson(Map<String, dynamic> json) => _$CampaignFromJson(json);

@override final  String id;
@override final  String title;
@override final  String message;
@override final  String category;
// Urgent, Event, News
@override final  String targetType;
// All Members, Groups, Individual
@override final  int recipientCount;
@override final  DateTime timestamp;
@override final  String? sentByUserId;
// Admin ID who sent it
@override final  String? actionUrl;
@override final  String? targetDescription;

/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CampaignCopyWith<_Campaign> get copyWith => __$CampaignCopyWithImpl<_Campaign>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CampaignToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Campaign&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.category, category) || other.category == category)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.recipientCount, recipientCount) || other.recipientCount == recipientCount)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.sentByUserId, sentByUserId) || other.sentByUserId == sentByUserId)&&(identical(other.actionUrl, actionUrl) || other.actionUrl == actionUrl)&&(identical(other.targetDescription, targetDescription) || other.targetDescription == targetDescription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,message,category,targetType,recipientCount,timestamp,sentByUserId,actionUrl,targetDescription);

@override
String toString() {
  return 'Campaign(id: $id, title: $title, message: $message, category: $category, targetType: $targetType, recipientCount: $recipientCount, timestamp: $timestamp, sentByUserId: $sentByUserId, actionUrl: $actionUrl, targetDescription: $targetDescription)';
}


}

/// @nodoc
abstract mixin class _$CampaignCopyWith<$Res> implements $CampaignCopyWith<$Res> {
  factory _$CampaignCopyWith(_Campaign value, $Res Function(_Campaign) _then) = __$CampaignCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String message, String category, String targetType, int recipientCount, DateTime timestamp, String? sentByUserId, String? actionUrl, String? targetDescription
});




}
/// @nodoc
class __$CampaignCopyWithImpl<$Res>
    implements _$CampaignCopyWith<$Res> {
  __$CampaignCopyWithImpl(this._self, this._then);

  final _Campaign _self;
  final $Res Function(_Campaign) _then;

/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? message = null,Object? category = null,Object? targetType = null,Object? recipientCount = null,Object? timestamp = null,Object? sentByUserId = freezed,Object? actionUrl = freezed,Object? targetDescription = freezed,}) {
  return _then(_Campaign(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,recipientCount: null == recipientCount ? _self.recipientCount : recipientCount // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,sentByUserId: freezed == sentByUserId ? _self.sentByUserId : sentByUserId // ignore: cast_nullable_to_non_nullable
as String?,actionUrl: freezed == actionUrl ? _self.actionUrl : actionUrl // ignore: cast_nullable_to_non_nullable
as String?,targetDescription: freezed == targetDescription ? _self.targetDescription : targetDescription // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
