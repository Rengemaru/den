require 'gosu'
require 'singleton'
require 'erb'
require 'socket'

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


# Contentクラスを定義

class Content

    include Singleton

    attr_accessor :input_text, :input_color, :input_color_code, :input_font_size, :input_count, :font_size, :font1, :font2, :ip_index, :ip_message
    attr_reader :input_length, :font_ratio, :font_y_offset, :x, :y, :speed, :my_ip, :my_ip_address, :ip_index, :ip_message
    
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
        @x = -600
        @y = 300
        @speed = -2
        @my_ip = my_address.chomp
        @my_ip_address = "http://#{my_address}:8000/"
        puts "URL: #{@my_ip_address}"
    end


def my_address
    udp = UDPSocket.new
    # クラスBの先頭アドレス,echoポート 実際にはパケットは送信されない。
    udp.connect("128.0.0.0", 7)
    adrs = Socket.unpack_sockaddr_in(udp.getsockname)[1]
    udp.close
    adrs
end

    def set_text(text)
        @input_text = text
        puts "input_text: #{@input_text}"
        @input_count = @input_text.length / 3
        puts "input_count: #{@input_count}"
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
                    when "2" then -5
                    when "3" then -8
                    else -2
                end
    end

    def recalculate_layout
        @font_ratio = @font_size * 0.68
        puts "font_ratio: #{@font_ratio}"
        @font_y_offset = @font_size * 0.45
        @input_length = @input_count * @font_ratio
        puts "input_length: #{@input_length}"
        @font1 = Gosu::Font.new(@font_size, name: "fonts/NotoSansJP-Regular.ttf")
        @font2 = Gosu::Font.new(@font_size, name: "fonts/NotoSansJP-Regular.ttf")
    end

    def update
        @x += @speed
        @x = -@input_length + 500 if @x < -(@input_length + (@input_length - 500) + 400)
    end

    def draw
        @font1.draw_text(@input_text, @x, @y - @font_y_offset, 2, 1.0, 1.0, @input_color_code)
        @font2.draw_text(@input_text, @x + @input_length + 400, @y - @font_y_offset, 2, 1.0, 1.0, @input_color_code)
    end
end

class Window < Gosu::Window
    def initialize
        super 800, 600
        self.caption = "部室電光掲示板"
        @content = Content.instance
    end

    def update
        @content.update
        exit if Gosu.button_down?(Gosu::KB_ESCAPE)
    end

    def draw
        @content.draw
    end
end

# HTTPサーバを起動
Server.new.run
window = Window.new
window.show