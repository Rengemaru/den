require 'gosu'

# Input_textに標準入力を格納
print "表示する文字を入力してください："
Input_text = gets.chomp
Input_count = Input_text.length
print "色を選択してください 1:赤 2:緑 n3:青 4:黄："
Input_color = gets.chomp
Input_color_code = Gosu::Color::RED if Input_color == "1"
Input_color_code = Gosu::Color::GREEN if Input_color == "2"
Input_color_code = Gosu::Color::BLUE if Input_color == "3"
Input_color_code = Gosu::Color::YELLOW if Input_color == "4"

# Contentクラスを定義

class Content
    def initialize
        @input_length = Input_count * 82
        @font = Gosu::Font.new(120, name: "fonts/NotoSansJP-Regular.ttf")
        @x = -600
        @y = 270
        @speed = -2
    end

    def update
        @x += @speed
        @x = -@input_length + 500 if @x < -(@input_length + (@input_length - 500) + 400)
    end

    def draw
        @font.draw_text(Input_text, @x, @y, 2, 1.0, 1.0, Input_color_code)
        @font.draw_text(Input_text, @x + @input_length + 400, @y, 2, 1.0, 1.0, Input_color_code)
    end
end

class Window < Gosu::Window
    def initialize
        super 800, 600
        self.caption = "部室電光掲示板"
        @content = Content.new
    end

    def update
        @content.update
        exit if Gosu.button_down?(Gosu::KB_ESCAPE)
    end

    def draw
        @content.draw
    end
end

window = Window.new
window.show