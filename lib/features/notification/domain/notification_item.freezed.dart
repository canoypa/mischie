// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationItem {

 String get id; String get createdAt; String get type; User? get user; Note? get note; String? get reaction;/// `reaction:grouped` の中身。新しい順。
 List<GroupedReaction>? get reactions;/// `renote:grouped` の相手。新しい順。
 List<User>? get users;
/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationItemCopyWith<NotificationItem> get copyWith => _$NotificationItemCopyWithImpl<NotificationItem>(this as NotificationItem, _$identity);

  /// Serializes this NotificationItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotificationItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.reaction, _this.reaction) || other.reaction == _this.reaction)&&const DeepCollectionEquality().equals(other.reactions, _this.reactions)&&const DeepCollectionEquality().equals(other.users, _this.users));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationItem;
  return Object.hash(runtimeType,_this.id,_this.createdAt,_this.type,_this.user,_this.note,_this.reaction,const DeepCollectionEquality().hash(_this.reactions),const DeepCollectionEquality().hash(_this.users));
}

@override
String toString() {
  final _this = this as NotificationItem;
  return 'NotificationItem(id: ${_this.id}, createdAt: ${_this.createdAt}, type: ${_this.type}, user: ${_this.user}, note: ${_this.note}, reaction: ${_this.reaction}, reactions: ${_this.reactions}, users: ${_this.users})';
}


}

/// @nodoc
abstract mixin class $NotificationItemCopyWith<$Res>  {
  factory $NotificationItemCopyWith(NotificationItem value, $Res Function(NotificationItem) _then) = _$NotificationItemCopyWithImpl;
@useResult
$Res call({
 String id, String createdAt, String type, User? user, Note? note, String? reaction, List<GroupedReaction>? reactions, List<User>? users
});


$UserCopyWith<$Res>? get user;$NoteCopyWith<$Res>? get note;

}
/// @nodoc
class _$NotificationItemCopyWithImpl<$Res>
    implements $NotificationItemCopyWith<$Res> {
  _$NotificationItemCopyWithImpl(this._self, this._then);

  final NotificationItem _self;
  final $Res Function(NotificationItem) _then;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? type = null,Object? user = freezed,Object? note = freezed,Object? reaction = freezed,Object? reactions = freezed,Object? users = freezed,}) {
  return _then(NotificationItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as Note?,reaction: freezed == reaction ? _self.reaction : reaction // ignore: cast_nullable_to_non_nullable
as String?,reactions: freezed == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<GroupedReaction>?,users: freezed == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<User>?,
  ));
}
/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteCopyWith<$Res>? get note {
    if (_self.note == null) {
    return null;
  }

  return $NoteCopyWith<$Res>(_self.note!, (value) {
    return _then(_self.copyWith(note: value));
  });
}
}


/// Adds pattern-matching-related methods to [NotificationItem].
extension NotificationItemPatterns on NotificationItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationItem value)  $default,){
final _that = this;
switch (_that) {
case _NotificationItem():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationItem value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String createdAt,  String type,  User? user,  Note? note,  String? reaction,  List<GroupedReaction>? reactions,  List<User>? users)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
return $default(_that.id,_that.createdAt,_that.type,_that.user,_that.note,_that.reaction,_that.reactions,_that.users);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String createdAt,  String type,  User? user,  Note? note,  String? reaction,  List<GroupedReaction>? reactions,  List<User>? users)  $default,) {final _that = this;
switch (_that) {
case _NotificationItem():
return $default(_that.id,_that.createdAt,_that.type,_that.user,_that.note,_that.reaction,_that.reactions,_that.users);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String createdAt,  String type,  User? user,  Note? note,  String? reaction,  List<GroupedReaction>? reactions,  List<User>? users)?  $default,) {final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
return $default(_that.id,_that.createdAt,_that.type,_that.user,_that.note,_that.reaction,_that.reactions,_that.users);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationItem implements NotificationItem {
  const _NotificationItem({required this.id, required this.createdAt, required this.type, this.user, this.note, this.reaction,  List<GroupedReaction>? reactions,  List<User>? users}): _reactions = reactions,_users = users;
  factory _NotificationItem.fromJson(Map<String, dynamic> json) => _$NotificationItemFromJson(json);

@override final  String id;
@override final  String createdAt;
@override final  String type;
@override final  User? user;
@override final  Note? note;
@override final  String? reaction;
/// `reaction:grouped` の中身。新しい順。
 final  List<GroupedReaction>? _reactions;
/// `reaction:grouped` の中身。新しい順。
@override List<GroupedReaction>? get reactions {
  final value = _reactions;
  if (value == null) return null;
  if (_reactions is EqualUnmodifiableListView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// `renote:grouped` の相手。新しい順。
 final  List<User>? _users;
/// `renote:grouped` の相手。新しい順。
@override List<User>? get users {
  final value = _users;
  if (value == null) return null;
  if (_users is EqualUnmodifiableListView) return _users;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationItemCopyWith<_NotificationItem> get copyWith => __$NotificationItemCopyWithImpl<_NotificationItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationItem&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.user, user) || other.user == user)&&(identical(other.note, note) || other.note == note)&&(identical(other.reaction, reaction) || other.reaction == reaction)&&const DeepCollectionEquality().equals(other.reactions, _reactions)&&const DeepCollectionEquality().equals(other.users, _users));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,createdAt,type,user,note,reaction,const DeepCollectionEquality().hash(_reactions),const DeepCollectionEquality().hash(_users));
}

