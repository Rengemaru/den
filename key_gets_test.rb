require 'gosu'

class KeyGetsTest < Gosu::Window
    def initialize
      super 800, 600
      self.caption = "Key Gets Test"
      @font = Gosu::Font.new(50, name: "fonts/NotoSansJP-Regular.ttf")
      
      # フォントを事前に作成（重要な改善点）
      @small_font = Gosu::Font.new(20, name: "fonts/NotoSansJP-Regular.ttf")
      @medium_font = Gosu::Font.new(28, name: "fonts/NotoSansJP-Regular.ttf")
      
      @input_text = "aaaaaaa"
      @x = 0
      @y = 300
      @speed = -2
      @display = 0 # 0:表示する, 1:表示しない
      
      # フォーム関連
      @form_mode = false
      @current_field = 0
      @text_input = Gosu::TextInput.new
      @form_data = {
        text: "",
        color_index: 0,
        size_index: 1,
        speed_index: 1
      }
      
      # 色と大きさと速度の設定
      @colors = [Gosu::Color::WHITE, Gosu::Color::RED, Gosu::Color::GREEN, 
                 Gosu::Color::BLUE, Gosu::Color::YELLOW, Gosu::Color::CYAN]
      @color_names = ["白", "赤", "緑", "青", "黄", "シアン"]
      @current_color_index = 0
      
      @font_sizes = [30, 50, 70, 90]
      @size_names = ["小", "中", "大", "特大"]
      @current_size_index = 1
      
      @speeds = [-1, -2, -4, -6]
      @speed_names = ["とても遅い", "遅い", "普通", "速い"]
      @current_speed_index = 1
      
      @field_names = ["文字", "色", "サイズ", "速度"]
      
      # フォームの各フィールドの位置
      @field_positions = [
        { x: 150, y: 150, width: 400, height: 40 },
        { x: 150, y: 220, width: 400, height: 40 },
        { x: 150, y: 290, width: 400, height: 40 },
        { x: 150, y: 360, width: 400, height: 40 }
      ]
      
      # 最後に更新されたフレーム数を記録（描画最適化用）
      @last_update_frame = 0
      @frame_count = 0
      
      update_font
    end

    def update_font
      @font = Gosu::Font.new(@font_sizes[@current_size_index], name: "fonts/NotoSansJP-Regular.ttf")
    end

    def update
      @frame_count += 1
      
      # メインテキストのスクロール（フォーム表示中は停止）
      unless @form_mode
        @x += @speed
        text_width = @input_text.length * (@font_sizes[@current_size_index] * 0.6)
        @x = 800 if @x < -text_width
      end
    end

    def button_down(id)
      if @form_mode
        handle_form_input(id)
      else
        if id == Gosu::KB_RETURN  # 通常時にエンターキーが押された
          start_form_mode
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
      @form_data[:text] = @input_text
      @form_data[:color_index] = @current_color_index
      @form_data[:size_index] = @current_size_index
      @form_data[:speed_index] = @current_speed_index
      
      select_field(0)
    end

    def handle_form_input(id)
      case id
      when Gosu::KB_TAB
        # Tabキーで次のフィールドに移動
        next_field
      when Gosu::KB_ESCAPE
        cancel_form
      when Gosu::KB_RETURN
        if @current_field == 0
          # 文字入力フィールドでEnter
          @form_data[:text] = @text_input.text unless @text_input.text.empty?
          next_field
        else
          # 他のフィールドでEnter（適用ボタンがフォーカスされている場合）
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
        @form_data[:color_index] = (@form_data[:color_index] - 1) % @colors.length
      when Gosu::KB_RIGHT
        @form_data[:color_index] = (@form_data[:color_index] + 1) % @colors.length
      end
    end

    def handle_size_input(id)
      case id
      when Gosu::KB_LEFT
        @form_data[:size_index] = (@form_data[:size_index] - 1) % @font_sizes.length
      when Gosu::KB_RIGHT
        @form_data[:size_index] = (@form_data[:size_index] + 1) % @font_sizes.length
      end
    end

    def handle_speed_input(id)
      case id
      when Gosu::KB_LEFT
        @form_data[:speed_index] = (@form_data[:speed_index] - 1) % @speeds.length
      when Gosu::KB_RIGHT
        @form_data[:speed_index] = (@form_data[:speed_index] + 1) % @speeds.length
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
      @input_text = @form_data[:text]
      @current_color_index = @form_data[:color_index]
      @current_size_index = @form_data[:size_index]
      @current_speed_index = @form_data[:speed_index]
      @speed = @speeds[@current_speed_index]
      
      update_font
      @x = 0  # 位置をリセット
      @form_mode = false
    end

    def cancel_form
      @form_mode = false
      self.text_input = nil
    end

    def draw
      # フォーム表示中はメインテキストを描画しない（パフォーマンス改善）
      unless @form_mode
        current_color = @colors[@current_color_index]
        @font.draw_text(@input_text, @x, @y, 2, 1.0, 1.0, current_color)
        draw_normal_mode
      else
        draw_form
      end
    end

    def draw_form
      # 事前に作成したフォントを使用（重要な改善点）
      
      # フォームの背景
      Gosu.draw_rect(50, 50, 700, 500, Gosu::Color.new(200, 0, 0, 0), 3)
      Gosu.draw_rect(55, 55, 690, 490, Gosu::Color.new(180, 30, 30, 30), 4)
      
      # フォームタイトル
      @medium_font.draw_text("設定変更フォーム", 70, 70, 5, 1.0, 1.0, Gosu::Color::WHITE)
      
      # 各フィールドの描画
      draw_field(0, "文字:", @form_data[:text])
      draw_field(1, "色:", @color_names[@form_data[:color_index]])
      draw_field(2, "サイズ:", @size_names[@form_data[:size_index]])
      draw_field(3, "速度:", @speed_names[@form_data[:speed_index]])
      
      # 適用ボタン
      button_y = 430
      button_color = (@current_field == 4) ? Gosu::Color::YELLOW : Gosu::Color::GREEN
      Gosu.draw_rect(300, button_y, 100, 40, button_color, 5)
      @small_font.draw_text("適用", 330, button_y + 10, 6, 1.0, 1.0, Gosu::Color::BLACK)
      
      # キャンセルボタン
      Gosu.draw_rect(420, button_y, 100, 40, Gosu::Color::RED, 5)
      @small_font.draw_text("キャンセル", 440, button_y + 10, 6, 1.0, 1.0, Gosu::Color::WHITE)
      
      # 操作説明
      @small_font.draw_text("Tab: 次の項目  Enter: 確定  ESC: キャンセル", 70, 480, 5, 1.0, 1.0, Gosu::Color::CYAN)
      @small_font.draw_text("←→: 値変更  クリック: 項目選択", 70, 500, 5, 1.0, 1.0, Gosu::Color::CYAN)
    end

    def draw_field(index, label, value)
      pos = @field_positions[index]
      
      # ラベル
      @small_font.draw_text(label, 70, pos[:y] + 10, 5, 1.0, 1.0, Gosu::Color::WHITE)
      
      # フィールドの枠
      field_color = (@current_field == index) ? Gosu::Color::YELLOW : Gosu::Color::GRAY
      Gosu.draw_rect(pos[:x], pos[:y], pos[:width], pos[:height], field_color, 5)
      Gosu.draw_rect(pos[:x] + 2, pos[:y] + 2, pos[:width] - 4, pos[:height] - 4, Gosu::Color::BLACK, 6)
      
      # 値の表示
      display_value = value
      if index == 0 && @current_field == 0 && self.text_input
        display_value = @text_input.text + "_"
      end
      
      @small_font.draw_text(display_value, pos[:x] + 10, pos[:y] + 10, 7, 1.0, 1.0, Gosu::Color::WHITE)
      
      # 選択項目には矢印表示
      if index > 0 && @current_field == index
        @small_font.draw_text("←→", pos[:x] + pos[:width] - 40, pos[:y] + 10, 7, 1.0, 1.0, Gosu::Color::CYAN)
      end
    end

    def draw_normal_mode
      # 操作説明
      @small_font.draw_text("Enter: 設定変更フォームを開く", 10, 10, 3, 1.0, 1.0, Gosu::Color::GREEN)
      
      # 現在の設定表示（必要に応じてコメントアウト解除）
      # current_color = @colors[@current_color_index]
      # @small_font.draw_text("現在の色: #{@color_names[@current_color_index]}", 10, 100, 3, 1.0, 1.0, current_color)
      # @small_font.draw_text("現在のサイズ: #{@size_names[@current_size_index]} (#{@font_sizes[@current_size_index]}px)", 10, 125, 3, 1.0, 1.0, Gosu::Color::WHITE)
      # @small_font.draw_text("現在の速度: #{@speed_names[@current_speed_index]}", 10, 150, 3, 1.0, 1.0, Gosu::Color::WHITE)
    end
end

window = KeyGetsTest.new
window.show

# アルゴリズムの詳細解説は key_gets_test.md ファイルを参照してください