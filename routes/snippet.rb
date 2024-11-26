require 'mysql2'

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