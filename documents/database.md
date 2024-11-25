## 初期データベース構築について
### テーブル作成・テストデータの挿入
1. スクリプトについて
`db/init.sql`が該当のファイル．
2. スクリプトの実行
```bash
# コンテナ内にファイルをコピー
docker cp db/init.sql team_development_1-db-1:/init.sql
# コンテナ内に入る
docker exec -it team_development_1-db-1 bash
# スクリプトを実行
mysql -u root -p < /init.sql
```
3. データの確認
```bash
# コンテナ内に入り，MySQLに接続する．
docker exec -it team_development_1-db-1 mysql -u root -p
```

```SQL
-- SQLでデータの確認
SHOW DATABASES;
USE snippet_db;
SHOW TABLES;
SELECT * FROM snippets;
```

### Rubyスクリプトによるデータベースとの接続テスト
1. スクリプトについて
`routes/snippet.rb`が該当のファイル．
2. スクリプトの実行
``` bash
# コンテナ内にファイルをコピー
docker cp routes/snippet.rb team_development_1-web-1:/snippet.rb
# コンテナの中に入る
docker exec -it team_development_1-web-1 bash
# スクリプトを実行
ruby routes/snippet.rb
#=> 成功すると，テーブル一覧が表示されるはず
```