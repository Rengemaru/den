# den.rb プログラム解説書

## プログラム概要

このプログラムは、Ruby + Gosuライブラリを使用した高機能な電光掲示板システムです。以下の機能を持ちます：

- **リアルタイム文字スクロール表示**
- **WEBサーバー統合によるHTTP API**
- **QRコード生成・表示**
- **GUI設定フォーム（リアルタイム設定変更）**
- **時間制御による表示・非表示**
- **フルスクリーンモード対応**

---

## メインアルゴリズム構造

### 1. 初期化フェーズ
```
1. 標準入力による初期設定取得
2. Gosuウィンドウ作成（フルスクリーン）
3. 各クラスのインスタンス化
4. フォント・画像リソース読み込み
5. QRコード生成
6. HTTPサーバー起動
```

### 2. メインループ
```
while ゲーム実行中 do
    1. 入力処理（キーボード・マウス）
    2. 状態更新（文字位置・時間チェック）
    3. 描画処理（文字・QR・フォーム）
    4. フレーム同期（60FPS）
end
```

### 3. クラス設計
- **Content**: 電光掲示板の表示データ管理
- **Qr_make**: QRコード生成・表示
- **SettingsForm**: GUI設定フォーム
- **Window**: メインウィンドウ・イベント処理

---

<br>

## Contentクラス詳細アルゴリズム

### 初期化アルゴリズム（initialize）

```ruby
def initialize
    # Step 1: フォント関連の計算
    @font_ratio = Font_size * 0.68        # 文字幅係数
    @font_y_offset = Font_size * 0.45      # Y軸オフセット
    
    # Step 2: 表示データの設定
    @input_text = Input_text               # 表示文字
    @input_color = Input_color             # 色番号（1-4）
    @input_color_code = 色変換処理          # Gosu::Color変換
    
    # Step 3: レイアウト計算
    @input_count = Input_text.length       # 文字数
    @input_length = @input_count * @font_ratio  # 表示幅
    
    # Step 4: Gosuリソースの作成
    @font1 = Gosu::Font.new(Font_size, name: "fonts/NotoSansJP-Regular.ttf")
    @font2 = Gosu::Font.new(Font_size, name: "fonts/NotoSansJP-Regular.ttf")
    @background_image = Gosu::Image.new("images/black_backgound_color.png", tileable: true)
    
    # Step 5: アニメーション初期値
    @x = -600                              # 初期X座標
    @y = 300                               # Y座標（固定）
    @speed = -2                            # スクロール速度
    @display = 0                           # 表示状態フラグ
end
```

### スクロール更新アルゴリズム（update）

```ruby
def update
    # Step 1: 座標更新
    @x += @speed
    
    # Step 2: 画面外判定・リセット
    reset_point = -@input_length + 500
    boundary = -(@input_length + (@input_length - 500) + 400)
    if @x < boundary then
        @x = reset_point
    end
    
    # Step 3: 時間制御（オプション）
    @time = Time.now.strftime("%H")
    # 19時〜7時は表示制御可能（現在は無効化）
end
```

### 描画アルゴリズム（draw）

```ruby
def draw
    # メインテキスト描画（2重表示でループ効果）
    @font1.draw_text(@input_text, @x, @y - @font_y_offset, 2, 1.0, 1.0, @input_color_code)
    @font2.draw_text(@input_text, @x + @input_length + 400, @y - @font_y_offset, 2, 1.0, 1.0, @input_color_code)
    
    # 背景制御（時間による表示・非表示）
    if @display == 1 then
        @background_image.draw(-100, -100, 100, scale_x, scale_y)
    end
end
```

---

## QRコード生成アルゴリズム（Qr_make）

### 初期化・生成プロセス

```ruby
def initialize
    # Step 1: QRコード設定
    @qr_size = 133
    @x_qr = 800 - @qr_size                 # 右下配置
    @y_qr = 600 - @qr_size
    
    # Step 2: ネットワーク情報取得
    @my_ip = my_address.chomp              # 自動IP取得
    @my_URL = "http://#{my_address}:8000/"
    
    # Step 3: QRコード生成
    qrcode = RQRCode::QRCode.new(@my_URL)
    png = qrcode.as_png(各種設定)
    
    # Step 4: Gosu用画像変換
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
```

### IP自動取得アルゴリズム（my_address）

