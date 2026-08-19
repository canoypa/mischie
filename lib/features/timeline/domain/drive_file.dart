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

    /// 画像の説明（alt）。読み上げと、内容を確かめたいときに使う。
    String? comment,
    @Default(false) bool isSensitive,
  }) = _DriveFile;

  factory DriveFile.fromJson(Map<String, dynamic> json) =>
      _$DriveFileFromJson(json);
}
