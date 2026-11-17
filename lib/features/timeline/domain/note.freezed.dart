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

 String get id; String get createdAt; User get user; String? get userId; String? get text; String? get cw; String? get replyId; Note? get reply; Note? get renote; String? get uri; String? get url; String? get channelId; NoteChannel? get channel; Poll? get poll; String get visibility; bool get localOnly; int get repliesCount; int get renoteCount; String? get myReaction; List<DriveFile> get files; Map<String, int> get reactions; Map<String, String> get emojis; Map<String, String> get reactionEmojis;
/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteCopyWith<Note> get copyWith => _$NoteCopyWithImpl<Note>(this as Note, _$identity);

  /// Serializes this Note to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Note&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.user, user) || other.user == user)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.text, text) || other.text == text)&&(identical(other.cw, cw) || other.cw == cw)&&(identical(other.replyId, replyId) || other.replyId == replyId)&&(identical(other.reply, reply) || other.reply == reply)&&(identical(other.renote, renote) || other.renote == renote)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.url, url) || other.url == url)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.poll, poll) || other.poll == poll)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.localOnly, localOnly) || other.localOnly == localOnly)&&(identical(other.repliesCount, repliesCount) || other.repliesCount == repliesCount)&&(identical(other.renoteCount, renoteCount) || other.renoteCount == renoteCount)&&(identical(other.myReaction, myReaction) || other.myReaction == myReaction)&&const DeepCollectionEquality().equals(other.files, files)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&const DeepCollectionEquality().equals(other.emojis, emojis)&&const DeepCollectionEquality().equals(other.reactionEmojis, reactionEmojis));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,createdAt,user,userId,text,cw,replyId,reply,renote,uri,url,channelId,channel,poll,visibility,localOnly,repliesCount,renoteCount,myReaction,const DeepCollectionEquality().hash(files),const DeepCollectionEquality().hash(reactions),const DeepCollectionEquality().hash(emojis),const DeepCollectionEquality().hash(reactionEmojis)]);

@override
String toString() {
  return 'Note(id: $id, createdAt: $createdAt, user: $user, userId: $userId, text: $text, cw: $cw, replyId: $replyId, reply: $reply, renote: $renote, uri: $uri, url: $url, channelId: $channelId, channel: $channel, poll: $poll, visibility: $visibility, localOnly: $localOnly, repliesCount: $repliesCount, renoteCount: $renoteCount, myReaction: $myReaction, files: $files, reactions: $reactions, emojis: $emojis, reactionEmojis: $reactionEmojis)';
}


}

