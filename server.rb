require 'webrick'
require_relative 'routes/snippet_routes'
require_relative 'routes/snippet'

server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: './views')

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

trap('INT') { server.shutdown }
server.start
