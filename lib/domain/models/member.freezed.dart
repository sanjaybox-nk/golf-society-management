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

 String get id; String get firstName; String get lastName; String get email; String? get nickname; String? get phone; String? get address; String? get bio; String? get avatarUrl; double get handicap; String? get handicapId; bool get isHandicapLocked; MemberRole get role; String? get societyRole;// [NEW]
 MemberStatus get status; bool get hasPaid; bool get isArchived; double get accountCredit;// Account credit for vouchers or overpayments
 String? get gender;// [NEW] 'Male' or 'Female'
@OptionalTimestampConverter() DateTime? get joinedDate;@OptionalTimestampConverter() DateTime? get membershipEndDate;// [NEW] Track annual renewal term
 MemberRenewalStatus get renewalStatus;// [NEW] Member renewal choice
 bool get allowSocialEventsOnly;// [NEW] Master switch for suspended members
@OptionalTimestampConverter() DateTime? get lastNudgedAt;// [NEW] Track recent renewal nudges
 int get nudgeCount;
/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberCopyWith<Member> get copyWith => _$MemberCopyWithImpl<Member>(this as Member, _$identity);

  /// Serializes this Member to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Member&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.handicap, handicap) || other.handicap == handicap)&&(identical(other.handicapId, handicapId) || other.handicapId == handicapId)&&(identical(other.isHandicapLocked, isHandicapLocked) || other.isHandicapLocked == isHandicapLocked)&&(identical(other.role, role) || other.role == role)&&(identical(other.societyRole, societyRole) || other.societyRole == societyRole)&&(identical(other.status, status) || other.status == status)&&(identical(other.hasPaid, hasPaid) || other.hasPaid == hasPaid)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.accountCredit, accountCredit) || other.accountCredit == accountCredit)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.joinedDate, joinedDate) || other.joinedDate == joinedDate)&&(identical(other.membershipEndDate, membershipEndDate) || other.membershipEndDate == membershipEndDate)&&(identical(other.renewalStatus, renewalStatus) || other.renewalStatus == renewalStatus)&&(identical(other.allowSocialEventsOnly, allowSocialEventsOnly) || other.allowSocialEventsOnly == allowSocialEventsOnly)&&(identical(other.lastNudgedAt, lastNudgedAt) || other.lastNudgedAt == lastNudgedAt)&&(identical(other.nudgeCount, nudgeCount) || other.nudgeCount == nudgeCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,firstName,lastName,email,nickname,phone,address,bio,avatarUrl,handicap,handicapId,isHandicapLocked,role,societyRole,status,hasPaid,isArchived,accountCredit,gender,joinedDate,membershipEndDate,renewalStatus,allowSocialEventsOnly,lastNudgedAt,nudgeCount]);

@override
String toString() {
  return 'Member(id: $id, firstName: $firstName, lastName: $lastName, email: $email, nickname: $nickname, phone: $phone, address: $address, bio: $bio, avatarUrl: $avatarUrl, handicap: $handicap, handicapId: $handicapId, isHandicapLocked: $isHandicapLocked, role: $role, societyRole: $societyRole, status: $status, hasPaid: $hasPaid, isArchived: $isArchived, accountCredit: $accountCredit, gender: $gender, joinedDate: $joinedDate, membershipEndDate: $membershipEndDate, renewalStatus: $renewalStatus, allowSocialEventsOnly: $allowSocialEventsOnly, lastNudgedAt: $lastNudgedAt, nudgeCount: $nudgeCount)';
}


}

