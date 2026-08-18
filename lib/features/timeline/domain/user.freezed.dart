// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String get id; String get username; String? get name; String? get avatarUrl; String? get host; bool get isCat; bool get isBot; List<AvatarDecoration> get avatarDecorations;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.host, host) || other.host == host)&&(identical(other.isCat, isCat) || other.isCat == isCat)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&const DeepCollectionEquality().equals(other.avatarDecorations, avatarDecorations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,name,avatarUrl,host,isCat,isBot,const DeepCollectionEquality().hash(avatarDecorations));

@override
String toString() {
  return 'User(id: $id, username: $username, name: $name, avatarUrl: $avatarUrl, host: $host, isCat: $isCat, isBot: $isBot, avatarDecorations: $avatarDecorations)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String username, String? name, String? avatarUrl, String? host, bool isCat, bool isBot, List<AvatarDecoration> avatarDecorations
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? name = freezed,Object? avatarUrl = freezed,Object? host = freezed,Object? isCat = null,Object? isBot = null,Object? avatarDecorations = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String?,isCat: null == isCat ? _self.isCat : isCat // ignore: cast_nullable_to_non_nullable
as bool,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,avatarDecorations: null == avatarDecorations ? _self.avatarDecorations : avatarDecorations // ignore: cast_nullable_to_non_nullable
as List<AvatarDecoration>,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String? name,  String? avatarUrl,  String? host,  bool isCat,  bool isBot,  List<AvatarDecoration> avatarDecorations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.username,_that.name,_that.avatarUrl,_that.host,_that.isCat,_that.isBot,_that.avatarDecorations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String? name,  String? avatarUrl,  String? host,  bool isCat,  bool isBot,  List<AvatarDecoration> avatarDecorations)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.username,_that.name,_that.avatarUrl,_that.host,_that.isCat,_that.isBot,_that.avatarDecorations);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String? name,  String? avatarUrl,  String? host,  bool isCat,  bool isBot,  List<AvatarDecoration> avatarDecorations)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.username,_that.name,_that.avatarUrl,_that.host,_that.isCat,_that.isBot,_that.avatarDecorations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.id, required this.username, this.name, this.avatarUrl, this.host, this.isCat = false, this.isBot = false, final  List<AvatarDecoration> avatarDecorations = const []}): _avatarDecorations = avatarDecorations;
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String username;
@override final  String? name;
@override final  String? avatarUrl;
@override final  String? host;
@override@JsonKey() final  bool isCat;
@override@JsonKey() final  bool isBot;
 final  List<AvatarDecoration> _avatarDecorations;
@override@JsonKey() List<AvatarDecoration> get avatarDecorations {
  if (_avatarDecorations is EqualUnmodifiableListView) return _avatarDecorations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_avatarDecorations);
}


/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.host, host) || other.host == host)&&(identical(other.isCat, isCat) || other.isCat == isCat)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&const DeepCollectionEquality().equals(other._avatarDecorations, _avatarDecorations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,name,avatarUrl,host,isCat,isBot,const DeepCollectionEquality().hash(_avatarDecorations));

@override
String toString() {
  return 'User(id: $id, username: $username, name: $name, avatarUrl: $avatarUrl, host: $host, isCat: $isCat, isBot: $isBot, avatarDecorations: $avatarDecorations)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String? name, String? avatarUrl, String? host, bool isCat, bool isBot, List<AvatarDecoration> avatarDecorations
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? name = freezed,Object? avatarUrl = freezed,Object? host = freezed,Object? isCat = null,Object? isBot = null,Object? avatarDecorations = null,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String?,isCat: null == isCat ? _self.isCat : isCat // ignore: cast_nullable_to_non_nullable
as bool,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,avatarDecorations: null == avatarDecorations ? _self._avatarDecorations : avatarDecorations // ignore: cast_nullable_to_non_nullable
as List<AvatarDecoration>,
  ));
}


}


/// @nodoc
mixin _$AvatarDecoration {

 String get id; String get url; double get angle; bool get flipH; double get offsetX; double get offsetY;
/// Create a copy of AvatarDecoration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvatarDecorationCopyWith<AvatarDecoration> get copyWith => _$AvatarDecorationCopyWithImpl<AvatarDecoration>(this as AvatarDecoration, _$identity);

  /// Serializes this AvatarDecoration to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvatarDecoration&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.angle, angle) || other.angle == angle)&&(identical(other.flipH, flipH) || other.flipH == flipH)&&(identical(other.offsetX, offsetX) || other.offsetX == offsetX)&&(identical(other.offsetY, offsetY) || other.offsetY == offsetY));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,angle,flipH,offsetX,offsetY);

@override
String toString() {
  return 'AvatarDecoration(id: $id, url: $url, angle: $angle, flipH: $flipH, offsetX: $offsetX, offsetY: $offsetY)';
}


}

