import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';
import 'package:mischie/features/timeline/domain/user.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@freezed
sealed class Note with _$Note {
  const factory Note({
    required String id,
    required String createdAt,
    required User user,
    String? text,
    String? cw,
    Note? renote,
    List<Note>? replies,
    @Default([]) List<DriveFile> files,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
