require 'webrick'
require 'mysql2'
require_relative 'routes/snippet'  # snippet.rb を読み込む

# webコンテナ内で設定した環境変数を読み込みruby内で使用できるように変数に代入
# GitHub Actionsの動作確認2回目
DB_HOST = ENV['DATABASE_HOST']
DB_USER = ENV['DATABASE_USER']
DB_PASSWORD = ENV['DATABASE_PASSWORD']
DB_NAME = ENV['DATABASE_NAME']

server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: './views')

server.start