@override
String toString() {
    return 'NotificationItem(id: $id, createdAt: $createdAt, type: $type, user: $user, note: $note, reaction: $reaction, reactions: $reactions, users: $users)';
}


}

/// @nodoc
abstract mixin class _$NotificationItemCopyWith<$Res> implements $NotificationItemCopyWith<$Res> {
  factory _$NotificationItemCopyWith(_NotificationItem value, $Res Function(_NotificationItem) _then) = __$NotificationItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String createdAt, String type, User? user, Note? note, String? reaction, List<GroupedReaction>? reactions, List<User>? users
});


@override $UserCopyWith<$Res>? get user;@override $NoteCopyWith<$Res>? get note;

}
/// @nodoc
class __$NotificationItemCopyWithImpl<$Res>
    implements _$NotificationItemCopyWith<$Res> {
  __$NotificationItemCopyWithImpl(this._self, this._then);

  final _NotificationItem _self;
  final $Res Function(_NotificationItem) _then;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? type = null,Object? user = freezed,Object? note = freezed,Object? reaction = freezed,Object? reactions = freezed,Object? users = freezed,}) {
  return _then(_NotificationItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as Note?,reaction: freezed == reaction ? _self.reaction : reaction // ignore: cast_nullable_to_non_nullable
as String?,reactions: freezed == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<GroupedReaction>?,users: freezed == users ? _self._users : users // ignore: cast_nullable_to_non_nullable
as List<User>?,
  ));
}

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteCopyWith<$Res>? get note {
    if (_self.note == null) {
    return null;
  }

  return $NoteCopyWith<$Res>(_self.note!, (value) {
    return _then(_self.copyWith(note: value));
  });
}
}


/// @nodoc
mixin _$GroupedReaction {

 User get user; String get reaction;
/// Create a copy of GroupedReaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupedReactionCopyWith<GroupedReaction> get copyWith => _$GroupedReactionCopyWithImpl<GroupedReaction>(this as GroupedReaction, _$identity);

  /// Serializes this GroupedReaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GroupedReaction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupedReaction&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.reaction, _this.reaction) || other.reaction == _this.reaction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GroupedReaction;
  return Object.hash(runtimeType,_this.user,_this.reaction);
}

@override
String toString() {
  final _this = this as GroupedReaction;
  return 'GroupedReaction(user: ${_this.user}, reaction: ${_this.reaction})';
}


}

/// @nodoc
abstract mixin class $GroupedReactionCopyWith<$Res>  {
  factory $GroupedReactionCopyWith(GroupedReaction value, $Res Function(GroupedReaction) _then) = _$GroupedReactionCopyWithImpl;
@useResult
$Res call({
 User user, String reaction
});


$UserCopyWith<$Res> get user;

}
/// @nodoc
class _$GroupedReactionCopyWithImpl<$Res>
    implements $GroupedReactionCopyWith<$Res> {
  _$GroupedReactionCopyWithImpl(this._self, this._then);

  final GroupedReaction _self;
  final $Res Function(GroupedReaction) _then;

/// Create a copy of GroupedReaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? reaction = null,}) {
  return _then(GroupedReaction(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,reaction: null == reaction ? _self.reaction : reaction // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of GroupedReaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupedReaction].
extension GroupedReactionPatterns on GroupedReaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupedReaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupedReaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupedReaction value)  $default,){
final _that = this;
switch (_that) {
case _GroupedReaction():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupedReaction value)?  $default,){
final _that = this;
switch (_that) {
case _GroupedReaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User user,  String reaction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupedReaction() when $default != null:
return $default(_that.user,_that.reaction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User user,  String reaction)  $default,) {final _that = this;
switch (_that) {
case _GroupedReaction():
return $default(_that.user,_that.reaction);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User user,  String reaction)?  $default,) {final _that = this;
switch (_that) {
case _GroupedReaction() when $default != null:
return $default(_that.user,_that.reaction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupedReaction implements GroupedReaction {
  const _GroupedReaction({required this.user, required this.reaction});
  factory _GroupedReaction.fromJson(Map<String, dynamic> json) => _$GroupedReactionFromJson(json);

@override final  User user;
@override final  String reaction;

/// Create a copy of GroupedReaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupedReactionCopyWith<_GroupedReaction> get copyWith => __$GroupedReactionCopyWithImpl<_GroupedReaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupedReactionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupedReaction&&(identical(other.user, user) || other.user == user)&&(identical(other.reaction, reaction) || other.reaction == reaction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,user,reaction);
}

@override
String toString() {
    return 'GroupedReaction(user: $user, reaction: $reaction)';
}


}

/// @nodoc
abstract mixin class _$GroupedReactionCopyWith<$Res> implements $GroupedReactionCopyWith<$Res> {
  factory _$GroupedReactionCopyWith(_GroupedReaction value, $Res Function(_GroupedReaction) _then) = __$GroupedReactionCopyWithImpl;
@override @useResult
$Res call({
 User user, String reaction
});


@override $UserCopyWith<$Res> get user;

}
/// @nodoc
class __$GroupedReactionCopyWithImpl<$Res>
    implements _$GroupedReactionCopyWith<$Res> {
  __$GroupedReactionCopyWithImpl(this._self, this._then);

  final _GroupedReaction _self;
  final $Res Function(_GroupedReaction) _then;

/// Create a copy of GroupedReaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? reaction = null,}) {
  return _then(_GroupedReaction(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,reaction: null == reaction ? _self.reaction : reaction // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of GroupedReaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
