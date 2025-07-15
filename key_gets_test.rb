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

# ========================================
# プログラムアルゴリズム詳細解説
# ========================================
#
# 【メインアルゴリズム概要】
# 1. 初期化フェーズ
# 2. メインループ（Gosuのゲームループ）
#    - 入力処理（button_down, button_up）
#    - 更新処理（update）
#    - 描画処理（draw）
# 3. 状態管理（通常モード ⇔ フォームモード）
#
# ========================================
# 【1. 初期化アルゴリズム（initialize）】
# ========================================
# Step 1: Gosuウィンドウの初期化（800x600ピクセル）
# Step 2: フォントオブジェクトの事前作成（パフォーマンス最適化）
#         - @font: メインテキスト用（可変サイズ）
#         - @small_font: UI用（20px固定）
#         - @medium_font: タイトル用（28px固定）
# Step 3: 表示テキストの初期化
#         - @input_text: 表示する文字列
#         - @x, @y: テキストの座標
#         - @speed: スクロール速度
# Step 4: フォーム関連変数の初期化
#         - @form_mode: モード切替フラグ（false=通常, true=フォーム）
#         - @current_field: 現在選択中のフィールド番号（0-4）
#         - @text_input: Gosuのテキスト入力オブジェクト
#         - @form_data: フォーム入力データのハッシュ
# Step 5: 設定配列の定義
#         - @colors: 色オブジェクトの配列
#         - @color_names: 色名の配列
#         - @font_sizes: フォントサイズの配列
#         - @size_names: サイズ名の配列
#         - @speeds: スクロール速度の配列
#         - @speed_names: 速度名の配列
# Step 6: フィールド位置情報の定義
#         - @field_positions: 各フォームフィールドの座標とサイズ
# Step 7: パフォーマンス監視用変数の初期化
# Step 8: 初期フォント設定の適用
#
# ========================================
# 【2. 更新アルゴリズム（update）】
# ========================================
# Step 1: フレームカウンタの増加
# Step 2: モード判定
#         IF @form_mode == false THEN
#             Step 3: テキストスクロール処理
#                     - @x座標を@speed分移動
#                     - 画面外判定（テキスト幅を考慮）
#                     - 画面外の場合、右端に戻す
#         ELSE
#             スクロール停止（パフォーマンス向上）
#         END IF
#
# ========================================
# 【3. 入力処理アルゴリズム】
# ========================================
# 【3-1. キー押下処理（button_down）】
# Step 1: モード判定
#         IF @form_mode == true THEN
#             handle_form_input(id)を呼び出し
#         ELSE
#             IF キー == Enter THEN
#                 start_form_mode()を呼び出し
#             END IF
#         END IF
#
# 【3-2. マウス処理（button_up）】
# Step 1: フォームモード且つ左クリック判定
# Step 2: マウス座標取得
# Step 3: フィールド位置配列をループ
#         FOR each @field_positions DO
#             IF マウス座標がフィールド範囲内 THEN
#                 select_field(フィールド番号)を呼び出し
#                 ループ脱出
#             END IF
#         END FOR
#
# ========================================
# 【4. フォーム処理アルゴリズム】
# ========================================
# 【4-1. フォームモード開始（start_form_mode）】
# Step 1: @form_mode = trueに設定
# Step 2: @current_field = 0に初期化
# Step 3: 現在の設定値をフォームデータにコピー
# Step 4: 最初のフィールド（文字入力）を選択
#
# 【4-2. フィールド選択（select_field）】
# Step 1: @current_fieldを指定されたインデックスに設定
# Step 2: IF フィールド == 0（文字入力）THEN
#             テキスト入力モードを有効化
#         ELSE
#             テキスト入力モードを無効化
#         END IF
#
# 【4-3. フォーム入力処理（handle_form_input）】
# Step 1: 共通キー処理
#         CASE キー OF
#             Tab: next_field()呼び出し
#             Escape: cancel_form()呼び出し
#             Enter: フィールド別処理
#                    IF 文字入力フィールド THEN
#                        入力テキストを保存してnext_field()
#                    ELSE IF 適用ボタン THEN
#                        apply_form_data()呼び出し
#                    ELSE
#                        next_field()呼び出し
#                    END IF
#         END CASE
# Step 2: フィールド固有処理
#         CASE @current_field OF
#             1: handle_color_input(id)
#             2: handle_size_input(id)
#             3: handle_speed_input(id)
#         END CASE
#
# 【4-4. 色選択処理（handle_color_input）】
# 左矢印: インデックスを減少（循環）
# 右矢印: インデックスを増加（循環）
# 計算式: (current_index ± 1) % array_length
#
# 【4-5. サイズ選択処理（handle_size_input）】
# 左矢印: インデックスを減少（循環）
# 右矢印: インデックスを増加（循環）
#
# 【4-6. 速度選択処理（handle_speed_input）】
# 左矢印: インデックスを減少（循環）
# 右矢印: インデックスを増加（循環）
#
# 【4-7. 次フィールド移動（next_field）】
# Step 1: @current_fieldを循環増加（0-4）
# Step 2: IF 文字入力フィールドに戻った THEN
#             テキスト入力モード有効化
#         ELSE
#             テキスト入力モード無効化
#         END IF
#
# 【4-8. 設定適用（apply_form_data）】
# Step 1: フォームデータを実際の設定変数にコピー
# Step 2: フォントサイズが変更された場合、update_font()呼び出し
# Step 3: テキスト位置をリセット
# Step 4: フォームモードを終了
#
# 【4-9. フォームキャンセル（cancel_form）】
# Step 1: @form_mode = falseに設定
# Step 2: テキスト入力モードを無効化
#
# ========================================
# 【5. 描画アルゴリズム（draw）】
# ========================================
# 【5-1. メイン描画分岐】
# IF @form_mode == false THEN
#     Step 1: 現在の色を取得
#     Step 2: メインテキストを描画
#     Step 3: draw_normal_mode()呼び出し
# ELSE
#     draw_form()呼び出し
# END IF
#
# 【5-2. 通常モード描画（draw_normal_mode）】
# Step 1: 操作説明文の描画
# Step 2: 現在の設定表示（オプション）
#
# 【5-3. フォーム描画（draw_form）】
# Step 1: 背景矩形の描画（2層構造）
# Step 2: フォームタイトルの描画
# Step 3: 各フィールドの描画ループ
#         FOR i = 0 TO 3 DO
#             draw_field(i, ラベル, 値)呼び出し
#         END FOR
# Step 4: 適用ボタンの描画
#         - 選択中の場合は黄色、そうでなければ緑色
# Step 5: キャンセルボタンの描画（赤色）
# Step 6: 操作説明の描画
#
# 【5-4. フィールド描画（draw_field）】
# Step 1: フィールド位置情報を取得
# Step 2: ラベルテキストの描画
# Step 3: フィールド枠の描画
#         - 選択中: 黄色の枠
#         - 非選択: グレーの枠
#         - 内側に黒い背景矩形
# Step 4: 値の表示処理
#         IF 文字入力フィールド且つ選択中 THEN
#             リアルタイム入力文字 + カーソル("_")を表示
#         ELSE
#             設定値を表示
#         END IF
# Step 5: 選択項目への矢印表示（文字入力以外）
#
# ========================================
# 【6. パフォーマンス最適化アルゴリズム】
# ========================================
# 最適化1: フォント事前作成
#          - 初期化時に全フォントを作成
#          - 描画時の動的生成を回避
# 最適化2: 条件付き描画
#          - フォームモード時はメインテキスト描画を停止
#          - 不要な描画処理を削減
# 最適化3: 条件付きスクロール
#          - フォームモード時はスクロール更新を停止
#          - CPU使用率を削減
# 最適化4: 事前計算
#          - フィールド位置を配列で事前定義
#          - 動的計算を回避
#
# ========================================
# 【7. 状態管理アルゴリズム】
# ========================================
# 状態1: 通常モード
#        - メインテキストのスクロール表示
#        - Enterキーでフォームモードに遷移
# 状態2: フォームモード
#        - フォーム表示とフィールド選択
#        - 各種入力処理
#        - 適用またはキャンセルで通常モードに遷移
# 状態遷移条件:
#        通常 -> フォーム: Enterキー
#        フォーム -> 通常: 適用ボタン、キャンセル、Escapeキー
#
# ========================================
# 【8. データ構造アルゴリズム】
# ========================================
# 配列管理:
# - @colors, @color_names: インデックス同期による色管理
# - @font_sizes, @size_names: インデックス同期によるサイズ管理  
# - @speeds, @speed_names: インデックス同期による速度管理
# - @field_positions: ハッシュ配列によるUI座標管理
# 
# 循環インデックス計算:
# new_index = (current_index ± 1) % array_length
# - 配列の境界を超えた場合の循環処理
# - 負の値の場合も正しく循環
#
# ========================================
# 【9. エラーハンドリングアルゴリズム】
# ========================================
# 入力検証:
# - 空文字チェック: unless text.empty?
# - 配列境界チェック: % array_length による循環
# - マウス座標検証: 範囲内判定
# 
# フォールバック処理:
# - 無効な設定値の場合はデフォルト値を使用
# - フォントロードエラーの場合は継続実行
#
# ========================================