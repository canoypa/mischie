// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drive_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriveFile {

 String get id; String get type; String get url; String? get thumbnailUrl; String? get name; String? get blurhash;/// 画像の説明（alt）。読み上げと、内容を確かめたいときに使う。
 String? get comment;/// 画像の寸法など。縦横比を保って表示するのに使う。
 DriveFileProperties? get properties; bool get isSensitive;
/// Create a copy of DriveFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriveFileCopyWith<DriveFile> get copyWith => _$DriveFileCopyWithImpl<DriveFile>(this as DriveFile, _$identity);

  /// Serializes this DriveFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveFile&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.url, url) || other.url == url)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.name, name) || other.name == name)&&(identical(other.blurhash, blurhash) || other.blurhash == blurhash)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.properties, properties) || other.properties == properties)&&(identical(other.isSensitive, isSensitive) || other.isSensitive == isSensitive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,url,thumbnailUrl,name,blurhash,comment,properties,isSensitive);

@override
String toString() {
  return 'DriveFile(id: $id, type: $type, url: $url, thumbnailUrl: $thumbnailUrl, name: $name, blurhash: $blurhash, comment: $comment, properties: $properties, isSensitive: $isSensitive)';
}


}

/// @nodoc
abstract mixin class $DriveFileCopyWith<$Res>  {
  factory $DriveFileCopyWith(DriveFile value, $Res Function(DriveFile) _then) = _$DriveFileCopyWithImpl;
@useResult
$Res call({
 String id, String type, String url, String? thumbnailUrl, String? name, String? blurhash, String? comment, DriveFileProperties? properties, bool isSensitive
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? url = null,Object? thumbnailUrl = freezed,Object? name = freezed,Object? blurhash = freezed,Object? comment = freezed,Object? properties = freezed,Object? isSensitive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,blurhash: freezed == blurhash ? _self.blurhash : blurhash // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String url,  String? thumbnailUrl,  String? name,  String? blurhash,  String? comment,  DriveFileProperties? properties,  bool isSensitive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriveFile() when $default != null:
return $default(_that.id,_that.type,_that.url,_that.thumbnailUrl,_that.name,_that.blurhash,_that.comment,_that.properties,_that.isSensitive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String url,  String? thumbnailUrl,  String? name,  String? blurhash,  String? comment,  DriveFileProperties? properties,  bool isSensitive)  $default,) {final _that = this;
switch (_that) {
case _DriveFile():
return $default(_that.id,_that.type,_that.url,_that.thumbnailUrl,_that.name,_that.blurhash,_that.comment,_that.properties,_that.isSensitive);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String url,  String? thumbnailUrl,  String? name,  String? blurhash,  String? comment,  DriveFileProperties? properties,  bool isSensitive)?  $default,) {final _that = this;
switch (_that) {
case _DriveFile() when $default != null:
return $default(_that.id,_that.type,_that.url,_that.thumbnailUrl,_that.name,_that.blurhash,_that.comment,_that.properties,_that.isSensitive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriveFile extends DriveFile {
  const _DriveFile({required this.id, required this.type, required this.url, this.thumbnailUrl, this.name, this.blurhash, this.comment, this.properties, this.isSensitive = false}): super._();
  factory _DriveFile.fromJson(Map<String, dynamic> json) => _$DriveFileFromJson(json);

@override final  String id;
@override final  String type;
@override final  String url;
@override final  String? thumbnailUrl;
@override final  String? name;
@override final  String? blurhash;
/// 画像の説明（alt）。読み上げと、内容を確かめたいときに使う。
@override final  String? comment;
/// 画像の寸法など。縦横比を保って表示するのに使う。
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriveFile&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.url, url) || other.url == url)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.name, name) || other.name == name)&&(identical(other.blurhash, blurhash) || other.blurhash == blurhash)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.properties, properties) || other.properties == properties)&&(identical(other.isSensitive, isSensitive) || other.isSensitive == isSensitive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,url,thumbnailUrl,name,blurhash,comment,properties,isSensitive);

@override
String toString() {
  return 'DriveFile(id: $id, type: $type, url: $url, thumbnailUrl: $thumbnailUrl, name: $name, blurhash: $blurhash, comment: $comment, properties: $properties, isSensitive: $isSensitive)';
}


}

/// @nodoc
abstract mixin class _$DriveFileCopyWith<$Res> implements $DriveFileCopyWith<$Res> {
  factory _$DriveFileCopyWith(_DriveFile value, $Res Function(_DriveFile) _then) = __$DriveFileCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String url, String? thumbnailUrl, String? name, String? blurhash, String? comment, DriveFileProperties? properties, bool isSensitive
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? url = null,Object? thumbnailUrl = freezed,Object? name = freezed,Object? blurhash = freezed,Object? comment = freezed,Object? properties = freezed,Object? isSensitive = null,}) {
  return _then(_DriveFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,blurhash: freezed == blurhash ? _self.blurhash : blurhash // ignore: cast_nullable_to_non_nullable
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveFileProperties&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,width,height);

@override
String toString() {
  return 'DriveFileProperties(width: $width, height: $height)';
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
  return _then(_self.copyWith(
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
int get hashCode => Object.hash(runtimeType,width,height);

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
