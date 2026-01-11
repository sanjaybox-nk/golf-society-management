// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'distribution_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DistributionList {

 String get id; String get name; List<String> get memberIds; DateTime get createdAt;
/// Create a copy of DistributionList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DistributionListCopyWith<DistributionList> get copyWith => _$DistributionListCopyWithImpl<DistributionList>(this as DistributionList, _$identity);

  /// Serializes this DistributionList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DistributionList&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.memberIds, memberIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(memberIds),createdAt);

@override
String toString() {
  return 'DistributionList(id: $id, name: $name, memberIds: $memberIds, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DistributionListCopyWith<$Res>  {
  factory $DistributionListCopyWith(DistributionList value, $Res Function(DistributionList) _then) = _$DistributionListCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> memberIds, DateTime createdAt
});




}
/// @nodoc
class _$DistributionListCopyWithImpl<$Res>
    implements $DistributionListCopyWith<$Res> {
  _$DistributionListCopyWithImpl(this._self, this._then);

  final DistributionList _self;
  final $Res Function(DistributionList) _then;

/// Create a copy of DistributionList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? memberIds = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,memberIds: null == memberIds ? _self.memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DistributionList].
extension DistributionListPatterns on DistributionList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DistributionList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DistributionList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DistributionList value)  $default,){
final _that = this;
switch (_that) {
case _DistributionList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DistributionList value)?  $default,){
final _that = this;
switch (_that) {
case _DistributionList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<String> memberIds,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DistributionList() when $default != null:
return $default(_that.id,_that.name,_that.memberIds,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<String> memberIds,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _DistributionList():
return $default(_that.id,_that.name,_that.memberIds,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<String> memberIds,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DistributionList() when $default != null:
return $default(_that.id,_that.name,_that.memberIds,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DistributionList implements DistributionList {
  const _DistributionList({required this.id, required this.name, required final  List<String> memberIds, required this.createdAt}): _memberIds = memberIds;
  factory _DistributionList.fromJson(Map<String, dynamic> json) => _$DistributionListFromJson(json);

@override final  String id;
@override final  String name;
 final  List<String> _memberIds;
@override List<String> get memberIds {
  if (_memberIds is EqualUnmodifiableListView) return _memberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberIds);
}

@override final  DateTime createdAt;

/// Create a copy of DistributionList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DistributionListCopyWith<_DistributionList> get copyWith => __$DistributionListCopyWithImpl<_DistributionList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DistributionListToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DistributionList&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._memberIds, _memberIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_memberIds),createdAt);

@override
String toString() {
  return 'DistributionList(id: $id, name: $name, memberIds: $memberIds, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DistributionListCopyWith<$Res> implements $DistributionListCopyWith<$Res> {
  factory _$DistributionListCopyWith(_DistributionList value, $Res Function(_DistributionList) _then) = __$DistributionListCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> memberIds, DateTime createdAt
});




}
/// @nodoc
class __$DistributionListCopyWithImpl<$Res>
    implements _$DistributionListCopyWith<$Res> {
  __$DistributionListCopyWithImpl(this._self, this._then);

  final _DistributionList _self;
  final $Res Function(_DistributionList) _then;

/// Create a copy of DistributionList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? memberIds = null,Object? createdAt = null,}) {
  return _then(_DistributionList(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,memberIds: null == memberIds ? _self._memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
