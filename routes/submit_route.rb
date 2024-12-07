require 'cgi'
require_relative 'snippet_form'

module SubmitRoute
  def self.handle_request(req, res)
    if req.request_method == 'POST'
      begin
        # フォームデータのパース
        params = CGI.parse(req.body)
        SnippetForm.save_snippet({
                                   'title' => params['title'][0],
                                   'code' => params['code'][0],
                                   'description' => params['description'][0],
                                   'tags' => params['tags'][0]
                                 })

        # 成功時のリダイレクト
        res.status = 200
        res['Content-Type'] = 'text/html'
        res.body = <<~HTML
          <!doctype html>
          <html lang="jp">
            <head>
              <meta charset="UTF-8" />
              <meta name="viewport" content="width=device-width, initial-scale=1.0" />
              <title>成功</title>
            </head>
            <body>
              <h1>データが正常に保存されました！</h1>
              <a href="/">トップページに戻る</a>
            </body>
          </html>
        HTML
      rescue StandardError => e
        res.status = 500
        res.body = "Error: #{e.message}"
      end
    else
      res.status = 400
      res.body = "Bad Request"
    end
  end
end