```ruby
def my_address
    # UDPソケットを使用したローカルIP取得
    udp = UDPSocket.new
    udp.connect("128.0.0.0", 7)           # ダミー接続
    adrs = Socket.unpack_sockaddr_in(udp.getsockname)[1]
    udp.close
    return adrs
end
```

---

## SettingsFormクラス詳細アルゴリズム

### フォーム状態管理

```ruby
# 状態変数
@active = false                            # フォーム表示状態
@current_field = 0                         # 現在選択中のフィールド（0-4）
@text_input = Gosu::TextInput.new          # Gosuテキスト入力オブジェクト
@form_data = {                             # フォームデータ
    text: "",
    color_index: 0,
    size_index: 1,
    speed_index: 1
}

# 設定配列
@color_names = ["赤", "緑", "青", "黄", "白"]
@size_names = ["小", "中", "大"]
@speed_names = ["とても遅い", "遅い", "普通", "速い", "爆速", "神速"]
```

### キー入力処理アルゴリズム（handle_key_input）

```ruby
def handle_key_input(id, window)
    case id
    when Gosu::KB_TAB         # Tab: 次の項目
        next_field(window)
    when Gosu::KB_UP          # ↑: 前の項目
        previous_field(window)
    when Gosu::KB_DOWN        # ↓: 次の項目
        next_field(window)
    when Gosu::KB_ESCAPE      # ESC: キャンセル
        hide ; window.text_input = nil
    when Gosu::KB_RETURN      # Enter: 確定
        if @current_field == 0
            # 文字入力フィールド
            @form_data[:text] = @text_input.text
            next_field(window)
        elsif @current_field == 4
            # 適用ボタン
            apply_settings ; hide ; window.text_input = nil
        else
            next_field(window)
        end
    end
    
    # フィールド別処理
    case @current_field
    when 1: handle_color_input(id)    # 色選択（←→キー）
    when 2: handle_size_input(id)     # サイズ選択（←→キー）
    when 3: handle_speed_input(id)    # 速度選択（←→キー）
    end
end
```

### 値変更アルゴリズム（循環選択）

```ruby
# 色選択の例
def handle_color_input(id)
    case id
    when Gosu::KB_LEFT
        @form_data[:color_index] = (@form_data[:color_index] - 1) % @color_names.length
    when Gosu::KB_RIGHT
        @form_data[:color_index] = (@form_data[:color_index] + 1) % @color_names.length
    end
end

# 循環計算の仕組み
# 配列長が5の場合：
# (0 - 1) % 5 = 4  (最初から最後へ)
# (4 + 1) % 5 = 0  (最後から最初へ)
```

### マウス処理アルゴリズム（handle_mouse_click）

```ruby
def handle_mouse_click(mouse_x, mouse_y, window)
    # フィールドクリック判定
    @field_positions.each_with_index do |pos, i|
        if mouse_x >= pos[:x] && mouse_x <= pos[:x] + pos[:width] &&
           mouse_y >= pos[:y] && mouse_y <= pos[:y] + pos[:height]
            select_field(i, window)
            break
        end
    end
    
    # ボタンクリック判定
    button_y = 430
    if mouse_x.between?(300, 400) && mouse_y.between?(button_y, button_y + 40)
        apply_settings ; hide ; window.text_input = nil  # 適用ボタン
    elsif mouse_x.between?(420, 520) && mouse_y.between?(button_y, button_y + 40)
        hide ; window.text_input = nil                   # キャンセルボタン
    end
end
```

### 設定同期アルゴリズム

```ruby
# Contentから設定読み込み
def load_current_settings
    @form_data[:text] = @content.input_text || ""
    
    # インデックス変換（1-based → 0-based）
    @form_data[:color_index] = [@content.input_color.to_i - 1, 0].max
    @form_data[:size_index] = [@content.input_font_size.to_i - 1, 0].max
    @form_data[:speed_index] = [(@content.input_speed || "2").to_i - 1, 0].max
end

# Contentに設定適用
def apply_settings
    if @form_data[:text] && !@form_data[:text].empty?
        @content.set_text(@form_data[:text])
    end
    @content.set_color((@form_data[:color_index] + 1).to_s)      # 0-based → 1-based
    @content.set_font_size((@form_data[:size_index] + 1).to_s)
    @content.set_speed((@form_data[:speed_index] + 1).to_s)
end
```

---

## Windowクラス（メインループ制御）

### 入力処理分岐アルゴリズム

