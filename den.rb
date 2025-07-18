require 'gosu'
require 'singleton'
require 'erb'
require 'socket'
require 'rqrcode'
require 'chunky_png'
require 'stringio'

require_relative 'webrick'

# Input_textに標準入力を格納
print "表示する文字を入力してください："
Input_text = gets.chomp
Input_count = Input_text.length
print "半角で色を選択してください 1:赤 2:緑 3:青 4:黄\n※ 色を選択しない場合はEnterを押してください："
Input_color = gets.chomp
Input_color_code = case Input_color
                    when "1" then Gosu::Color::RED
                    when "2" then Gosu::Color::GREEN
                    when "3" then Gosu::Color::BLUE
                    when "4" then Gosu::Color::YELLOW
                    else Gosu::Color::WHITE
                end
print "半角でフォントサイズを選択してください 1:小 2:中 3:大："
Input_font_size = gets.chomp
Font_size = case Input_font_size
                when "1" then 120
                when "2" then 240
                when "3" then 360
                else 240
            end
print "現在繋いでいるWi-FiのSSIDを入力してください："
Input_ssid = gets.chomp

# Contentクラスを定義

class Content

    include Singleton

    attr_accessor :input_text, :input_color, :input_color_code, :input_font_size, :input_count, :font_size, :font1, :font2, :input_speed
    attr_reader :input_length, :font_ratio, :font_y_offset, :x, :y, :speed
    
    def initialize
        @font_ratio = Font_size * 0.68
        @font_y_offset = Font_size * 0.45
        @input_text = Input_text
        @input_color = Input_color
        @input_color_code = Input_color_code
        @input_font_size = Input_font_size
        @input_count = Input_count
        @font_size = Font_size
        @input_length = Input_count * @font_ratio
        @font1 = Gosu::Font.new(Font_size, name: "fonts/NotoSansJP-Regular.ttf")
        @font2 = Gosu::Font.new(Font_size, name: "fonts/NotoSansJP-Regular.ttf")
        @background_image = Gosu::Image.new("images/black_backgound_color.png", tileable: true)
        @x = -600
        @y = 300
        @speed = -2
        @display = 0 # 0:表示する, 1:表示しない
        @time = 0
    end

    def set_text(text)
        @input_text = text
        @input_count = @input_text.length / 3
        recalculate_layout
        @x = -600
    end

    def set_color(color_code)
        @input_color = color_code
        @input_color_code = case @input_color
                            when "1" then Gosu::Color::RED
                            when "2" then Gosu::Color::GREEN
                            when "3" then Gosu::Color::BLUE
                            when "4" then Gosu::Color::YELLOW
                            else Gosu::Color::WHITE
                        end
    end

    def set_font_size(font_size)
        @input_font_size = font_size
        @font_size = case @input_font_size
                        when "1" then 120
                        when "2" then 240
                        when "3" then 360
                        else 240
            end
        recalculate_layout
        @x = -600
    end

    def set_speed(speed)
        @input_speed = speed
        @speed = case @input_speed
                    when "1" then -2
                    when "2" then -4
                    when "3" then -8
                    when "4" then -64
                    when "5" then -128
                    else -2
                end
    end

    def recalculate_layout
        @font_ratio = @font_size * 0.68
        @font_y_offset = @font_size * 0.45
        @input_length = @input_count * @font_ratio
        @font1 = Gosu::Font.new(@font_size, name: "fonts/NotoSansJP-Regular.ttf")
        @font2 = Gosu::Font.new(@font_size, name: "fonts/NotoSansJP-Regular.ttf")
    end

    def update
        @x += @speed
        @x = -@input_length + 500 if @x < -(@input_length + (@input_length - 500) + 400)
        @time = Time.now.strftime("%H")
        if @time.to_i >= 19 || @time.to_i <= 7
            @display = 1
            @input_text = ""
        else
            @display = 0
        end
    end

    def draw
        @font1.draw_text(@input_text, @x, @y - @font_y_offset, 2, 1.0, 1.0, @input_color_code)
        @font2.draw_text(@input_text, @x + @input_length + 400, @y - @font_y_offset, 2, 1.0, 1.0, @input_color_code)
        if @display == 1 
            @background_image.draw(-100, -100, 4, 1000.0 / @background_image.width, 1000.0 / @background_image.height)
        end
    end
