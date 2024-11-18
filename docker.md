### Dockerの仕様書
#### Dockerコンテナの起動から削除

1. 作成
```bash
docker compose --build
```
2. 起動
```bash
docker compose up
```
`-d`のオプションをつけることによりデタッチモードでコンテナを起動

3. 停止
```bash
docker compose stop
```

4. 削除
```bash
docker compose down
```

5. 作成&起動
```bash
docker compose up -d --build
```

#### MySQLにログイン
```bash
docker exec -it team_development_1-db-1 mysql -u root -p
```

#### シェル操作
```bash
docker compose exec web bash
```
