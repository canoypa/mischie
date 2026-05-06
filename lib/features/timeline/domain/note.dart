import 'package:freezed_annotation/freezed_annotation.dart';
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
    Note? renote,
    List<Note>? replies,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
