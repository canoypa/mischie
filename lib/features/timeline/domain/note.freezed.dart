// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Note {

 String get id; String get createdAt; User get user; String? get userId; String? get text; String? get cw; String? get replyId; String? get renoteId; Note? get reply; Note? get renote; List<Note>? get replies; String? get uri; String? get url; String get visibility; bool get localOnly; int get repliesCount; int get renoteCount; String? get myReaction; List<DriveFile> get files; Map<String, int> get reactions; Map<String, String> get emojis; Map<String, String> get reactionEmojis;
/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteCopyWith<Note> get copyWith => _$NoteCopyWithImpl<Note>(this as Note, _$identity);

  /// Serializes this Note to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Note&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.user, user) || other.user == user)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.text, text) || other.text == text)&&(identical(other.cw, cw) || other.cw == cw)&&(identical(other.replyId, replyId) || other.replyId == replyId)&&(identical(other.renoteId, renoteId) || other.renoteId == renoteId)&&(identical(other.reply, reply) || other.reply == reply)&&(identical(other.renote, renote) || other.renote == renote)&&const DeepCollectionEquality().equals(other.replies, replies)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.url, url) || other.url == url)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.localOnly, localOnly) || other.localOnly == localOnly)&&(identical(other.repliesCount, repliesCount) || other.repliesCount == repliesCount)&&(identical(other.renoteCount, renoteCount) || other.renoteCount == renoteCount)&&(identical(other.myReaction, myReaction) || other.myReaction == myReaction)&&const DeepCollectionEquality().equals(other.files, files)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&const DeepCollectionEquality().equals(other.emojis, emojis)&&const DeepCollectionEquality().equals(other.reactionEmojis, reactionEmojis));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,createdAt,user,userId,text,cw,replyId,renoteId,reply,renote,const DeepCollectionEquality().hash(replies),uri,url,visibility,localOnly,repliesCount,renoteCount,myReaction,const DeepCollectionEquality().hash(files),const DeepCollectionEquality().hash(reactions),const DeepCollectionEquality().hash(emojis),const DeepCollectionEquality().hash(reactionEmojis)]);

@override
String toString() {
  return 'Note(id: $id, createdAt: $createdAt, user: $user, userId: $userId, text: $text, cw: $cw, replyId: $replyId, renoteId: $renoteId, reply: $reply, renote: $renote, replies: $replies, uri: $uri, url: $url, visibility: $visibility, localOnly: $localOnly, repliesCount: $repliesCount, renoteCount: $renoteCount, myReaction: $myReaction, files: $files, reactions: $reactions, emojis: $emojis, reactionEmojis: $reactionEmojis)';
}


}

