// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Member {

 String get id; String get firstName; String get lastName; String get email; String? get phone; String? get address; String? get bio; String? get avatarUrl; double get handicap; String? get whsNumber; bool get isHandicapLocked; MemberRole get role; bool get hasPaid; bool get isArchived;
/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberCopyWith<Member> get copyWith => _$MemberCopyWithImpl<Member>(this as Member, _$identity);

  /// Serializes this Member to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Member&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.handicap, handicap) || other.handicap == handicap)&&(identical(other.whsNumber, whsNumber) || other.whsNumber == whsNumber)&&(identical(other.isHandicapLocked, isHandicapLocked) || other.isHandicapLocked == isHandicapLocked)&&(identical(other.role, role) || other.role == role)&&(identical(other.hasPaid, hasPaid) || other.hasPaid == hasPaid)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email,phone,address,bio,avatarUrl,handicap,whsNumber,isHandicapLocked,role,hasPaid,isArchived);

@override
String toString() {
  return 'Member(id: $id, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, address: $address, bio: $bio, avatarUrl: $avatarUrl, handicap: $handicap, whsNumber: $whsNumber, isHandicapLocked: $isHandicapLocked, role: $role, hasPaid: $hasPaid, isArchived: $isArchived)';
}


}

/// @nodoc
abstract mixin class $MemberCopyWith<$Res>  {
  factory $MemberCopyWith(Member value, $Res Function(Member) _then) = _$MemberCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, String lastName, String email, String? phone, String? address, String? bio, String? avatarUrl, double handicap, String? whsNumber, bool isHandicapLocked, MemberRole role, bool hasPaid, bool isArchived
});




}
/// @nodoc
class _$MemberCopyWithImpl<$Res>
    implements $MemberCopyWith<$Res> {
  _$MemberCopyWithImpl(this._self, this._then);

  final Member _self;
  final $Res Function(Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? phone = freezed,Object? address = freezed,Object? bio = freezed,Object? avatarUrl = freezed,Object? handicap = null,Object? whsNumber = freezed,Object? isHandicapLocked = null,Object? role = null,Object? hasPaid = null,Object? isArchived = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,handicap: null == handicap ? _self.handicap : handicap // ignore: cast_nullable_to_non_nullable
as double,whsNumber: freezed == whsNumber ? _self.whsNumber : whsNumber // ignore: cast_nullable_to_non_nullable
as String?,isHandicapLocked: null == isHandicapLocked ? _self.isHandicapLocked : isHandicapLocked // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,hasPaid: null == hasPaid ? _self.hasPaid : hasPaid // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Member].
extension MemberPatterns on Member {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Member value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Member() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Member value)  $default,){
final _that = this;
switch (_that) {
case _Member():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Member value)?  $default,){
final _that = this;
switch (_that) {
case _Member() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String email,  String? phone,  String? address,  String? bio,  String? avatarUrl,  double handicap,  String? whsNumber,  bool isHandicapLocked,  MemberRole role,  bool hasPaid,  bool isArchived)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.phone,_that.address,_that.bio,_that.avatarUrl,_that.handicap,_that.whsNumber,_that.isHandicapLocked,_that.role,_that.hasPaid,_that.isArchived);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String email,  String? phone,  String? address,  String? bio,  String? avatarUrl,  double handicap,  String? whsNumber,  bool isHandicapLocked,  MemberRole role,  bool hasPaid,  bool isArchived)  $default,) {final _that = this;
switch (_that) {
case _Member():
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.phone,_that.address,_that.bio,_that.avatarUrl,_that.handicap,_that.whsNumber,_that.isHandicapLocked,_that.role,_that.hasPaid,_that.isArchived);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String firstName,  String lastName,  String email,  String? phone,  String? address,  String? bio,  String? avatarUrl,  double handicap,  String? whsNumber,  bool isHandicapLocked,  MemberRole role,  bool hasPaid,  bool isArchived)?  $default,) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.phone,_that.address,_that.bio,_that.avatarUrl,_that.handicap,_that.whsNumber,_that.isHandicapLocked,_that.role,_that.hasPaid,_that.isArchived);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Member extends Member {
  const _Member({required this.id, required this.firstName, required this.lastName, required this.email, this.phone, this.address, this.bio, this.avatarUrl, this.handicap = 0.0, this.whsNumber, this.isHandicapLocked = false, this.role = MemberRole.member, this.hasPaid = false, this.isArchived = false}): super._();
  factory _Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

@override final  String id;
@override final  String firstName;
@override final  String lastName;
@override final  String email;
@override final  String? phone;
@override final  String? address;
@override final  String? bio;
@override final  String? avatarUrl;
@override@JsonKey() final  double handicap;
@override final  String? whsNumber;
@override@JsonKey() final  bool isHandicapLocked;
@override@JsonKey() final  MemberRole role;
@override@JsonKey() final  bool hasPaid;
@override@JsonKey() final  bool isArchived;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberCopyWith<_Member> get copyWith => __$MemberCopyWithImpl<_Member>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Member&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.handicap, handicap) || other.handicap == handicap)&&(identical(other.whsNumber, whsNumber) || other.whsNumber == whsNumber)&&(identical(other.isHandicapLocked, isHandicapLocked) || other.isHandicapLocked == isHandicapLocked)&&(identical(other.role, role) || other.role == role)&&(identical(other.hasPaid, hasPaid) || other.hasPaid == hasPaid)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email,phone,address,bio,avatarUrl,handicap,whsNumber,isHandicapLocked,role,hasPaid,isArchived);

@override
String toString() {
  return 'Member(id: $id, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, address: $address, bio: $bio, avatarUrl: $avatarUrl, handicap: $handicap, whsNumber: $whsNumber, isHandicapLocked: $isHandicapLocked, role: $role, hasPaid: $hasPaid, isArchived: $isArchived)';
}


}

/// @nodoc
abstract mixin class _$MemberCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$MemberCopyWith(_Member value, $Res Function(_Member) _then) = __$MemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, String lastName, String email, String? phone, String? address, String? bio, String? avatarUrl, double handicap, String? whsNumber, bool isHandicapLocked, MemberRole role, bool hasPaid, bool isArchived
});




}
/// @nodoc
class __$MemberCopyWithImpl<$Res>
    implements _$MemberCopyWith<$Res> {
  __$MemberCopyWithImpl(this._self, this._then);

  final _Member _self;
  final $Res Function(_Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? phone = freezed,Object? address = freezed,Object? bio = freezed,Object? avatarUrl = freezed,Object? handicap = null,Object? whsNumber = freezed,Object? isHandicapLocked = null,Object? role = null,Object? hasPaid = null,Object? isArchived = null,}) {
  return _then(_Member(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,handicap: null == handicap ? _self.handicap : handicap // ignore: cast_nullable_to_non_nullable
as double,whsNumber: freezed == whsNumber ? _self.whsNumber : whsNumber // ignore: cast_nullable_to_non_nullable
as String?,isHandicapLocked: null == isHandicapLocked ? _self.isHandicapLocked : isHandicapLocked // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,hasPaid: null == hasPaid ? _self.hasPaid : hasPaid // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
