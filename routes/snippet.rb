require 'mysql2'
require 'webrick'
require 'json'

# MySQLの接続情報
DB_HOST = ENV['DATABASE_HOST']
DB_USER = ENV['DATABASE_USER']
DB_PASSWORD = ENV['DATABASE_PASSWORD']
DB_NAME = ENV['DATABASE_NAME']

# 一覧表示するスニペットを取得する
def get_snippets(limit, offset)
  client = Mysql2::Client.new(
    host: DB_HOST,
    username: DB_USER,
    password: DB_PASSWORD,
    database: DB_NAME
  )
  
  # タグ情報も一緒に取得するJOINクエリ
  query = <<-SQL
    SELECT 
      s.id, 
      s.title, 
      s.content, 
      s.created_at,
      GROUP_CONCAT(t.name SEPARATOR ', ') AS tags
    FROM 
      snippets s
    LEFT JOIN 
      snippet_tags st ON s.id = st.snippet_id
    LEFT JOIN 
      tags t ON st.tag_id = t.id
    GROUP BY 
      s.id, s.title, s.content, s.created_at
    LIMIT #{limit} OFFSET #{offset};
  SQL
  
  results = client.query(query)

  snippets = results.map do |row|
    {
      id: row['id'],
      title: row['title'],
      content: row['content'],
      tags: row['tags']&.split(', ') || [] , # タグがない場合は空配列
      created_at: row['created_at'] 
    }
  end
  client.close
  snippets
end

# WEBrickサーバー設定
server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: './views')

# /get_snippets エンドポイント
server.mount_proc '/get_snippets' do |req, res|
  # クエリパラメータからlimitとoffsetを取得
  limit = req.query['limit'] || 4
  offset = req.query['offset'] || 0

  snippets = get_snippets(limit, offset)

  res.content_type = 'application/json'
  res.body = snippets.to_json
end

server.start
