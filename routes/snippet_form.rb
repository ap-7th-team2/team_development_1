require 'mysql2'

module SnippetForm
  DB_HOST = ENV['DATABASE_HOST']
  DB_USER = ENV['DATABASE_USER']
  DB_PASSWORD = ENV['DATABASE_PASSWORD']
  DB_NAME = ENV['DATABASE_NAME']

  # データベースクライアントの生成
  def self.create_client
    Mysql2::Client.new(
      host: DB_HOST,
      username: DB_USER,
      password: DB_PASSWORD,
      database: DB_NAME
    )
  end

  # 入力データのバリデーション
  def self.validate_snippet(params)
    errors = []
    errors << "タイトルは必須です" if params['title'].nil? || params['title'].strip.empty?
    errors << "コードは必須です" if params['code'].nil? || params['code'].strip.empty?
    errors
  end

  # スニペットを保存する
  def self.save_snippet(params)
    errors = validate_snippet(params)
    raise StandardError, errors.join(", ") unless errors.empty?
  
    client = create_client
    begin
      # プレースホルダーを使ったクエリでデータを保存
      snippet_query = <<~SQL
        INSERT INTO snippets (title, content, description) 
        VALUES (?, ?, ?)
      SQL
  
      # スニペットデータを保存しIDを取得
      statement = client.prepare(snippet_query)
      statement.execute(params['title'], params['code'], params['description'])
      snippet_id = client.last_id
  
      # タグの保存処理
      save_tags(client, snippet_id, params['tags'])
    ensure
      client.close
    end
  end
  
  def self.save_tags(client, snippet_id, tags)
    tag_query = <<~SQL
      INSERT INTO tags (name) VALUES (?)
      ON DUPLICATE KEY UPDATE id=LAST_INSERT_ID(id)
    SQL
    snippet_tag_query = <<~SQL
      INSERT INTO snippet_tags (snippet_id, tag_id) VALUES (?, ?)
    SQL
  
    tags.split(/\s+/).each do |tag|
      tag_stmt = client.prepare(tag_query)
      tag_stmt.execute(tag)
      tag_id = client.last_id
  
      snippet_tag_stmt = client.prepare(snippet_tag_query)
      snippet_tag_stmt.execute(snippet_id, tag_id)
    end
  end
  

  # スニペットを取得する
  def self.get_snippet(id)
    client = create_client
    begin
      result = client.query("SELECT snippets.*, GROUP_CONCAT(tags.name SEPARATOR ' ') as tags
                             FROM snippets
                             LEFT JOIN snippet_tags ON snippets.id = snippet_tags.snippet_id
                             LEFT JOIN tags ON snippet_tags.tag_id = tags.id
                             WHERE snippets.id = #{client.escape(id)}
                             GROUP BY snippets.id")
      result.first
    ensure
      client.close
    end
  end

  # スニペットを更新する
  def self.update_snippet(params)
    errors = validate_snippet(params)
    raise StandardError, errors.join(", ") unless errors.empty?

    client = create_client
    begin
      title = client.escape(params['title'])
      code = client.escape(params['code'])
      description = client.escape(params['description'])
      id = client.escape(params['id'])

      # スニペットを更新
      client.query("UPDATE snippets SET title = '#{title}', content = '#{code}', description = '#{description}' WHERE id = #{id}")

      # タグの更新
      tags = params['tags'].split(/\s+/).map { |tag| client.escape(tag) }
      client.query("DELETE FROM snippet_tags WHERE snippet_id = #{id}") # 古いタグを削除
      tags.each do |tag|
        tag_result = client.query("SELECT id FROM tags WHERE name = '#{tag}' LIMIT 1")
        tag_id = tag_result.first ? tag_result.first['id'] : nil

        unless tag_id
          client.query("INSERT INTO tags (name) VALUES ('#{tag}')")
          tag_id = client.last_id
        end

        client.query("INSERT INTO snippet_tags (snippet_id, tag_id) VALUES (#{id}, #{tag_id})")
      end
    ensure
      client.close
    end
  end
end
