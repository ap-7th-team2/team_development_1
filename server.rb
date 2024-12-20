# frozen_string_literal: true

require 'webrick'
require 'mysql2'
require "erb"
require_relative 'routes/snippet_routes'
require_relative 'routes/index_route'

  # MySQLの接続情報
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
    SELECT snippets.id, snippets.title, snippets.content, snippets.description
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
server.mount('/css', WEBrick::HTTPServlet::FileHandler, './views/css')
server.mount('/js', WEBrick::HTTPServlet::FileHandler, './views/js')

# /get_snippetsエンドポイント
server.mount_proc '/get_snippets' do |req, res|
  sort_by = req.query['sort_by'] || 'created_at_desc' # デフォルト値
  tags_filter = req.query['tags'] || nil             # タグの絞り込み条件
  search_query = req.query['search'] || nil          # 検索キーワード

  # オプションを構成
  options = {
    sort_by: sort_by,
    tags: tags_filter,
    search: search_query
  }
  tags = IndexRoute.obtain_tags
  snippets = IndexRoute.get_snippets(options) # options を渡す
  snippet_html = IndexRoute.generate_snippets_html(snippets)
  res.content_type = 'text/html'
  res.body = IndexRoute.generate_page_html(snippet_html, tags)
end

# `/create` エンドポイントでフォームデータを処理
server.mount_proc '/create' do |req, res|
  begin
    SnippetRoutes.handle_create(req, res)
  rescue StandardError => e
    res.status = 500
    res.body = "Internal Server Error: #{e.message}"
  end
end

# `/edit` エンドポイントでフォームのデータを処理
server.mount_proc '/edit' do |req, res|
  begin
    SnippetRoutes.handle_edit(req, res)
  rescue StandardError => e
    res.status = 500
    res.body = "Internal Server Error: #{e.message}"
  end
end

# `/update` エンドポイントでフォームのデータを処理
server.mount_proc '/update' do |req, res|
  begin
    SnippetRoutes.handle_update(req, res)
  rescue StandardError => e
    res.status = 500
    res.body = "Internal Server Error: #{e.message}"
  end
end

# `/delete/:id` エンドポイントでスニペットを削除
server.mount_proc '/delete' do |req, res|
  begin
    # POSTリクエストとmethod-overrideをチェック
    if req.request_method == 'POST' && req.query['_method'] == 'DELETE'
      snippet_id = req.path.split('/delete/').last

      client = Mysql2::Client.new(
        host: DB_HOST,
        username: DB_USER,
        password: DB_PASSWORD,
        database: DB_NAME,
        encoding: 'utf8'
      )

      # トランザクションを開始
      client.query('START TRANSACTION')
      begin
        # スニペットとタグの関連付けを削除
        client.query("DELETE FROM snippet_tags WHERE snippet_id = #{client.escape(snippet_id)}")
        # スニペットを削除
        client.query("DELETE FROM snippets WHERE id = #{client.escape(snippet_id)}")
        client.query('COMMIT')
      rescue StandardError => e
        client.query('ROLLBACK')
        raise e
      ensure
        client.close
      end

      # 削除成功後、トップページにリダイレクト
      res.status = 302
      res.header['Location'] = '/delete_complete.html'
    else
      res.status = 405
      res.body = 'Method not allowed'
    end
  rescue StandardError => e
    res.status = 500
    res.body = "Internal Server Error: #{e.message}"
  end
end

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
    id: snippet['id'],
    title: snippet['title'],
    content: snippet['content'],
    description: snippet['description'],
    tags: tags
  )
end

trap('INT') { server.shutdown }
server.start