/// @nodoc
abstract mixin class $MemberCopyWith<$Res>  {
  factory $MemberCopyWith(Member value, $Res Function(Member) _then) = _$MemberCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, String lastName, String email, String? nickname, String? phone, String? address, String? bio, String? avatarUrl, double handicap, String? handicapId, bool isHandicapLocked, MemberRole role, String? societyRole, MemberStatus status, bool hasPaid, bool isArchived, double accountCredit, String? gender,@OptionalTimestampConverter() DateTime? joinedDate,@OptionalTimestampConverter() DateTime? membershipEndDate, MemberRenewalStatus renewalStatus, bool allowSocialEventsOnly,@OptionalTimestampConverter() DateTime? lastNudgedAt, int nudgeCount
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? nickname = freezed,Object? phone = freezed,Object? address = freezed,Object? bio = freezed,Object? avatarUrl = freezed,Object? handicap = null,Object? handicapId = freezed,Object? isHandicapLocked = null,Object? role = null,Object? societyRole = freezed,Object? status = null,Object? hasPaid = null,Object? isArchived = null,Object? accountCredit = null,Object? gender = freezed,Object? joinedDate = freezed,Object? membershipEndDate = freezed,Object? renewalStatus = null,Object? allowSocialEventsOnly = null,Object? lastNudgedAt = freezed,Object? nudgeCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,handicap: null == handicap ? _self.handicap : handicap // ignore: cast_nullable_to_non_nullable
as double,handicapId: freezed == handicapId ? _self.handicapId : handicapId // ignore: cast_nullable_to_non_nullable
as String?,isHandicapLocked: null == isHandicapLocked ? _self.isHandicapLocked : isHandicapLocked // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,societyRole: freezed == societyRole ? _self.societyRole : societyRole // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,hasPaid: null == hasPaid ? _self.hasPaid : hasPaid // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,accountCredit: null == accountCredit ? _self.accountCredit : accountCredit // ignore: cast_nullable_to_non_nullable
as double,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,joinedDate: freezed == joinedDate ? _self.joinedDate : joinedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,membershipEndDate: freezed == membershipEndDate ? _self.membershipEndDate : membershipEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,renewalStatus: null == renewalStatus ? _self.renewalStatus : renewalStatus // ignore: cast_nullable_to_non_nullable
as MemberRenewalStatus,allowSocialEventsOnly: null == allowSocialEventsOnly ? _self.allowSocialEventsOnly : allowSocialEventsOnly // ignore: cast_nullable_to_non_nullable
as bool,lastNudgedAt: freezed == lastNudgedAt ? _self.lastNudgedAt : lastNudgedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nudgeCount: null == nudgeCount ? _self.nudgeCount : nudgeCount // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String email,  String? nickname,  String? phone,  String? address,  String? bio,  String? avatarUrl,  double handicap,  String? handicapId,  bool isHandicapLocked,  MemberRole role,  String? societyRole,  MemberStatus status,  bool hasPaid,  bool isArchived,  double accountCredit,  String? gender, @OptionalTimestampConverter()  DateTime? joinedDate, @OptionalTimestampConverter()  DateTime? membershipEndDate,  MemberRenewalStatus renewalStatus,  bool allowSocialEventsOnly, @OptionalTimestampConverter()  DateTime? lastNudgedAt,  int nudgeCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.nickname,_that.phone,_that.address,_that.bio,_that.avatarUrl,_that.handicap,_that.handicapId,_that.isHandicapLocked,_that.role,_that.societyRole,_that.status,_that.hasPaid,_that.isArchived,_that.accountCredit,_that.gender,_that.joinedDate,_that.membershipEndDate,_that.renewalStatus,_that.allowSocialEventsOnly,_that.lastNudgedAt,_that.nudgeCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String email,  String? nickname,  String? phone,  String? address,  String? bio,  String? avatarUrl,  double handicap,  String? handicapId,  bool isHandicapLocked,  MemberRole role,  String? societyRole,  MemberStatus status,  bool hasPaid,  bool isArchived,  double accountCredit,  String? gender, @OptionalTimestampConverter()  DateTime? joinedDate, @OptionalTimestampConverter()  DateTime? membershipEndDate,  MemberRenewalStatus renewalStatus,  bool allowSocialEventsOnly, @OptionalTimestampConverter()  DateTime? lastNudgedAt,  int nudgeCount)  $default,) {final _that = this;
switch (_that) {
case _Member():
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.nickname,_that.phone,_that.address,_that.bio,_that.avatarUrl,_that.handicap,_that.handicapId,_that.isHandicapLocked,_that.role,_that.societyRole,_that.status,_that.hasPaid,_that.isArchived,_that.accountCredit,_that.gender,_that.joinedDate,_that.membershipEndDate,_that.renewalStatus,_that.allowSocialEventsOnly,_that.lastNudgedAt,_that.nudgeCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String firstName,  String lastName,  String email,  String? nickname,  String? phone,  String? address,  String? bio,  String? avatarUrl,  double handicap,  String? handicapId,  bool isHandicapLocked,  MemberRole role,  String? societyRole,  MemberStatus status,  bool hasPaid,  bool isArchived,  double accountCredit,  String? gender, @OptionalTimestampConverter()  DateTime? joinedDate, @OptionalTimestampConverter()  DateTime? membershipEndDate,  MemberRenewalStatus renewalStatus,  bool allowSocialEventsOnly, @OptionalTimestampConverter()  DateTime? lastNudgedAt,  int nudgeCount)?  $default,) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.nickname,_that.phone,_that.address,_that.bio,_that.avatarUrl,_that.handicap,_that.handicapId,_that.isHandicapLocked,_that.role,_that.societyRole,_that.status,_that.hasPaid,_that.isArchived,_that.accountCredit,_that.gender,_that.joinedDate,_that.membershipEndDate,_that.renewalStatus,_that.allowSocialEventsOnly,_that.lastNudgedAt,_that.nudgeCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Member extends Member {
  const _Member({required this.id, required this.firstName, required this.lastName, required this.email, this.nickname, this.phone, this.address, this.bio, this.avatarUrl, this.handicap = 0.0, this.handicapId, this.isHandicapLocked = false, this.role = MemberRole.member, this.societyRole, this.status = MemberStatus.member, this.hasPaid = false, this.isArchived = false, this.accountCredit = 0.0, this.gender, @OptionalTimestampConverter() this.joinedDate, @OptionalTimestampConverter() this.membershipEndDate, this.renewalStatus = MemberRenewalStatus.none, this.allowSocialEventsOnly = false, @OptionalTimestampConverter() this.lastNudgedAt, this.nudgeCount = 0}): super._();
  factory _Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

@override final  String id;
@override final  String firstName;
@override final  String lastName;
@override final  String email;
@override final  String? nickname;
@override final  String? phone;
@override final  String? address;
@override final  String? bio;
@override final  String? avatarUrl;
@override@JsonKey() final  double handicap;
@override final  String? handicapId;
@override@JsonKey() final  bool isHandicapLocked;
@override@JsonKey() final  MemberRole role;
@override final  String? societyRole;
// [NEW]
@override@JsonKey() final  MemberStatus status;
@override@JsonKey() final  bool hasPaid;
@override@JsonKey() final  bool isArchived;
@override@JsonKey() final  double accountCredit;
// Account credit for vouchers or overpayments
@override final  String? gender;
// [NEW] 'Male' or 'Female'
@override@OptionalTimestampConverter() final  DateTime? joinedDate;
@override@OptionalTimestampConverter() final  DateTime? membershipEndDate;
// [NEW] Track annual renewal term
@override@JsonKey() final  MemberRenewalStatus renewalStatus;
// [NEW] Member renewal choice
@override@JsonKey() final  bool allowSocialEventsOnly;
// [NEW] Master switch for suspended members
@override@OptionalTimestampConverter() final  DateTime? lastNudgedAt;
// [NEW] Track recent renewal nudges
@override@JsonKey() final  int nudgeCount;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Member&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.handicap, handicap) || other.handicap == handicap)&&(identical(other.handicapId, handicapId) || other.handicapId == handicapId)&&(identical(other.isHandicapLocked, isHandicapLocked) || other.isHandicapLocked == isHandicapLocked)&&(identical(other.role, role) || other.role == role)&&(identical(other.societyRole, societyRole) || other.societyRole == societyRole)&&(identical(other.status, status) || other.status == status)&&(identical(other.hasPaid, hasPaid) || other.hasPaid == hasPaid)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.accountCredit, accountCredit) || other.accountCredit == accountCredit)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.joinedDate, joinedDate) || other.joinedDate == joinedDate)&&(identical(other.membershipEndDate, membershipEndDate) || other.membershipEndDate == membershipEndDate)&&(identical(other.renewalStatus, renewalStatus) || other.renewalStatus == renewalStatus)&&(identical(other.allowSocialEventsOnly, allowSocialEventsOnly) || other.allowSocialEventsOnly == allowSocialEventsOnly)&&(identical(other.lastNudgedAt, lastNudgedAt) || other.lastNudgedAt == lastNudgedAt)&&(identical(other.nudgeCount, nudgeCount) || other.nudgeCount == nudgeCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,firstName,lastName,email,nickname,phone,address,bio,avatarUrl,handicap,handicapId,isHandicapLocked,role,societyRole,status,hasPaid,isArchived,accountCredit,gender,joinedDate,membershipEndDate,renewalStatus,allowSocialEventsOnly,lastNudgedAt,nudgeCount]);