/// @nodoc
abstract mixin class $NoteCopyWith<$Res>  {
  factory $NoteCopyWith(Note value, $Res Function(Note) _then) = _$NoteCopyWithImpl;
@useResult
$Res call({
 String id, String createdAt, User user, String? userId, String? text, String? cw, String? replyId, String? renoteId, Note? reply, Note? renote, List<Note>? replies, String? uri, String? url, String visibility, bool localOnly, int repliesCount, int renoteCount, String? myReaction, List<DriveFile> files, Map<String, int> reactions, Map<String, String> emojis, Map<String, String> reactionEmojis
});


$UserCopyWith<$Res> get user;$NoteCopyWith<$Res>? get reply;$NoteCopyWith<$Res>? get renote;

}
/// @nodoc
class _$NoteCopyWithImpl<$Res>
    implements $NoteCopyWith<$Res> {
  _$NoteCopyWithImpl(this._self, this._then);

  final Note _self;
  final $Res Function(Note) _then;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? user = null,Object? userId = freezed,Object? text = freezed,Object? cw = freezed,Object? replyId = freezed,Object? renoteId = freezed,Object? reply = freezed,Object? renote = freezed,Object? replies = freezed,Object? uri = freezed,Object? url = freezed,Object? visibility = null,Object? localOnly = null,Object? repliesCount = null,Object? renoteCount = null,Object? myReaction = freezed,Object? files = null,Object? reactions = null,Object? emojis = null,Object? reactionEmojis = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,cw: freezed == cw ? _self.cw : cw // ignore: cast_nullable_to_non_nullable
as String?,replyId: freezed == replyId ? _self.replyId : replyId // ignore: cast_nullable_to_non_nullable
as String?,renoteId: freezed == renoteId ? _self.renoteId : renoteId // ignore: cast_nullable_to_non_nullable
as String?,reply: freezed == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as Note?,renote: freezed == renote ? _self.renote : renote // ignore: cast_nullable_to_non_nullable
as Note?,replies: freezed == replies ? _self.replies : replies // ignore: cast_nullable_to_non_nullable
as List<Note>?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,localOnly: null == localOnly ? _self.localOnly : localOnly // ignore: cast_nullable_to_non_nullable
as bool,repliesCount: null == repliesCount ? _self.repliesCount : repliesCount // ignore: cast_nullable_to_non_nullable
as int,renoteCount: null == renoteCount ? _self.renoteCount : renoteCount // ignore: cast_nullable_to_non_nullable
as int,myReaction: freezed == myReaction ? _self.myReaction : myReaction // ignore: cast_nullable_to_non_nullable
as String?,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<DriveFile>,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as Map<String, int>,emojis: null == emojis ? _self.emojis : emojis // ignore: cast_nullable_to_non_nullable
as Map<String, String>,reactionEmojis: null == reactionEmojis ? _self.reactionEmojis : reactionEmojis // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}
/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteCopyWith<$Res>? get reply {
    if (_self.reply == null) {
    return null;
  }

  return $NoteCopyWith<$Res>(_self.reply!, (value) {
    return _then(_self.copyWith(reply: value));
  });
}/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteCopyWith<$Res>? get renote {
    if (_self.renote == null) {
    return null;
  }

  return $NoteCopyWith<$Res>(_self.renote!, (value) {
    return _then(_self.copyWith(renote: value));
  });
}
}


