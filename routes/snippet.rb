require 'mysql2'

DB_HOST = ENV['DATABASE_HOST']
DB_USER = ENV['DATABASE_USER']
DB_PASSWORD = ENV['DATABASE_PASSWORD']
DB_NAME = ENV['DATABASE_NAME']

begin
  # MySQLサーバに接続
  client = Mysql2::Client.new(
    host: DB_HOST,
    username: DB_USER,
    password: DB_PASSWORD,
    database: DB_NAME
  )

  puts "データベースに接続しました！"

  # テーブル情報の取得
  results = client.query("SHOW TABLES;")
  puts "テーブル一覧:"
  results.each do |row|
    puts row
  end

rescue Mysql2::Error => e
  puts "エラー: #{e.message}"
ensure
  client&.close
  puts "接続を閉じました。"
end

# 動作確認