end

class Qr_make
    def initialize
        @qr_size = 133 # QRコードのサイズ
        @x_qr = 800 - @qr_size
        @y_qr = 600 - @qr_size
        @my_ip = my_address.chomp
        @my_URL = "http://#{my_address}:8000/"
        puts "URL: #{@my_URL}"
        @font = Gosu::Font.new(@qr_size / 2, name: "fonts/NotoSansJP-Regular.ttf")
        # QRコード作成
        qrcode = RQRCode::QRCode.new(@my_URL)
        key_gets_frag = 0

        # QRコードをPNGに変換
        png = qrcode.as_png(
            bit_depth: 1,
            border_modules: 4,
            color_mode: ChunkyPNG::COLOR_GRAYSCALE,
            color: 'black',
            file: nil,
            fill: 'white',
            module_px_size: 5,
            resize_exactly_to: false,
            resize_gte_to: false,
            size: @qr_size
        )

        # メモリ上のIOオブジェクトに書き出して、Gosu::Imageとして読み込み
        # PNGデータをRGBA配列に変換
        rgba_data = ""
        png.height.times do |y|
            png.width.times do |x|
                color = png[x, y]
                r = ChunkyPNG::Color.r(color)
                g = ChunkyPNG::Color.g(color)
                b = ChunkyPNG::Color.b(color)
                a = ChunkyPNG::Color.a(color)
                rgba_data << [r, g, b, a].pack("C4")
            end
        end
        @qr_image = Gosu::Image.from_blob(png.width, png.height, rgba_data)
    end

    def my_address
        udp = UDPSocket.new
        # クラスBの先頭アドレス,echoポート 実際にはパケットは送信されない。
        udp.connect("128.0.0.0", 7)
        adrs = Socket.unpack_sockaddr_in(udp.getsockname)[1]
        udp.close
        adrs
    end
    
    def update
    end

    def draw
        @font.draw_text("Wi-Fiを#{Input_ssid}に繋いで\nQRコードを読み取ってください", 0, (600 - @qr_size), 2, 1.0, 1.0, Gosu::Color::WHITE)
        @qr_image.draw(@x_qr, @y_qr, 2)
    end
