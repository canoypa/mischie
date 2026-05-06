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
    @Default(false) bool isSensitive,
  }) = _DriveFile;

  factory DriveFile.fromJson(Map<String, dynamic> json) =>
      _$DriveFileFromJson(json);
}
