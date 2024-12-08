require 'mysql2'
require 'webrick'

# MySQLの接続情報
DB_HOST = ENV['DATABASE_HOST']
DB_USER = ENV['DATABASE_USER']
DB_PASSWORD = ENV['DATABASE_PASSWORD']
DB_NAME = ENV['DATABASE_NAME']

module IndexRoute # rubocop:disable Metrics/ModuleLength
  # タグをすべて取得するメソッド
  def self.obtain_tags
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

  # スニペットを取得するメソッド
  def self.get_snippets(options = {})
    client = Mysql2::Client.new(
      host: DB_HOST,
      username: DB_USER,
      password: DB_PASSWORD,
      database: DB_NAME
    )

    # 基本のSQLクエリ
    base_query = <<-SQL
      SELECT 
        s.id,
        s.title,
        s.description,
        s.content,
        s.created_at,
        s.copy_count,
        GROUP_CONCAT(t.name SEPARATOR ', ') AS tags
      FROM 
        snippets s
      LEFT JOIN 
        snippet_tags st ON s.id = st.snippet_id
      LEFT JOIN 
        tags t ON st.tag_id = t.id
    SQL

    # 条件の配列を初期化
    conditions = []
    params = []

    
    # タグでの絞り込み
    if options[:tags] && !options[:tags].empty?
      conditions << "t.name = ?"
      params << options[:tags]
    end

    # 検索キーワード
    if options[:search] && !options[:search].empty?
      search_condition = "(s.title LIKE ? OR s.description LIKE ? OR s.content LIKE ?)"
      conditions << search_condition
      search_param = "%#{options[:search]}%"
      params += [search_param, search_param, search_param]
    end

    # 条件をクエリに追加
    base_query += " WHERE #{conditions.join(' AND ')}" unless conditions.empty?

    # グループ化
    base_query += " GROUP BY s.id, s.description, s.title, s.content, s.created_at, s.copy_count"

    # ソート
    case options[:sort_by]
    when 'copy_count_desc'
      base_query += " ORDER BY s.copy_count DESC"
    when 'copy_count_asc'
      base_query += " ORDER BY s.copy_count ASC"
    when 'created_at_desc'
      base_query += " ORDER BY s.created_at DESC"
    when 'created_at_asc'
      base_query += " ORDER BY s.created_at ASC"
    end

    # 最初の100件を取得
    base_query += " LIMIT 100"

    # プリペアドステートメントを使用
    statement = client.prepare(base_query)
    results = statement.execute(*params)

    snippets = results.map do |row|
      {
        id: row['id'],
        title: row['title'],
        description: row['description'],
        content: row['content'],
        tags: row['tags']&.split(', ') || [],
        created_at: row['created_at'],
        copy_count: row['copy_count']
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
        <div class="snippet" id = "#{snippet[:id]}">
          <h2>#{snippet[:title]}</h2>
          <p>#{snippet[:description]}</p>
          <div class="tags">Tags: #{snippet[:tags].join(', ')}</div>
          <p>Created at: #{snippet[:created_at]}</p>
        </div>
      HTML
    end.join("\n")
  end

  # ページHTMLを生成するメソッド
  def self.generate_page_html(snippet_html, tags)
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
              <a href="/snippet_add.html"><button>+ 新しいスニペットを作成</button></a>
            </div>
          </header>
          <main id="snippet-container">
            #{snippet_html}
          </main>

          <div id="filter-menu-overlay" class="hidden">
            <div id="filter-menu">
              <h3>絞り込み・並べ替えメニュー</h3>
              <div>
                <label>タグ</label>
                #{tags.map { |tag| "<button class='tag'>#{tag}</button>" }.join(' ')}
              </div>
              <div>
                <label>コピー回数</label>
                <button data-sort="copy_count_desc">降順（DESC)</button>
                <button data-sort="copy_count_asc">昇順（ASC)</button>
              </div>
              <div>
                <label>投稿日</label>
                <button data-sort="created_at_desc">新しい順</button>
                <button data-sort="created_at_asc">古い順</button>
              </div>
            </div>
          </div>
          <script src="js/snippet_index.js"></script>
        </body>
      </html>
    HTML
  end
end