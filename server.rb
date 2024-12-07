# frozen_string_literal: true

require 'webrick'
require 'mysql2'
require "erb"

# ダミーのデータベース
SNIPPETS = {
  1 => 'This is the first snippet content.',
  2 => 'This is the second snippet content.',
  3 => 'This is another example of a snippet.'
}

# webコンテナ内で設定した環境変数を読み込みruby内で使用できるように変数に代入
# GitHub Actionsの動作確認2回目
DB_HOST = ENV['DATABASE_HOST']
DB_USER = ENV['DATABASE_USER']
DB_PASSWORD = ENV['DATABASE_PASSWORD']
DB_NAME = ENV['DATABASE_NAME']

server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: './views')

# 詳細ページ用の動的ルーティング
server.mount_proc "/snippets" do |req, res|
  # URLからスニペットIDを取得(Ex. 「/snippets/1」にアクセスすると、「1」を取得)
  id = req.path.split("/").last.to_i # パスから「/」で分割した配列を作り、配列の最後の要素を整数に変換

  # ERBテンプレートの読み込み(読み込みには"erb"gemが必須)
  template = ERB.new(File.read("views/snippet_detail.html.erb"))

  # データをテンプレートに渡してHTMLを生成
  content = SNIPPETS[id]
  # binding()を使ってテンプレートに変数を渡す
  res.body = template.result_with_hash(id: id, content: content)
end

server.start