```ruby
def button_down(id)
    if @settings_form.active?
        # フォームアクティブ時：フォームに処理委譲
        @settings_form.handle_key_input(id, self)
    else
        # 通常時：Enter処理
        if id == Gosu::KB_RETURN
            if Gosu.button_down?(Gosu::KB_LEFT_ALT) || Gosu.button_down?(Gosu::KB_RIGHT_ALT)
                # Alt+Enter：全画面切り替え（Gosuの標準機能）
            else
                # 単独Enter：フォーム表示
                @settings_form.show
                @settings_form.select_field(0, self)
            end
        end
    end
end
```

### 描画制御アルゴリズム

```ruby
def draw
    unless @settings_form.active?
        # 通常モード：電光掲示板 + QRコード
        @content.draw
        @qr_make.draw
        draw_normal_mode
    else
        # フォームモード：背景暗化 + フォーム
        Gosu.draw_rect(0, 0, 800, 600, Gosu::Color.new(180, 0, 0, 0), 10)
        @settings_form.draw
    end
end
```

---

## Gosuライブラリ使用技術詳解

### 1. ウィンドウ管理

```ruby
# フルスクリーンウィンドウ作成
super 800, 600, { fullscreen: true }
self.caption = "部室電光掲示板"

# ウィンドウサイズ情報
width    # ウィンドウ幅
height   # ウィンドウ高さ

# マウス座標取得
self.mouse_x  # X座標
self.mouse_y  # Y座標
```

### 2. フォント処理

```ruby
# フォント作成（日本語対応）
@font = Gosu::Font.new(Font_size, name: "fonts/NotoSansJP-Regular.ttf")

# 文字描画
@font.draw_text(
    text,           # 描画文字列
    x, y,           # 描画座標
    z,              # 描画順序（Z座標）
    scale_x, scale_y, # スケール（拡大率）
    color           # 色（Gosu::Color）
)

# 使用例
@font.draw_text("テスト", 100, 50, 2, 1.0, 1.0, Gosu::Color::WHITE)
```

### 3. 色管理

```ruby
# 定義済み色
Gosu::Color::WHITE    # 白
Gosu::Color::RED      # 赤
Gosu::Color::GREEN    # 緑
Gosu::Color::BLUE     # 青
Gosu::Color::YELLOW   # 黄
Gosu::Color::CYAN     # シアン

# カスタム色（ARGB）
Gosu::Color.new(alpha, red, green, blue)
Gosu::Color.new(180, 30, 30, 30)  # 半透明グレー

# 色変換システム
case color_code
when "1" then Gosu::Color::RED
when "2" then Gosu::Color::GREEN
when "3" then Gosu::Color::BLUE
when "4" then Gosu::Color::YELLOW
else Gosu::Color::WHITE
end
```

### 4. 矩形描画

```ruby
# 塗りつぶし矩形
Gosu.draw_rect(
    x, y,           # 左上座標
    width, height,  # 幅・高さ
    color,          # 色
    z               # 描画順序
)

# フォーム背景の例
Gosu.draw_rect(50, 50, 700, 500, Gosu::Color.new(200, 0, 0, 0), 11)  # 外枠
Gosu.draw_rect(55, 55, 690, 490, Gosu::Color.new(180, 30, 30, 30), 12) # 内枠
```
<br>

### 5. 画像処理

```ruby
# 画像読み込み
@image = Gosu::Image.new("path/to/image.png", tileable: true)

# 画像描画
@image.draw(x, y, z, scale_x, scale_y)

# バイナリデータから画像作成
@image = Gosu::Image.from_blob(width, height, rgba_data)

# 画像拡大描画
scale_x = 1000.0 / @image.width
scale_y = 1000.0 / @image.height
@image.draw(-100, -100, 100, scale_x, scale_y)
```

### 6. 入力処理

```ruby
# キーボード定数
Gosu::KB_RETURN     # Enter
Gosu::KB_ESCAPE     # Escape
Gosu::KB_TAB        # Tab
Gosu::KB_LEFT       # ←
Gosu::KB_RIGHT      # →
Gosu::KB_UP         # ↑
Gosu::KB_DOWN       # ↓
Gosu::KB_LEFT_ALT   # 左Alt
Gosu::KB_RIGHT_ALT  # 右Alt

# マウス定数
Gosu::MS_LEFT       # 左クリック
Gosu::MS_RIGHT      # 右クリック
Gosu::MS_MIDDLE     # 中央クリック

# キー押下判定
Gosu.button_down?(key_id)  # 指定キーが押されているか

# イベントハンドラ
def button_down(id)   # キー・マウス押下時
def button_up(id)     # キー・マウス解放時
```

