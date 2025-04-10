require 'gosu'

class Content
    def initialize(font)
        @font = font
        @x = -600
        @y = 270
        @speed = -2
    end

    def update
        @x += @speed
        @x = -600 if @x < -2000
    end

    def draw
        @font.draw(@x, @y, 2)
        @font.draw(@x + 1400, @y, 2)
    end
end

class Window < Gosu::Window
    def initialize
        super 800, 600
        self.caption = "プログラミングサークル_電光掲示板"
        @background_image = Gosu::Image.new("images/black_background.png", tileable: false)
        @image = Gosu::Image.new("images/font.png", tileable: false)
        @content = Content.new(@image)
    end

    def update
        @content.update
        exit if Gosu.button_down?(Gosu::KB_ESCAPE)
    end

    def draw
        @content.draw
        @background_image.draw(0, 0, 0)
    end
end

window = Window.new
window.show