end
class Window < Gosu::Window
    def initialize
        super 800, 600, { fullscreen: true }
        self.caption = "部室電光掲示板"
        @content = Content.instance
        @qr_make = Qr_make.new
        
        # フォーム機能用の追加変数
        @small_font = Gosu::Font.new(20, name: "fonts/NotoSansJP-Regular.ttf")
        @medium_font = Gosu::Font.new(28, name: "fonts/NotoSansJP-Regular.ttf")
        
        @form_mode = false
        @current_field = 0
        @text_input = Gosu::TextInput.new
        @form_data = {
            text: "",
            color_index: 0,
            size_index: 1,
            speed_index: 1
        }
        
        # 設定用配列
        @color_names = ["白", "赤", "緑", "青", "黄"]
        @size_names = ["小", "中", "大"]
        @speed_names = ["とても遅い", "遅い", "普通", "速い", "とても速い"]
        
        @field_names = ["文字", "色", "サイズ", "速度"]
        
        # フォームの各フィールドの位置
        @field_positions = [
            { x: 150, y: 150, width: 400, height: 40 },
            { x: 150, y: 220, width: 400, height: 40 },
            { x: 150, y: 290, width: 400, height: 40 },
            { x: 150, y: 360, width: 400, height: 40 }
        ]
        
        @frame_count = 0
    end

    def update
        @frame_count += 1
        @content.update
        exit if Gosu.button_down?(Gosu::KB_ESCAPE) && !@form_mode
    end

    def button_down(id)
        if @form_mode
            handle_form_input(id)
        else
            if id == Gosu::KB_RETURN
                # Alt+Enterの場合は全画面切り替え、単独Enterの場合はフォーム表示
                if Gosu.button_down?(Gosu::KB_LEFT_ALT) || Gosu.button_down?(Gosu::KB_RIGHT_ALT)
                    # Alt+Enterで全画面切り替え（Gosuの標準機能）
                    # 何もしない（Gosuが自動で処理する）
                else
                    # 単独Enterでフォーム表示
                    start_form_mode
                end
            end
        end
    end

    def button_up(id)
        # マウスクリックでフィールド選択
        if @form_mode && id == Gosu::MS_LEFT
            mouse_x = self.mouse_x
            mouse_y = self.mouse_y
            
            @field_positions.each_with_index do |pos, i|
                if mouse_x >= pos[:x] && mouse_x <= pos[:x] + pos[:width] &&
                   mouse_y >= pos[:y] && mouse_y <= pos[:y] + pos[:height]
                    select_field(i)
                    break
                end
            end
        end
    end

    def select_field(field_index)
        @current_field = field_index
        
        if @current_field == 0  # 文字入力フィールド
            @text_input.text = @form_data[:text]
            self.text_input = @text_input
        else
            self.text_input = nil
        end
    end

    def start_form_mode
        @form_mode = true
        @current_field = 0
        @form_data[:text] = @content.input_text
        @form_data[:color_index] = @content.input_color.to_i - 1
        @form_data[:color_index] = 0 if @form_data[:color_index] < 0
        @form_data[:size_index] = @content.input_font_size.to_i - 1
        @form_data[:size_index] = 1 if @form_data[:size_index] < 0
        @form_data[:speed_index] = (@content.input_speed || "1").to_i - 1
        @form_data[:speed_index] = 1 if @form_data[:speed_index] < 0
        
        select_field(0)
    end

    def handle_form_input(id)
        case id
        when Gosu::KB_TAB
            next_field
        when Gosu::KB_ESCAPE
            cancel_form
        when Gosu::KB_RETURN
            if @current_field == 0
                @form_data[:text] = @text_input.text unless @text_input.text.empty?
                next_field
            else
                if @current_field == 4  # 適用ボタン
                    apply_form_data
                else
                    next_field
                end
            end
        end
        
        # 各フィールド固有の処理
        case @current_field
        when 1  # 色選択
            handle_color_input(id)
        when 2  # サイズ選択
            handle_size_input(id)
        when 3  # 速度選択
            handle_speed_input(id)
        end
    end

    def handle_color_input(id)
        case id
        when Gosu::KB_LEFT
            @form_data[:color_index] = (@form_data[:color_index] - 1) % @color_names.length
        when Gosu::KB_RIGHT
            @form_data[:color_index] = (@form_data[:color_index] + 1) % @color_names.length
        end
    end

    def handle_size_input(id)
        case id
        when Gosu::KB_LEFT
            @form_data[:size_index] = (@form_data[:size_index] - 1) % @size_names.length
        when Gosu::KB_RIGHT
            @form_data[:size_index] = (@form_data[:size_index] + 1) % @size_names.length
        end
    end

    def handle_speed_input(id)
        case id
        when Gosu::KB_LEFT
            @form_data[:speed_index] = (@form_data[:speed_index] - 1) % @speed_names.length
        when Gosu::KB_RIGHT
            @form_data[:speed_index] = (@form_data[:speed_index] + 1) % @speed_names.length
        end
    end

    def next_field
        @current_field = (@current_field + 1) % 5  # 0-4のループ（4は適用ボタン）
        
        if @current_field == 0  # 文字入力フィールド
            @text_input.text = @form_data[:text]
            self.text_input = @text_input
        else
            self.text_input = nil
        end
    end

    def apply_form_data
        @content.set_text(@form_data[:text])
        @content.set_color((@form_data[:color_index] + 1).to_s)
        @content.set_font_size((@form_data[:size_index] + 1).to_s)
        @content.set_speed((@form_data[:speed_index] + 1).to_s)
        @form_mode = false
        self.text_input = nil
    end

    def cancel_form
        @form_mode = false
        self.text_input = nil
    end

    def draw
        # メインコンテンツの描画
        unless @form_mode
            @content.draw
            @qr_make.draw
            draw_normal_mode
        else
            # フォーム表示時は背景を暗くして、フォームのみ表示
            Gosu.draw_rect(0, 0, 800, 600, Gosu::Color.new(180, 0, 0, 0), 10)
            draw_form
        end
    end

    def draw_normal_mode
        # 操作説明
        @small_font.draw_text("Enter: 設定変更フォームを開く", 10, 10, 5, 1.0, 1.0, Gosu::Color::GREEN)
        @small_font.draw_text("Alt+Enter: 全画面切り替え", 10, 30, 5, 1.0, 1.0, Gosu::Color::CYAN)
        # @small_font.draw_text("現在のframe_count: #{@frame_count}", 10, 50, 5, 1.0, 1.0, Gosu::Color::WHITE)
    end

    def draw_form
        # フォームの背景
        Gosu.draw_rect(50, 50, 700, 500, Gosu::Color.new(200, 0, 0, 0), 11)
        Gosu.draw_rect(55, 55, 690, 490, Gosu::Color.new(180, 30, 30, 30), 12)
        
        # フォームタイトル
        @medium_font.draw_text("電光掲示板設定変更フォーム", 70, 70, 15, 1.0, 1.0, Gosu::Color::WHITE)
        
        # 各フィールドの描画
        draw_field(0, "文字:", @form_data[:text])
        draw_field(1, "色:", @color_names[@form_data[:color_index]])
        draw_field(2, "サイズ:", @size_names[@form_data[:size_index]])
        draw_field(3, "速度:", @speed_names[@form_data[:speed_index]])
        
        # 適用ボタン
        button_y = 430
        button_color = (@current_field == 4) ? Gosu::Color::YELLOW : Gosu::Color::GREEN
        Gosu.draw_rect(300, button_y, 100, 40, button_color, 15)
        @small_font.draw_text("適用", 330, button_y + 10, 16, 1.0, 1.0, Gosu::Color::BLACK)
        
        # キャンセルボタン
        Gosu.draw_rect(420, button_y, 100, 40, Gosu::Color::RED, 15)
        @small_font.draw_text("キャンセル", 440, button_y + 10, 16, 1.0, 1.0, Gosu::Color::WHITE)
        
        # 操作説明
        @small_font.draw_text("Tab: 次の項目  Enter: 確定  ESC: キャンセル", 70, 480, 15, 1.0, 1.0, Gosu::Color::CYAN)
        @small_font.draw_text("←→: 値変更  クリック: 項目選択", 70, 500, 15, 1.0, 1.0, Gosu::Color::CYAN)
    end

    def draw_field(index, label, value)
        pos = @field_positions[index]
        
        # ラベル
        @small_font.draw_text(label, 70, pos[:y] + 10, 15, 1.0, 1.0, Gosu::Color::WHITE)
        
        # フィールドの枠
        field_color = (@current_field == index) ? Gosu::Color::YELLOW : Gosu::Color::GRAY
        Gosu.draw_rect(pos[:x], pos[:y], pos[:width], pos[:height], field_color, 15)
        Gosu.draw_rect(pos[:x] + 2, pos[:y] + 2, pos[:width] - 4, pos[:height] - 4, Gosu::Color::BLACK, 16)
        
        # 値の表示
        display_value = value
        if index == 0 && @current_field == 0 && self.text_input
            display_value = @text_input.text + "_"
        end
        
        @small_font.draw_text(display_value, pos[:x] + 10, pos[:y] + 10, 17, 1.0, 1.0, Gosu::Color::WHITE)
        
        # 選択項目には矢印表示
        if index > 0 && @current_field == index
            @small_font.draw_text("←→", pos[:x] + pos[:width] - 40, pos[:y] + 10, 17, 1.0, 1.0, Gosu::Color::CYAN)
        end
    end
end

# HTTPサーバを起動
Server.new.run
window = Window.new
window.show