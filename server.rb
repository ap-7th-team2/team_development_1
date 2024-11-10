require 'webrick'
require 'mysql2'

DB_HOST = ENV['DATABASE_HOST']
DB_USER = ENV['DATABASE_USER']
DB_PASSWORD = ENV['DATABASE_PASSWORD']
DB_NAME = ENV['DATABASE_NAME']

# client = Mysql2::Client.new(
#   host: DB_HOST,
#   username: DB_USER,
#   password: DB_PASSWORD,
#   database: DB_NAME
# )

server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: './views')

server.start
