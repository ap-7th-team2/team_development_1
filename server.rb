# frozen_string_literal: true

require 'webrick'
require 'mysql2'
require "erb"

# webコンテナ内で設定した環境変数を読み込みruby内で使用できるように変数に代入
# GitHub Actionsの動作確認2回目
DB_HOST = ENV['DATABASE_HOST']
DB_USER = ENV['DATABASE_USER']
DB_PASSWORD = ENV['DATABASE_PASSWORD']
DB_NAME = ENV['DATABASE_NAME']

# データベースからスニペット情報を取得する関数
def fetch_snippet_from_db(snippet_id)
  client = Mysql2::Client.new(
    host: DB_HOST,
    username: DB_USER,
    password: DB_PASSWORD,
    database: DB_NAME,
    encoding: 'utf8'
  )

  # スニペット情報の取得
  snippet_query = <<~SQL
    SELECT snippets.id, snippets.title, snippets.content
    FROM snippets
    WHERE snippets.id = #{client.escape(snippet_id.to_s)} LIMIT 1;
  SQL

  snippet = client.query(snippet_query).first

  # タグ情報の取得
  tags_query = <<~SQL
    SELECT tags.name
    FROM tags
    JOIN snippet_tags ON snippet_tags.tag_id = tags.id
    WHERE snippet_tags.snippet_id = #{client.escape(snippet_id.to_s)};
  SQL

  tags = client.query(tags_query).map { |row| row['name'] }

  client.close

  return { snippet: snippet, tags: tags }
end

server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: './views')

# 詳細ページ用の動的ルーティング
server.mount_proc "/snippets" do |req, res|
  # URLからスニペットIDを取得(Ex. 「/snippets/1」にアクセスすると、「1」を取得)
  id = req.path.split("/").last.to_i # パスから「/」で分割した配列を作り、配列の最後の要素を整数に変換

  # 情報をDBから取得
  result = fetch_snippet_from_db(id)
  snippet = result[:snippet]
  tags = result[:tags]

  # ERBテンプレートの読み込み(読み込みには"erb"gemが必須)
  template = ERB.new(File.read("views/snippet_detail.html.erb"))

  # データをテンプレートに渡してHTMLを生成
  res.body = template.result_with_hash(
    title: snippet['title'],
    content: snippet['content'],
    tags: tags
  )
end

server.start