/// @nodoc
abstract mixin class $NoteCopyWith<$Res>  {
  factory $NoteCopyWith(Note value, $Res Function(Note) _then) = _$NoteCopyWithImpl;
@useResult
$Res call({
 String id, String createdAt, User user, String? userId, String? text, String? cw, String? replyId, Note? reply, Note? renote, String? uri, String? url, String? channelId, NoteChannel? channel, Poll? poll, String visibility, bool localOnly, int repliesCount, int renoteCount, String? myReaction, List<DriveFile> files, Map<String, int> reactions, Map<String, String> emojis, Map<String, String> reactionEmojis
});


$UserCopyWith<$Res> get user;$NoteCopyWith<$Res>? get reply;$NoteCopyWith<$Res>? get renote;$NoteChannelCopyWith<$Res>? get channel;$PollCopyWith<$Res>? get poll;

}
/// @nodoc
class _$NoteCopyWithImpl<$Res>
    implements $NoteCopyWith<$Res> {
  _$NoteCopyWithImpl(this._self, this._then);

  final Note _self;
  final $Res Function(Note) _then;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? user = null,Object? userId = freezed,Object? text = freezed,Object? cw = freezed,Object? replyId = freezed,Object? reply = freezed,Object? renote = freezed,Object? uri = freezed,Object? url = freezed,Object? channelId = freezed,Object? channel = freezed,Object? poll = freezed,Object? visibility = null,Object? localOnly = null,Object? repliesCount = null,Object? renoteCount = null,Object? myReaction = freezed,Object? files = null,Object? reactions = null,Object? emojis = null,Object? reactionEmojis = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,cw: freezed == cw ? _self.cw : cw // ignore: cast_nullable_to_non_nullable
as String?,replyId: freezed == replyId ? _self.replyId : replyId // ignore: cast_nullable_to_non_nullable
as String?,reply: freezed == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as Note?,renote: freezed == renote ? _self.renote : renote // ignore: cast_nullable_to_non_nullable
as Note?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as NoteChannel?,poll: freezed == poll ? _self.poll : poll // ignore: cast_nullable_to_non_nullable
as Poll?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
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
}/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteChannelCopyWith<$Res>? get channel {
    if (_self.channel == null) {
    return null;
  }

  return $NoteChannelCopyWith<$Res>(_self.channel!, (value) {
    return _then(_self.copyWith(channel: value));
  });
}/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PollCopyWith<$Res>? get poll {
    if (_self.poll == null) {
    return null;
  }

  return $PollCopyWith<$Res>(_self.poll!, (value) {
    return _then(_self.copyWith(poll: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String createdAt,  User user,  String? userId,  String? text,  String? cw,  String? replyId,  Note? reply,  Note? renote,  String? uri,  String? url,  String? channelId,  NoteChannel? channel,  Poll? poll,  String visibility,  bool localOnly,  int repliesCount,  int renoteCount,  String? myReaction,  List<DriveFile> files,  Map<String, int> reactions,  Map<String, String> emojis,  Map<String, String> reactionEmojis)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Note() when $default != null:
return $default(_that.id,_that.createdAt,_that.user,_that.userId,_that.text,_that.cw,_that.replyId,_that.reply,_that.renote,_that.uri,_that.url,_that.channelId,_that.channel,_that.poll,_that.visibility,_that.localOnly,_that.repliesCount,_that.renoteCount,_that.myReaction,_that.files,_that.reactions,_that.emojis,_that.reactionEmojis);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String createdAt,  User user,  String? userId,  String? text,  String? cw,  String? replyId,  Note? reply,  Note? renote,  String? uri,  String? url,  String? channelId,  NoteChannel? channel,  Poll? poll,  String visibility,  bool localOnly,  int repliesCount,  int renoteCount,  String? myReaction,  List<DriveFile> files,  Map<String, int> reactions,  Map<String, String> emojis,  Map<String, String> reactionEmojis)  $default,) {final _that = this;
switch (_that) {
case _Note():
return $default(_that.id,_that.createdAt,_that.user,_that.userId,_that.text,_that.cw,_that.replyId,_that.reply,_that.renote,_that.uri,_that.url,_that.channelId,_that.channel,_that.poll,_that.visibility,_that.localOnly,_that.repliesCount,_that.renoteCount,_that.myReaction,_that.files,_that.reactions,_that.emojis,_that.reactionEmojis);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String createdAt,  User user,  String? userId,  String? text,  String? cw,  String? replyId,  Note? reply,  Note? renote,  String? uri,  String? url,  String? channelId,  NoteChannel? channel,  Poll? poll,  String visibility,  bool localOnly,  int repliesCount,  int renoteCount,  String? myReaction,  List<DriveFile> files,  Map<String, int> reactions,  Map<String, String> emojis,  Map<String, String> reactionEmojis)?  $default,) {final _that = this;
switch (_that) {
case _Note() when $default != null:
return $default(_that.id,_that.createdAt,_that.user,_that.userId,_that.text,_that.cw,_that.replyId,_that.reply,_that.renote,_that.uri,_that.url,_that.channelId,_that.channel,_that.poll,_that.visibility,_that.localOnly,_that.repliesCount,_that.renoteCount,_that.myReaction,_that.files,_that.reactions,_that.emojis,_that.reactionEmojis);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Note extends Note {
  const _Note({required this.id, required this.createdAt, required this.user, this.userId, this.text, this.cw, this.replyId, this.reply, this.renote, this.uri, this.url, this.channelId, this.channel, this.poll, this.visibility = 'public', this.localOnly = false, this.repliesCount = 0, this.renoteCount = 0, this.myReaction, final  List<DriveFile> files = const [], final  Map<String, int> reactions = const {}, final  Map<String, String> emojis = const {}, final  Map<String, String> reactionEmojis = const {}}): _files = files,_reactions = reactions,_emojis = emojis,_reactionEmojis = reactionEmojis,super._();
  factory _Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

@override final  String id;
@override final  String createdAt;
@override final  User user;
@override final  String? userId;
@override final  String? text;
@override final  String? cw;
@override final  String? replyId;
@override final  Note? reply;
@override final  Note? renote;
@override final  String? uri;
@override final  String? url;
@override final  String? channelId;
@override final  NoteChannel? channel;
@override final  Poll? poll;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Note&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.user, user) || other.user == user)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.text, text) || other.text == text)&&(identical(other.cw, cw) || other.cw == cw)&&(identical(other.replyId, replyId) || other.replyId == replyId)&&(identical(other.reply, reply) || other.reply == reply)&&(identical(other.renote, renote) || other.renote == renote)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.url, url) || other.url == url)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.poll, poll) || other.poll == poll)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.localOnly, localOnly) || other.localOnly == localOnly)&&(identical(other.repliesCount, repliesCount) || other.repliesCount == repliesCount)&&(identical(other.renoteCount, renoteCount) || other.renoteCount == renoteCount)&&(identical(other.myReaction, myReaction) || other.myReaction == myReaction)&&const DeepCollectionEquality().equals(other._files, _files)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&const DeepCollectionEquality().equals(other._emojis, _emojis)&&const DeepCollectionEquality().equals(other._reactionEmojis, _reactionEmojis));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,createdAt,user,userId,text,cw,replyId,reply,renote,uri,url,channelId,channel,poll,visibility,localOnly,repliesCount,renoteCount,myReaction,const DeepCollectionEquality().hash(_files),const DeepCollectionEquality().hash(_reactions),const DeepCollectionEquality().hash(_emojis),const DeepCollectionEquality().hash(_reactionEmojis)]);

