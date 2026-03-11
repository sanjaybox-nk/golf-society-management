// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'golf_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventNote {

 String? get title; String get content; String? get imageUrl;
/// Create a copy of EventNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventNoteCopyWith<EventNote> get copyWith => _$EventNoteCopyWithImpl<EventNote>(this as EventNote, _$identity);

  /// Serializes this EventNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventNote&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,content,imageUrl);

@override
String toString() {
  return 'EventNote(title: $title, content: $content, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $EventNoteCopyWith<$Res>  {
  factory $EventNoteCopyWith(EventNote value, $Res Function(EventNote) _then) = _$EventNoteCopyWithImpl;
@useResult
$Res call({
 String? title, String content, String? imageUrl
});




}
/// @nodoc
class _$EventNoteCopyWithImpl<$Res>
    implements $EventNoteCopyWith<$Res> {
  _$EventNoteCopyWithImpl(this._self, this._then);

  final EventNote _self;
  final $Res Function(EventNote) _then;

/// Create a copy of EventNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? content = null,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventNote].
extension EventNotePatterns on EventNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventNote value)  $default,){
final _that = this;
switch (_that) {
case _EventNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventNote value)?  $default,){
final _that = this;
switch (_that) {
case _EventNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String content,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventNote() when $default != null:
return $default(_that.title,_that.content,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String content,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _EventNote():
return $default(_that.title,_that.content,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String content,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _EventNote() when $default != null:
return $default(_that.title,_that.content,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventNote implements EventNote {
  const _EventNote({this.title, required this.content, this.imageUrl});
  factory _EventNote.fromJson(Map<String, dynamic> json) => _$EventNoteFromJson(json);

@override final  String? title;
@override final  String content;
@override final  String? imageUrl;

/// Create a copy of EventNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventNoteCopyWith<_EventNote> get copyWith => __$EventNoteCopyWithImpl<_EventNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventNote&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,content,imageUrl);

@override
String toString() {
  return 'EventNote(title: $title, content: $content, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$EventNoteCopyWith<$Res> implements $EventNoteCopyWith<$Res> {
  factory _$EventNoteCopyWith(_EventNote value, $Res Function(_EventNote) _then) = __$EventNoteCopyWithImpl;
@override @useResult
$Res call({
 String? title, String content, String? imageUrl
});




}
/// @nodoc
class __$EventNoteCopyWithImpl<$Res>
    implements _$EventNoteCopyWith<$Res> {
  __$EventNoteCopyWithImpl(this._self, this._then);

  final _EventNote _self;
  final $Res Function(_EventNote) _then;

/// Create a copy of EventNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? content = null,Object? imageUrl = freezed,}) {
  return _then(_EventNote(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EventExpense {

 String get id; String get label; double get amount; String get category;// Venue, Food, Prize, Misc
@OptionalTimestampConverter() DateTime? get date;
/// Create a copy of EventExpense
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventExpenseCopyWith<EventExpense> get copyWith => _$EventExpenseCopyWithImpl<EventExpense>(this as EventExpense, _$identity);

  /// Serializes this EventExpense to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventExpense&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.category, category) || other.category == category)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,amount,category,date);

@override
String toString() {
  return 'EventExpense(id: $id, label: $label, amount: $amount, category: $category, date: $date)';
}


}

/// @nodoc
abstract mixin class $EventExpenseCopyWith<$Res>  {
  factory $EventExpenseCopyWith(EventExpense value, $Res Function(EventExpense) _then) = _$EventExpenseCopyWithImpl;
@useResult
$Res call({
 String id, String label, double amount, String category,@OptionalTimestampConverter() DateTime? date
});




}
/// @nodoc
class _$EventExpenseCopyWithImpl<$Res>
    implements $EventExpenseCopyWith<$Res> {
  _$EventExpenseCopyWithImpl(this._self, this._then);

  final EventExpense _self;
  final $Res Function(EventExpense) _then;

/// Create a copy of EventExpense
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? amount = null,Object? category = null,Object? date = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventExpense].
extension EventExpensePatterns on EventExpense {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventExpense value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventExpense() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventExpense value)  $default,){
final _that = this;
switch (_that) {
case _EventExpense():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventExpense value)?  $default,){
final _that = this;
switch (_that) {
case _EventExpense() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  double amount,  String category, @OptionalTimestampConverter()  DateTime? date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventExpense() when $default != null:
return $default(_that.id,_that.label,_that.amount,_that.category,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  double amount,  String category, @OptionalTimestampConverter()  DateTime? date)  $default,) {final _that = this;
switch (_that) {
case _EventExpense():
return $default(_that.id,_that.label,_that.amount,_that.category,_that.date);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  double amount,  String category, @OptionalTimestampConverter()  DateTime? date)?  $default,) {final _that = this;
switch (_that) {
case _EventExpense() when $default != null:
return $default(_that.id,_that.label,_that.amount,_that.category,_that.date);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventExpense implements EventExpense {
  const _EventExpense({required this.id, required this.label, required this.amount, this.category = 'Misc', @OptionalTimestampConverter() this.date});
  factory _EventExpense.fromJson(Map<String, dynamic> json) => _$EventExpenseFromJson(json);

@override final  String id;
@override final  String label;
@override final  double amount;
@override@JsonKey() final  String category;
// Venue, Food, Prize, Misc
@override@OptionalTimestampConverter() final  DateTime? date;

/// Create a copy of EventExpense
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventExpenseCopyWith<_EventExpense> get copyWith => __$EventExpenseCopyWithImpl<_EventExpense>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventExpenseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventExpense&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.category, category) || other.category == category)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,amount,category,date);

@override
String toString() {
  return 'EventExpense(id: $id, label: $label, amount: $amount, category: $category, date: $date)';
}


}

/// @nodoc
abstract mixin class _$EventExpenseCopyWith<$Res> implements $EventExpenseCopyWith<$Res> {
  factory _$EventExpenseCopyWith(_EventExpense value, $Res Function(_EventExpense) _then) = __$EventExpenseCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, double amount, String category,@OptionalTimestampConverter() DateTime? date
});




}
/// @nodoc
class __$EventExpenseCopyWithImpl<$Res>
    implements _$EventExpenseCopyWith<$Res> {
  __$EventExpenseCopyWithImpl(this._self, this._then);

  final _EventExpense _self;
  final $Res Function(_EventExpense) _then;

/// Create a copy of EventExpense
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? amount = null,Object? category = null,Object? date = freezed,}) {
  return _then(_EventExpense(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$EventAward {

 String get id; String get label; String get type;// Cup, Cash, Voucher
 double get value; String? get winnerId; String? get winnerName;
/// Create a copy of EventAward
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventAwardCopyWith<EventAward> get copyWith => _$EventAwardCopyWithImpl<EventAward>(this as EventAward, _$identity);

  /// Serializes this EventAward to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventAward&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.winnerName, winnerName) || other.winnerName == winnerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,type,value,winnerId,winnerName);

@override
String toString() {
  return 'EventAward(id: $id, label: $label, type: $type, value: $value, winnerId: $winnerId, winnerName: $winnerName)';
}


}

/// @nodoc
abstract mixin class $EventAwardCopyWith<$Res>  {
  factory $EventAwardCopyWith(EventAward value, $Res Function(EventAward) _then) = _$EventAwardCopyWithImpl;
@useResult
$Res call({
 String id, String label, String type, double value, String? winnerId, String? winnerName
});




}
/// @nodoc
class _$EventAwardCopyWithImpl<$Res>
    implements $EventAwardCopyWith<$Res> {
  _$EventAwardCopyWithImpl(this._self, this._then);

  final EventAward _self;
  final $Res Function(EventAward) _then;

/// Create a copy of EventAward
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? type = null,Object? value = null,Object? winnerId = freezed,Object? winnerName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,winnerName: freezed == winnerName ? _self.winnerName : winnerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventAward].
extension EventAwardPatterns on EventAward {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventAward value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventAward() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventAward value)  $default,){
final _that = this;
switch (_that) {
case _EventAward():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventAward value)?  $default,){
final _that = this;
switch (_that) {
case _EventAward() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String type,  double value,  String? winnerId,  String? winnerName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventAward() when $default != null:
return $default(_that.id,_that.label,_that.type,_that.value,_that.winnerId,_that.winnerName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String type,  double value,  String? winnerId,  String? winnerName)  $default,) {final _that = this;
switch (_that) {
case _EventAward():
return $default(_that.id,_that.label,_that.type,_that.value,_that.winnerId,_that.winnerName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String type,  double value,  String? winnerId,  String? winnerName)?  $default,) {final _that = this;
switch (_that) {
case _EventAward() when $default != null:
return $default(_that.id,_that.label,_that.type,_that.value,_that.winnerId,_that.winnerName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventAward implements EventAward {
  const _EventAward({required this.id, required this.label, this.type = 'Cash', this.value = 0.0, this.winnerId, this.winnerName});
  factory _EventAward.fromJson(Map<String, dynamic> json) => _$EventAwardFromJson(json);

@override final  String id;
@override final  String label;
@override@JsonKey() final  String type;
// Cup, Cash, Voucher
@override@JsonKey() final  double value;
@override final  String? winnerId;
@override final  String? winnerName;

/// Create a copy of EventAward
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventAwardCopyWith<_EventAward> get copyWith => __$EventAwardCopyWithImpl<_EventAward>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventAwardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventAward&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.winnerName, winnerName) || other.winnerName == winnerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,type,value,winnerId,winnerName);

@override
String toString() {
  return 'EventAward(id: $id, label: $label, type: $type, value: $value, winnerId: $winnerId, winnerName: $winnerName)';
}


}

/// @nodoc
abstract mixin class _$EventAwardCopyWith<$Res> implements $EventAwardCopyWith<$Res> {
  factory _$EventAwardCopyWith(_EventAward value, $Res Function(_EventAward) _then) = __$EventAwardCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String type, double value, String? winnerId, String? winnerName
});




}
/// @nodoc
class __$EventAwardCopyWithImpl<$Res>
    implements _$EventAwardCopyWith<$Res> {
  __$EventAwardCopyWithImpl(this._self, this._then);

  final _EventAward _self;
  final $Res Function(_EventAward) _then;

/// Create a copy of EventAward
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? type = null,Object? value = null,Object? winnerId = freezed,Object? winnerName = freezed,}) {
  return _then(_EventAward(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,winnerName: freezed == winnerName ? _self.winnerName : winnerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EventFeedItem {

 String get id; FeedItemType get type; String? get title; String get content; String? get imageUrl; bool get isPinned; bool get isPublished; int get sortOrder; DateTime get createdAt; Map<String, dynamic> get pollData;
/// Create a copy of EventFeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventFeedItemCopyWith<EventFeedItem> get copyWith => _$EventFeedItemCopyWithImpl<EventFeedItem>(this as EventFeedItem, _$identity);

  /// Serializes this EventFeedItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventFeedItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.pollData, pollData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,content,imageUrl,isPinned,isPublished,sortOrder,createdAt,const DeepCollectionEquality().hash(pollData));

@override
String toString() {
  return 'EventFeedItem(id: $id, type: $type, title: $title, content: $content, imageUrl: $imageUrl, isPinned: $isPinned, isPublished: $isPublished, sortOrder: $sortOrder, createdAt: $createdAt, pollData: $pollData)';
}


}

/// @nodoc
abstract mixin class $EventFeedItemCopyWith<$Res>  {
  factory $EventFeedItemCopyWith(EventFeedItem value, $Res Function(EventFeedItem) _then) = _$EventFeedItemCopyWithImpl;
@useResult
$Res call({
 String id, FeedItemType type, String? title, String content, String? imageUrl, bool isPinned, bool isPublished, int sortOrder, DateTime createdAt, Map<String, dynamic> pollData
});




}
/// @nodoc
class _$EventFeedItemCopyWithImpl<$Res>
    implements $EventFeedItemCopyWith<$Res> {
  _$EventFeedItemCopyWithImpl(this._self, this._then);

  final EventFeedItem _self;
  final $Res Function(EventFeedItem) _then;

/// Create a copy of EventFeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? title = freezed,Object? content = null,Object? imageUrl = freezed,Object? isPinned = null,Object? isPublished = null,Object? sortOrder = null,Object? createdAt = null,Object? pollData = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FeedItemType,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,pollData: null == pollData ? _self.pollData : pollData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [EventFeedItem].
extension EventFeedItemPatterns on EventFeedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventFeedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventFeedItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventFeedItem value)  $default,){
final _that = this;
switch (_that) {
case _EventFeedItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventFeedItem value)?  $default,){
final _that = this;
switch (_that) {
case _EventFeedItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  FeedItemType type,  String? title,  String content,  String? imageUrl,  bool isPinned,  bool isPublished,  int sortOrder,  DateTime createdAt,  Map<String, dynamic> pollData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventFeedItem() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.content,_that.imageUrl,_that.isPinned,_that.isPublished,_that.sortOrder,_that.createdAt,_that.pollData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  FeedItemType type,  String? title,  String content,  String? imageUrl,  bool isPinned,  bool isPublished,  int sortOrder,  DateTime createdAt,  Map<String, dynamic> pollData)  $default,) {final _that = this;
switch (_that) {
case _EventFeedItem():
return $default(_that.id,_that.type,_that.title,_that.content,_that.imageUrl,_that.isPinned,_that.isPublished,_that.sortOrder,_that.createdAt,_that.pollData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  FeedItemType type,  String? title,  String content,  String? imageUrl,  bool isPinned,  bool isPublished,  int sortOrder,  DateTime createdAt,  Map<String, dynamic> pollData)?  $default,) {final _that = this;
switch (_that) {
case _EventFeedItem() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.content,_that.imageUrl,_that.isPinned,_that.isPublished,_that.sortOrder,_that.createdAt,_that.pollData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventFeedItem implements EventFeedItem {
  const _EventFeedItem({required this.id, required this.type, this.title, this.content = '', this.imageUrl, this.isPinned = false, this.isPublished = false, this.sortOrder = 0, required this.createdAt, final  Map<String, dynamic> pollData = const {}}): _pollData = pollData;
  factory _EventFeedItem.fromJson(Map<String, dynamic> json) => _$EventFeedItemFromJson(json);

@override final  String id;
@override final  FeedItemType type;
@override final  String? title;
@override@JsonKey() final  String content;
@override final  String? imageUrl;
@override@JsonKey() final  bool isPinned;
@override@JsonKey() final  bool isPublished;
@override@JsonKey() final  int sortOrder;
@override final  DateTime createdAt;
 final  Map<String, dynamic> _pollData;
@override@JsonKey() Map<String, dynamic> get pollData {
  if (_pollData is EqualUnmodifiableMapView) return _pollData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_pollData);
}


/// Create a copy of EventFeedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventFeedItemCopyWith<_EventFeedItem> get copyWith => __$EventFeedItemCopyWithImpl<_EventFeedItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventFeedItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventFeedItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._pollData, _pollData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,content,imageUrl,isPinned,isPublished,sortOrder,createdAt,const DeepCollectionEquality().hash(_pollData));

@override
String toString() {
  return 'EventFeedItem(id: $id, type: $type, title: $title, content: $content, imageUrl: $imageUrl, isPinned: $isPinned, isPublished: $isPublished, sortOrder: $sortOrder, createdAt: $createdAt, pollData: $pollData)';
}


}

/// @nodoc
abstract mixin class _$EventFeedItemCopyWith<$Res> implements $EventFeedItemCopyWith<$Res> {
  factory _$EventFeedItemCopyWith(_EventFeedItem value, $Res Function(_EventFeedItem) _then) = __$EventFeedItemCopyWithImpl;
@override @useResult
$Res call({
 String id, FeedItemType type, String? title, String content, String? imageUrl, bool isPinned, bool isPublished, int sortOrder, DateTime createdAt, Map<String, dynamic> pollData
});




}
/// @nodoc
class __$EventFeedItemCopyWithImpl<$Res>
    implements _$EventFeedItemCopyWith<$Res> {
  __$EventFeedItemCopyWithImpl(this._self, this._then);

  final _EventFeedItem _self;
  final $Res Function(_EventFeedItem) _then;

/// Create a copy of EventFeedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? title = freezed,Object? content = null,Object? imageUrl = freezed,Object? isPinned = null,Object? isPublished = null,Object? sortOrder = null,Object? createdAt = null,Object? pollData = null,}) {
  return _then(_EventFeedItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FeedItemType,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,pollData: null == pollData ? _self._pollData : pollData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$GolfEvent {

 String get id; String get title; String get seasonId;@TimestampConverter() DateTime get date; String? get description; String? get imageUrl;@OptionalTimestampConverter() DateTime? get regTime;@OptionalTimestampConverter() DateTime? get teeOffTime;@OptionalTimestampConverter() DateTime? get registrationDeadline; List<EventRegistration> get registrations;// New detailed fields
 String? get courseName; String? get courseDetails; String? get dressCode; int? get availableBuggies; int? get maxParticipants; List<String> get facilities; double? get memberCost; double? get guestCost; double? get breakfastCost; double? get lunchCost; double? get dinnerCost; double? get buggyCost; bool get hasBreakfast; bool get hasLunch; bool get hasDinner; String? get dinnerLocation; String? get dinnerAddress; double? get societyGreenFee; double? get societyBreakfastCost; double? get societyLunchCost; double? get societyDinnerCost; List<EventNote> get notes;// DEPRECATED: Moving to feedItems
 List<String> get galleryUrls; bool get showRegistrationButton; int get teeOffInterval; bool get isGroupingPublished;// Multi-day support
 bool get isMultiDay;@OptionalTimestampConverter() DateTime? get endDate;// Grouping/Tee Sheet data
 Map<String, dynamic> get grouping;// Results/Leaderboard data
 List<Map<String, dynamic>> get results;// Course configuration (Par, SI, holes)
 String? get courseId; CourseConfig get courseConfig; String? get selectedTeeName; String? get selectedFemaleTeeName;// [NEW] Explicit mapping for female players
 List<String> get flashUpdates; List<EventFeedItem> get feedItems; bool get isScoringLocked; bool get isStatsReleased; Map<String, dynamic> get finalizedStats; String? get secondaryTemplateId;// Reference for Match Play overlay
 bool get isInvitational; EventStatus get status; List<EventExpense> get expenses; bool get showAwards; List<EventAward> get awards; EventType get eventType; Map<String, double> get manualCuts;// [NEW] Per-event player handicap adjustments
 double? get eventCost;
/// Create a copy of GolfEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GolfEventCopyWith<GolfEvent> get copyWith => _$GolfEventCopyWithImpl<GolfEvent>(this as GolfEvent, _$identity);

  /// Serializes this GolfEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GolfEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.seasonId, seasonId) || other.seasonId == seasonId)&&(identical(other.date, date) || other.date == date)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.regTime, regTime) || other.regTime == regTime)&&(identical(other.teeOffTime, teeOffTime) || other.teeOffTime == teeOffTime)&&(identical(other.registrationDeadline, registrationDeadline) || other.registrationDeadline == registrationDeadline)&&const DeepCollectionEquality().equals(other.registrations, registrations)&&(identical(other.courseName, courseName) || other.courseName == courseName)&&(identical(other.courseDetails, courseDetails) || other.courseDetails == courseDetails)&&(identical(other.dressCode, dressCode) || other.dressCode == dressCode)&&(identical(other.availableBuggies, availableBuggies) || other.availableBuggies == availableBuggies)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&const DeepCollectionEquality().equals(other.facilities, facilities)&&(identical(other.memberCost, memberCost) || other.memberCost == memberCost)&&(identical(other.guestCost, guestCost) || other.guestCost == guestCost)&&(identical(other.breakfastCost, breakfastCost) || other.breakfastCost == breakfastCost)&&(identical(other.lunchCost, lunchCost) || other.lunchCost == lunchCost)&&(identical(other.dinnerCost, dinnerCost) || other.dinnerCost == dinnerCost)&&(identical(other.buggyCost, buggyCost) || other.buggyCost == buggyCost)&&(identical(other.hasBreakfast, hasBreakfast) || other.hasBreakfast == hasBreakfast)&&(identical(other.hasLunch, hasLunch) || other.hasLunch == hasLunch)&&(identical(other.hasDinner, hasDinner) || other.hasDinner == hasDinner)&&(identical(other.dinnerLocation, dinnerLocation) || other.dinnerLocation == dinnerLocation)&&(identical(other.dinnerAddress, dinnerAddress) || other.dinnerAddress == dinnerAddress)&&(identical(other.societyGreenFee, societyGreenFee) || other.societyGreenFee == societyGreenFee)&&(identical(other.societyBreakfastCost, societyBreakfastCost) || other.societyBreakfastCost == societyBreakfastCost)&&(identical(other.societyLunchCost, societyLunchCost) || other.societyLunchCost == societyLunchCost)&&(identical(other.societyDinnerCost, societyDinnerCost) || other.societyDinnerCost == societyDinnerCost)&&const DeepCollectionEquality().equals(other.notes, notes)&&const DeepCollectionEquality().equals(other.galleryUrls, galleryUrls)&&(identical(other.showRegistrationButton, showRegistrationButton) || other.showRegistrationButton == showRegistrationButton)&&(identical(other.teeOffInterval, teeOffInterval) || other.teeOffInterval == teeOffInterval)&&(identical(other.isGroupingPublished, isGroupingPublished) || other.isGroupingPublished == isGroupingPublished)&&(identical(other.isMultiDay, isMultiDay) || other.isMultiDay == isMultiDay)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.grouping, grouping)&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.courseConfig, courseConfig) || other.courseConfig == courseConfig)&&(identical(other.selectedTeeName, selectedTeeName) || other.selectedTeeName == selectedTeeName)&&(identical(other.selectedFemaleTeeName, selectedFemaleTeeName) || other.selectedFemaleTeeName == selectedFemaleTeeName)&&const DeepCollectionEquality().equals(other.flashUpdates, flashUpdates)&&const DeepCollectionEquality().equals(other.feedItems, feedItems)&&(identical(other.isScoringLocked, isScoringLocked) || other.isScoringLocked == isScoringLocked)&&(identical(other.isStatsReleased, isStatsReleased) || other.isStatsReleased == isStatsReleased)&&const DeepCollectionEquality().equals(other.finalizedStats, finalizedStats)&&(identical(other.secondaryTemplateId, secondaryTemplateId) || other.secondaryTemplateId == secondaryTemplateId)&&(identical(other.isInvitational, isInvitational) || other.isInvitational == isInvitational)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.expenses, expenses)&&(identical(other.showAwards, showAwards) || other.showAwards == showAwards)&&const DeepCollectionEquality().equals(other.awards, awards)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&const DeepCollectionEquality().equals(other.manualCuts, manualCuts)&&(identical(other.eventCost, eventCost) || other.eventCost == eventCost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,seasonId,date,description,imageUrl,regTime,teeOffTime,registrationDeadline,const DeepCollectionEquality().hash(registrations),courseName,courseDetails,dressCode,availableBuggies,maxParticipants,const DeepCollectionEquality().hash(facilities),memberCost,guestCost,breakfastCost,lunchCost,dinnerCost,buggyCost,hasBreakfast,hasLunch,hasDinner,dinnerLocation,dinnerAddress,societyGreenFee,societyBreakfastCost,societyLunchCost,societyDinnerCost,const DeepCollectionEquality().hash(notes),const DeepCollectionEquality().hash(galleryUrls),showRegistrationButton,teeOffInterval,isGroupingPublished,isMultiDay,endDate,const DeepCollectionEquality().hash(grouping),const DeepCollectionEquality().hash(results),courseId,courseConfig,selectedTeeName,selectedFemaleTeeName,const DeepCollectionEquality().hash(flashUpdates),const DeepCollectionEquality().hash(feedItems),isScoringLocked,isStatsReleased,const DeepCollectionEquality().hash(finalizedStats),secondaryTemplateId,isInvitational,status,const DeepCollectionEquality().hash(expenses),showAwards,const DeepCollectionEquality().hash(awards),eventType,const DeepCollectionEquality().hash(manualCuts),eventCost]);

@override
String toString() {
  return 'GolfEvent(id: $id, title: $title, seasonId: $seasonId, date: $date, description: $description, imageUrl: $imageUrl, regTime: $regTime, teeOffTime: $teeOffTime, registrationDeadline: $registrationDeadline, registrations: $registrations, courseName: $courseName, courseDetails: $courseDetails, dressCode: $dressCode, availableBuggies: $availableBuggies, maxParticipants: $maxParticipants, facilities: $facilities, memberCost: $memberCost, guestCost: $guestCost, breakfastCost: $breakfastCost, lunchCost: $lunchCost, dinnerCost: $dinnerCost, buggyCost: $buggyCost, hasBreakfast: $hasBreakfast, hasLunch: $hasLunch, hasDinner: $hasDinner, dinnerLocation: $dinnerLocation, dinnerAddress: $dinnerAddress, societyGreenFee: $societyGreenFee, societyBreakfastCost: $societyBreakfastCost, societyLunchCost: $societyLunchCost, societyDinnerCost: $societyDinnerCost, notes: $notes, galleryUrls: $galleryUrls, showRegistrationButton: $showRegistrationButton, teeOffInterval: $teeOffInterval, isGroupingPublished: $isGroupingPublished, isMultiDay: $isMultiDay, endDate: $endDate, grouping: $grouping, results: $results, courseId: $courseId, courseConfig: $courseConfig, selectedTeeName: $selectedTeeName, selectedFemaleTeeName: $selectedFemaleTeeName, flashUpdates: $flashUpdates, feedItems: $feedItems, isScoringLocked: $isScoringLocked, isStatsReleased: $isStatsReleased, finalizedStats: $finalizedStats, secondaryTemplateId: $secondaryTemplateId, isInvitational: $isInvitational, status: $status, expenses: $expenses, showAwards: $showAwards, awards: $awards, eventType: $eventType, manualCuts: $manualCuts, eventCost: $eventCost)';
}


}

/// @nodoc
abstract mixin class $GolfEventCopyWith<$Res>  {
  factory $GolfEventCopyWith(GolfEvent value, $Res Function(GolfEvent) _then) = _$GolfEventCopyWithImpl;
@useResult
$Res call({
 String id, String title, String seasonId,@TimestampConverter() DateTime date, String? description, String? imageUrl,@OptionalTimestampConverter() DateTime? regTime,@OptionalTimestampConverter() DateTime? teeOffTime,@OptionalTimestampConverter() DateTime? registrationDeadline, List<EventRegistration> registrations, String? courseName, String? courseDetails, String? dressCode, int? availableBuggies, int? maxParticipants, List<String> facilities, double? memberCost, double? guestCost, double? breakfastCost, double? lunchCost, double? dinnerCost, double? buggyCost, bool hasBreakfast, bool hasLunch, bool hasDinner, String? dinnerLocation, String? dinnerAddress, double? societyGreenFee, double? societyBreakfastCost, double? societyLunchCost, double? societyDinnerCost, List<EventNote> notes, List<String> galleryUrls, bool showRegistrationButton, int teeOffInterval, bool isGroupingPublished, bool isMultiDay,@OptionalTimestampConverter() DateTime? endDate, Map<String, dynamic> grouping, List<Map<String, dynamic>> results, String? courseId, CourseConfig courseConfig, String? selectedTeeName, String? selectedFemaleTeeName, List<String> flashUpdates, List<EventFeedItem> feedItems, bool isScoringLocked, bool isStatsReleased, Map<String, dynamic> finalizedStats, String? secondaryTemplateId, bool isInvitational, EventStatus status, List<EventExpense> expenses, bool showAwards, List<EventAward> awards, EventType eventType, Map<String, double> manualCuts, double? eventCost
});


$CourseConfigCopyWith<$Res> get courseConfig;

}
/// @nodoc
class _$GolfEventCopyWithImpl<$Res>
    implements $GolfEventCopyWith<$Res> {
  _$GolfEventCopyWithImpl(this._self, this._then);

  final GolfEvent _self;
  final $Res Function(GolfEvent) _then;

/// Create a copy of GolfEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? seasonId = null,Object? date = null,Object? description = freezed,Object? imageUrl = freezed,Object? regTime = freezed,Object? teeOffTime = freezed,Object? registrationDeadline = freezed,Object? registrations = null,Object? courseName = freezed,Object? courseDetails = freezed,Object? dressCode = freezed,Object? availableBuggies = freezed,Object? maxParticipants = freezed,Object? facilities = null,Object? memberCost = freezed,Object? guestCost = freezed,Object? breakfastCost = freezed,Object? lunchCost = freezed,Object? dinnerCost = freezed,Object? buggyCost = freezed,Object? hasBreakfast = null,Object? hasLunch = null,Object? hasDinner = null,Object? dinnerLocation = freezed,Object? dinnerAddress = freezed,Object? societyGreenFee = freezed,Object? societyBreakfastCost = freezed,Object? societyLunchCost = freezed,Object? societyDinnerCost = freezed,Object? notes = null,Object? galleryUrls = null,Object? showRegistrationButton = null,Object? teeOffInterval = null,Object? isGroupingPublished = null,Object? isMultiDay = null,Object? endDate = freezed,Object? grouping = null,Object? results = null,Object? courseId = freezed,Object? courseConfig = null,Object? selectedTeeName = freezed,Object? selectedFemaleTeeName = freezed,Object? flashUpdates = null,Object? feedItems = null,Object? isScoringLocked = null,Object? isStatsReleased = null,Object? finalizedStats = null,Object? secondaryTemplateId = freezed,Object? isInvitational = null,Object? status = null,Object? expenses = null,Object? showAwards = null,Object? awards = null,Object? eventType = null,Object? manualCuts = null,Object? eventCost = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,seasonId: null == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,regTime: freezed == regTime ? _self.regTime : regTime // ignore: cast_nullable_to_non_nullable
as DateTime?,teeOffTime: freezed == teeOffTime ? _self.teeOffTime : teeOffTime // ignore: cast_nullable_to_non_nullable
as DateTime?,registrationDeadline: freezed == registrationDeadline ? _self.registrationDeadline : registrationDeadline // ignore: cast_nullable_to_non_nullable
as DateTime?,registrations: null == registrations ? _self.registrations : registrations // ignore: cast_nullable_to_non_nullable
as List<EventRegistration>,courseName: freezed == courseName ? _self.courseName : courseName // ignore: cast_nullable_to_non_nullable
as String?,courseDetails: freezed == courseDetails ? _self.courseDetails : courseDetails // ignore: cast_nullable_to_non_nullable
as String?,dressCode: freezed == dressCode ? _self.dressCode : dressCode // ignore: cast_nullable_to_non_nullable
as String?,availableBuggies: freezed == availableBuggies ? _self.availableBuggies : availableBuggies // ignore: cast_nullable_to_non_nullable
as int?,maxParticipants: freezed == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int?,facilities: null == facilities ? _self.facilities : facilities // ignore: cast_nullable_to_non_nullable
as List<String>,memberCost: freezed == memberCost ? _self.memberCost : memberCost // ignore: cast_nullable_to_non_nullable
as double?,guestCost: freezed == guestCost ? _self.guestCost : guestCost // ignore: cast_nullable_to_non_nullable
as double?,breakfastCost: freezed == breakfastCost ? _self.breakfastCost : breakfastCost // ignore: cast_nullable_to_non_nullable
as double?,lunchCost: freezed == lunchCost ? _self.lunchCost : lunchCost // ignore: cast_nullable_to_non_nullable
as double?,dinnerCost: freezed == dinnerCost ? _self.dinnerCost : dinnerCost // ignore: cast_nullable_to_non_nullable
as double?,buggyCost: freezed == buggyCost ? _self.buggyCost : buggyCost // ignore: cast_nullable_to_non_nullable
as double?,hasBreakfast: null == hasBreakfast ? _self.hasBreakfast : hasBreakfast // ignore: cast_nullable_to_non_nullable
as bool,hasLunch: null == hasLunch ? _self.hasLunch : hasLunch // ignore: cast_nullable_to_non_nullable
as bool,hasDinner: null == hasDinner ? _self.hasDinner : hasDinner // ignore: cast_nullable_to_non_nullable
as bool,dinnerLocation: freezed == dinnerLocation ? _self.dinnerLocation : dinnerLocation // ignore: cast_nullable_to_non_nullable
as String?,dinnerAddress: freezed == dinnerAddress ? _self.dinnerAddress : dinnerAddress // ignore: cast_nullable_to_non_nullable
as String?,societyGreenFee: freezed == societyGreenFee ? _self.societyGreenFee : societyGreenFee // ignore: cast_nullable_to_non_nullable
as double?,societyBreakfastCost: freezed == societyBreakfastCost ? _self.societyBreakfastCost : societyBreakfastCost // ignore: cast_nullable_to_non_nullable
as double?,societyLunchCost: freezed == societyLunchCost ? _self.societyLunchCost : societyLunchCost // ignore: cast_nullable_to_non_nullable
as double?,societyDinnerCost: freezed == societyDinnerCost ? _self.societyDinnerCost : societyDinnerCost // ignore: cast_nullable_to_non_nullable
as double?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<EventNote>,galleryUrls: null == galleryUrls ? _self.galleryUrls : galleryUrls // ignore: cast_nullable_to_non_nullable
as List<String>,showRegistrationButton: null == showRegistrationButton ? _self.showRegistrationButton : showRegistrationButton // ignore: cast_nullable_to_non_nullable
as bool,teeOffInterval: null == teeOffInterval ? _self.teeOffInterval : teeOffInterval // ignore: cast_nullable_to_non_nullable
as int,isGroupingPublished: null == isGroupingPublished ? _self.isGroupingPublished : isGroupingPublished // ignore: cast_nullable_to_non_nullable
as bool,isMultiDay: null == isMultiDay ? _self.isMultiDay : isMultiDay // ignore: cast_nullable_to_non_nullable
as bool,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,grouping: null == grouping ? _self.grouping : grouping // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,courseId: freezed == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String?,courseConfig: null == courseConfig ? _self.courseConfig : courseConfig // ignore: cast_nullable_to_non_nullable
as CourseConfig,selectedTeeName: freezed == selectedTeeName ? _self.selectedTeeName : selectedTeeName // ignore: cast_nullable_to_non_nullable
as String?,selectedFemaleTeeName: freezed == selectedFemaleTeeName ? _self.selectedFemaleTeeName : selectedFemaleTeeName // ignore: cast_nullable_to_non_nullable
as String?,flashUpdates: null == flashUpdates ? _self.flashUpdates : flashUpdates // ignore: cast_nullable_to_non_nullable
as List<String>,feedItems: null == feedItems ? _self.feedItems : feedItems // ignore: cast_nullable_to_non_nullable
as List<EventFeedItem>,isScoringLocked: null == isScoringLocked ? _self.isScoringLocked : isScoringLocked // ignore: cast_nullable_to_non_nullable
as bool,isStatsReleased: null == isStatsReleased ? _self.isStatsReleased : isStatsReleased // ignore: cast_nullable_to_non_nullable
as bool,finalizedStats: null == finalizedStats ? _self.finalizedStats : finalizedStats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,secondaryTemplateId: freezed == secondaryTemplateId ? _self.secondaryTemplateId : secondaryTemplateId // ignore: cast_nullable_to_non_nullable
as String?,isInvitational: null == isInvitational ? _self.isInvitational : isInvitational // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventStatus,expenses: null == expenses ? _self.expenses : expenses // ignore: cast_nullable_to_non_nullable
as List<EventExpense>,showAwards: null == showAwards ? _self.showAwards : showAwards // ignore: cast_nullable_to_non_nullable
as bool,awards: null == awards ? _self.awards : awards // ignore: cast_nullable_to_non_nullable
as List<EventAward>,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as EventType,manualCuts: null == manualCuts ? _self.manualCuts : manualCuts // ignore: cast_nullable_to_non_nullable
as Map<String, double>,eventCost: freezed == eventCost ? _self.eventCost : eventCost // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}
/// Create a copy of GolfEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CourseConfigCopyWith<$Res> get courseConfig {
  
  return $CourseConfigCopyWith<$Res>(_self.courseConfig, (value) {
    return _then(_self.copyWith(courseConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [GolfEvent].
extension GolfEventPatterns on GolfEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GolfEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GolfEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GolfEvent value)  $default,){
final _that = this;
switch (_that) {
case _GolfEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GolfEvent value)?  $default,){
final _that = this;
switch (_that) {
case _GolfEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String seasonId, @TimestampConverter()  DateTime date,  String? description,  String? imageUrl, @OptionalTimestampConverter()  DateTime? regTime, @OptionalTimestampConverter()  DateTime? teeOffTime, @OptionalTimestampConverter()  DateTime? registrationDeadline,  List<EventRegistration> registrations,  String? courseName,  String? courseDetails,  String? dressCode,  int? availableBuggies,  int? maxParticipants,  List<String> facilities,  double? memberCost,  double? guestCost,  double? breakfastCost,  double? lunchCost,  double? dinnerCost,  double? buggyCost,  bool hasBreakfast,  bool hasLunch,  bool hasDinner,  String? dinnerLocation,  String? dinnerAddress,  double? societyGreenFee,  double? societyBreakfastCost,  double? societyLunchCost,  double? societyDinnerCost,  List<EventNote> notes,  List<String> galleryUrls,  bool showRegistrationButton,  int teeOffInterval,  bool isGroupingPublished,  bool isMultiDay, @OptionalTimestampConverter()  DateTime? endDate,  Map<String, dynamic> grouping,  List<Map<String, dynamic>> results,  String? courseId,  CourseConfig courseConfig,  String? selectedTeeName,  String? selectedFemaleTeeName,  List<String> flashUpdates,  List<EventFeedItem> feedItems,  bool isScoringLocked,  bool isStatsReleased,  Map<String, dynamic> finalizedStats,  String? secondaryTemplateId,  bool isInvitational,  EventStatus status,  List<EventExpense> expenses,  bool showAwards,  List<EventAward> awards,  EventType eventType,  Map<String, double> manualCuts,  double? eventCost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GolfEvent() when $default != null:
return $default(_that.id,_that.title,_that.seasonId,_that.date,_that.description,_that.imageUrl,_that.regTime,_that.teeOffTime,_that.registrationDeadline,_that.registrations,_that.courseName,_that.courseDetails,_that.dressCode,_that.availableBuggies,_that.maxParticipants,_that.facilities,_that.memberCost,_that.guestCost,_that.breakfastCost,_that.lunchCost,_that.dinnerCost,_that.buggyCost,_that.hasBreakfast,_that.hasLunch,_that.hasDinner,_that.dinnerLocation,_that.dinnerAddress,_that.societyGreenFee,_that.societyBreakfastCost,_that.societyLunchCost,_that.societyDinnerCost,_that.notes,_that.galleryUrls,_that.showRegistrationButton,_that.teeOffInterval,_that.isGroupingPublished,_that.isMultiDay,_that.endDate,_that.grouping,_that.results,_that.courseId,_that.courseConfig,_that.selectedTeeName,_that.selectedFemaleTeeName,_that.flashUpdates,_that.feedItems,_that.isScoringLocked,_that.isStatsReleased,_that.finalizedStats,_that.secondaryTemplateId,_that.isInvitational,_that.status,_that.expenses,_that.showAwards,_that.awards,_that.eventType,_that.manualCuts,_that.eventCost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String seasonId, @TimestampConverter()  DateTime date,  String? description,  String? imageUrl, @OptionalTimestampConverter()  DateTime? regTime, @OptionalTimestampConverter()  DateTime? teeOffTime, @OptionalTimestampConverter()  DateTime? registrationDeadline,  List<EventRegistration> registrations,  String? courseName,  String? courseDetails,  String? dressCode,  int? availableBuggies,  int? maxParticipants,  List<String> facilities,  double? memberCost,  double? guestCost,  double? breakfastCost,  double? lunchCost,  double? dinnerCost,  double? buggyCost,  bool hasBreakfast,  bool hasLunch,  bool hasDinner,  String? dinnerLocation,  String? dinnerAddress,  double? societyGreenFee,  double? societyBreakfastCost,  double? societyLunchCost,  double? societyDinnerCost,  List<EventNote> notes,  List<String> galleryUrls,  bool showRegistrationButton,  int teeOffInterval,  bool isGroupingPublished,  bool isMultiDay, @OptionalTimestampConverter()  DateTime? endDate,  Map<String, dynamic> grouping,  List<Map<String, dynamic>> results,  String? courseId,  CourseConfig courseConfig,  String? selectedTeeName,  String? selectedFemaleTeeName,  List<String> flashUpdates,  List<EventFeedItem> feedItems,  bool isScoringLocked,  bool isStatsReleased,  Map<String, dynamic> finalizedStats,  String? secondaryTemplateId,  bool isInvitational,  EventStatus status,  List<EventExpense> expenses,  bool showAwards,  List<EventAward> awards,  EventType eventType,  Map<String, double> manualCuts,  double? eventCost)  $default,) {final _that = this;
switch (_that) {
case _GolfEvent():
return $default(_that.id,_that.title,_that.seasonId,_that.date,_that.description,_that.imageUrl,_that.regTime,_that.teeOffTime,_that.registrationDeadline,_that.registrations,_that.courseName,_that.courseDetails,_that.dressCode,_that.availableBuggies,_that.maxParticipants,_that.facilities,_that.memberCost,_that.guestCost,_that.breakfastCost,_that.lunchCost,_that.dinnerCost,_that.buggyCost,_that.hasBreakfast,_that.hasLunch,_that.hasDinner,_that.dinnerLocation,_that.dinnerAddress,_that.societyGreenFee,_that.societyBreakfastCost,_that.societyLunchCost,_that.societyDinnerCost,_that.notes,_that.galleryUrls,_that.showRegistrationButton,_that.teeOffInterval,_that.isGroupingPublished,_that.isMultiDay,_that.endDate,_that.grouping,_that.results,_that.courseId,_that.courseConfig,_that.selectedTeeName,_that.selectedFemaleTeeName,_that.flashUpdates,_that.feedItems,_that.isScoringLocked,_that.isStatsReleased,_that.finalizedStats,_that.secondaryTemplateId,_that.isInvitational,_that.status,_that.expenses,_that.showAwards,_that.awards,_that.eventType,_that.manualCuts,_that.eventCost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String seasonId, @TimestampConverter()  DateTime date,  String? description,  String? imageUrl, @OptionalTimestampConverter()  DateTime? regTime, @OptionalTimestampConverter()  DateTime? teeOffTime, @OptionalTimestampConverter()  DateTime? registrationDeadline,  List<EventRegistration> registrations,  String? courseName,  String? courseDetails,  String? dressCode,  int? availableBuggies,  int? maxParticipants,  List<String> facilities,  double? memberCost,  double? guestCost,  double? breakfastCost,  double? lunchCost,  double? dinnerCost,  double? buggyCost,  bool hasBreakfast,  bool hasLunch,  bool hasDinner,  String? dinnerLocation,  String? dinnerAddress,  double? societyGreenFee,  double? societyBreakfastCost,  double? societyLunchCost,  double? societyDinnerCost,  List<EventNote> notes,  List<String> galleryUrls,  bool showRegistrationButton,  int teeOffInterval,  bool isGroupingPublished,  bool isMultiDay, @OptionalTimestampConverter()  DateTime? endDate,  Map<String, dynamic> grouping,  List<Map<String, dynamic>> results,  String? courseId,  CourseConfig courseConfig,  String? selectedTeeName,  String? selectedFemaleTeeName,  List<String> flashUpdates,  List<EventFeedItem> feedItems,  bool isScoringLocked,  bool isStatsReleased,  Map<String, dynamic> finalizedStats,  String? secondaryTemplateId,  bool isInvitational,  EventStatus status,  List<EventExpense> expenses,  bool showAwards,  List<EventAward> awards,  EventType eventType,  Map<String, double> manualCuts,  double? eventCost)?  $default,) {final _that = this;
switch (_that) {
case _GolfEvent() when $default != null:
return $default(_that.id,_that.title,_that.seasonId,_that.date,_that.description,_that.imageUrl,_that.regTime,_that.teeOffTime,_that.registrationDeadline,_that.registrations,_that.courseName,_that.courseDetails,_that.dressCode,_that.availableBuggies,_that.maxParticipants,_that.facilities,_that.memberCost,_that.guestCost,_that.breakfastCost,_that.lunchCost,_that.dinnerCost,_that.buggyCost,_that.hasBreakfast,_that.hasLunch,_that.hasDinner,_that.dinnerLocation,_that.dinnerAddress,_that.societyGreenFee,_that.societyBreakfastCost,_that.societyLunchCost,_that.societyDinnerCost,_that.notes,_that.galleryUrls,_that.showRegistrationButton,_that.teeOffInterval,_that.isGroupingPublished,_that.isMultiDay,_that.endDate,_that.grouping,_that.results,_that.courseId,_that.courseConfig,_that.selectedTeeName,_that.selectedFemaleTeeName,_that.flashUpdates,_that.feedItems,_that.isScoringLocked,_that.isStatsReleased,_that.finalizedStats,_that.secondaryTemplateId,_that.isInvitational,_that.status,_that.expenses,_that.showAwards,_that.awards,_that.eventType,_that.manualCuts,_that.eventCost);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GolfEvent extends GolfEvent {
  const _GolfEvent({required this.id, required this.title, required this.seasonId, @TimestampConverter() required this.date, this.description, this.imageUrl, @OptionalTimestampConverter() this.regTime, @OptionalTimestampConverter() this.teeOffTime, @OptionalTimestampConverter() this.registrationDeadline, final  List<EventRegistration> registrations = const [], this.courseName, this.courseDetails, this.dressCode, this.availableBuggies, this.maxParticipants, final  List<String> facilities = const [], this.memberCost, this.guestCost, this.breakfastCost, this.lunchCost, this.dinnerCost, this.buggyCost, this.hasBreakfast = false, this.hasLunch = false, this.hasDinner = true, this.dinnerLocation, this.dinnerAddress, this.societyGreenFee, this.societyBreakfastCost, this.societyLunchCost, this.societyDinnerCost, final  List<EventNote> notes = const [], final  List<String> galleryUrls = const [], this.showRegistrationButton = true, this.teeOffInterval = 10, this.isGroupingPublished = false, this.isMultiDay = false, @OptionalTimestampConverter() this.endDate, final  Map<String, dynamic> grouping = const {}, final  List<Map<String, dynamic>> results = const [], this.courseId, this.courseConfig = const CourseConfig(), this.selectedTeeName, this.selectedFemaleTeeName, final  List<String> flashUpdates = const [], final  List<EventFeedItem> feedItems = const [], this.isScoringLocked = false, this.isStatsReleased = false, final  Map<String, dynamic> finalizedStats = const {}, this.secondaryTemplateId, this.isInvitational = false, this.status = EventStatus.draft, final  List<EventExpense> expenses = const [], this.showAwards = true, final  List<EventAward> awards = const [], this.eventType = EventType.golf, final  Map<String, double> manualCuts = const {}, this.eventCost}): _registrations = registrations,_facilities = facilities,_notes = notes,_galleryUrls = galleryUrls,_grouping = grouping,_results = results,_flashUpdates = flashUpdates,_feedItems = feedItems,_finalizedStats = finalizedStats,_expenses = expenses,_awards = awards,_manualCuts = manualCuts,super._();
  factory _GolfEvent.fromJson(Map<String, dynamic> json) => _$GolfEventFromJson(json);

@override final  String id;
@override final  String title;
@override final  String seasonId;
@override@TimestampConverter() final  DateTime date;
@override final  String? description;
@override final  String? imageUrl;
@override@OptionalTimestampConverter() final  DateTime? regTime;
@override@OptionalTimestampConverter() final  DateTime? teeOffTime;
@override@OptionalTimestampConverter() final  DateTime? registrationDeadline;
 final  List<EventRegistration> _registrations;
@override@JsonKey() List<EventRegistration> get registrations {
  if (_registrations is EqualUnmodifiableListView) return _registrations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_registrations);
}

// New detailed fields
@override final  String? courseName;
@override final  String? courseDetails;
@override final  String? dressCode;
@override final  int? availableBuggies;
@override final  int? maxParticipants;
 final  List<String> _facilities;
@override@JsonKey() List<String> get facilities {
  if (_facilities is EqualUnmodifiableListView) return _facilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_facilities);
}

@override final  double? memberCost;
@override final  double? guestCost;
@override final  double? breakfastCost;
@override final  double? lunchCost;
@override final  double? dinnerCost;
@override final  double? buggyCost;
@override@JsonKey() final  bool hasBreakfast;
@override@JsonKey() final  bool hasLunch;
@override@JsonKey() final  bool hasDinner;
@override final  String? dinnerLocation;
@override final  String? dinnerAddress;
@override final  double? societyGreenFee;
@override final  double? societyBreakfastCost;
@override final  double? societyLunchCost;
@override final  double? societyDinnerCost;
 final  List<EventNote> _notes;
@override@JsonKey() List<EventNote> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}

// DEPRECATED: Moving to feedItems
 final  List<String> _galleryUrls;
// DEPRECATED: Moving to feedItems
@override@JsonKey() List<String> get galleryUrls {
  if (_galleryUrls is EqualUnmodifiableListView) return _galleryUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_galleryUrls);
}

@override@JsonKey() final  bool showRegistrationButton;
@override@JsonKey() final  int teeOffInterval;
@override@JsonKey() final  bool isGroupingPublished;
// Multi-day support
@override@JsonKey() final  bool isMultiDay;
@override@OptionalTimestampConverter() final  DateTime? endDate;
// Grouping/Tee Sheet data
 final  Map<String, dynamic> _grouping;
// Grouping/Tee Sheet data
@override@JsonKey() Map<String, dynamic> get grouping {
  if (_grouping is EqualUnmodifiableMapView) return _grouping;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_grouping);
}

// Results/Leaderboard data
 final  List<Map<String, dynamic>> _results;
// Results/Leaderboard data
@override@JsonKey() List<Map<String, dynamic>> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

// Course configuration (Par, SI, holes)
@override final  String? courseId;
@override@JsonKey() final  CourseConfig courseConfig;
@override final  String? selectedTeeName;
@override final  String? selectedFemaleTeeName;
// [NEW] Explicit mapping for female players
 final  List<String> _flashUpdates;
// [NEW] Explicit mapping for female players
@override@JsonKey() List<String> get flashUpdates {
  if (_flashUpdates is EqualUnmodifiableListView) return _flashUpdates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_flashUpdates);
}

 final  List<EventFeedItem> _feedItems;
@override@JsonKey() List<EventFeedItem> get feedItems {
  if (_feedItems is EqualUnmodifiableListView) return _feedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_feedItems);
}

@override@JsonKey() final  bool isScoringLocked;
@override@JsonKey() final  bool isStatsReleased;
 final  Map<String, dynamic> _finalizedStats;
@override@JsonKey() Map<String, dynamic> get finalizedStats {
  if (_finalizedStats is EqualUnmodifiableMapView) return _finalizedStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_finalizedStats);
}

@override final  String? secondaryTemplateId;
// Reference for Match Play overlay
@override@JsonKey() final  bool isInvitational;
@override@JsonKey() final  EventStatus status;
 final  List<EventExpense> _expenses;
@override@JsonKey() List<EventExpense> get expenses {
  if (_expenses is EqualUnmodifiableListView) return _expenses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expenses);
}

@override@JsonKey() final  bool showAwards;
 final  List<EventAward> _awards;
@override@JsonKey() List<EventAward> get awards {
  if (_awards is EqualUnmodifiableListView) return _awards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_awards);
}

@override@JsonKey() final  EventType eventType;
 final  Map<String, double> _manualCuts;
@override@JsonKey() Map<String, double> get manualCuts {
  if (_manualCuts is EqualUnmodifiableMapView) return _manualCuts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_manualCuts);
}

// [NEW] Per-event player handicap adjustments
@override final  double? eventCost;

/// Create a copy of GolfEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GolfEventCopyWith<_GolfEvent> get copyWith => __$GolfEventCopyWithImpl<_GolfEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GolfEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GolfEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.seasonId, seasonId) || other.seasonId == seasonId)&&(identical(other.date, date) || other.date == date)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.regTime, regTime) || other.regTime == regTime)&&(identical(other.teeOffTime, teeOffTime) || other.teeOffTime == teeOffTime)&&(identical(other.registrationDeadline, registrationDeadline) || other.registrationDeadline == registrationDeadline)&&const DeepCollectionEquality().equals(other._registrations, _registrations)&&(identical(other.courseName, courseName) || other.courseName == courseName)&&(identical(other.courseDetails, courseDetails) || other.courseDetails == courseDetails)&&(identical(other.dressCode, dressCode) || other.dressCode == dressCode)&&(identical(other.availableBuggies, availableBuggies) || other.availableBuggies == availableBuggies)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&const DeepCollectionEquality().equals(other._facilities, _facilities)&&(identical(other.memberCost, memberCost) || other.memberCost == memberCost)&&(identical(other.guestCost, guestCost) || other.guestCost == guestCost)&&(identical(other.breakfastCost, breakfastCost) || other.breakfastCost == breakfastCost)&&(identical(other.lunchCost, lunchCost) || other.lunchCost == lunchCost)&&(identical(other.dinnerCost, dinnerCost) || other.dinnerCost == dinnerCost)&&(identical(other.buggyCost, buggyCost) || other.buggyCost == buggyCost)&&(identical(other.hasBreakfast, hasBreakfast) || other.hasBreakfast == hasBreakfast)&&(identical(other.hasLunch, hasLunch) || other.hasLunch == hasLunch)&&(identical(other.hasDinner, hasDinner) || other.hasDinner == hasDinner)&&(identical(other.dinnerLocation, dinnerLocation) || other.dinnerLocation == dinnerLocation)&&(identical(other.dinnerAddress, dinnerAddress) || other.dinnerAddress == dinnerAddress)&&(identical(other.societyGreenFee, societyGreenFee) || other.societyGreenFee == societyGreenFee)&&(identical(other.societyBreakfastCost, societyBreakfastCost) || other.societyBreakfastCost == societyBreakfastCost)&&(identical(other.societyLunchCost, societyLunchCost) || other.societyLunchCost == societyLunchCost)&&(identical(other.societyDinnerCost, societyDinnerCost) || other.societyDinnerCost == societyDinnerCost)&&const DeepCollectionEquality().equals(other._notes, _notes)&&const DeepCollectionEquality().equals(other._galleryUrls, _galleryUrls)&&(identical(other.showRegistrationButton, showRegistrationButton) || other.showRegistrationButton == showRegistrationButton)&&(identical(other.teeOffInterval, teeOffInterval) || other.teeOffInterval == teeOffInterval)&&(identical(other.isGroupingPublished, isGroupingPublished) || other.isGroupingPublished == isGroupingPublished)&&(identical(other.isMultiDay, isMultiDay) || other.isMultiDay == isMultiDay)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._grouping, _grouping)&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.courseConfig, courseConfig) || other.courseConfig == courseConfig)&&(identical(other.selectedTeeName, selectedTeeName) || other.selectedTeeName == selectedTeeName)&&(identical(other.selectedFemaleTeeName, selectedFemaleTeeName) || other.selectedFemaleTeeName == selectedFemaleTeeName)&&const DeepCollectionEquality().equals(other._flashUpdates, _flashUpdates)&&const DeepCollectionEquality().equals(other._feedItems, _feedItems)&&(identical(other.isScoringLocked, isScoringLocked) || other.isScoringLocked == isScoringLocked)&&(identical(other.isStatsReleased, isStatsReleased) || other.isStatsReleased == isStatsReleased)&&const DeepCollectionEquality().equals(other._finalizedStats, _finalizedStats)&&(identical(other.secondaryTemplateId, secondaryTemplateId) || other.secondaryTemplateId == secondaryTemplateId)&&(identical(other.isInvitational, isInvitational) || other.isInvitational == isInvitational)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._expenses, _expenses)&&(identical(other.showAwards, showAwards) || other.showAwards == showAwards)&&const DeepCollectionEquality().equals(other._awards, _awards)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&const DeepCollectionEquality().equals(other._manualCuts, _manualCuts)&&(identical(other.eventCost, eventCost) || other.eventCost == eventCost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,seasonId,date,description,imageUrl,regTime,teeOffTime,registrationDeadline,const DeepCollectionEquality().hash(_registrations),courseName,courseDetails,dressCode,availableBuggies,maxParticipants,const DeepCollectionEquality().hash(_facilities),memberCost,guestCost,breakfastCost,lunchCost,dinnerCost,buggyCost,hasBreakfast,hasLunch,hasDinner,dinnerLocation,dinnerAddress,societyGreenFee,societyBreakfastCost,societyLunchCost,societyDinnerCost,const DeepCollectionEquality().hash(_notes),const DeepCollectionEquality().hash(_galleryUrls),showRegistrationButton,teeOffInterval,isGroupingPublished,isMultiDay,endDate,const DeepCollectionEquality().hash(_grouping),const DeepCollectionEquality().hash(_results),courseId,courseConfig,selectedTeeName,selectedFemaleTeeName,const DeepCollectionEquality().hash(_flashUpdates),const DeepCollectionEquality().hash(_feedItems),isScoringLocked,isStatsReleased,const DeepCollectionEquality().hash(_finalizedStats),secondaryTemplateId,isInvitational,status,const DeepCollectionEquality().hash(_expenses),showAwards,const DeepCollectionEquality().hash(_awards),eventType,const DeepCollectionEquality().hash(_manualCuts),eventCost]);

@override
String toString() {
  return 'GolfEvent(id: $id, title: $title, seasonId: $seasonId, date: $date, description: $description, imageUrl: $imageUrl, regTime: $regTime, teeOffTime: $teeOffTime, registrationDeadline: $registrationDeadline, registrations: $registrations, courseName: $courseName, courseDetails: $courseDetails, dressCode: $dressCode, availableBuggies: $availableBuggies, maxParticipants: $maxParticipants, facilities: $facilities, memberCost: $memberCost, guestCost: $guestCost, breakfastCost: $breakfastCost, lunchCost: $lunchCost, dinnerCost: $dinnerCost, buggyCost: $buggyCost, hasBreakfast: $hasBreakfast, hasLunch: $hasLunch, hasDinner: $hasDinner, dinnerLocation: $dinnerLocation, dinnerAddress: $dinnerAddress, societyGreenFee: $societyGreenFee, societyBreakfastCost: $societyBreakfastCost, societyLunchCost: $societyLunchCost, societyDinnerCost: $societyDinnerCost, notes: $notes, galleryUrls: $galleryUrls, showRegistrationButton: $showRegistrationButton, teeOffInterval: $teeOffInterval, isGroupingPublished: $isGroupingPublished, isMultiDay: $isMultiDay, endDate: $endDate, grouping: $grouping, results: $results, courseId: $courseId, courseConfig: $courseConfig, selectedTeeName: $selectedTeeName, selectedFemaleTeeName: $selectedFemaleTeeName, flashUpdates: $flashUpdates, feedItems: $feedItems, isScoringLocked: $isScoringLocked, isStatsReleased: $isStatsReleased, finalizedStats: $finalizedStats, secondaryTemplateId: $secondaryTemplateId, isInvitational: $isInvitational, status: $status, expenses: $expenses, showAwards: $showAwards, awards: $awards, eventType: $eventType, manualCuts: $manualCuts, eventCost: $eventCost)';
}


}

/// @nodoc
abstract mixin class _$GolfEventCopyWith<$Res> implements $GolfEventCopyWith<$Res> {
  factory _$GolfEventCopyWith(_GolfEvent value, $Res Function(_GolfEvent) _then) = __$GolfEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String seasonId,@TimestampConverter() DateTime date, String? description, String? imageUrl,@OptionalTimestampConverter() DateTime? regTime,@OptionalTimestampConverter() DateTime? teeOffTime,@OptionalTimestampConverter() DateTime? registrationDeadline, List<EventRegistration> registrations, String? courseName, String? courseDetails, String? dressCode, int? availableBuggies, int? maxParticipants, List<String> facilities, double? memberCost, double? guestCost, double? breakfastCost, double? lunchCost, double? dinnerCost, double? buggyCost, bool hasBreakfast, bool hasLunch, bool hasDinner, String? dinnerLocation, String? dinnerAddress, double? societyGreenFee, double? societyBreakfastCost, double? societyLunchCost, double? societyDinnerCost, List<EventNote> notes, List<String> galleryUrls, bool showRegistrationButton, int teeOffInterval, bool isGroupingPublished, bool isMultiDay,@OptionalTimestampConverter() DateTime? endDate, Map<String, dynamic> grouping, List<Map<String, dynamic>> results, String? courseId, CourseConfig courseConfig, String? selectedTeeName, String? selectedFemaleTeeName, List<String> flashUpdates, List<EventFeedItem> feedItems, bool isScoringLocked, bool isStatsReleased, Map<String, dynamic> finalizedStats, String? secondaryTemplateId, bool isInvitational, EventStatus status, List<EventExpense> expenses, bool showAwards, List<EventAward> awards, EventType eventType, Map<String, double> manualCuts, double? eventCost
});


@override $CourseConfigCopyWith<$Res> get courseConfig;

}
/// @nodoc
class __$GolfEventCopyWithImpl<$Res>
    implements _$GolfEventCopyWith<$Res> {
  __$GolfEventCopyWithImpl(this._self, this._then);

  final _GolfEvent _self;
  final $Res Function(_GolfEvent) _then;

/// Create a copy of GolfEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? seasonId = null,Object? date = null,Object? description = freezed,Object? imageUrl = freezed,Object? regTime = freezed,Object? teeOffTime = freezed,Object? registrationDeadline = freezed,Object? registrations = null,Object? courseName = freezed,Object? courseDetails = freezed,Object? dressCode = freezed,Object? availableBuggies = freezed,Object? maxParticipants = freezed,Object? facilities = null,Object? memberCost = freezed,Object? guestCost = freezed,Object? breakfastCost = freezed,Object? lunchCost = freezed,Object? dinnerCost = freezed,Object? buggyCost = freezed,Object? hasBreakfast = null,Object? hasLunch = null,Object? hasDinner = null,Object? dinnerLocation = freezed,Object? dinnerAddress = freezed,Object? societyGreenFee = freezed,Object? societyBreakfastCost = freezed,Object? societyLunchCost = freezed,Object? societyDinnerCost = freezed,Object? notes = null,Object? galleryUrls = null,Object? showRegistrationButton = null,Object? teeOffInterval = null,Object? isGroupingPublished = null,Object? isMultiDay = null,Object? endDate = freezed,Object? grouping = null,Object? results = null,Object? courseId = freezed,Object? courseConfig = null,Object? selectedTeeName = freezed,Object? selectedFemaleTeeName = freezed,Object? flashUpdates = null,Object? feedItems = null,Object? isScoringLocked = null,Object? isStatsReleased = null,Object? finalizedStats = null,Object? secondaryTemplateId = freezed,Object? isInvitational = null,Object? status = null,Object? expenses = null,Object? showAwards = null,Object? awards = null,Object? eventType = null,Object? manualCuts = null,Object? eventCost = freezed,}) {
  return _then(_GolfEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,seasonId: null == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,regTime: freezed == regTime ? _self.regTime : regTime // ignore: cast_nullable_to_non_nullable
as DateTime?,teeOffTime: freezed == teeOffTime ? _self.teeOffTime : teeOffTime // ignore: cast_nullable_to_non_nullable
as DateTime?,registrationDeadline: freezed == registrationDeadline ? _self.registrationDeadline : registrationDeadline // ignore: cast_nullable_to_non_nullable
as DateTime?,registrations: null == registrations ? _self._registrations : registrations // ignore: cast_nullable_to_non_nullable
as List<EventRegistration>,courseName: freezed == courseName ? _self.courseName : courseName // ignore: cast_nullable_to_non_nullable
as String?,courseDetails: freezed == courseDetails ? _self.courseDetails : courseDetails // ignore: cast_nullable_to_non_nullable
as String?,dressCode: freezed == dressCode ? _self.dressCode : dressCode // ignore: cast_nullable_to_non_nullable
as String?,availableBuggies: freezed == availableBuggies ? _self.availableBuggies : availableBuggies // ignore: cast_nullable_to_non_nullable
as int?,maxParticipants: freezed == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int?,facilities: null == facilities ? _self._facilities : facilities // ignore: cast_nullable_to_non_nullable
as List<String>,memberCost: freezed == memberCost ? _self.memberCost : memberCost // ignore: cast_nullable_to_non_nullable
as double?,guestCost: freezed == guestCost ? _self.guestCost : guestCost // ignore: cast_nullable_to_non_nullable
as double?,breakfastCost: freezed == breakfastCost ? _self.breakfastCost : breakfastCost // ignore: cast_nullable_to_non_nullable
as double?,lunchCost: freezed == lunchCost ? _self.lunchCost : lunchCost // ignore: cast_nullable_to_non_nullable
as double?,dinnerCost: freezed == dinnerCost ? _self.dinnerCost : dinnerCost // ignore: cast_nullable_to_non_nullable
as double?,buggyCost: freezed == buggyCost ? _self.buggyCost : buggyCost // ignore: cast_nullable_to_non_nullable
as double?,hasBreakfast: null == hasBreakfast ? _self.hasBreakfast : hasBreakfast // ignore: cast_nullable_to_non_nullable
as bool,hasLunch: null == hasLunch ? _self.hasLunch : hasLunch // ignore: cast_nullable_to_non_nullable
as bool,hasDinner: null == hasDinner ? _self.hasDinner : hasDinner // ignore: cast_nullable_to_non_nullable
as bool,dinnerLocation: freezed == dinnerLocation ? _self.dinnerLocation : dinnerLocation // ignore: cast_nullable_to_non_nullable
as String?,dinnerAddress: freezed == dinnerAddress ? _self.dinnerAddress : dinnerAddress // ignore: cast_nullable_to_non_nullable
as String?,societyGreenFee: freezed == societyGreenFee ? _self.societyGreenFee : societyGreenFee // ignore: cast_nullable_to_non_nullable
as double?,societyBreakfastCost: freezed == societyBreakfastCost ? _self.societyBreakfastCost : societyBreakfastCost // ignore: cast_nullable_to_non_nullable
as double?,societyLunchCost: freezed == societyLunchCost ? _self.societyLunchCost : societyLunchCost // ignore: cast_nullable_to_non_nullable
as double?,societyDinnerCost: freezed == societyDinnerCost ? _self.societyDinnerCost : societyDinnerCost // ignore: cast_nullable_to_non_nullable
as double?,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<EventNote>,galleryUrls: null == galleryUrls ? _self._galleryUrls : galleryUrls // ignore: cast_nullable_to_non_nullable
as List<String>,showRegistrationButton: null == showRegistrationButton ? _self.showRegistrationButton : showRegistrationButton // ignore: cast_nullable_to_non_nullable
as bool,teeOffInterval: null == teeOffInterval ? _self.teeOffInterval : teeOffInterval // ignore: cast_nullable_to_non_nullable
as int,isGroupingPublished: null == isGroupingPublished ? _self.isGroupingPublished : isGroupingPublished // ignore: cast_nullable_to_non_nullable
as bool,isMultiDay: null == isMultiDay ? _self.isMultiDay : isMultiDay // ignore: cast_nullable_to_non_nullable
as bool,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,grouping: null == grouping ? _self._grouping : grouping // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,courseId: freezed == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String?,courseConfig: null == courseConfig ? _self.courseConfig : courseConfig // ignore: cast_nullable_to_non_nullable
as CourseConfig,selectedTeeName: freezed == selectedTeeName ? _self.selectedTeeName : selectedTeeName // ignore: cast_nullable_to_non_nullable
as String?,selectedFemaleTeeName: freezed == selectedFemaleTeeName ? _self.selectedFemaleTeeName : selectedFemaleTeeName // ignore: cast_nullable_to_non_nullable
as String?,flashUpdates: null == flashUpdates ? _self._flashUpdates : flashUpdates // ignore: cast_nullable_to_non_nullable
as List<String>,feedItems: null == feedItems ? _self._feedItems : feedItems // ignore: cast_nullable_to_non_nullable
as List<EventFeedItem>,isScoringLocked: null == isScoringLocked ? _self.isScoringLocked : isScoringLocked // ignore: cast_nullable_to_non_nullable
as bool,isStatsReleased: null == isStatsReleased ? _self.isStatsReleased : isStatsReleased // ignore: cast_nullable_to_non_nullable
as bool,finalizedStats: null == finalizedStats ? _self._finalizedStats : finalizedStats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,secondaryTemplateId: freezed == secondaryTemplateId ? _self.secondaryTemplateId : secondaryTemplateId // ignore: cast_nullable_to_non_nullable
as String?,isInvitational: null == isInvitational ? _self.isInvitational : isInvitational // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventStatus,expenses: null == expenses ? _self._expenses : expenses // ignore: cast_nullable_to_non_nullable
as List<EventExpense>,showAwards: null == showAwards ? _self.showAwards : showAwards // ignore: cast_nullable_to_non_nullable
as bool,awards: null == awards ? _self._awards : awards // ignore: cast_nullable_to_non_nullable
as List<EventAward>,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as EventType,manualCuts: null == manualCuts ? _self._manualCuts : manualCuts // ignore: cast_nullable_to_non_nullable
as Map<String, double>,eventCost: freezed == eventCost ? _self.eventCost : eventCost // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

/// Create a copy of GolfEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CourseConfigCopyWith<$Res> get courseConfig {
  
  return $CourseConfigCopyWith<$Res>(_self.courseConfig, (value) {
    return _then(_self.copyWith(courseConfig: value));
  });
}
}

// dart format on
