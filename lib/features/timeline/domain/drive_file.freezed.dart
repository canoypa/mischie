// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drive_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriveFile {

 String get id; String get type; String get url; String? get thumbnailUrl; String? get name; String? get blurhash;/// バイト数。
 int? get size;/// ルートなら null。
 String? get folderId;/// 画像の説明（alt）。
 String? get comment; DriveFileProperties? get properties; bool get isSensitive;
/// Create a copy of DriveFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriveFileCopyWith<DriveFile> get copyWith => _$DriveFileCopyWithImpl<DriveFile>(this as DriveFile, _$identity);

  /// Serializes this DriveFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DriveFile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveFile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.thumbnailUrl, _this.thumbnailUrl) || other.thumbnailUrl == _this.thumbnailUrl)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.blurhash, _this.blurhash) || other.blurhash == _this.blurhash)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.folderId, _this.folderId) || other.folderId == _this.folderId)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.properties, _this.properties) || other.properties == _this.properties)&&(identical(other.isSensitive, _this.isSensitive) || other.isSensitive == _this.isSensitive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DriveFile;
  return Object.hash(runtimeType,_this.id,_this.type,_this.url,_this.thumbnailUrl,_this.name,_this.blurhash,_this.size,_this.folderId,_this.comment,_this.properties,_this.isSensitive);
}

@override
String toString() {
  final _this = this as DriveFile;
  return 'DriveFile(id: ${_this.id}, type: ${_this.type}, url: ${_this.url}, thumbnailUrl: ${_this.thumbnailUrl}, name: ${_this.name}, blurhash: ${_this.blurhash}, size: ${_this.size}, folderId: ${_this.folderId}, comment: ${_this.comment}, properties: ${_this.properties}, isSensitive: ${_this.isSensitive})';
}


}

