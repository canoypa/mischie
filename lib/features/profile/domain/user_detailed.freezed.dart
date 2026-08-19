// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_detailed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserDetailed {

 String get id; String get username; String? get name; String? get host; String? get avatarUrl; String? get bannerUrl; String? get bannerBlurhash; String? get description; String? get location; String? get birthday; String? get createdAt; bool get isBot; bool get isCat; bool get isFollowing; bool get isFollowed; bool get isMuted; bool get isBlocking; List<AvatarDecoration> get avatarDecorations; int? get followersCount; int? get followingCount; int? get notesCount; List<ProfileField> get fields;/// 本人が固定した投稿。プロフィールの先頭に出す。
 List<Note> get pinnedNotes; List<UserRole> get roles; Map<String, String> get emojis;
/// Create a copy of UserDetailed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDetailedCopyWith<UserDetailed> get copyWith => _$UserDetailedCopyWithImpl<UserDetailed>(this as UserDetailed, _$identity);

  /// Serializes this UserDetailed to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserDetailed&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.name, name) || other.name == name)&&(identical(other.host, host) || other.host == host)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.bannerBlurhash, bannerBlurhash) || other.bannerBlurhash == bannerBlurhash)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isCat, isCat) || other.isCat == isCat)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.isFollowed, isFollowed) || other.isFollowed == isFollowed)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isBlocking, isBlocking) || other.isBlocking == isBlocking)&&const DeepCollectionEquality().equals(other.avatarDecorations, avatarDecorations)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.notesCount, notesCount) || other.notesCount == notesCount)&&const DeepCollectionEquality().equals(other.fields, fields)&&const DeepCollectionEquality().equals(other.pinnedNotes, pinnedNotes)&&const DeepCollectionEquality().equals(other.roles, roles)&&const DeepCollectionEquality().equals(other.emojis, emojis));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,username,name,host,avatarUrl,bannerUrl,bannerBlurhash,description,location,birthday,createdAt,isBot,isCat,isFollowing,isFollowed,isMuted,isBlocking,const DeepCollectionEquality().hash(avatarDecorations),followersCount,followingCount,notesCount,const DeepCollectionEquality().hash(fields),const DeepCollectionEquality().hash(pinnedNotes),const DeepCollectionEquality().hash(roles),const DeepCollectionEquality().hash(emojis)]);

@override
String toString() {
  return 'UserDetailed(id: $id, username: $username, name: $name, host: $host, avatarUrl: $avatarUrl, bannerUrl: $bannerUrl, bannerBlurhash: $bannerBlurhash, description: $description, location: $location, birthday: $birthday, createdAt: $createdAt, isBot: $isBot, isCat: $isCat, isFollowing: $isFollowing, isFollowed: $isFollowed, isMuted: $isMuted, isBlocking: $isBlocking, avatarDecorations: $avatarDecorations, followersCount: $followersCount, followingCount: $followingCount, notesCount: $notesCount, fields: $fields, pinnedNotes: $pinnedNotes, roles: $roles, emojis: $emojis)';
}


}