### 7. テキスト入力

```ruby
# テキスト入力オブジェクト作成
@text_input = Gosu::TextInput.new

# テキスト入力モード開始
self.text_input = @text_input

# 入力内容取得
input_text = @text_input.text

# 入力内容設定
@text_input.text = "初期文字列"

# テキスト入力モード終了
self.text_input = nil
```

### 8. 描画順序（Z座標）管理

```ruby
# 推奨Z座標体系
Z_BACKGROUND = 0-1     # 背景
Z_CONTENT = 2-5        # メインコンテンツ
Z_UI_BACKGROUND = 10-12 # UI背景
Z_UI_CONTENT = 15-17    # UI内容

# 実装例
@background_image.draw(-100, -100, 1)                           # 背景
@font.draw_text(@input_text, @x, @y, 2, 1.0, 1.0, @color)     # メインテキスト
Gosu.draw_rect(50, 50, 700, 500, @bg_color, 11)               # フォーム背景
@small_font.draw_text("ラベル", 70, 70, 15, 1.0, 1.0, @color) # フォームテキスト
```

---

## パフォーマンス最適化技術

### 1. フォント事前作成

```ruby
# ❌ 悪い例：毎フレーム作成
def draw
    font = Gosu::Font.new(20)
    font.draw_text("text", x, y, z)
end

# ✅ 良い例：初期化時に作成
def initialize
    @small_font = Gosu::Font.new(20, name: "fonts/NotoSansJP-Regular.ttf")
    @medium_font = Gosu::Font.new(28, name: "fonts/NotoSansJP-Regular.ttf")
end

def draw
    @small_font.draw_text("text", x, y, z)
end
```
<br><br>

### 2. 条件付き描画

```ruby
def draw
    unless @settings_form.active?
        # フォーム非表示時のみメインコンテンツ描画
        @content.draw
        @qr_make.draw
    else
        # フォーム表示時は背景とフォームのみ
        Gosu.draw_rect(0, 0, 800, 600, @overlay_color, 10)
        @settings_form.draw
    end
end
```

### 3. リソース管理

```ruby
# 画像の効率的な読み込み
def initialize
    @background_image = Gosu::Image.new("images/black_backgound_color.png", tileable: true)
end

# 計算結果のキャッシュ
def recalculate_layout
    @font_ratio = @font_size * 0.68
    @font_y_offset = @font_size * 0.45
    @input_length = @input_count * @font_ratio
    # フォント再作成（サイズ変更時のみ）
    @font1 = Gosu::Font.new(@font_size, name: "fonts/NotoSansJP-Regular.ttf")
end
```

---

## デバッグ・ログ出力システム

### コンソールログ出力

```ruby
# 設定変更時のデバッグ出力
puts "Content: テキストを更新 -> '#{@input_text}'"
puts "Content: 色を更新 -> #{@input_color} (#{@input_color_code})"
puts "Content: フォントサイズを更新 -> #{@font_size}px"
puts "Content: 速度を更新 -> #{@speed}"

# フォーム状態のデバッグ出力
puts "SettingsForm: 現在の設定を読み込み"
puts "  テキスト: '#{@form_data[:text]}'"
puts "  色: #{@color_names[@form_data[:color_index]]} (#{@form_data[:color_index]})"
puts "  サイズ: #{@size_names[@form_data[:size_index]]} (#{@form_data[:size_index]})"
puts "  速度: #{@speed_names[@form_data[:speed_index]]} (#{@form_data[:speed_index]})"
```

### 画面内デバッグ表示

```ruby
def draw_normal_mode
    # デバッグ情報を画面に表示
    @small_font.draw_text("現在のテキスト: '#{@content.input_text}'", 10, 60, 5, 1.0, 1.0, Gosu::Color::WHITE)
    @small_font.draw_text("文字数: #{@content.input_count}", 10, 80, 5, 1.0, 1.0, Gosu::Color::WHITE)
    @small_font.draw_text("速度: #{@content.speed}", 10, 100, 5, 1.0, 1.0, Gosu::Color::WHITE)
end
```

---

## HTTP統合・QRコード技術

### WEBrick統合

