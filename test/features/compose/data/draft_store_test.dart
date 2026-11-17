import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/compose/data/draft_store.dart';

void main() {
  group('Draft JSON round trip', () {
    test('replyId・renoteId・投票を保って戻る', () {
      const draft = Draft(
        id: 'd1',
        text: '本文',
        savedAt: '2026-09-19T00:00:00.000Z',
        cw: '閲覧注意',
        visibility: 'followers',
        fileIds: ['f1', 'f2'],
        replyId: 'note-reply',
        renoteId: 'note-renote',
        channelId: 'channel1',
        channelName: 'お絵かき',
        pollChoices: ['A', 'B', ''],
        pollMultiple: true,
        pollExpiresInMs: 3600000,
      );

      final restored = Draft.fromJson(draft.toJson());

      expect(restored.id, draft.id);
      expect(restored.text, draft.text);
      expect(restored.cw, draft.cw);
      expect(restored.visibility, draft.visibility);
      expect(restored.fileIds, draft.fileIds);
      expect(restored.replyId, 'note-reply');
      expect(restored.renoteId, 'note-renote');
      expect(restored.channelId, 'channel1');
      expect(restored.channelName, 'お絵かき');
      expect(restored.pollChoices, ['A', 'B', '']);
      expect(restored.pollMultiple, isTrue);
      expect(restored.pollExpiresInMs, 3600000);
    });

    test('投票なしの下書きは pollChoices が null で戻る', () {
      const draft = Draft(
        id: 'd2',
        text: '投票なし',
        savedAt: '2026-09-19T00:00:00.000Z',
      );

      final restored = Draft.fromJson(draft.toJson());

      expect(restored.pollChoices, isNull);
      expect(restored.pollMultiple, isFalse);
      expect(restored.pollExpiresInMs, isNull);
      expect(restored.replyId, isNull);
      expect(restored.renoteId, isNull);
    });

    test('後から足した項目が無い古い下書きも読める', () {
      final old = Draft.fromJson({
        'id': 'old-1',
        'text': '昔の下書き',
        'savedAt': '2024-01-01T00:00:00.000Z',
        'cw': null,
        'visibility': 'public',
        'fileIds': <String>[],
      });

      expect(old.text, '昔の下書き');
      expect(old.pollChoices, isNull);
      expect(old.pollMultiple, isFalse);
      expect(old.pollExpiresInMs, isNull);
      expect(old.replyId, isNull);
      expect(old.renoteId, isNull);
      expect(old.channelId, isNull);
      expect(old.channelName, isNull);
    });
  });
}
