import 'package:freezed_annotation/freezed_annotation.dart';

part 'drive_file.freezed.dart';
part 'drive_file.g.dart';

@freezed
sealed class DriveFile with _$DriveFile {
  const factory DriveFile({
    required String id,
    required String type,
    required String url,
    String? thumbnailUrl,
    String? name,
    String? blurhash,

    /// バイト数。
    int? size,

    /// ルートなら null。
    String? folderId,

    /// 画像の説明（alt）。
    String? comment,

    DriveFileProperties? properties,
    @Default(false) bool isSensitive,
  }) = _DriveFile;

  const DriveFile._();

  factory DriveFile.fromJson(Map<String, dynamic> json) =>
      _$DriveFileFromJson(json);

  /// 極端な縦長・横長がタイムラインを占領しないよう上下限を設ける。
  double get displayAspectRatio {
    final width = properties?.width;
    final height = properties?.height;
    if (width == null || height == null || width <= 0 || height <= 0) {
      return 16 / 9;
    }
    return (width / height).clamp(0.75, 16 / 9);
  }
}

@freezed
sealed class DriveFileProperties with _$DriveFileProperties {
  const factory DriveFileProperties({double? width, double? height}) =
      _DriveFileProperties;

  factory DriveFileProperties.fromJson(Map<String, dynamic> json) =>
      _$DriveFilePropertiesFromJson(json);
}
