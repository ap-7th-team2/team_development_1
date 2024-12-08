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
      # 入力データを取得してエスケープ処理
      title = client.escape(params['title'])
      code = client.escape(params['code'])
      description = client.escape(params['description'])
      tags = params['tags'].split(/\s+/).map { |tag| client.escape(tag) }

      # snippetsテーブルにデータを保存
      client.query("INSERT INTO snippets (title, content, description) VALUES ('#{title}', '#{code}', '#{description}')")
      snippet_id = client.last_id

      # tagsテーブルとsnippet_tagsテーブルにデータを保存
      tags.each do |tag|
        tag_result = client.query("SELECT id FROM tags WHERE name = '#{tag}' LIMIT 1")
        tag_id = tag_result.first ? tag_result.first['id'] : nil

        unless tag_id
          client.query("INSERT INTO tags (name) VALUES ('#{tag}')")
          tag_id = client.last_id
        end

        client.query("INSERT INTO snippet_tags (snippet_id, tag_id) VALUES (#{snippet_id}, #{tag_id})")
      end
    ensure
      client.close
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