/// Adds pattern-matching-related methods to [Note].
extension NotePatterns on Note {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Note value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Note() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Note value)  $default,){
final _that = this;
switch (_that) {
case _Note():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Note value)?  $default,){
final _that = this;
switch (_that) {
case _Note() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String createdAt,  User user,  String? userId,  String? text,  String? cw,  String? replyId,  String? renoteId,  Note? reply,  Note? renote,  List<Note>? replies,  String? uri,  String? url,  String visibility,  bool localOnly,  int repliesCount,  int renoteCount,  String? myReaction,  List<DriveFile> files,  Map<String, int> reactions,  Map<String, String> emojis,  Map<String, String> reactionEmojis)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Note() when $default != null:
return $default(_that.id,_that.createdAt,_that.user,_that.userId,_that.text,_that.cw,_that.replyId,_that.renoteId,_that.reply,_that.renote,_that.replies,_that.uri,_that.url,_that.visibility,_that.localOnly,_that.repliesCount,_that.renoteCount,_that.myReaction,_that.files,_that.reactions,_that.emojis,_that.reactionEmojis);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String createdAt,  User user,  String? userId,  String? text,  String? cw,  String? replyId,  String? renoteId,  Note? reply,  Note? renote,  List<Note>? replies,  String? uri,  String? url,  String visibility,  bool localOnly,  int repliesCount,  int renoteCount,  String? myReaction,  List<DriveFile> files,  Map<String, int> reactions,  Map<String, String> emojis,  Map<String, String> reactionEmojis)  $default,) {final _that = this;
switch (_that) {
case _Note():
return $default(_that.id,_that.createdAt,_that.user,_that.userId,_that.text,_that.cw,_that.replyId,_that.renoteId,_that.reply,_that.renote,_that.replies,_that.uri,_that.url,_that.visibility,_that.localOnly,_that.repliesCount,_that.renoteCount,_that.myReaction,_that.files,_that.reactions,_that.emojis,_that.reactionEmojis);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String createdAt,  User user,  String? userId,  String? text,  String? cw,  String? replyId,  String? renoteId,  Note? reply,  Note? renote,  List<Note>? replies,  String? uri,  String? url,  String visibility,  bool localOnly,  int repliesCount,  int renoteCount,  String? myReaction,  List<DriveFile> files,  Map<String, int> reactions,  Map<String, String> emojis,  Map<String, String> reactionEmojis)?  $default,) {final _that = this;
switch (_that) {
case _Note() when $default != null:
return $default(_that.id,_that.createdAt,_that.user,_that.userId,_that.text,_that.cw,_that.replyId,_that.renoteId,_that.reply,_that.renote,_that.replies,_that.uri,_that.url,_that.visibility,_that.localOnly,_that.repliesCount,_that.renoteCount,_that.myReaction,_that.files,_that.reactions,_that.emojis,_that.reactionEmojis);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Note extends Note {
  const _Note({required this.id, required this.createdAt, required this.user, this.userId, this.text, this.cw, this.replyId, this.renoteId, this.reply, this.renote, final  List<Note>? replies, this.uri, this.url, this.visibility = 'public', this.localOnly = false, this.repliesCount = 0, this.renoteCount = 0, this.myReaction, final  List<DriveFile> files = const [], final  Map<String, int> reactions = const {}, final  Map<String, String> emojis = const {}, final  Map<String, String> reactionEmojis = const {}}): _replies = replies,_files = files,_reactions = reactions,_emojis = emojis,_reactionEmojis = reactionEmojis,super._();
  factory _Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

@override final  String id;
@override final  String createdAt;
@override final  User user;
@override final  String? userId;
@override final  String? text;
@override final  String? cw;
@override final  String? replyId;
@override final  String? renoteId;
@override final  Note? reply;
@override final  Note? renote;
 final  List<Note>? _replies;
@override List<Note>? get replies {
  final value = _replies;
  if (value == null) return null;
  if (_replies is EqualUnmodifiableListView) return _replies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? uri;
@override final  String? url;
@override@JsonKey() final  String visibility;
@override@JsonKey() final  bool localOnly;
@override@JsonKey() final  int repliesCount;
@override@JsonKey() final  int renoteCount;
@override final  String? myReaction;
 final  List<DriveFile> _files;
@override@JsonKey() List<DriveFile> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

 final  Map<String, int> _reactions;
@override@JsonKey() Map<String, int> get reactions {
  if (_reactions is EqualUnmodifiableMapView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactions);
}

 final  Map<String, String> _emojis;
@override@JsonKey() Map<String, String> get emojis {
  if (_emojis is EqualUnmodifiableMapView) return _emojis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_emojis);
}

 final  Map<String, String> _reactionEmojis;
@override@JsonKey() Map<String, String> get reactionEmojis {
  if (_reactionEmojis is EqualUnmodifiableMapView) return _reactionEmojis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactionEmojis);
}


/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteCopyWith<_Note> get copyWith => __$NoteCopyWithImpl<_Note>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Note&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.user, user) || other.user == user)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.text, text) || other.text == text)&&(identical(other.cw, cw) || other.cw == cw)&&(identical(other.replyId, replyId) || other.replyId == replyId)&&(identical(other.renoteId, renoteId) || other.renoteId == renoteId)&&(identical(other.reply, reply) || other.reply == reply)&&(identical(other.renote, renote) || other.renote == renote)&&const DeepCollectionEquality().equals(other._replies, _replies)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.url, url) || other.url == url)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.localOnly, localOnly) || other.localOnly == localOnly)&&(identical(other.repliesCount, repliesCount) || other.repliesCount == repliesCount)&&(identical(other.renoteCount, renoteCount) || other.renoteCount == renoteCount)&&(identical(other.myReaction, myReaction) || other.myReaction == myReaction)&&const DeepCollectionEquality().equals(other._files, _files)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&const DeepCollectionEquality().equals(other._emojis, _emojis)&&const DeepCollectionEquality().equals(other._reactionEmojis, _reactionEmojis));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,createdAt,user,userId,text,cw,replyId,renoteId,reply,renote,const DeepCollectionEquality().hash(_replies),uri,url,visibility,localOnly,repliesCount,renoteCount,myReaction,const DeepCollectionEquality().hash(_files),const DeepCollectionEquality().hash(_reactions),const DeepCollectionEquality().hash(_emojis),const DeepCollectionEquality().hash(_reactionEmojis)]);

