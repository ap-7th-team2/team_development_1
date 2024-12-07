require 'mysql2'
require 'webrick'

# MySQLの接続情報
DB_HOST = ENV['DATABASE_HOST']
DB_USER = ENV['DATABASE_USER']
DB_PASSWORD = ENV['DATABASE_PASSWORD']
DB_NAME = ENV['DATABASE_NAME']

module IndexRoute
  # タグをすべて取得するメソッド
  def self.get_tags
    client = Mysql2::Client.new(
      host: DB_HOST,
      username: DB_USER,
      password: DB_PASSWORD,
      database: DB_NAME
    )
    query = 'SELECT name FROM tags'
    results = client.query(query).map { |row| row['name'] }
    client.close
    results
  rescue Mysql2::Error => e
    puts "MySQL Error: #{e.message}"
    []
  end

  # 一覧表示するスニペットを取得するメソッド
  def self.get_snippets(limit, offset)
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
          s.description,
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
          s.id, s.description, s.title, s.content, s.created_at
        LIMIT #{limit} OFFSET #{offset};
    SQL

    results = client.query(query)

    snippets = results.map do |row|
      {
        id: row['id'],
        title: row['title'],
        description: row['description'],
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
  def self.generate_snippets_html(snippets)
    snippets.map do |snippet|
      <<-HTML
        <div class="snippet">
          <h2>#{snippet[:title]}</h2>
          <p>#{snippet[:description]}</p>
          <div class="tags">Tags: #{snippet[:tags].join(', ')}</div>
          <p>Created at: #{snippet[:created_at]}</p>
        </div>
      HTML
    end.join("\n")
  end

  # データベースに次のページのデータが存在するかを確認するメソッド
  def self.next_page?(limit, offset)
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
  def self.generate_page_html(snippet_html, offset, limit, snippets, tags)
    # 次のページがあるかどうかを判定
    has_next_page = next_page?(limit, offset)

    <<~HTML
      <!DOCTYPE html>
        <html lang="ja">
        <head>
          <meta charset="UTF-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>Snippet App</title>
          <link rel="stylesheet" href="css/snippet_index.css" />
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
              <a href="/snippet_add.html"><button>+ Create a new snippet</button></a>
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

          <div id="filter-menu-overlay" class="hidden">
            <div id="filter-menu">
              <h3>絞り込み・並べ替えメニュー</h3>
              <div>
                <label>タグ</label>
                #{tags.map { |tag| "<button class='tag'>#{tag}</button>" }.join(' ')}
              </div>
              <div>
                <label>コピー回数</label>
                <button>降順（DESC)</button>
                <button>昇順（ASC)</button>
              </div>
              <div>
                <label>投稿日</label>
                <button>新しい順</button>
                <form action="/get_snippet" method="get">
                  <button>古い順</button>
                </form>
              </div>
            </div>
          </div>
          <script src="js/snippet_index.js"></script>
        </body>
      </html>
    HTML
  end
end