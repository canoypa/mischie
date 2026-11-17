# Mischie

Android 向けの軽量な [Misskey](https://misskey-hub.net/) クライアント。Flutter 製。

起動・スクロール・画面遷移の速さを最優先にしている。Mischie に無い画面（Play、リストやアンテナの管理、各種設定など）は Web クライアントで開く。

## できること

- タイムライン（ホーム・ローカル・ソーシャル・グローバル、リスト）のストリーミング表示、チャンネルとハッシュタグのノート一覧
- リアクション・リノート・引用・返信・投票、ノート詳細、リアクションした人とリノートした人の一覧
- ノートの共有・お気に入り・ピン留め・スレッドのミュート・通報・削除して編集
- 投稿（画像・動画・ドライブのファイルの添付、投票、CW、公開範囲、チャンネル、下書き、絵文字・MFM・メンションの入力補完）
- 他アプリからの画像・動画・テキストの共有を受け取っての投稿
- 通知一覧と未読バッジ、フォローリクエストの承認・拒否
- プロフィール、フォロー・ミュート・ブロック、ワードミュート、検索、お気に入り
- ドライブ（ファイルとフォルダの閲覧・整理・削除）
- 複数サーバーのアカウントの切り替え

## 開発

ツールのバージョンは [mise](https://mise.jdx.dev/) で揃える。

```sh
mise install
flutter pub get
dart run build_runner build   # freezed / json_serializable / Riverpod のコード生成
flutter test
flutter run
```

見た目の確認は `test/goldens/` のゴールデンテストで行う。

```sh
flutter test test/goldens --update-goldens
```

構成と実装上の注意は [AGENTS.md](AGENTS.md) にある。

### リリースビルド

署名鍵の設定を `android/key.properties` に置く（リポジトリには含めない）。無ければデバッグ鍵で署名される。

```properties
storeFile=/path/to/release.jks
storePassword=...
keyAlias=...
keyPassword=...
```

```sh
flutter build apk --release
```

## ライセンス

[AGPL-3.0](LICENSE)