@override
String toString() {
  return 'Member(id: $id, firstName: $firstName, lastName: $lastName, email: $email, nickname: $nickname, phone: $phone, address: $address, bio: $bio, avatarUrl: $avatarUrl, handicap: $handicap, handicapId: $handicapId, isHandicapLocked: $isHandicapLocked, role: $role, societyRole: $societyRole, status: $status, hasPaid: $hasPaid, isArchived: $isArchived, accountCredit: $accountCredit, gender: $gender, joinedDate: $joinedDate, membershipEndDate: $membershipEndDate, renewalStatus: $renewalStatus, allowSocialEventsOnly: $allowSocialEventsOnly, lastNudgedAt: $lastNudgedAt, nudgeCount: $nudgeCount)';
}


}

/// @nodoc
abstract mixin class _$MemberCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$MemberCopyWith(_Member value, $Res Function(_Member) _then) = __$MemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, String lastName, String email, String? nickname, String? phone, String? address, String? bio, String? avatarUrl, double handicap, String? handicapId, bool isHandicapLocked, MemberRole role, String? societyRole, MemberStatus status, bool hasPaid, bool isArchived, double accountCredit, String? gender,@OptionalTimestampConverter() DateTime? joinedDate,@OptionalTimestampConverter() DateTime? membershipEndDate, MemberRenewalStatus renewalStatus, bool allowSocialEventsOnly,@OptionalTimestampConverter() DateTime? lastNudgedAt, int nudgeCount
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? nickname = freezed,Object? phone = freezed,Object? address = freezed,Object? bio = freezed,Object? avatarUrl = freezed,Object? handicap = null,Object? handicapId = freezed,Object? isHandicapLocked = null,Object? role = null,Object? societyRole = freezed,Object? status = null,Object? hasPaid = null,Object? isArchived = null,Object? accountCredit = null,Object? gender = freezed,Object? joinedDate = freezed,Object? membershipEndDate = freezed,Object? renewalStatus = null,Object? allowSocialEventsOnly = null,Object? lastNudgedAt = freezed,Object? nudgeCount = null,}) {
  return _then(_Member(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,handicap: null == handicap ? _self.handicap : handicap // ignore: cast_nullable_to_non_nullable
as double,handicapId: freezed == handicapId ? _self.handicapId : handicapId // ignore: cast_nullable_to_non_nullable
as String?,isHandicapLocked: null == isHandicapLocked ? _self.isHandicapLocked : isHandicapLocked // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,societyRole: freezed == societyRole ? _self.societyRole : societyRole // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,hasPaid: null == hasPaid ? _self.hasPaid : hasPaid // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,accountCredit: null == accountCredit ? _self.accountCredit : accountCredit // ignore: cast_nullable_to_non_nullable
as double,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,joinedDate: freezed == joinedDate ? _self.joinedDate : joinedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,membershipEndDate: freezed == membershipEndDate ? _self.membershipEndDate : membershipEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,renewalStatus: null == renewalStatus ? _self.renewalStatus : renewalStatus // ignore: cast_nullable_to_non_nullable
as MemberRenewalStatus,allowSocialEventsOnly: null == allowSocialEventsOnly ? _self.allowSocialEventsOnly : allowSocialEventsOnly // ignore: cast_nullable_to_non_nullable
as bool,lastNudgedAt: freezed == lastNudgedAt ? _self.lastNudgedAt : lastNudgedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nudgeCount: null == nudgeCount ? _self.nudgeCount : nudgeCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
