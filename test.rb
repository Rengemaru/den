require 'gosu'

# Input_textに標準入力を格納
Input_text = gets.chomp
Input_count = Input_text.length


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
        @font.draw_text(Input_text, @x, @y, 2, 1.0, 1.0)
        @font.draw_text(Input_text, @x + @input_length + 400, @y, 2, 1.0, 1.0)
    end
end

class Window < Gosu::Window
    def initialize
        super 800, 600
        self.caption = "プログラミングサークル_電光掲示板"
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