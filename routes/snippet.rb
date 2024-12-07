require 'mysql2'
require 'webrick'

# MySQLの接続情報
DB_HOST = ENV['DATABASE_HOST']
DB_USER = ENV['DATABASE_USER']
DB_PASSWORD = ENV['DATABASE_PASSWORD']
DB_NAME = ENV['DATABASE_NAME']

# 一覧表示するスニペットを取得するメソッド
def get_snippets(limit, offset)
  client = Mysql2::Client.new(
    host: DB_HOST,
    username: DB_USER,
    password: DB_PASSWORD,
    database: DB_NAME
  )

  query = <<-SQL
      SELECT#{' '}
        s.id,
        s.title,
        s.content,
        s.created_at,
        GROUP_CONCAT(t.name SEPARATOR ', ') AS tags
      FROM#{' '}
        snippets s
      LEFT JOIN#{' '}
        snippet_tags st ON s.id = st.snippet_id
      LEFT JOIN#{' '}
        tags t ON st.tag_id = t.id
      GROUP BY#{' '}
        s.id, s.title, s.content, s.created_at
      LIMIT #{limit} OFFSET #{offset};
  SQL

  results = client.query(query)

  snippets = results.map do |row|
    {
      id: row['id'],
      title: row['title'],
      content: row['content'],
      tags: row['tags']&.split(', ') || [],
      created_at: row['created_at']
    }
  end
  client.close
  snippets
rescue Mysql2::Error => e
  puts "MySQL Error: #{e.message}"
  []
end

# スニペットをHTMLに変換するメソッド
def generate_snippets_html(snippets)
  snippets.map do |snippet|
    <<~HTML
      <div class='snippet'>
        <h2>#{snippet[:title]}</h2>
        <p>#{snippet[:content]}</p>
        <p class='tags'>
          #{snippet[:tags].map { |tag| "<span class='tag'>#{tag}</span>" }.join(' ')}
        </p>
      </div>
    HTML
  end.join
end

# データベースに次のページのデータが存在するかを確認するメソッド
def next_page?(limit, offset)
  client = Mysql2::Client.new(
    host: DB_HOST,
    username: DB_USER,
    password: DB_PASSWORD,
    database: DB_NAME
  )

  # 次のページのデータ数を確認するクエリ
  query = <<-SQL
      SELECT COUNT(*) as next_page_count
      FROM (
        SELECT#{' '}
          s.id
        FROM#{' '}
          snippets s
        LEFT JOIN#{' '}
          snippet_tags st ON s.id = st.snippet_id
        LEFT JOIN#{' '}
          tags t ON st.tag_id = t.id
        GROUP BY#{' '}
          s.id, s.title, s.content, s.created_at
        LIMIT #{limit} OFFSET #{offset + limit}
      ) as next_page
  SQL

  result = client.query(query)
  count = result.first['next_page_count']
  client.close

  count.positive?
rescue Mysql2::Error => e
  puts "MySQL Error: #{e.message}"
  false
end

# ページHTMLを生成するメソッド
def generate_page_html(snippet_html, offset, limit, _snippets)
  # 次のページがあるかどうかを判定
  has_next_page = next_page?(limit, offset)

  <<~HTML
    <!DOCTYPE html>
      <html lang="ja">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Snippet App</title>
        <link rel="stylesheet" href="css/style.css" />
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
      </head>
      <body>
        <header>
          <div id="title"><h1><a href = "/">Snippet App</a></h1></div>
          <div id="filter-button">
            <button><i class="fas fa-sliders-h"></i></button>
          </div>
          <div class="search-container">
            <i class="fas fa-search search-icon"></i>
            <input type="text" placeholder="どんなコードを探してみる？（例：「配列 ハッシュ」「class」）">
          </div>
          <div id="create-button">
            <button>+ Create a new snippet</button>
          </div>
        </header>
        <main id="snippet-container">
          #{snippet_html}
        </main>
        <div id="pagination-controls">
          <form action="/get_snippets" method="get">
            <input type="hidden" name="offset" value="#{offset - limit}" id="previous-offset">
            <input type="hidden" name="limit" value="#{limit}">
            <button type="submit" #{offset.zero? ? 'disabled' : ''}>Previous</button>
          </form>
          <form action="/get_snippets" method="get">
            <input type="hidden" name="offset" value="#{offset + limit}" id="next-offset">
            <input type="hidden" name="limit" value="#{limit}">
            <button type="submit" #{has_next_page ? '' : 'disabled'}>Next</button>
          </form>
        </div>
      </body>
    </html>
  HTML
end

# WEBrickサーバー設定
server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: './views')
server.mount('/css', WEBrick::HTTPServlet::FileHandler, './views/css')

# /get_snippetsエンドポイント
server.mount_proc '/get_snippets' do |req, res|
  offset = req.query['offset'].to_i || 0
  limit = req.query['limit'].to_i || 4

  snippets = get_snippets(limit, offset)
  snippet_html = generate_snippets_html(snippets)

  res.content_type = 'text/html'
  res.body = generate_page_html(snippet_html, offset, limit, snippets)
end

# ルートパス
server.mount_proc '/' do |_req, res|
  offset = 0
  limit = 4

  snippets = get_snippets(limit, offset)
  snippet_html = generate_snippets_html(snippets)

  res.content_type = 'text/html'
  res.body = generate_page_html(snippet_html, offset, limit, snippets)
end

server.start
