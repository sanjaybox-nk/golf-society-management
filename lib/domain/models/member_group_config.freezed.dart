// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_group_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemberGroup {

 String get id; String get name; List<String> get manualMemberIds;
/// Create a copy of MemberGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberGroupCopyWith<MemberGroup> get copyWith => _$MemberGroupCopyWithImpl<MemberGroup>(this as MemberGroup, _$identity);

  /// Serializes this MemberGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.manualMemberIds, manualMemberIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(manualMemberIds));

@override
String toString() {
  return 'MemberGroup(id: $id, name: $name, manualMemberIds: $manualMemberIds)';
}


}

/// @nodoc
abstract mixin class $MemberGroupCopyWith<$Res>  {
  factory $MemberGroupCopyWith(MemberGroup value, $Res Function(MemberGroup) _then) = _$MemberGroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> manualMemberIds
});




}
/// @nodoc
class _$MemberGroupCopyWithImpl<$Res>
    implements $MemberGroupCopyWith<$Res> {
  _$MemberGroupCopyWithImpl(this._self, this._then);

  final MemberGroup _self;
  final $Res Function(MemberGroup) _then;

/// Create a copy of MemberGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? manualMemberIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,manualMemberIds: null == manualMemberIds ? _self.manualMemberIds : manualMemberIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberGroup].
extension MemberGroupPatterns on MemberGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberGroup value)  $default,){
final _that = this;
switch (_that) {
case _MemberGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberGroup value)?  $default,){
final _that = this;
switch (_that) {
case _MemberGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<String> manualMemberIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberGroup() when $default != null:
return $default(_that.id,_that.name,_that.manualMemberIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<String> manualMemberIds)  $default,) {final _that = this;
switch (_that) {
case _MemberGroup():
return $default(_that.id,_that.name,_that.manualMemberIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<String> manualMemberIds)?  $default,) {final _that = this;
switch (_that) {
case _MemberGroup() when $default != null:
return $default(_that.id,_that.name,_that.manualMemberIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberGroup implements MemberGroup {
  const _MemberGroup({required this.id, required this.name, final  List<String> manualMemberIds = const []}): _manualMemberIds = manualMemberIds;
  factory _MemberGroup.fromJson(Map<String, dynamic> json) => _$MemberGroupFromJson(json);

@override final  String id;
@override final  String name;
 final  List<String> _manualMemberIds;
@override@JsonKey() List<String> get manualMemberIds {
  if (_manualMemberIds is EqualUnmodifiableListView) return _manualMemberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_manualMemberIds);
}


/// Create a copy of MemberGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberGroupCopyWith<_MemberGroup> get copyWith => __$MemberGroupCopyWithImpl<_MemberGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._manualMemberIds, _manualMemberIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_manualMemberIds));

@override
String toString() {
  return 'MemberGroup(id: $id, name: $name, manualMemberIds: $manualMemberIds)';
}


}

/// @nodoc
abstract mixin class _$MemberGroupCopyWith<$Res> implements $MemberGroupCopyWith<$Res> {
  factory _$MemberGroupCopyWith(_MemberGroup value, $Res Function(_MemberGroup) _then) = __$MemberGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> manualMemberIds
});




}
/// @nodoc
class __$MemberGroupCopyWithImpl<$Res>
    implements _$MemberGroupCopyWith<$Res> {
  __$MemberGroupCopyWithImpl(this._self, this._then);

  final _MemberGroup _self;
  final $Res Function(_MemberGroup) _then;

/// Create a copy of MemberGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? manualMemberIds = null,}) {
  return _then(_MemberGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,manualMemberIds: null == manualMemberIds ? _self._manualMemberIds : manualMemberIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$MemberGroupConfig {

 String get id; String get name; GroupSplitType get splitType; double? get handicapThreshold; List<MemberGroup> get groups; List<String> get voluntaryFirstGroupMemberIds;
/// Create a copy of MemberGroupConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberGroupConfigCopyWith<MemberGroupConfig> get copyWith => _$MemberGroupConfigCopyWithImpl<MemberGroupConfig>(this as MemberGroupConfig, _$identity);

  /// Serializes this MemberGroupConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberGroupConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.splitType, splitType) || other.splitType == splitType)&&(identical(other.handicapThreshold, handicapThreshold) || other.handicapThreshold == handicapThreshold)&&const DeepCollectionEquality().equals(other.groups, groups)&&const DeepCollectionEquality().equals(other.voluntaryFirstGroupMemberIds, voluntaryFirstGroupMemberIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,splitType,handicapThreshold,const DeepCollectionEquality().hash(groups),const DeepCollectionEquality().hash(voluntaryFirstGroupMemberIds));

@override
String toString() {
  return 'MemberGroupConfig(id: $id, name: $name, splitType: $splitType, handicapThreshold: $handicapThreshold, groups: $groups, voluntaryFirstGroupMemberIds: $voluntaryFirstGroupMemberIds)';
}


}

/// @nodoc
abstract mixin class $MemberGroupConfigCopyWith<$Res>  {
  factory $MemberGroupConfigCopyWith(MemberGroupConfig value, $Res Function(MemberGroupConfig) _then) = _$MemberGroupConfigCopyWithImpl;
@useResult
$Res call({
 String id, String name, GroupSplitType splitType, double? handicapThreshold, List<MemberGroup> groups, List<String> voluntaryFirstGroupMemberIds
});




}
/// @nodoc
class _$MemberGroupConfigCopyWithImpl<$Res>
    implements $MemberGroupConfigCopyWith<$Res> {
  _$MemberGroupConfigCopyWithImpl(this._self, this._then);

  final MemberGroupConfig _self;
  final $Res Function(MemberGroupConfig) _then;

/// Create a copy of MemberGroupConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? splitType = null,Object? handicapThreshold = freezed,Object? groups = null,Object? voluntaryFirstGroupMemberIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,splitType: null == splitType ? _self.splitType : splitType // ignore: cast_nullable_to_non_nullable
as GroupSplitType,handicapThreshold: freezed == handicapThreshold ? _self.handicapThreshold : handicapThreshold // ignore: cast_nullable_to_non_nullable
as double?,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<MemberGroup>,voluntaryFirstGroupMemberIds: null == voluntaryFirstGroupMemberIds ? _self.voluntaryFirstGroupMemberIds : voluntaryFirstGroupMemberIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberGroupConfig].
extension MemberGroupConfigPatterns on MemberGroupConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberGroupConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberGroupConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberGroupConfig value)  $default,){
final _that = this;
switch (_that) {
case _MemberGroupConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberGroupConfig value)?  $default,){
final _that = this;
switch (_that) {
case _MemberGroupConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  GroupSplitType splitType,  double? handicapThreshold,  List<MemberGroup> groups,  List<String> voluntaryFirstGroupMemberIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberGroupConfig() when $default != null:
return $default(_that.id,_that.name,_that.splitType,_that.handicapThreshold,_that.groups,_that.voluntaryFirstGroupMemberIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  GroupSplitType splitType,  double? handicapThreshold,  List<MemberGroup> groups,  List<String> voluntaryFirstGroupMemberIds)  $default,) {final _that = this;
switch (_that) {
case _MemberGroupConfig():
return $default(_that.id,_that.name,_that.splitType,_that.handicapThreshold,_that.groups,_that.voluntaryFirstGroupMemberIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  GroupSplitType splitType,  double? handicapThreshold,  List<MemberGroup> groups,  List<String> voluntaryFirstGroupMemberIds)?  $default,) {final _that = this;
switch (_that) {
case _MemberGroupConfig() when $default != null:
return $default(_that.id,_that.name,_that.splitType,_that.handicapThreshold,_that.groups,_that.voluntaryFirstGroupMemberIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberGroupConfig implements MemberGroupConfig {
  const _MemberGroupConfig({required this.id, required this.name, this.splitType = GroupSplitType.handicap, this.handicapThreshold, final  List<MemberGroup> groups = const [], final  List<String> voluntaryFirstGroupMemberIds = const []}): _groups = groups,_voluntaryFirstGroupMemberIds = voluntaryFirstGroupMemberIds;
  factory _MemberGroupConfig.fromJson(Map<String, dynamic> json) => _$MemberGroupConfigFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  GroupSplitType splitType;
@override final  double? handicapThreshold;
 final  List<MemberGroup> _groups;
@override@JsonKey() List<MemberGroup> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

 final  List<String> _voluntaryFirstGroupMemberIds;
@override@JsonKey() List<String> get voluntaryFirstGroupMemberIds {
  if (_voluntaryFirstGroupMemberIds is EqualUnmodifiableListView) return _voluntaryFirstGroupMemberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_voluntaryFirstGroupMemberIds);
}


/// Create a copy of MemberGroupConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberGroupConfigCopyWith<_MemberGroupConfig> get copyWith => __$MemberGroupConfigCopyWithImpl<_MemberGroupConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberGroupConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberGroupConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.splitType, splitType) || other.splitType == splitType)&&(identical(other.handicapThreshold, handicapThreshold) || other.handicapThreshold == handicapThreshold)&&const DeepCollectionEquality().equals(other._groups, _groups)&&const DeepCollectionEquality().equals(other._voluntaryFirstGroupMemberIds, _voluntaryFirstGroupMemberIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,splitType,handicapThreshold,const DeepCollectionEquality().hash(_groups),const DeepCollectionEquality().hash(_voluntaryFirstGroupMemberIds));

@override
String toString() {
  return 'MemberGroupConfig(id: $id, name: $name, splitType: $splitType, handicapThreshold: $handicapThreshold, groups: $groups, voluntaryFirstGroupMemberIds: $voluntaryFirstGroupMemberIds)';
}


}

/// @nodoc
abstract mixin class _$MemberGroupConfigCopyWith<$Res> implements $MemberGroupConfigCopyWith<$Res> {
  factory _$MemberGroupConfigCopyWith(_MemberGroupConfig value, $Res Function(_MemberGroupConfig) _then) = __$MemberGroupConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, GroupSplitType splitType, double? handicapThreshold, List<MemberGroup> groups, List<String> voluntaryFirstGroupMemberIds
});




}
/// @nodoc
class __$MemberGroupConfigCopyWithImpl<$Res>
    implements _$MemberGroupConfigCopyWith<$Res> {
  __$MemberGroupConfigCopyWithImpl(this._self, this._then);

  final _MemberGroupConfig _self;
  final $Res Function(_MemberGroupConfig) _then;

/// Create a copy of MemberGroupConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? splitType = null,Object? handicapThreshold = freezed,Object? groups = null,Object? voluntaryFirstGroupMemberIds = null,}) {
  return _then(_MemberGroupConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,splitType: null == splitType ? _self.splitType : splitType // ignore: cast_nullable_to_non_nullable
as GroupSplitType,handicapThreshold: freezed == handicapThreshold ? _self.handicapThreshold : handicapThreshold // ignore: cast_nullable_to_non_nullable
as double?,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<MemberGroup>,voluntaryFirstGroupMemberIds: null == voluntaryFirstGroupMemberIds ? _self._voluntaryFirstGroupMemberIds : voluntaryFirstGroupMemberIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
