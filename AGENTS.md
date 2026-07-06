# Mischie

Flutter 製の Misskey クライアント
Misskey API は WebSocket + REST、認証は OAuth 2.0 PKCE。

## コマンド

```sh
# コード生成（モデル変更・プロバイダー追加後は必須）
dart run build_runner build

# 静的解析
flutter analyze lib/

# 実行（接続済みデバイスが必要）
flutter run
```

## アーキテクチャ

`lib/features/<name>/` に機能を分割。各機能は `data/`, `domain/`, `presentation/` 層を持つ。

- **状態管理**: Riverpod 3 (`AsyncNotifier`, `FutureProvider`)
- **モデル**: `freezed` + `json_serializable`。変更後は必ずコード生成を実行する
- **ルーティング**: `go_router`
- **デザイン**: Material Design 3

## 実装上の注意点

- **Riverpod**: `build()` 内で他のプロバイダーを変更しない（assertion エラーになる）
- **`CachedNetworkImage`**: サイズを外側から制約できない箇所では `placeholder` に `SizedBox(height, width)` を指定する（省略するとロード前にサイズが 0 になりレイアウトが崩れる）
