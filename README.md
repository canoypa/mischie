# Mischie

Android 向けの軽量な [Misskey](https://misskey-hub.net/) クライアント。Flutter 製。

起動・スクロール・画面遷移の速さを最優先にしている。Misskey の全機能を持つことは目指さず、Mischie に無い画面（Play、ドライブ、ページ、各種設定など）は Web クライアントで開く。

## できること

- タイムライン（ホーム・ローカル・ソーシャル・グローバル、リスト、チャンネル）のストリーミング表示
- リアクション・リノート・引用・返信・投票、ノート詳細
- 投稿（画像やファイルの添付、投票、CW、公開範囲、下書き、絵文字・MFM・メンションの入力補完）
- 他アプリからの画像・テキストの共有を受け取っての投稿
- 通知一覧と未読バッジ
- プロフィール、フォロー・ミュート・ブロック、検索
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

## OAuth

サーバーへのログインは OAuth 2.0（PKCE）で、`client_id` は `docs/` を GitHub Pages で公開した https://mischie.tepbyte.dev/ を使う。このページがリダイレクト先の `mischie://oauth/callback` を宣言している。