```ruby
require_relative 'webrick'  # 外部HTTPサーバー

# サーバー起動（非同期）
Server.new.run

# URL生成
@my_ip = my_address.chomp
@my_URL = "http://#{my_address}:8000/"
```

### QRCode生成技術

```ruby
require 'rqrcode'        # QRコード生成
require 'chunky_png'     # PNG画像処理

# QRコード作成
qrcode = RQRCode::QRCode.new(@my_URL)
png = qrcode.as_png(
    bit_depth: 1,
    border_modules: 4,
    color_mode: ChunkyPNG::COLOR_GRAYSCALE,
    color: 'black',
    fill: 'white',
    module_px_size: 5,
    size: @qr_size
)

# GosuImage変換
rgba_data = ""
png.height.times do |y|
    png.width.times do |x|
        color = png[x, y]
        r, g, b, a = ChunkyPNG::Color.r(color), ChunkyPNG::Color.g(color), 
                     ChunkyPNG::Color.b(color), ChunkyPNG::Color.a(color)
        rgba_data << [r, g, b, a].pack("C4")
    end
end
@qr_image = Gosu::Image.from_blob(png.width, png.height, rgba_data)
```

---

## エラーハンドリング・安全性

### nil値保護

```ruby
# 文字列のnil保護
@form_data[:text] = @content.input_text || ""
display_value = value || ""
@text_input.text = @form_data[:text] || ""

# 数値変換の安全化
color_value = @content.input_color.to_i
@form_data[:color_index] = color_value > 0 ? color_value - 1 : 0
```

### 配列境界保護

```ruby
# 循環インデックス計算（負の値も安全）
@form_data[:color_index] = (@form_data[:color_index] - 1) % @color_names.length
@form_data[:color_index] = (@form_data[:color_index] + 1) % @color_names.length

# 範囲チェック
@form_data[:size_index] = [@content.input_font_size.to_i - 1, 0].max
```

### リソース保護

```ruby
# フォント読み込み失敗時の対応
begin
    @font = Gosu::Font.new(@font_size, name: "fonts/NotoSansJP-Regular.ttf")
rescue => e
    puts "フォント読み込みエラー: #{e.message}"
    @font = Gosu::Font.new(@font_size)  # デフォルトフォント使用
end
```

---

## 拡張可能な設計パターン

### Singletonパターン（Content）

```ruby
class Content
    include Singleton
    
    def self.instance
        # スレッドセーフな単一インスタンス取得
    end
end

# 使用方法
@content = Content.instance
```

### Strategyパターン（設定管理）

```ruby
# 色設定ストラテジー
def set_color(color_code)
    @input_color_code = case @input_color
        when "1" then Gosu::Color::RED
        when "2" then Gosu::Color::GREEN
        # ... 拡張可能
    end
end

# 速度設定ストラテジー
def set_speed(speed)
    @speed = case @input_speed
        when "1" then -1
        when "2" then -2
        # ... 新しい速度を簡単に追加可能
    end
end
```

### Observer的パターン（設定同期）

```ruby
# SettingsForm → Content への変更通知
def apply_settings
    @content.set_text(@form_data[:text])      # 通知1
    @content.set_color((@form_data[:color_index] + 1).to_s)  # 通知2
    @content.set_font_size((@form_data[:size_index] + 1).to_s)  # 通知3
    @content.set_speed((@form_data[:speed_index] + 1).to_s)     # 通知4
end
```

---

## まとめ

このden.rbプログラムは以下の技術を統合した高度なRuby/Gosuアプリケーションです：

### **主要技術スタック**
- **Ruby 3.2+**: メイン言語
- **Gosu**: ゲームライブラリ（GUI・グラフィックス）
- **WEBrick**: HTTPサーバー
- **RQRCode + ChunkyPNG**: QRコード生成
- **Singleton**: デザインパターン

### **アーキテクチャ特徴**
- **60FPS リアルタイム描画**
- **イベント駆動型入力処理**
- **モーダルGUIシステム**
- **レスポンシブUI設計**
- **デバッグ機能統合**

### **実用性**
- **長期運用対応**（フレームカウンター管理）
- **エラー耐性**（nil値保護・境界チェック）
- **拡張性**（新機能追加容易）
- **保守性**（クラス分離・責任分離）

このシステムは部室や店舗での電光掲示板として実用的に活用でき、WebAPIとの連携により遠隔制御も可能な完成度の高いアプリケーションです。