/// @nodoc
abstract mixin class $UserDetailedCopyWith<$Res>  {
  factory $UserDetailedCopyWith(UserDetailed value, $Res Function(UserDetailed) _then) = _$UserDetailedCopyWithImpl;
@useResult
$Res call({
 String id, String username, String? name, String? host, String? avatarUrl, String? bannerUrl, String? bannerBlurhash, String? description, String? location, String? birthday, String? createdAt, bool isBot, bool isCat, bool isFollowing, bool isFollowed, bool isMuted, bool isBlocking, List<AvatarDecoration> avatarDecorations, int? followersCount, int? followingCount, int? notesCount, List<ProfileField> fields, List<Note> pinnedNotes, List<UserRole> roles, Map<String, String> emojis
});




}
/// @nodoc
class _$UserDetailedCopyWithImpl<$Res>
    implements $UserDetailedCopyWith<$Res> {
  _$UserDetailedCopyWithImpl(this._self, this._then);

  final UserDetailed _self;
  final $Res Function(UserDetailed) _then;

/// Create a copy of UserDetailed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? name = freezed,Object? host = freezed,Object? avatarUrl = freezed,Object? bannerUrl = freezed,Object? bannerBlurhash = freezed,Object? description = freezed,Object? location = freezed,Object? birthday = freezed,Object? createdAt = freezed,Object? isBot = null,Object? isCat = null,Object? isFollowing = null,Object? isFollowed = null,Object? isMuted = null,Object? isBlocking = null,Object? avatarDecorations = null,Object? followersCount = freezed,Object? followingCount = freezed,Object? notesCount = freezed,Object? fields = null,Object? pinnedNotes = null,Object? roles = null,Object? emojis = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerBlurhash: freezed == bannerBlurhash ? _self.bannerBlurhash : bannerBlurhash // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,isCat: null == isCat ? _self.isCat : isCat // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,isFollowed: null == isFollowed ? _self.isFollowed : isFollowed // ignore: cast_nullable_to_non_nullable
as bool,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isBlocking: null == isBlocking ? _self.isBlocking : isBlocking // ignore: cast_nullable_to_non_nullable
as bool,avatarDecorations: null == avatarDecorations ? _self.avatarDecorations : avatarDecorations // ignore: cast_nullable_to_non_nullable
as List<AvatarDecoration>,followersCount: freezed == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int?,followingCount: freezed == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int?,notesCount: freezed == notesCount ? _self.notesCount : notesCount // ignore: cast_nullable_to_non_nullable
as int?,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<ProfileField>,pinnedNotes: null == pinnedNotes ? _self.pinnedNotes : pinnedNotes // ignore: cast_nullable_to_non_nullable
as List<Note>,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<UserRole>,emojis: null == emojis ? _self.emojis : emojis // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserDetailed].
extension UserDetailedPatterns on UserDetailed {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDetailed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDetailed() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDetailed value)  $default,){
final _that = this;
switch (_that) {
case _UserDetailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDetailed value)?  $default,){
final _that = this;
switch (_that) {
case _UserDetailed() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String? name,  String? host,  String? avatarUrl,  String? bannerUrl,  String? bannerBlurhash,  String? description,  String? location,  String? birthday,  String? createdAt,  bool isBot,  bool isCat,  bool isFollowing,  bool isFollowed,  bool isMuted,  bool isBlocking,  List<AvatarDecoration> avatarDecorations,  int? followersCount,  int? followingCount,  int? notesCount,  List<ProfileField> fields,  List<Note> pinnedNotes,  List<UserRole> roles,  Map<String, String> emojis)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDetailed() when $default != null:
return $default(_that.id,_that.username,_that.name,_that.host,_that.avatarUrl,_that.bannerUrl,_that.bannerBlurhash,_that.description,_that.location,_that.birthday,_that.createdAt,_that.isBot,_that.isCat,_that.isFollowing,_that.isFollowed,_that.isMuted,_that.isBlocking,_that.avatarDecorations,_that.followersCount,_that.followingCount,_that.notesCount,_that.fields,_that.pinnedNotes,_that.roles,_that.emojis);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String? name,  String? host,  String? avatarUrl,  String? bannerUrl,  String? bannerBlurhash,  String? description,  String? location,  String? birthday,  String? createdAt,  bool isBot,  bool isCat,  bool isFollowing,  bool isFollowed,  bool isMuted,  bool isBlocking,  List<AvatarDecoration> avatarDecorations,  int? followersCount,  int? followingCount,  int? notesCount,  List<ProfileField> fields,  List<Note> pinnedNotes,  List<UserRole> roles,  Map<String, String> emojis)  $default,) {final _that = this;
switch (_that) {
case _UserDetailed():
return $default(_that.id,_that.username,_that.name,_that.host,_that.avatarUrl,_that.bannerUrl,_that.bannerBlurhash,_that.description,_that.location,_that.birthday,_that.createdAt,_that.isBot,_that.isCat,_that.isFollowing,_that.isFollowed,_that.isMuted,_that.isBlocking,_that.avatarDecorations,_that.followersCount,_that.followingCount,_that.notesCount,_that.fields,_that.pinnedNotes,_that.roles,_that.emojis);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String? name,  String? host,  String? avatarUrl,  String? bannerUrl,  String? bannerBlurhash,  String? description,  String? location,  String? birthday,  String? createdAt,  bool isBot,  bool isCat,  bool isFollowing,  bool isFollowed,  bool isMuted,  bool isBlocking,  List<AvatarDecoration> avatarDecorations,  int? followersCount,  int? followingCount,  int? notesCount,  List<ProfileField> fields,  List<Note> pinnedNotes,  List<UserRole> roles,  Map<String, String> emojis)?  $default,) {final _that = this;
switch (_that) {
case _UserDetailed() when $default != null:
return $default(_that.id,_that.username,_that.name,_that.host,_that.avatarUrl,_that.bannerUrl,_that.bannerBlurhash,_that.description,_that.location,_that.birthday,_that.createdAt,_that.isBot,_that.isCat,_that.isFollowing,_that.isFollowed,_that.isMuted,_that.isBlocking,_that.avatarDecorations,_that.followersCount,_that.followingCount,_that.notesCount,_that.fields,_that.pinnedNotes,_that.roles,_that.emojis);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDetailed implements UserDetailed {
  const _UserDetailed({required this.id, required this.username, this.name, this.host, this.avatarUrl, this.bannerUrl, this.bannerBlurhash, this.description, this.location, this.birthday, this.createdAt, this.isBot = false, this.isCat = false, this.isFollowing = false, this.isFollowed = false, this.isMuted = false, this.isBlocking = false, final  List<AvatarDecoration> avatarDecorations = const [], this.followersCount, this.followingCount, this.notesCount, final  List<ProfileField> fields = const [], final  List<Note> pinnedNotes = const [], final  List<UserRole> roles = const [], final  Map<String, String> emojis = const {}}): _avatarDecorations = avatarDecorations,_fields = fields,_pinnedNotes = pinnedNotes,_roles = roles,_emojis = emojis;
  factory _UserDetailed.fromJson(Map<String, dynamic> json) => _$UserDetailedFromJson(json);

@override final  String id;
@override final  String username;
@override final  String? name;
@override final  String? host;
@override final  String? avatarUrl;
@override final  String? bannerUrl;
@override final  String? bannerBlurhash;
@override final  String? description;
@override final  String? location;
@override final  String? birthday;
@override final  String? createdAt;
@override@JsonKey() final  bool isBot;
@override@JsonKey() final  bool isCat;
@override@JsonKey() final  bool isFollowing;
@override@JsonKey() final  bool isFollowed;
@override@JsonKey() final  bool isMuted;
@override@JsonKey() final  bool isBlocking;
 final  List<AvatarDecoration> _avatarDecorations;
@override@JsonKey() List<AvatarDecoration> get avatarDecorations {
  if (_avatarDecorations is EqualUnmodifiableListView) return _avatarDecorations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_avatarDecorations);
}

@override final  int? followersCount;
@override final  int? followingCount;
@override final  int? notesCount;
 final  List<ProfileField> _fields;
@override@JsonKey() List<ProfileField> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}

/// 本人が固定した投稿。プロフィールの先頭に出す。
 final  List<Note> _pinnedNotes;
/// 本人が固定した投稿。プロフィールの先頭に出す。
@override@JsonKey() List<Note> get pinnedNotes {
  if (_pinnedNotes is EqualUnmodifiableListView) return _pinnedNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pinnedNotes);
}

 final  List<UserRole> _roles;