/// @nodoc
abstract mixin class $AvatarDecorationCopyWith<$Res>  {
  factory $AvatarDecorationCopyWith(AvatarDecoration value, $Res Function(AvatarDecoration) _then) = _$AvatarDecorationCopyWithImpl;
@useResult
$Res call({
 String id, String url, double angle, bool flipH, double offsetX, double offsetY
});




}
/// @nodoc
class _$AvatarDecorationCopyWithImpl<$Res>
    implements $AvatarDecorationCopyWith<$Res> {
  _$AvatarDecorationCopyWithImpl(this._self, this._then);

  final AvatarDecoration _self;
  final $Res Function(AvatarDecoration) _then;

/// Create a copy of AvatarDecoration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? angle = null,Object? flipH = null,Object? offsetX = null,Object? offsetY = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,angle: null == angle ? _self.angle : angle // ignore: cast_nullable_to_non_nullable
as double,flipH: null == flipH ? _self.flipH : flipH // ignore: cast_nullable_to_non_nullable
as bool,offsetX: null == offsetX ? _self.offsetX : offsetX // ignore: cast_nullable_to_non_nullable
as double,offsetY: null == offsetY ? _self.offsetY : offsetY // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AvatarDecoration].
extension AvatarDecorationPatterns on AvatarDecoration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvatarDecoration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvatarDecoration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvatarDecoration value)  $default,){
final _that = this;
switch (_that) {
case _AvatarDecoration():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvatarDecoration value)?  $default,){
final _that = this;
switch (_that) {
case _AvatarDecoration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url,  double angle,  bool flipH,  double offsetX,  double offsetY)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvatarDecoration() when $default != null:
return $default(_that.id,_that.url,_that.angle,_that.flipH,_that.offsetX,_that.offsetY);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url,  double angle,  bool flipH,  double offsetX,  double offsetY)  $default,) {final _that = this;
switch (_that) {
case _AvatarDecoration():
return $default(_that.id,_that.url,_that.angle,_that.flipH,_that.offsetX,_that.offsetY);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url,  double angle,  bool flipH,  double offsetX,  double offsetY)?  $default,) {final _that = this;
switch (_that) {
case _AvatarDecoration() when $default != null:
return $default(_that.id,_that.url,_that.angle,_that.flipH,_that.offsetX,_that.offsetY);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AvatarDecoration implements AvatarDecoration {
  const _AvatarDecoration({required this.id, required this.url, this.angle = 0, this.flipH = false, this.offsetX = 0, this.offsetY = 0});
  factory _AvatarDecoration.fromJson(Map<String, dynamic> json) => _$AvatarDecorationFromJson(json);

@override final  String id;
@override final  String url;
@override@JsonKey() final  double angle;
@override@JsonKey() final  bool flipH;
@override@JsonKey() final  double offsetX;
@override@JsonKey() final  double offsetY;

/// Create a copy of AvatarDecoration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvatarDecorationCopyWith<_AvatarDecoration> get copyWith => __$AvatarDecorationCopyWithImpl<_AvatarDecoration>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvatarDecorationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvatarDecoration&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.angle, angle) || other.angle == angle)&&(identical(other.flipH, flipH) || other.flipH == flipH)&&(identical(other.offsetX, offsetX) || other.offsetX == offsetX)&&(identical(other.offsetY, offsetY) || other.offsetY == offsetY));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,angle,flipH,offsetX,offsetY);

@override
String toString() {
  return 'AvatarDecoration(id: $id, url: $url, angle: $angle, flipH: $flipH, offsetX: $offsetX, offsetY: $offsetY)';
}


}

/// @nodoc
abstract mixin class _$AvatarDecorationCopyWith<$Res> implements $AvatarDecorationCopyWith<$Res> {
  factory _$AvatarDecorationCopyWith(_AvatarDecoration value, $Res Function(_AvatarDecoration) _then) = __$AvatarDecorationCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, double angle, bool flipH, double offsetX, double offsetY
});




}
/// @nodoc
class __$AvatarDecorationCopyWithImpl<$Res>
    implements _$AvatarDecorationCopyWith<$Res> {
  __$AvatarDecorationCopyWithImpl(this._self, this._then);

  final _AvatarDecoration _self;
  final $Res Function(_AvatarDecoration) _then;

/// Create a copy of AvatarDecoration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? angle = null,Object? flipH = null,Object? offsetX = null,Object? offsetY = null,}) {
  return _then(_AvatarDecoration(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,angle: null == angle ? _self.angle : angle // ignore: cast_nullable_to_non_nullable
as double,flipH: null == flipH ? _self.flipH : flipH // ignore: cast_nullable_to_non_nullable
as bool,offsetX: null == offsetX ? _self.offsetX : offsetX // ignore: cast_nullable_to_non_nullable
as double,offsetY: null == offsetY ? _self.offsetY : offsetY // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
