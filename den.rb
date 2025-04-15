require 'gosu'

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
Input_font_size = gets.chomp.to_i
Font_size = case Input_font_size
                when 1 then 120
                when 2 then 240
                when 3 then 360
                else 240
            end

# Contentクラスを定義

class Content
    def initialize
        font_ratio = Font_size * 0.68
        @font_y_offset = Font_size * 0.45
        @input_text = Input_text
        @input_color = Input_color
        @input_color_code = Input_color_code
        @input_length = Input_count * font_ratio
        @font = Gosu::Font.new(Font_size, name: "fonts/NotoSansJP-Regular.ttf")
        @x = -600
        @y = 300
        @speed = -2
        @input_frag = 0
    end

    def update
        # p "aaaaaaaaa"
        # @input_frag = gets.chomp.to_i if @input_frag == 0
        # if @input_frag == 1
        #     input
        # end
        @x += @speed
        @x = -@input_length + 500 if @x < -(@input_length + (@input_length - 500) + 400)
    end

    def input
        print "表示する文字を入力してください："
        @input_text = gets.chomp
        @input_count = @input_text.length
        print "色を選択してください 1:赤 2:緑 3:青 4:黄："
        @input_color = gets.chomp
        @input_color_code = case @input_color
                            when "1" then Gosu::Color::RED
                            when "2" then Gosu::Color::GREEN
                            when "3" then Gosu::Color::BLUE
                            when "4" then Gosu::Color::YELLOW
                            else Gosu::Color::WHITE
                            end
        @input_length = @input_count * 82
        @input_frag = 0
    end

    def draw
        @font.draw_text(Input_text, @x, @y - @font_y_offset, 2, 1.0, 1.0, Input_color_code)
        @font.draw_text(Input_text, @x + @input_length + 400, @y - @font_y_offset, 2, 1.0, 1.0, Input_color_code)
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