@override@JsonKey() List<UserRole> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

 final  Map<String, String> _emojis;
@override@JsonKey() Map<String, String> get emojis {
  if (_emojis is EqualUnmodifiableMapView) return _emojis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_emojis);
}


/// Create a copy of UserDetailed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDetailedCopyWith<_UserDetailed> get copyWith => __$UserDetailedCopyWithImpl<_UserDetailed>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDetailedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserDetailed&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.name, name) || other.name == name)&&(identical(other.host, host) || other.host == host)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.bannerBlurhash, bannerBlurhash) || other.bannerBlurhash == bannerBlurhash)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isCat, isCat) || other.isCat == isCat)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.isFollowed, isFollowed) || other.isFollowed == isFollowed)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isBlocking, isBlocking) || other.isBlocking == isBlocking)&&const DeepCollectionEquality().equals(other._avatarDecorations, _avatarDecorations)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.notesCount, notesCount) || other.notesCount == notesCount)&&const DeepCollectionEquality().equals(other._fields, _fields)&&const DeepCollectionEquality().equals(other._pinnedNotes, _pinnedNotes)&&const DeepCollectionEquality().equals(other._roles, _roles)&&const DeepCollectionEquality().equals(other._emojis, _emojis));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,username,name,host,avatarUrl,bannerUrl,bannerBlurhash,description,location,birthday,createdAt,isBot,isCat,isFollowing,isFollowed,isMuted,isBlocking,const DeepCollectionEquality().hash(_avatarDecorations),followersCount,followingCount,notesCount,const DeepCollectionEquality().hash(_fields),const DeepCollectionEquality().hash(_pinnedNotes),const DeepCollectionEquality().hash(_roles),const DeepCollectionEquality().hash(_emojis)]);

