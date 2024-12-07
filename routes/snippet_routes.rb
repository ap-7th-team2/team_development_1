require 'cgi'
require_relative 'snippet_form'

module SnippetRoutes
  def self.render_html(title, body_content)
    <<~HTML
      <!doctype html>
      <html lang="jp">
        <head>
          <meta charset="UTF-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>#{title}</title>
        </head>
        <body>
          #{body_content}
        </body>
      </html>
    HTML
  end

  def self.handle_error(res, error_message, status = 500)
    res.status = status
    res['Content-Type'] = 'text/html'
    res.body = render_html("エラー", "<h1>Error: #{error_message}</h1><a href='/'>トップページに戻る</a>")
  end

  def self.handle_create(req, res)
    if req.request_method == 'POST'
      begin
        params = CGI.parse(req.body)
        SnippetForm.save_snippet({
                                   'title' => params['title'][0],
                                   'code' => params['code'][0],
                                   'description' => params['description'][0],
                                   'tags' => params['tags'][0]
                                 })
        res.status = 200
        res['Content-Type'] = 'text/html'
        res.body = render_html("成功", "<h1>データが正常に保存されました！</h1><a href='/'>トップページに戻る</a>")
      rescue StandardError => e
        handle_error(res, e.message)
      end
    else
      res.status = 400
      res.body = render_html("無効なリクエスト", "<h1>Bad Request</h1>")
    end
  end

  def self.handle_edit(req, res)
    if req.request_method == 'GET'
      id = req.query['id']
      snippet = SnippetForm.get_snippet(id)

      if snippet
        html = File.read('./views/snippet_edit.html')
        html.gsub!('{%ID%}', snippet['id'].to_s)
        html.gsub!('{%TITLE%}', snippet['title'].to_s)
        html.gsub!('{%TAGS%}', snippet['tags'].to_s)
        html.gsub!('{%CODE%}', snippet['content'].to_s)
        html.gsub!('{%DESCRIPTION%}', snippet['description'].to_s)

        res.status = 200
        res['Content-Type'] = 'text/html'
        res.body = html
      else
        handle_error(res, "Snippet not found", 404)
      end
    else
      res.status = 400
      res.body = render_html("無効なリクエスト", "<h1>Bad Request</h1>")
    end
  end

  def self.handle_update(req, res)
    if req.request_method == 'POST'
      begin
        params = {}
        req.body.split('&').each do |pair|
          key, value = pair.split('=')
          params[key] = CGI.unescape(value)
        end

        SnippetForm.update_snippet(params)

        res.status = 200
        res['Content-Type'] = 'text/html'
        res.body = render_html("更新完了", "<h1>更新が完了しました！</h1><a href='/'>トップページに戻る</a>")
      rescue StandardError => e
        handle_error(res, e.message)
      end
    else
      res.status = 400
      res.body = render_html("無効なリクエスト", "<h1>Bad Request</h1>")
    end
  end
end
