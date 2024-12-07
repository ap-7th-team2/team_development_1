require 'webrick'
require_relative 'routes/submit_route'

server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: './views')

# `/submit` エンドポイントでフォームデータを処理
server.mount_proc '/submit' do |req, res|
  SubmitRoute.handle_request(req, res)
end

trap('INT') { server.shutdown }
server.start