@override
String toString() {
  return 'UserDetailed(id: $id, username: $username, name: $name, host: $host, avatarUrl: $avatarUrl, bannerUrl: $bannerUrl, bannerBlurhash: $bannerBlurhash, description: $description, location: $location, birthday: $birthday, createdAt: $createdAt, isBot: $isBot, isCat: $isCat, isFollowing: $isFollowing, isFollowed: $isFollowed, isMuted: $isMuted, isBlocking: $isBlocking, avatarDecorations: $avatarDecorations, followersCount: $followersCount, followingCount: $followingCount, notesCount: $notesCount, fields: $fields, pinnedNotes: $pinnedNotes, roles: $roles, emojis: $emojis)';
}


}

/// @nodoc
abstract mixin class _$UserDetailedCopyWith<$Res> implements $UserDetailedCopyWith<$Res> {
  factory _$UserDetailedCopyWith(_UserDetailed value, $Res Function(_UserDetailed) _then) = __$UserDetailedCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String? name, String? host, String? avatarUrl, String? bannerUrl, String? bannerBlurhash, String? description, String? location, String? birthday, String? createdAt, bool isBot, bool isCat, bool isFollowing, bool isFollowed, bool isMuted, bool isBlocking, List<AvatarDecoration> avatarDecorations, int? followersCount, int? followingCount, int? notesCount, List<ProfileField> fields, List<Note> pinnedNotes, List<UserRole> roles, Map<String, String> emojis
});




}
/// @nodoc
class __$UserDetailedCopyWithImpl<$Res>
    implements _$UserDetailedCopyWith<$Res> {
  __$UserDetailedCopyWithImpl(this._self, this._then);

  final _UserDetailed _self;
  final $Res Function(_UserDetailed) _then;

/// Create a copy of UserDetailed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? name = freezed,Object? host = freezed,Object? avatarUrl = freezed,Object? bannerUrl = freezed,Object? bannerBlurhash = freezed,Object? description = freezed,Object? location = freezed,Object? birthday = freezed,Object? createdAt = freezed,Object? isBot = null,Object? isCat = null,Object? isFollowing = null,Object? isFollowed = null,Object? isMuted = null,Object? isBlocking = null,Object? avatarDecorations = null,Object? followersCount = freezed,Object? followingCount = freezed,Object? notesCount = freezed,Object? fields = null,Object? pinnedNotes = null,Object? roles = null,Object? emojis = null,}) {
  return _then(_UserDetailed(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerBlurhash: freezed == bannerBlurhash ? _self.bannerBlurhash : bannerBlurhash // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,isCat: null == isCat ? _self.isCat : isCat // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,isFollowed: null == isFollowed ? _self.isFollowed : isFollowed // ignore: cast_nullable_to_non_nullable
as bool,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isBlocking: null == isBlocking ? _self.isBlocking : isBlocking // ignore: cast_nullable_to_non_nullable
as bool,avatarDecorations: null == avatarDecorations ? _self._avatarDecorations : avatarDecorations // ignore: cast_nullable_to_non_nullable
as List<AvatarDecoration>,followersCount: freezed == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int?,followingCount: freezed == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int?,notesCount: freezed == notesCount ? _self.notesCount : notesCount // ignore: cast_nullable_to_non_nullable
as int?,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<ProfileField>,pinnedNotes: null == pinnedNotes ? _self._pinnedNotes : pinnedNotes // ignore: cast_nullable_to_non_nullable
as List<Note>,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<UserRole>,emojis: null == emojis ? _self._emojis : emojis // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}


/// @nodoc
mixin _$ProfileField {

 String get name; String get value;
/// Create a copy of ProfileField
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileFieldCopyWith<ProfileField> get copyWith => _$ProfileFieldCopyWithImpl<ProfileField>(this as ProfileField, _$identity);

  /// Serializes this ProfileField to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileField&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,value);

@override
String toString() {
  return 'ProfileField(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class $ProfileFieldCopyWith<$Res>  {
  factory $ProfileFieldCopyWith(ProfileField value, $Res Function(ProfileField) _then) = _$ProfileFieldCopyWithImpl;
@useResult
$Res call({
 String name, String value
});




}
/// @nodoc
class _$ProfileFieldCopyWithImpl<$Res>
    implements $ProfileFieldCopyWith<$Res> {
  _$ProfileFieldCopyWithImpl(this._self, this._then);

  final ProfileField _self;
  final $Res Function(ProfileField) _then;

/// Create a copy of ProfileField
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? value = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileField].
extension ProfileFieldPatterns on ProfileField {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileField value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileField() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileField value)  $default,){
final _that = this;
switch (_that) {
case _ProfileField():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileField value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileField() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileField() when $default != null:
return $default(_that.name,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String value)  $default,) {final _that = this;
switch (_that) {
case _ProfileField():
return $default(_that.name,_that.value);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String value)?  $default,) {final _that = this;
switch (_that) {
case _ProfileField() when $default != null:
return $default(_that.name,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileField implements ProfileField {
  const _ProfileField({this.name = '', this.value = ''});
  factory _ProfileField.fromJson(Map<String, dynamic> json) => _$ProfileFieldFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  String value;

/// Create a copy of ProfileField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileFieldCopyWith<_ProfileField> get copyWith => __$ProfileFieldCopyWithImpl<_ProfileField>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileFieldToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileField&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,value);

@override
String toString() {
  return 'ProfileField(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class _$ProfileFieldCopyWith<$Res> implements $ProfileFieldCopyWith<$Res> {
  factory _$ProfileFieldCopyWith(_ProfileField value, $Res Function(_ProfileField) _then) = __$ProfileFieldCopyWithImpl;
@override @useResult
$Res call({
 String name, String value
});




}
/// @nodoc
class __$ProfileFieldCopyWithImpl<$Res>
    implements _$ProfileFieldCopyWith<$Res> {
  __$ProfileFieldCopyWithImpl(this._self, this._then);

  final _ProfileField _self;
  final $Res Function(_ProfileField) _then;

/// Create a copy of ProfileField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? value = null,}) {
  return _then(_ProfileField(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserRole {

 String get id; String get name; String? get color; String? get iconUrl;
/// Create a copy of UserRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserRoleCopyWith<UserRole> get copyWith => _$UserRoleCopyWithImpl<UserRole>(this as UserRole, _$identity);

  /// Serializes this UserRole to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserRole&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color,iconUrl);

@override
String toString() {
  return 'UserRole(id: $id, name: $name, color: $color, iconUrl: $iconUrl)';
}


}

/// @nodoc
abstract mixin class $UserRoleCopyWith<$Res>  {
  factory $UserRoleCopyWith(UserRole value, $Res Function(UserRole) _then) = _$UserRoleCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? color, String? iconUrl
});




}
/// @nodoc
class _$UserRoleCopyWithImpl<$Res>
    implements $UserRoleCopyWith<$Res> {
  _$UserRoleCopyWithImpl(this._self, this._then);

  final UserRole _self;
  final $Res Function(UserRole) _then;

/// Create a copy of UserRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? color = freezed,Object? iconUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserRole].
extension UserRolePatterns on UserRole {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserRole value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserRole() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserRole value)  $default,){
final _that = this;
switch (_that) {
case _UserRole():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserRole value)?  $default,){
final _that = this;
switch (_that) {
case _UserRole() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? color,  String? iconUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserRole() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.iconUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? color,  String? iconUrl)  $default,) {final _that = this;
switch (_that) {
case _UserRole():
return $default(_that.id,_that.name,_that.color,_that.iconUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? color,  String? iconUrl)?  $default,) {final _that = this;
switch (_that) {
case _UserRole() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.iconUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserRole implements UserRole {
  const _UserRole({required this.id, this.name = '', this.color, this.iconUrl});
  factory _UserRole.fromJson(Map<String, dynamic> json) => _$UserRoleFromJson(json);

@override final  String id;
@override@JsonKey() final  String name;
@override final  String? color;
@override final  String? iconUrl;

/// Create a copy of UserRole
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserRoleCopyWith<_UserRole> get copyWith => __$UserRoleCopyWithImpl<_UserRole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserRoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserRole&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color,iconUrl);

@override
String toString() {
  return 'UserRole(id: $id, name: $name, color: $color, iconUrl: $iconUrl)';
}


}

/// @nodoc
abstract mixin class _$UserRoleCopyWith<$Res> implements $UserRoleCopyWith<$Res> {
  factory _$UserRoleCopyWith(_UserRole value, $Res Function(_UserRole) _then) = __$UserRoleCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? color, String? iconUrl
});




}
/// @nodoc
class __$UserRoleCopyWithImpl<$Res>
    implements _$UserRoleCopyWith<$Res> {
  __$UserRoleCopyWithImpl(this._self, this._then);

  final _UserRole _self;
  final $Res Function(_UserRole) _then;

/// Create a copy of UserRole
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? color = freezed,Object? iconUrl = freezed,}) {
  return _then(_UserRole(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
