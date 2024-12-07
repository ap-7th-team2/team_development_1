require 'webrick'
require_relative 'routes/index_route'
require_relative 'routes/snippet_routes'
require_relative 'routes/index_route'

server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: './views')
server.mount('/css', WEBrick::HTTPServlet::FileHandler, './views/css')
server.mount('/js', WEBrick::HTTPServlet::FileHandler, './views/js')

# /get_snippetsエンドポイント
server.mount_proc '/get_snippets' do |req, res|
  offset = req.query['offset'].to_i || 0
  limit = req.query['limit'].to_i || 4
  tags = IndexRoute.obtain_tags
  snippets = IndexRoute.get_snippets(limit, offset)
  snippet_html = IndexRoute.generate_snippets_html(snippets)
  res.content_type = 'text/html'
  res.body = IndexRoute.generate_page_html(snippet_html, offset, limit, tags)
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

trap('INT') { server.shutdown }
server.start

# 