/// @nodoc
abstract mixin class $DriveFileCopyWith<$Res>  {
  factory $DriveFileCopyWith(DriveFile value, $Res Function(DriveFile) _then) = _$DriveFileCopyWithImpl;
@useResult
$Res call({
 String id, String type, String url, String? thumbnailUrl, String? name, String? blurhash, int? size, String? folderId, String? comment, DriveFileProperties? properties, bool isSensitive
});


$DriveFilePropertiesCopyWith<$Res>? get properties;

}
/// @nodoc
class _$DriveFileCopyWithImpl<$Res>
    implements $DriveFileCopyWith<$Res> {
  _$DriveFileCopyWithImpl(this._self, this._then);

  final DriveFile _self;
  final $Res Function(DriveFile) _then;

/// Create a copy of DriveFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? url = null,Object? thumbnailUrl = freezed,Object? name = freezed,Object? blurhash = freezed,Object? size = freezed,Object? folderId = freezed,Object? comment = freezed,Object? properties = freezed,Object? isSensitive = null,}) {
  return _then(DriveFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,blurhash: freezed == blurhash ? _self.blurhash : blurhash // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,properties: freezed == properties ? _self.properties : properties // ignore: cast_nullable_to_non_nullable
as DriveFileProperties?,isSensitive: null == isSensitive ? _self.isSensitive : isSensitive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of DriveFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriveFilePropertiesCopyWith<$Res>? get properties {
    if (_self.properties == null) {
    return null;
  }

  return $DriveFilePropertiesCopyWith<$Res>(_self.properties!, (value) {
    return _then(_self.copyWith(properties: value));
  });
}
}


/// Adds pattern-matching-related methods to [DriveFile].
extension DriveFilePatterns on DriveFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriveFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriveFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriveFile value)  $default,){
final _that = this;
switch (_that) {
case _DriveFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriveFile value)?  $default,){
final _that = this;
switch (_that) {
case _DriveFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String url,  String? thumbnailUrl,  String? name,  String? blurhash,  int? size,  String? folderId,  String? comment,  DriveFileProperties? properties,  bool isSensitive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriveFile() when $default != null:
return $default(_that.id,_that.type,_that.url,_that.thumbnailUrl,_that.name,_that.blurhash,_that.size,_that.folderId,_that.comment,_that.properties,_that.isSensitive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String url,  String? thumbnailUrl,  String? name,  String? blurhash,  int? size,  String? folderId,  String? comment,  DriveFileProperties? properties,  bool isSensitive)  $default,) {final _that = this;
switch (_that) {
case _DriveFile():
return $default(_that.id,_that.type,_that.url,_that.thumbnailUrl,_that.name,_that.blurhash,_that.size,_that.folderId,_that.comment,_that.properties,_that.isSensitive);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String url,  String? thumbnailUrl,  String? name,  String? blurhash,  int? size,  String? folderId,  String? comment,  DriveFileProperties? properties,  bool isSensitive)?  $default,) {final _that = this;
switch (_that) {
case _DriveFile() when $default != null:
return $default(_that.id,_that.type,_that.url,_that.thumbnailUrl,_that.name,_that.blurhash,_that.size,_that.folderId,_that.comment,_that.properties,_that.isSensitive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriveFile extends DriveFile {
  const _DriveFile({required this.id, required this.type, required this.url, this.thumbnailUrl, this.name, this.blurhash, this.size, this.folderId, this.comment, this.properties, this.isSensitive = false}): super._();
  factory _DriveFile.fromJson(Map<String, dynamic> json) => _$DriveFileFromJson(json);

@override final  String id;
@override final  String type;
@override final  String url;
@override final  String? thumbnailUrl;
@override final  String? name;
@override final  String? blurhash;
/// バイト数。
@override final  int? size;
/// ルートなら null。
@override final  String? folderId;
/// 画像の説明（alt）。
@override final  String? comment;
@override final  DriveFileProperties? properties;
@override@JsonKey() final  bool isSensitive;

/// Create a copy of DriveFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriveFileCopyWith<_DriveFile> get copyWith => __$DriveFileCopyWithImpl<_DriveFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriveFileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriveFile&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.url, url) || other.url == url)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.name, name) || other.name == name)&&(identical(other.blurhash, blurhash) || other.blurhash == blurhash)&&(identical(other.size, size) || other.size == size)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.properties, properties) || other.properties == properties)&&(identical(other.isSensitive, isSensitive) || other.isSensitive == isSensitive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type,url,thumbnailUrl,name,blurhash,size,folderId,comment,properties,isSensitive);
}

@override
String toString() {
    return 'DriveFile(id: $id, type: $type, url: $url, thumbnailUrl: $thumbnailUrl, name: $name, blurhash: $blurhash, size: $size, folderId: $folderId, comment: $comment, properties: $properties, isSensitive: $isSensitive)';
}


}

/// @nodoc
abstract mixin class _$DriveFileCopyWith<$Res> implements $DriveFileCopyWith<$Res> {
  factory _$DriveFileCopyWith(_DriveFile value, $Res Function(_DriveFile) _then) = __$DriveFileCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String url, String? thumbnailUrl, String? name, String? blurhash, int? size, String? folderId, String? comment, DriveFileProperties? properties, bool isSensitive
});


@override $DriveFilePropertiesCopyWith<$Res>? get properties;

}
/// @nodoc
class __$DriveFileCopyWithImpl<$Res>
    implements _$DriveFileCopyWith<$Res> {
  __$DriveFileCopyWithImpl(this._self, this._then);

  final _DriveFile _self;
  final $Res Function(_DriveFile) _then;

/// Create a copy of DriveFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? url = null,Object? thumbnailUrl = freezed,Object? name = freezed,Object? blurhash = freezed,Object? size = freezed,Object? folderId = freezed,Object? comment = freezed,Object? properties = freezed,Object? isSensitive = null,}) {
  return _then(_DriveFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,blurhash: freezed == blurhash ? _self.blurhash : blurhash // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,properties: freezed == properties ? _self.properties : properties // ignore: cast_nullable_to_non_nullable
as DriveFileProperties?,isSensitive: null == isSensitive ? _self.isSensitive : isSensitive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of DriveFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriveFilePropertiesCopyWith<$Res>? get properties {
    if (_self.properties == null) {
    return null;
  }

  return $DriveFilePropertiesCopyWith<$Res>(_self.properties!, (value) {
    return _then(_self.copyWith(properties: value));
  });
}
}


/// @nodoc
mixin _$DriveFileProperties {

 double? get width; double? get height;
/// Create a copy of DriveFileProperties
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriveFilePropertiesCopyWith<DriveFileProperties> get copyWith => _$DriveFilePropertiesCopyWithImpl<DriveFileProperties>(this as DriveFileProperties, _$identity);

  /// Serializes this DriveFileProperties to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DriveFileProperties;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveFileProperties&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DriveFileProperties;
  return Object.hash(runtimeType,_this.width,_this.height);
}

@override
String toString() {
  final _this = this as DriveFileProperties;
  return 'DriveFileProperties(width: ${_this.width}, height: ${_this.height})';
}


}

/// @nodoc
abstract mixin class $DriveFilePropertiesCopyWith<$Res>  {
  factory $DriveFilePropertiesCopyWith(DriveFileProperties value, $Res Function(DriveFileProperties) _then) = _$DriveFilePropertiesCopyWithImpl;
@useResult
$Res call({
 double? width, double? height
});




}
/// @nodoc
class _$DriveFilePropertiesCopyWithImpl<$Res>
    implements $DriveFilePropertiesCopyWith<$Res> {
  _$DriveFilePropertiesCopyWithImpl(this._self, this._then);

  final DriveFileProperties _self;
  final $Res Function(DriveFileProperties) _then;

/// Create a copy of DriveFileProperties
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? width = freezed,Object? height = freezed,}) {
  return _then(DriveFileProperties(
width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriveFileProperties].
extension DriveFilePropertiesPatterns on DriveFileProperties {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriveFileProperties value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriveFileProperties() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriveFileProperties value)  $default,){
final _that = this;
switch (_that) {
case _DriveFileProperties():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriveFileProperties value)?  $default,){
final _that = this;
switch (_that) {
case _DriveFileProperties() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? width,  double? height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriveFileProperties() when $default != null:
return $default(_that.width,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? width,  double? height)  $default,) {final _that = this;
switch (_that) {
case _DriveFileProperties():
return $default(_that.width,_that.height);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? width,  double? height)?  $default,) {final _that = this;
switch (_that) {
case _DriveFileProperties() when $default != null:
return $default(_that.width,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriveFileProperties implements DriveFileProperties {
  const _DriveFileProperties({this.width, this.height});
  factory _DriveFileProperties.fromJson(Map<String, dynamic> json) => _$DriveFilePropertiesFromJson(json);

@override final  double? width;
@override final  double? height;

/// Create a copy of DriveFileProperties
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriveFilePropertiesCopyWith<_DriveFileProperties> get copyWith => __$DriveFilePropertiesCopyWithImpl<_DriveFileProperties>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriveFilePropertiesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriveFileProperties&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,width,height);
}

@override
String toString() {
    return 'DriveFileProperties(width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class _$DriveFilePropertiesCopyWith<$Res> implements $DriveFilePropertiesCopyWith<$Res> {
  factory _$DriveFilePropertiesCopyWith(_DriveFileProperties value, $Res Function(_DriveFileProperties) _then) = __$DriveFilePropertiesCopyWithImpl;
@override @useResult
$Res call({
 double? width, double? height
});




}
/// @nodoc
class __$DriveFilePropertiesCopyWithImpl<$Res>
    implements _$DriveFilePropertiesCopyWith<$Res> {
  __$DriveFilePropertiesCopyWithImpl(this._self, this._then);

  final _DriveFileProperties _self;
  final $Res Function(_DriveFileProperties) _then;

/// Create a copy of DriveFileProperties
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? width = freezed,Object? height = freezed,}) {
  return _then(_DriveFileProperties(
width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
