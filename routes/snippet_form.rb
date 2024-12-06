require 'mysql2'

module SnippetForm
  DB_HOST = ENV['DATABASE_HOST']
  DB_USER = ENV['DATABASE_USER']
  DB_PASSWORD = ENV['DATABASE_PASSWORD']
  DB_NAME = ENV['DATABASE_NAME']

  def self.save_snippet(params)
    client = Mysql2::Client.new(
      host: DB_HOST,
      username: DB_USER,
      password: DB_PASSWORD,
      database: DB_NAME
    )

    begin
      # 入力データを取得
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
end
