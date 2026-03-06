// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'course_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TeeConfig {

 String get name; double get rating; int get slope; List<int> get holePars; List<int> get holeSIs; List<int> get yardages;
/// Create a copy of TeeConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeeConfigCopyWith<TeeConfig> get copyWith => _$TeeConfigCopyWithImpl<TeeConfig>(this as TeeConfig, _$identity);

  /// Serializes this TeeConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeeConfig&&(identical(other.name, name) || other.name == name)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.slope, slope) || other.slope == slope)&&const DeepCollectionEquality().equals(other.holePars, holePars)&&const DeepCollectionEquality().equals(other.holeSIs, holeSIs)&&const DeepCollectionEquality().equals(other.yardages, yardages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,rating,slope,const DeepCollectionEquality().hash(holePars),const DeepCollectionEquality().hash(holeSIs),const DeepCollectionEquality().hash(yardages));

@override
String toString() {
  return 'TeeConfig(name: $name, rating: $rating, slope: $slope, holePars: $holePars, holeSIs: $holeSIs, yardages: $yardages)';
}


}

/// @nodoc
abstract mixin class $TeeConfigCopyWith<$Res>  {
  factory $TeeConfigCopyWith(TeeConfig value, $Res Function(TeeConfig) _then) = _$TeeConfigCopyWithImpl;
@useResult
$Res call({
 String name, double rating, int slope, List<int> holePars, List<int> holeSIs, List<int> yardages
});




}
/// @nodoc
class _$TeeConfigCopyWithImpl<$Res>
    implements $TeeConfigCopyWith<$Res> {
  _$TeeConfigCopyWithImpl(this._self, this._then);

  final TeeConfig _self;
  final $Res Function(TeeConfig) _then;

/// Create a copy of TeeConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? rating = null,Object? slope = null,Object? holePars = null,Object? holeSIs = null,Object? yardages = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,slope: null == slope ? _self.slope : slope // ignore: cast_nullable_to_non_nullable
as int,holePars: null == holePars ? _self.holePars : holePars // ignore: cast_nullable_to_non_nullable
as List<int>,holeSIs: null == holeSIs ? _self.holeSIs : holeSIs // ignore: cast_nullable_to_non_nullable
as List<int>,yardages: null == yardages ? _self.yardages : yardages // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [TeeConfig].
extension TeeConfigPatterns on TeeConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeeConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeeConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeeConfig value)  $default,){
final _that = this;
switch (_that) {
case _TeeConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeeConfig value)?  $default,){
final _that = this;
switch (_that) {
case _TeeConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double rating,  int slope,  List<int> holePars,  List<int> holeSIs,  List<int> yardages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeeConfig() when $default != null:
return $default(_that.name,_that.rating,_that.slope,_that.holePars,_that.holeSIs,_that.yardages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double rating,  int slope,  List<int> holePars,  List<int> holeSIs,  List<int> yardages)  $default,) {final _that = this;
switch (_that) {
case _TeeConfig():
return $default(_that.name,_that.rating,_that.slope,_that.holePars,_that.holeSIs,_that.yardages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double rating,  int slope,  List<int> holePars,  List<int> holeSIs,  List<int> yardages)?  $default,) {final _that = this;
switch (_that) {
case _TeeConfig() when $default != null:
return $default(_that.name,_that.rating,_that.slope,_that.holePars,_that.holeSIs,_that.yardages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeeConfig implements TeeConfig {
  const _TeeConfig({required this.name, required this.rating, required this.slope, required final  List<int> holePars, required final  List<int> holeSIs, required final  List<int> yardages}): _holePars = holePars,_holeSIs = holeSIs,_yardages = yardages;
  factory _TeeConfig.fromJson(Map<String, dynamic> json) => _$TeeConfigFromJson(json);

@override final  String name;
@override final  double rating;
@override final  int slope;
 final  List<int> _holePars;
@override List<int> get holePars {
  if (_holePars is EqualUnmodifiableListView) return _holePars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_holePars);
}

 final  List<int> _holeSIs;
@override List<int> get holeSIs {
  if (_holeSIs is EqualUnmodifiableListView) return _holeSIs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_holeSIs);
}

 final  List<int> _yardages;
@override List<int> get yardages {
  if (_yardages is EqualUnmodifiableListView) return _yardages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_yardages);
}


/// Create a copy of TeeConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeeConfigCopyWith<_TeeConfig> get copyWith => __$TeeConfigCopyWithImpl<_TeeConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeeConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeeConfig&&(identical(other.name, name) || other.name == name)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.slope, slope) || other.slope == slope)&&const DeepCollectionEquality().equals(other._holePars, _holePars)&&const DeepCollectionEquality().equals(other._holeSIs, _holeSIs)&&const DeepCollectionEquality().equals(other._yardages, _yardages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,rating,slope,const DeepCollectionEquality().hash(_holePars),const DeepCollectionEquality().hash(_holeSIs),const DeepCollectionEquality().hash(_yardages));

@override
String toString() {
  return 'TeeConfig(name: $name, rating: $rating, slope: $slope, holePars: $holePars, holeSIs: $holeSIs, yardages: $yardages)';
}


}

/// @nodoc
abstract mixin class _$TeeConfigCopyWith<$Res> implements $TeeConfigCopyWith<$Res> {
  factory _$TeeConfigCopyWith(_TeeConfig value, $Res Function(_TeeConfig) _then) = __$TeeConfigCopyWithImpl;
@override @useResult
$Res call({
 String name, double rating, int slope, List<int> holePars, List<int> holeSIs, List<int> yardages
});




}
/// @nodoc
class __$TeeConfigCopyWithImpl<$Res>
    implements _$TeeConfigCopyWith<$Res> {
  __$TeeConfigCopyWithImpl(this._self, this._then);

  final _TeeConfig _self;
  final $Res Function(_TeeConfig) _then;

/// Create a copy of TeeConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? rating = null,Object? slope = null,Object? holePars = null,Object? holeSIs = null,Object? yardages = null,}) {
  return _then(_TeeConfig(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,slope: null == slope ? _self.slope : slope // ignore: cast_nullable_to_non_nullable
as int,holePars: null == holePars ? _self._holePars : holePars // ignore: cast_nullable_to_non_nullable
as List<int>,holeSIs: null == holeSIs ? _self._holeSIs : holeSIs // ignore: cast_nullable_to_non_nullable
as List<int>,yardages: null == yardages ? _self._yardages : yardages // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$CourseHole {

 int get hole; int get par; int get si; int? get yardage;
/// Create a copy of CourseHole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourseHoleCopyWith<CourseHole> get copyWith => _$CourseHoleCopyWithImpl<CourseHole>(this as CourseHole, _$identity);

  /// Serializes this CourseHole to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourseHole&&(identical(other.hole, hole) || other.hole == hole)&&(identical(other.par, par) || other.par == par)&&(identical(other.si, si) || other.si == si)&&(identical(other.yardage, yardage) || other.yardage == yardage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hole,par,si,yardage);

@override
String toString() {
  return 'CourseHole(hole: $hole, par: $par, si: $si, yardage: $yardage)';
}


}

/// @nodoc
abstract mixin class $CourseHoleCopyWith<$Res>  {
  factory $CourseHoleCopyWith(CourseHole value, $Res Function(CourseHole) _then) = _$CourseHoleCopyWithImpl;
@useResult
$Res call({
 int hole, int par, int si, int? yardage
});




}
/// @nodoc
class _$CourseHoleCopyWithImpl<$Res>
    implements $CourseHoleCopyWith<$Res> {
  _$CourseHoleCopyWithImpl(this._self, this._then);

  final CourseHole _self;
  final $Res Function(CourseHole) _then;

/// Create a copy of CourseHole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hole = null,Object? par = null,Object? si = null,Object? yardage = freezed,}) {
  return _then(_self.copyWith(
hole: null == hole ? _self.hole : hole // ignore: cast_nullable_to_non_nullable
as int,par: null == par ? _self.par : par // ignore: cast_nullable_to_non_nullable
as int,si: null == si ? _self.si : si // ignore: cast_nullable_to_non_nullable
as int,yardage: freezed == yardage ? _self.yardage : yardage // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CourseHole].
extension CourseHolePatterns on CourseHole {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CourseHole value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CourseHole() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CourseHole value)  $default,){
final _that = this;
switch (_that) {
case _CourseHole():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CourseHole value)?  $default,){
final _that = this;
switch (_that) {
case _CourseHole() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int hole,  int par,  int si,  int? yardage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CourseHole() when $default != null:
return $default(_that.hole,_that.par,_that.si,_that.yardage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int hole,  int par,  int si,  int? yardage)  $default,) {final _that = this;
switch (_that) {
case _CourseHole():
return $default(_that.hole,_that.par,_that.si,_that.yardage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int hole,  int par,  int si,  int? yardage)?  $default,) {final _that = this;
switch (_that) {
case _CourseHole() when $default != null:
return $default(_that.hole,_that.par,_that.si,_that.yardage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CourseHole implements CourseHole {
  const _CourseHole({required this.hole, required this.par, required this.si, this.yardage});
  factory _CourseHole.fromJson(Map<String, dynamic> json) => _$CourseHoleFromJson(json);

@override final  int hole;
@override final  int par;
@override final  int si;
@override final  int? yardage;

/// Create a copy of CourseHole
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourseHoleCopyWith<_CourseHole> get copyWith => __$CourseHoleCopyWithImpl<_CourseHole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourseHoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CourseHole&&(identical(other.hole, hole) || other.hole == hole)&&(identical(other.par, par) || other.par == par)&&(identical(other.si, si) || other.si == si)&&(identical(other.yardage, yardage) || other.yardage == yardage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hole,par,si,yardage);

@override
String toString() {
  return 'CourseHole(hole: $hole, par: $par, si: $si, yardage: $yardage)';
}


}

/// @nodoc
abstract mixin class _$CourseHoleCopyWith<$Res> implements $CourseHoleCopyWith<$Res> {
  factory _$CourseHoleCopyWith(_CourseHole value, $Res Function(_CourseHole) _then) = __$CourseHoleCopyWithImpl;
@override @useResult
$Res call({
 int hole, int par, int si, int? yardage
});




}
/// @nodoc
class __$CourseHoleCopyWithImpl<$Res>
    implements _$CourseHoleCopyWith<$Res> {
  __$CourseHoleCopyWithImpl(this._self, this._then);

  final _CourseHole _self;
  final $Res Function(_CourseHole) _then;

/// Create a copy of CourseHole
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hole = null,Object? par = null,Object? si = null,Object? yardage = freezed,}) {
  return _then(_CourseHole(
hole: null == hole ? _self.hole : hole // ignore: cast_nullable_to_non_nullable
as int,par: null == par ? _self.par : par // ignore: cast_nullable_to_non_nullable
as int,si: null == si ? _self.si : si // ignore: cast_nullable_to_non_nullable
as int,yardage: freezed == yardage ? _self.yardage : yardage // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$CourseConfig {

 String get name; String get address; List<TeeConfig> get tees; List<CourseHole> get holes;// Flattened/Resolved holes for the event
 double? get rating; int? get slope; int? get par; String? get selectedTeeName; bool get isGlobal;
/// Create a copy of CourseConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourseConfigCopyWith<CourseConfig> get copyWith => _$CourseConfigCopyWithImpl<CourseConfig>(this as CourseConfig, _$identity);

  /// Serializes this CourseConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourseConfig&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other.tees, tees)&&const DeepCollectionEquality().equals(other.holes, holes)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.slope, slope) || other.slope == slope)&&(identical(other.par, par) || other.par == par)&&(identical(other.selectedTeeName, selectedTeeName) || other.selectedTeeName == selectedTeeName)&&(identical(other.isGlobal, isGlobal) || other.isGlobal == isGlobal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,address,const DeepCollectionEquality().hash(tees),const DeepCollectionEquality().hash(holes),rating,slope,par,selectedTeeName,isGlobal);

@override
String toString() {
  return 'CourseConfig(name: $name, address: $address, tees: $tees, holes: $holes, rating: $rating, slope: $slope, par: $par, selectedTeeName: $selectedTeeName, isGlobal: $isGlobal)';
}


}

/// @nodoc
abstract mixin class $CourseConfigCopyWith<$Res>  {
  factory $CourseConfigCopyWith(CourseConfig value, $Res Function(CourseConfig) _then) = _$CourseConfigCopyWithImpl;
@useResult
$Res call({
 String name, String address, List<TeeConfig> tees, List<CourseHole> holes, double? rating, int? slope, int? par, String? selectedTeeName, bool isGlobal
});




}
/// @nodoc
class _$CourseConfigCopyWithImpl<$Res>
    implements $CourseConfigCopyWith<$Res> {
  _$CourseConfigCopyWithImpl(this._self, this._then);

  final CourseConfig _self;
  final $Res Function(CourseConfig) _then;

/// Create a copy of CourseConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? address = null,Object? tees = null,Object? holes = null,Object? rating = freezed,Object? slope = freezed,Object? par = freezed,Object? selectedTeeName = freezed,Object? isGlobal = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,tees: null == tees ? _self.tees : tees // ignore: cast_nullable_to_non_nullable
as List<TeeConfig>,holes: null == holes ? _self.holes : holes // ignore: cast_nullable_to_non_nullable
as List<CourseHole>,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,slope: freezed == slope ? _self.slope : slope // ignore: cast_nullable_to_non_nullable
as int?,par: freezed == par ? _self.par : par // ignore: cast_nullable_to_non_nullable
as int?,selectedTeeName: freezed == selectedTeeName ? _self.selectedTeeName : selectedTeeName // ignore: cast_nullable_to_non_nullable
as String?,isGlobal: null == isGlobal ? _self.isGlobal : isGlobal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CourseConfig].
extension CourseConfigPatterns on CourseConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CourseConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CourseConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CourseConfig value)  $default,){
final _that = this;
switch (_that) {
case _CourseConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CourseConfig value)?  $default,){
final _that = this;
switch (_that) {
case _CourseConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String address,  List<TeeConfig> tees,  List<CourseHole> holes,  double? rating,  int? slope,  int? par,  String? selectedTeeName,  bool isGlobal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CourseConfig() when $default != null:
return $default(_that.name,_that.address,_that.tees,_that.holes,_that.rating,_that.slope,_that.par,_that.selectedTeeName,_that.isGlobal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String address,  List<TeeConfig> tees,  List<CourseHole> holes,  double? rating,  int? slope,  int? par,  String? selectedTeeName,  bool isGlobal)  $default,) {final _that = this;
switch (_that) {
case _CourseConfig():
return $default(_that.name,_that.address,_that.tees,_that.holes,_that.rating,_that.slope,_that.par,_that.selectedTeeName,_that.isGlobal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String address,  List<TeeConfig> tees,  List<CourseHole> holes,  double? rating,  int? slope,  int? par,  String? selectedTeeName,  bool isGlobal)?  $default,) {final _that = this;
switch (_that) {
case _CourseConfig() when $default != null:
return $default(_that.name,_that.address,_that.tees,_that.holes,_that.rating,_that.slope,_that.par,_that.selectedTeeName,_that.isGlobal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CourseConfig implements CourseConfig {
  const _CourseConfig({this.name = '', this.address = '', final  List<TeeConfig> tees = const [], final  List<CourseHole> holes = const [], this.rating, this.slope, this.par, this.selectedTeeName, this.isGlobal = true}): _tees = tees,_holes = holes;
  factory _CourseConfig.fromJson(Map<String, dynamic> json) => _$CourseConfigFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  String address;
 final  List<TeeConfig> _tees;
@override@JsonKey() List<TeeConfig> get tees {
  if (_tees is EqualUnmodifiableListView) return _tees;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tees);
}

 final  List<CourseHole> _holes;
@override@JsonKey() List<CourseHole> get holes {
  if (_holes is EqualUnmodifiableListView) return _holes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_holes);
}

// Flattened/Resolved holes for the event
@override final  double? rating;
@override final  int? slope;
@override final  int? par;
@override final  String? selectedTeeName;
@override@JsonKey() final  bool isGlobal;

/// Create a copy of CourseConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourseConfigCopyWith<_CourseConfig> get copyWith => __$CourseConfigCopyWithImpl<_CourseConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourseConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CourseConfig&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other._tees, _tees)&&const DeepCollectionEquality().equals(other._holes, _holes)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.slope, slope) || other.slope == slope)&&(identical(other.par, par) || other.par == par)&&(identical(other.selectedTeeName, selectedTeeName) || other.selectedTeeName == selectedTeeName)&&(identical(other.isGlobal, isGlobal) || other.isGlobal == isGlobal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,address,const DeepCollectionEquality().hash(_tees),const DeepCollectionEquality().hash(_holes),rating,slope,par,selectedTeeName,isGlobal);

@override
String toString() {
  return 'CourseConfig(name: $name, address: $address, tees: $tees, holes: $holes, rating: $rating, slope: $slope, par: $par, selectedTeeName: $selectedTeeName, isGlobal: $isGlobal)';
}


}

/// @nodoc
abstract mixin class _$CourseConfigCopyWith<$Res> implements $CourseConfigCopyWith<$Res> {
  factory _$CourseConfigCopyWith(_CourseConfig value, $Res Function(_CourseConfig) _then) = __$CourseConfigCopyWithImpl;
@override @useResult
$Res call({
 String name, String address, List<TeeConfig> tees, List<CourseHole> holes, double? rating, int? slope, int? par, String? selectedTeeName, bool isGlobal
});




}
/// @nodoc
class __$CourseConfigCopyWithImpl<$Res>
    implements _$CourseConfigCopyWith<$Res> {
  __$CourseConfigCopyWithImpl(this._self, this._then);

  final _CourseConfig _self;
  final $Res Function(_CourseConfig) _then;

/// Create a copy of CourseConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? address = null,Object? tees = null,Object? holes = null,Object? rating = freezed,Object? slope = freezed,Object? par = freezed,Object? selectedTeeName = freezed,Object? isGlobal = null,}) {
  return _then(_CourseConfig(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,tees: null == tees ? _self._tees : tees // ignore: cast_nullable_to_non_nullable
as List<TeeConfig>,holes: null == holes ? _self._holes : holes // ignore: cast_nullable_to_non_nullable
as List<CourseHole>,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,slope: freezed == slope ? _self.slope : slope // ignore: cast_nullable_to_non_nullable
as int?,par: freezed == par ? _self.par : par // ignore: cast_nullable_to_non_nullable
as int?,selectedTeeName: freezed == selectedTeeName ? _self.selectedTeeName : selectedTeeName // ignore: cast_nullable_to_non_nullable
as String?,isGlobal: null == isGlobal ? _self.isGlobal : isGlobal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