@override
String toString() {
  return 'Note(id: $id, createdAt: $createdAt, user: $user, userId: $userId, text: $text, cw: $cw, replyId: $replyId, renoteId: $renoteId, reply: $reply, renote: $renote, replies: $replies, uri: $uri, url: $url, visibility: $visibility, localOnly: $localOnly, repliesCount: $repliesCount, renoteCount: $renoteCount, myReaction: $myReaction, files: $files, reactions: $reactions, emojis: $emojis, reactionEmojis: $reactionEmojis)';
}


}

/// @nodoc
abstract mixin class _$NoteCopyWith<$Res> implements $NoteCopyWith<$Res> {
  factory _$NoteCopyWith(_Note value, $Res Function(_Note) _then) = __$NoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String createdAt, User user, String? userId, String? text, String? cw, String? replyId, String? renoteId, Note? reply, Note? renote, List<Note>? replies, String? uri, String? url, String visibility, bool localOnly, int repliesCount, int renoteCount, String? myReaction, List<DriveFile> files, Map<String, int> reactions, Map<String, String> emojis, Map<String, String> reactionEmojis
});


@override $UserCopyWith<$Res> get user;@override $NoteCopyWith<$Res>? get reply;@override $NoteCopyWith<$Res>? get renote;

}
/// @nodoc
class __$NoteCopyWithImpl<$Res>
    implements _$NoteCopyWith<$Res> {
  __$NoteCopyWithImpl(this._self, this._then);

  final _Note _self;
  final $Res Function(_Note) _then;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? user = null,Object? userId = freezed,Object? text = freezed,Object? cw = freezed,Object? replyId = freezed,Object? renoteId = freezed,Object? reply = freezed,Object? renote = freezed,Object? replies = freezed,Object? uri = freezed,Object? url = freezed,Object? visibility = null,Object? localOnly = null,Object? repliesCount = null,Object? renoteCount = null,Object? myReaction = freezed,Object? files = null,Object? reactions = null,Object? emojis = null,Object? reactionEmojis = null,}) {
  return _then(_Note(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,cw: freezed == cw ? _self.cw : cw // ignore: cast_nullable_to_non_nullable
as String?,replyId: freezed == replyId ? _self.replyId : replyId // ignore: cast_nullable_to_non_nullable
as String?,renoteId: freezed == renoteId ? _self.renoteId : renoteId // ignore: cast_nullable_to_non_nullable
as String?,reply: freezed == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as Note?,renote: freezed == renote ? _self.renote : renote // ignore: cast_nullable_to_non_nullable
as Note?,replies: freezed == replies ? _self._replies : replies // ignore: cast_nullable_to_non_nullable
as List<Note>?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,localOnly: null == localOnly ? _self.localOnly : localOnly // ignore: cast_nullable_to_non_nullable
as bool,repliesCount: null == repliesCount ? _self.repliesCount : repliesCount // ignore: cast_nullable_to_non_nullable
as int,renoteCount: null == renoteCount ? _self.renoteCount : renoteCount // ignore: cast_nullable_to_non_nullable
as int,myReaction: freezed == myReaction ? _self.myReaction : myReaction // ignore: cast_nullable_to_non_nullable
as String?,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<DriveFile>,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as Map<String, int>,emojis: null == emojis ? _self._emojis : emojis // ignore: cast_nullable_to_non_nullable
as Map<String, String>,reactionEmojis: null == reactionEmojis ? _self._reactionEmojis : reactionEmojis // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteCopyWith<$Res>? get reply {
    if (_self.reply == null) {
    return null;
  }

  return $NoteCopyWith<$Res>(_self.reply!, (value) {
    return _then(_self.copyWith(reply: value));
  });
}/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteCopyWith<$Res>? get renote {
    if (_self.renote == null) {
    return null;
  }

  return $NoteCopyWith<$Res>(_self.renote!, (value) {
    return _then(_self.copyWith(renote: value));
  });
}
}

// dart format on