@override
String toString() {
  return 'Note(id: $id, createdAt: $createdAt, user: $user, userId: $userId, text: $text, cw: $cw, replyId: $replyId, reply: $reply, renote: $renote, uri: $uri, url: $url, channelId: $channelId, channel: $channel, poll: $poll, visibility: $visibility, localOnly: $localOnly, repliesCount: $repliesCount, renoteCount: $renoteCount, myReaction: $myReaction, files: $files, reactions: $reactions, emojis: $emojis, reactionEmojis: $reactionEmojis)';
}


}

/// @nodoc
abstract mixin class _$NoteCopyWith<$Res> implements $NoteCopyWith<$Res> {
  factory _$NoteCopyWith(_Note value, $Res Function(_Note) _then) = __$NoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String createdAt, User user, String? userId, String? text, String? cw, String? replyId, Note? reply, Note? renote, String? uri, String? url, String? channelId, NoteChannel? channel, Poll? poll, String visibility, bool localOnly, int repliesCount, int renoteCount, String? myReaction, List<DriveFile> files, Map<String, int> reactions, Map<String, String> emojis, Map<String, String> reactionEmojis
});


@override $UserCopyWith<$Res> get user;@override $NoteCopyWith<$Res>? get reply;@override $NoteCopyWith<$Res>? get renote;@override $NoteChannelCopyWith<$Res>? get channel;@override $PollCopyWith<$Res>? get poll;

}
/// @nodoc
class __$NoteCopyWithImpl<$Res>
    implements _$NoteCopyWith<$Res> {
  __$NoteCopyWithImpl(this._self, this._then);

  final _Note _self;
  final $Res Function(_Note) _then;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? user = null,Object? userId = freezed,Object? text = freezed,Object? cw = freezed,Object? replyId = freezed,Object? reply = freezed,Object? renote = freezed,Object? uri = freezed,Object? url = freezed,Object? channelId = freezed,Object? channel = freezed,Object? poll = freezed,Object? visibility = null,Object? localOnly = null,Object? repliesCount = null,Object? renoteCount = null,Object? myReaction = freezed,Object? files = null,Object? reactions = null,Object? emojis = null,Object? reactionEmojis = null,}) {
  return _then(_Note(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,cw: freezed == cw ? _self.cw : cw // ignore: cast_nullable_to_non_nullable
as String?,replyId: freezed == replyId ? _self.replyId : replyId // ignore: cast_nullable_to_non_nullable
as String?,reply: freezed == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as Note?,renote: freezed == renote ? _self.renote : renote // ignore: cast_nullable_to_non_nullable
as Note?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as NoteChannel?,poll: freezed == poll ? _self.poll : poll // ignore: cast_nullable_to_non_nullable
as Poll?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
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
}/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteChannelCopyWith<$Res>? get channel {
    if (_self.channel == null) {
    return null;
  }

  return $NoteChannelCopyWith<$Res>(_self.channel!, (value) {
    return _then(_self.copyWith(channel: value));
  });
}/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PollCopyWith<$Res>? get poll {
    if (_self.poll == null) {
    return null;
  }

  return $PollCopyWith<$Res>(_self.poll!, (value) {
    return _then(_self.copyWith(poll: value));
  });
}
}


/// @nodoc
mixin _$Poll {

 List<PollChoice> get choices; bool get multiple; String? get expiresAt;
/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PollCopyWith<Poll> get copyWith => _$PollCopyWithImpl<Poll>(this as Poll, _$identity);

  /// Serializes this Poll to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Poll&&const DeepCollectionEquality().equals(other.choices, choices)&&(identical(other.multiple, multiple) || other.multiple == multiple)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(choices),multiple,expiresAt);

@override
String toString() {
  return 'Poll(choices: $choices, multiple: $multiple, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $PollCopyWith<$Res>  {
  factory $PollCopyWith(Poll value, $Res Function(Poll) _then) = _$PollCopyWithImpl;
@useResult
$Res call({
 List<PollChoice> choices, bool multiple, String? expiresAt
});




}
/// @nodoc
class _$PollCopyWithImpl<$Res>
    implements $PollCopyWith<$Res> {
  _$PollCopyWithImpl(this._self, this._then);

  final Poll _self;
  final $Res Function(Poll) _then;

/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? choices = null,Object? multiple = null,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
choices: null == choices ? _self.choices : choices // ignore: cast_nullable_to_non_nullable
as List<PollChoice>,multiple: null == multiple ? _self.multiple : multiple // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Poll].
extension PollPatterns on Poll {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Poll value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Poll() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Poll value)  $default,){
final _that = this;
switch (_that) {
case _Poll():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Poll value)?  $default,){
final _that = this;
switch (_that) {
case _Poll() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PollChoice> choices,  bool multiple,  String? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Poll() when $default != null:
return $default(_that.choices,_that.multiple,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PollChoice> choices,  bool multiple,  String? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _Poll():
return $default(_that.choices,_that.multiple,_that.expiresAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PollChoice> choices,  bool multiple,  String? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _Poll() when $default != null:
return $default(_that.choices,_that.multiple,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Poll extends Poll {
  const _Poll({final  List<PollChoice> choices = const [], this.multiple = false, this.expiresAt}): _choices = choices,super._();
  factory _Poll.fromJson(Map<String, dynamic> json) => _$PollFromJson(json);

 final  List<PollChoice> _choices;
@override@JsonKey() List<PollChoice> get choices {
  if (_choices is EqualUnmodifiableListView) return _choices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_choices);
}

@override@JsonKey() final  bool multiple;
@override final  String? expiresAt;

/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PollCopyWith<_Poll> get copyWith => __$PollCopyWithImpl<_Poll>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PollToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Poll&&const DeepCollectionEquality().equals(other._choices, _choices)&&(identical(other.multiple, multiple) || other.multiple == multiple)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_choices),multiple,expiresAt);

@override
String toString() {
  return 'Poll(choices: $choices, multiple: $multiple, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$PollCopyWith<$Res> implements $PollCopyWith<$Res> {
  factory _$PollCopyWith(_Poll value, $Res Function(_Poll) _then) = __$PollCopyWithImpl;
@override @useResult
$Res call({
 List<PollChoice> choices, bool multiple, String? expiresAt
});




}
/// @nodoc
class __$PollCopyWithImpl<$Res>
    implements _$PollCopyWith<$Res> {
  __$PollCopyWithImpl(this._self, this._then);

  final _Poll _self;
  final $Res Function(_Poll) _then;

/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? choices = null,Object? multiple = null,Object? expiresAt = freezed,}) {
  return _then(_Poll(
choices: null == choices ? _self._choices : choices // ignore: cast_nullable_to_non_nullable
as List<PollChoice>,multiple: null == multiple ? _self.multiple : multiple // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PollChoice {

 String get text; int get votes; bool get isVoted;
/// Create a copy of PollChoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PollChoiceCopyWith<PollChoice> get copyWith => _$PollChoiceCopyWithImpl<PollChoice>(this as PollChoice, _$identity);

  /// Serializes this PollChoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PollChoice&&(identical(other.text, text) || other.text == text)&&(identical(other.votes, votes) || other.votes == votes)&&(identical(other.isVoted, isVoted) || other.isVoted == isVoted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,votes,isVoted);

@override
String toString() {
  return 'PollChoice(text: $text, votes: $votes, isVoted: $isVoted)';
}


}

/// @nodoc
abstract mixin class $PollChoiceCopyWith<$Res>  {
  factory $PollChoiceCopyWith(PollChoice value, $Res Function(PollChoice) _then) = _$PollChoiceCopyWithImpl;
@useResult
$Res call({
 String text, int votes, bool isVoted
});




}
/// @nodoc
class _$PollChoiceCopyWithImpl<$Res>
    implements $PollChoiceCopyWith<$Res> {
  _$PollChoiceCopyWithImpl(this._self, this._then);

  final PollChoice _self;
  final $Res Function(PollChoice) _then;

/// Create a copy of PollChoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? votes = null,Object? isVoted = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,votes: null == votes ? _self.votes : votes // ignore: cast_nullable_to_non_nullable
as int,isVoted: null == isVoted ? _self.isVoted : isVoted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PollChoice].
extension PollChoicePatterns on PollChoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PollChoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PollChoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PollChoice value)  $default,){
final _that = this;
switch (_that) {
case _PollChoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PollChoice value)?  $default,){
final _that = this;
switch (_that) {
case _PollChoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  int votes,  bool isVoted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PollChoice() when $default != null:
return $default(_that.text,_that.votes,_that.isVoted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  int votes,  bool isVoted)  $default,) {final _that = this;
switch (_that) {
case _PollChoice():
return $default(_that.text,_that.votes,_that.isVoted);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  int votes,  bool isVoted)?  $default,) {final _that = this;
switch (_that) {
case _PollChoice() when $default != null:
return $default(_that.text,_that.votes,_that.isVoted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PollChoice implements PollChoice {
  const _PollChoice({this.text = '', this.votes = 0, this.isVoted = false});
  factory _PollChoice.fromJson(Map<String, dynamic> json) => _$PollChoiceFromJson(json);

@override@JsonKey() final  String text;
@override@JsonKey() final  int votes;
@override@JsonKey() final  bool isVoted;

/// Create a copy of PollChoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PollChoiceCopyWith<_PollChoice> get copyWith => __$PollChoiceCopyWithImpl<_PollChoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PollChoiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PollChoice&&(identical(other.text, text) || other.text == text)&&(identical(other.votes, votes) || other.votes == votes)&&(identical(other.isVoted, isVoted) || other.isVoted == isVoted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,votes,isVoted);

@override
String toString() {
  return 'PollChoice(text: $text, votes: $votes, isVoted: $isVoted)';
}


}

/// @nodoc
abstract mixin class _$PollChoiceCopyWith<$Res> implements $PollChoiceCopyWith<$Res> {
  factory _$PollChoiceCopyWith(_PollChoice value, $Res Function(_PollChoice) _then) = __$PollChoiceCopyWithImpl;
@override @useResult
$Res call({
 String text, int votes, bool isVoted
});




}
/// @nodoc
class __$PollChoiceCopyWithImpl<$Res>
    implements _$PollChoiceCopyWith<$Res> {
  __$PollChoiceCopyWithImpl(this._self, this._then);

  final _PollChoice _self;
  final $Res Function(_PollChoice) _then;

/// Create a copy of PollChoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? votes = null,Object? isVoted = null,}) {
  return _then(_PollChoice(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,votes: null == votes ? _self.votes : votes // ignore: cast_nullable_to_non_nullable
as int,isVoted: null == isVoted ? _self.isVoted : isVoted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$NoteChannel {

 String get id; String get name; String? get color; bool get isSensitive; bool get allowRenoteToExternal;
/// Create a copy of NoteChannel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteChannelCopyWith<NoteChannel> get copyWith => _$NoteChannelCopyWithImpl<NoteChannel>(this as NoteChannel, _$identity);

  /// Serializes this NoteChannel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteChannel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.isSensitive, isSensitive) || other.isSensitive == isSensitive)&&(identical(other.allowRenoteToExternal, allowRenoteToExternal) || other.allowRenoteToExternal == allowRenoteToExternal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color,isSensitive,allowRenoteToExternal);

@override
String toString() {
  return 'NoteChannel(id: $id, name: $name, color: $color, isSensitive: $isSensitive, allowRenoteToExternal: $allowRenoteToExternal)';
}


}

/// @nodoc
abstract mixin class $NoteChannelCopyWith<$Res>  {
  factory $NoteChannelCopyWith(NoteChannel value, $Res Function(NoteChannel) _then) = _$NoteChannelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? color, bool isSensitive, bool allowRenoteToExternal
});




}
/// @nodoc
class _$NoteChannelCopyWithImpl<$Res>
    implements $NoteChannelCopyWith<$Res> {
  _$NoteChannelCopyWithImpl(this._self, this._then);

  final NoteChannel _self;
  final $Res Function(NoteChannel) _then;

/// Create a copy of NoteChannel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? color = freezed,Object? isSensitive = null,Object? allowRenoteToExternal = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,isSensitive: null == isSensitive ? _self.isSensitive : isSensitive // ignore: cast_nullable_to_non_nullable
as bool,allowRenoteToExternal: null == allowRenoteToExternal ? _self.allowRenoteToExternal : allowRenoteToExternal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NoteChannel].
extension NoteChannelPatterns on NoteChannel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteChannel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteChannel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteChannel value)  $default,){
final _that = this;
switch (_that) {
case _NoteChannel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteChannel value)?  $default,){
final _that = this;
switch (_that) {
case _NoteChannel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? color,  bool isSensitive,  bool allowRenoteToExternal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteChannel() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.isSensitive,_that.allowRenoteToExternal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? color,  bool isSensitive,  bool allowRenoteToExternal)  $default,) {final _that = this;
switch (_that) {
case _NoteChannel():
return $default(_that.id,_that.name,_that.color,_that.isSensitive,_that.allowRenoteToExternal);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? color,  bool isSensitive,  bool allowRenoteToExternal)?  $default,) {final _that = this;
switch (_that) {
case _NoteChannel() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.isSensitive,_that.allowRenoteToExternal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NoteChannel implements NoteChannel {
  const _NoteChannel({required this.id, this.name = '', this.color, this.isSensitive = false, this.allowRenoteToExternal = true});
  factory _NoteChannel.fromJson(Map<String, dynamic> json) => _$NoteChannelFromJson(json);

@override final  String id;
@override@JsonKey() final  String name;
@override final  String? color;
@override@JsonKey() final  bool isSensitive;
@override@JsonKey() final  bool allowRenoteToExternal;

/// Create a copy of NoteChannel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteChannelCopyWith<_NoteChannel> get copyWith => __$NoteChannelCopyWithImpl<_NoteChannel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NoteChannelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteChannel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.isSensitive, isSensitive) || other.isSensitive == isSensitive)&&(identical(other.allowRenoteToExternal, allowRenoteToExternal) || other.allowRenoteToExternal == allowRenoteToExternal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color,isSensitive,allowRenoteToExternal);

@override
String toString() {
  return 'NoteChannel(id: $id, name: $name, color: $color, isSensitive: $isSensitive, allowRenoteToExternal: $allowRenoteToExternal)';
}


}

/// @nodoc
abstract mixin class _$NoteChannelCopyWith<$Res> implements $NoteChannelCopyWith<$Res> {
  factory _$NoteChannelCopyWith(_NoteChannel value, $Res Function(_NoteChannel) _then) = __$NoteChannelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? color, bool isSensitive, bool allowRenoteToExternal
});




}
/// @nodoc
class __$NoteChannelCopyWithImpl<$Res>
    implements _$NoteChannelCopyWith<$Res> {
  __$NoteChannelCopyWithImpl(this._self, this._then);

  final _NoteChannel _self;
  final $Res Function(_NoteChannel) _then;

/// Create a copy of NoteChannel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? color = freezed,Object? isSensitive = null,Object? allowRenoteToExternal = null,}) {
  return _then(_NoteChannel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,isSensitive: null == isSensitive ? _self.isSensitive : isSensitive // ignore: cast_nullable_to_non_nullable
as bool,allowRenoteToExternal: null == allowRenoteToExternal ? _self.allowRenoteToExternal : allowRenoteToExternal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
