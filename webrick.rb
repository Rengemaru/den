require 'webrick'
require 'json'

# Webrick（HTTPサーバ）にマウントするサーブレットの共通クラス
class BaseServlet < WEBrick::HTTPServlet::AbstractServlet

  private

  # クエリパラメータのバリデーション
  def validate(query, keys)
    result = true
    keys.each do |key|
      result = false unless query.has_key?(key.to_s)
    end
    return result
  end

  # 捜査対象キャラクタをクエリパラメータから取得する
  def parse_target(query)
    if query.has_key?("target")
      Object.const_get(query["target"])
    else
      Content
    end
  end

  # HTTPクライアントへの成功応答を作成する
  def succeeded(response)
    response.status = 200
    response['Content-Type'] = 'text/html'
    File.open('public/succeeded.html') do |file|
      response.body = file.read
    end
  end

  # HTTPクライアントへの失敗応答を作成する
  def failed(response)
    response.status = 400
    response['Content-Type'] = 'text/html'
    File.open('public/failed.html') do |file|
      response.body = file.read
    end
  end
end

class IndexServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    content = Content.instance
    template = ERB.new(File.read("public/index.html"))
    response.status = 200
    response['Content-Type'] = 'text/html'
    response.body = template.result(binding)
  end
end


class MessageServlet < BaseServlet
  def do_GET(request, response)
    query = request.query
    target = parse_target(query)
    if validate(query, [:text, :color, :font_size])
      target.instance.set_text(query["text"].to_s)
      target.instance.set_color(query["color"].to_s)
      target.instance.set_font_size(query["font_size"].to_s)
      target.instance.set_speed(query["speed"].to_s)
      succeeded(response)
    else
      failed(response)
    end
  end
end

class StatusServlet < BaseServlet
  # GETリクエストに対する処理
  # クエリパラメータから現在の状態を取得してJSON形式で返す
  def do_GET(req, res)
    content = Content.instance
    res.status = 200
    res['Content-Type'] = 'application/json'
    res.body = {
      text: content.input_text,
      color: content.input_color,
      font_size: content.input_font_size,
      speed: content.input_speed
    }.to_json
  end
end

class StyleServlet < BaseServlet
  def do_GET(req, res)
    res.status = 200
    res['Content-Type'] = 'text/css'
    res.body = File.read(File.expand_path('./public/style.css'))
  end
end

class ScriptServlet < BaseServlet
  def do_GET(req, res)
    res.status = 200
    res['Content-Type'] = 'application/javascript'
    res.body = File.read(File.expand_path('./public/index.js'))
  end
end

# HTTPサーバクラス
class Server
  # コンストラクタ
  def initialize
    # HTTPサーバの設定情報
    @server_config = {
      Port: 8000,
      BindAddress: '0.0.0.0', # すべてのIPアドレスからアクセス可能
      DocumentRoot: File.expand_path('./public/'),
    }
    # HTTPサーバオブジェクトの生成（Webrick使用）
    @server = WEBrick::HTTPServer.new(@server_config)

    # エンドポイントのマウント
    @server.mount('/', IndexServlet)
    @server.mount('/message', MessageServlet)
    @server.mount('/status', StatusServlet)
    @server.mount('/style.css', StyleServlet)
    @server.mount('/index.js', ScriptServlet)

    # アプリケーション終了時の処理（サーバ停止）
    trap('INT') { @server.shutdown }
  end

  # サーバ起動
  def run
    # 別スレッドを立ててそこでHTTPサーバを動かす。
    # NOTE: メインウィンドウと同じスレッドで起動すると処理が進まなくなってしまうため。
    Thread.new do
      @server.start
    end
  end
end