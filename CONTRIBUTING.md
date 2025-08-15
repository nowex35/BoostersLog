## 貢献ガイド（Contributing Guide）

このリポジトリに貢献するための最小限の手順とルールをまとめています。日々の開発でここを参照してください。

### 対象ディレクトリ
- Rails アプリ本体: `service`
- CI/Dependabot 設定: ルートの`.github`配下

---

## 開発環境

### 前提
- Docker / Docker Compose がインストール済み
- OS: 任意（Windows/Mac/Linux）

### 初回セットアップ
1) `.env` を必要に応じて用意（未使用ならスキップ）
2) コンテナ起動
```bash
docker-compose up -d
```

### 停止/ログ
```bash
docker-compose stop
docker-compose logs -f api
```

### アプリに入る
```bash
docker-compose exec api bash
```

---

## データベース
- Compose の `db` サービス（PostgreSQL）を使用します
- 開発用設定は `service/config/database.yml` にあります（`host: db`, `username: postgres`, `password: password`, `database: service_development`）
    - 開発用設定を使う際には.envファイルのRAILS_ENVをdevelopmentに、本番環境を触りたい場合はRAILS_ENVをproductionにしてください

### マイグレーション
```bash
# 生成（例: users に name/email を追加）
docker-compose exec api bundle exec rails g migration AddNameAndEmailToUsers name:string email:string

# 実行
docker-compose exec api bundle exec rails db:migrate
```

### よくある操作
```bash
# 作成/リセット
docker-compose exec api bundle exec rails db:create
docker-compose exec api bundle exec rails db:reset

# スキーマ確認
docker-compose exec api cat db/schema.rb
```

---

## 命名規則（マイグレーション）
- `CreateUsers` → `users`テーブルを作成
- `AddXxxToUsers` → `users`テーブルにカラムを追加
- Rails は命名から対象テーブルを推測し、生成ファイルでは `add_column :users, :name, :string` のように明示されます

---

## テスト
CI と同等の条件で実行するには DB を起動した状態で行います。
```bash
docker-compose exec api bundle exec rails db:create
docker-compose exec api bundle exec rails db:migrate
docker-compose exec api bundle exec rails test
```

---

## Lint / Security チェック
RuboCop と Brakeman を使用します（CI でも必須）。

### RuboCop（自動修正あり）
```bash
# 解析
docker-compose exec api bundle exec rubocop -f github

# 安全な自動修正
docker-compose exec api bundle exec rubocop -a

# 強力（破壊的変更の可能性あり）
docker-compose exec api bundle exec rubocop -A
```

### Brakeman（セキュリティ静的解析）
```bash
docker-compose exec api bundle exec brakeman --no-pager
```

---

## GitHub Actions（CI）
- 設定: ルートの`.github/workflows/ci.yml`
- Ruby: `3.3.9`
- Rails コマンドは `bundle exec` で実行
- Postgres は CI サービスとして自動起動

CI での主な流れ:
1) RuboCop（`bundle exec rubocop -f github`）
2) Brakeman（`bundle exec brakeman --no-pager`）
3) DB 作成/マイグレーション後にテスト（`bundle exec rails test`）

---

## Dependabot
- ルートの`.github/dependabot.yml`で `bundler`（`/service`）と `github-actions` を監視

---

## コードスタイル
- RuboCop のデフォルトルールに準拠（例: 文字列は基本ダブルクォート、末尾スペース禁止 など）
- PR 前に `rubocop -a` を必ず実行して差分を最小化

---

## Git/PR ルール
- ブランチ: `feature/<短い説明>` または `fix/<短い説明>`
- コミットメッセージ（推奨）: Conventional Commits 風（例: `feat: add name/email to users`）
- PR は小さく・レビューしやすく。テンプレ（概要/変更点/テスト観点/リスク）を意識
- CI がグリーンであること

---

## `.keep` ファイル
- Git は空ディレクトリを追跡しないため、`log/`, `tmp/`, `storage/` などに `.keep` を置いてディレクトリを保持

---

## FAQ（トラブルシュート）
- Permission denied（`bin/rails` 等）
  - 直接 `bundle exec rails ...` を使う

- `db/schema.rb doesn't exist` と言われる
  - `bundle exec rails db:create db:migrate` を実行

- DB 接続拒否（Connection refused）
  - `docker-compose up -d` が起動済みか確認
  - `service/config/database.yml` の `host: db` を確認

---

## プッシュ前チェックリスト
- [ ] `docker-compose up -d` で環境が起動している
- [ ] `bundle exec rubocop -a` を実施し、違反ゼロ
- [ ] `bundle exec brakeman` が重大警告ゼロ（可能な限り）
- [ ] `bundle exec rails test` がグリーン
- [ ] マイグレーションを含む場合、手順と影響範囲を PR に記載

---

## デプロイ（ECS Fargate）

### 前提条件
- AWS CLI がインストール済み
- AWS認証情報が設定済み（`aws configure`）
- 必要なIAM権限が付与済み

### 手動デプロイ
```bash
# デプロイスクリプトを実行
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### 自動デプロイ（GitHub Actions）
- `main`ブランチにプッシュすると自動デプロイ
- CIが成功した後にCDが実行される

### 必要なAWSリソース
1. **ECRリポジトリ**: `boosterslog-api`
2. **ECSクラスター**: `boosterslog-cluster`
3. **ECSサービス**: `boosterslog-api-service`
4. **RDS**: PostgreSQLデータベース
5. **ALB**: ロードバランサー
6. **IAMロール**: ECS実行ロール

### 環境変数（GitHub Secrets）
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 設定ファイル
- `service/ecs-task-definition.json`: ECSタスク定義
- `service/ecs-service-definition.json`: ECSサービス定義
- `service/Dockerfile.prod`: 本番用Dockerfile
- `.github/workflows/deploy.yml`: デプロイワークフロー


