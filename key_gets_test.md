# プログラムアルゴリズム詳細解説

## メインアルゴリズム概要

1. 初期化フェーズ
2. メインループ（Gosuのゲームループ）
   - 入力処理（button_down, button_up）
   - 更新処理（update）
   - 描画処理（draw）
3. 状態管理（通常モード ⇔ フォームモード）

---

## 1. 初期化アルゴリズム（initialize）

### Step 1: Gosuウィンドウの初期化（800x600ピクセル）

### Step 2: フォントオブジェクトの事前作成（パフォーマンス最適化）
- `@font`: メインテキスト用（可変サイズ）
- `@small_font`: UI用（20px固定）
- `@medium_font`: タイトル用（28px固定）

### Step 3: 表示テキストの初期化
- `@input_text`: 表示する文字列
- `@x`, `@y`: テキストの座標
- `@speed`: スクロール速度

### Step 4: フォーム関連変数の初期化
- `@form_mode`: モード切替フラグ（false=通常, true=フォーム）
- `@current_field`: 現在選択中のフィールド番号（0-4）
- `@text_input`: Gosuのテキスト入力オブジェクト
- `@form_data`: フォーム入力データのハッシュ

### Step 5: 設定配列の定義
- `@colors`: 色オブジェクトの配列
- `@color_names`: 色名の配列
- `@font_sizes`: フォントサイズの配列
- `@size_names`: サイズ名の配列
- `@speeds`: スクロール速度の配列
- `@speed_names`: 速度名の配列

### Step 6: フィールド位置情報の定義
- `@field_positions`: 各フォームフィールドの座標とサイズ

### Step 7: パフォーマンス監視用変数の初期化

### Step 8: 初期フォント設定の適用

---

## 2. 更新アルゴリズム（update）

### Step 1: フレームカウンタの増加

### Step 2: モード判定
### Step 3: テキストスクロール処理
```
IF @form_mode == false THEN
            - @x座標を@speed分移動
            - 画面外判定（テキスト幅を考慮）
            - 画面外の場合、右端に戻す
ELSE
    スクロール停止（パフォーマンス向上）
END IF
```

---

## 3. 入力処理アルゴリズム

### 3-1. キー押下処理（button_down）

#### Step 1: モード判定
```
IF @form_mode == true THEN
    handle_form_input(id)を呼び出し
ELSE
    IF キー == Enter THEN
        start_form_mode()を呼び出し
    END IF
END IF
```

### 3-2. マウス処理（button_up）

#### Step 1: フォームモード且つ左クリック判定
#### Step 2: マウス座標取得
#### Step 3: フィールド位置配列をループ
```
FOR each @field_positions DO
    IF マウス座標がフィールド範囲内 THEN
        select_field(フィールド番号)を呼び出し
        ループ脱出
    END IF
END FOR
```

---

## 4. フォーム処理アルゴリズム

### 4-1. フォームモード開始（start_form_mode）

- **Step 1**: `@form_mode = true`に設定
- **Step 2**: `@current_field = 0`に初期化
- **Step 3**: 現在の設定値をフォームデータにコピー
- **Step 4**: 最初のフィールド（文字入力）を選択

### 4-2. フィールド選択（select_field）

- **Step 1**: `@current_field`を指定されたインデックスに設定
- **Step 2**: 
```
IF フィールド == 0（文字入力）THEN
    テキスト入力モードを有効化
ELSE
    テキスト入力モードを無効化
END IF
```

### 4-3. フォーム入力処理（handle_form_input）

#### Step 1: 共通キー処理
```
CASE キー OF
    Tab: next_field()呼び出し
    Escape: cancel_form()呼び出し
    Enter: フィールド別処理
           IF 文字入力フィールド THEN
               入力テキストを保存してnext_field()
           ELSE IF 適用ボタン THEN
               apply_form_data()呼び出し
           ELSE
               next_field()呼び出し
           END IF
END CASE
```

#### Step 2: フィールド固有処理
```
CASE @current_field OF
    1: handle_color_input(id)
    2: handle_size_input(id)
    3: handle_speed_input(id)
END CASE
```

### 4-4. 色選択処理（handle_color_input）

- **左矢印**: インデックスを減少（循環）
- **右矢印**: インデックスを増加（循環）
- **計算式**: `(current_index ± 1) % array_length`

### 4-5. サイズ選択処理（handle_size_input）

- **左矢印**: インデックスを減少（循環）
- **右矢印**: インデックスを増加（循環）

### 4-6. 速度選択処理（handle_speed_input）

- **左矢印**: インデックスを減少（循環）
- **右矢印**: インデックスを増加（循環）

### 4-7. 次フィールド移動（next_field）

- **Step 1**: `@current_field`を循環増加（0-4）
- **Step 2**: 
```
IF 文字入力フィールドに戻った THEN
    テキスト入力モード有効化
ELSE
    テキスト入力モード無効化
END IF
```

### 4-8. 設定適用（apply_form_data）

- **Step 1**: フォームデータを実際の設定変数にコピー
- **Step 2**: フォントサイズが変更された場合、`update_font()`呼び出し
- **Step 3**: テキスト位置をリセット
- **Step 4**: フォームモードを終了

### 4-9. フォームキャンセル（cancel_form）

- **Step 1**: `@form_mode = false`に設定
- **Step 2**: テキスト入力モードを無効化

---

## 5. 描画アルゴリズム（draw）

### 5-1. メイン描画分岐

```
IF @form_mode == false THEN
    Step 1: 現在の色を取得
    Step 2: メインテキストを描画
    Step 3: draw_normal_mode()呼び出し
ELSE
    draw_form()呼び出し
END IF
```

### 5-2. 通常モード描画（draw_normal_mode）

- **Step 1**: 操作説明文の描画
- **Step 2**: 現在の設定表示（オプション）

### 5-3. フォーム描画（draw_form）

- **Step 1**: 背景矩形の描画（2層構造）
- **Step 2**: フォームタイトルの描画
- **Step 3**: 各フィールドの描画ループ
```
FOR i = 0 TO 3 DO
    draw_field(i, ラベル, 値)呼び出し
END FOR
```
- **Step 4**: 適用ボタンの描画
  - 選択中の場合は黄色、そうでなければ緑色
- **Step 5**: キャンセルボタンの描画（赤色）
- **Step 6**: 操作説明の描画

### 5-4. フィールド描画（draw_field）

- **Step 1**: フィールド位置情報を取得
- **Step 2**: ラベルテキストの描画
- **Step 3**: フィールド枠の描画
  - 選択中: 黄色の枠
  - 非選択: グレーの枠
  - 内側に黒い背景矩形
- **Step 4**: 値の表示処理
```
IF 文字入力フィールド且つ選択中 THEN
    リアルタイム入力文字 + カーソル("_")を表示
ELSE
    設定値を表示
END IF
```
- **Step 5**: 選択項目への矢印表示（文字入力以外）

---

## 6. パフォーマンス最適化アルゴリズム

### 最適化1: フォント事前作成
- 初期化時に全フォントを作成
- 描画時の動的生成を回避

### 最適化2: 条件付き描画
- フォームモード時はメインテキスト描画を停止
- 不要な描画処理を削減

### 最適化3: 条件付きスクロール
- フォームモード時はスクロール更新を停止
- CPU使用率を削減

### 最適化4: 事前計算
- フィールド位置を配列で事前定義
- 動的計算を回避

---

## 7. 状態管理アルゴリズム

### 状態1: 通常モード
- メインテキストのスクロール表示
- Enterキーでフォームモードに遷移

### 状態2: フォームモード
- フォーム表示とフィールド選択
- 各種入力処理
- 適用またはキャンセルで通常モードに遷移

### 状態遷移条件
- **通常 → フォーム**: Enterキー
- **フォーム → 通常**: 適用ボタン、キャンセル、Escapeキー

---

## 8. データ構造アルゴリズム

### 配列管理
- `@colors`, `@color_names`: インデックス同期による色管理
- `@font_sizes`, `@size_names`: インデックス同期によるサイズ管理
- `@speeds`, `@speed_names`: インデックス同期による速度管理
- `@field_positions`: ハッシュ配列によるUI座標管理

### 循環インデックス計算
```ruby
new_index = (current_index ± 1) % array_length
```
- 配列の境界を超えた場合の循環処理
- 負の値の場合も正しく循環

---

## 9. エラーハンドリングアルゴリズム

### 入力検証
- **空文字チェック**: `unless text.empty?`
- **配列境界チェック**: `% array_length` による循環
- **マウス座標検証**: 範囲内判定

### フォールバック処理
- 無効な設定値の場合はデフォルト値を使用
- フォントロードエラーの場合は継続実行

---

## プログラムの特徴

このプログラムは以下の特徴を持つ高度なGUIアプリケーションです：

1. **リアルタイム処理**: 60FPSでのスムーズなテキストスクロール
2. **直感的UI**: マウスとキーボードの両方に対応
3. **モーダル設計**: 通常モードとフォームモードの明確な分離
4. **パフォーマンス重視**: 最適化されたレンダリング処理
5. **拡張性**: 新しいフィールドや機能を簡単に追加可能

プログラムの各部分が相互に連携し、ユーザーフレンドリーなインターフェースを提供しています。

---

## Gosuライブラリの記法・使用方法

### 基本的なクラス・メソッド

#### 1. ウィンドウクラス（Gosu::Window）
```ruby
class KeyGetsTest < Gosu::Window
  def initialize
    super 800, 600  # 幅800, 高さ600でウィンドウ作成
    self.caption = "タイトル"  # ウィンドウタイトル設定
  end
  
  def update
    # 毎フレーム呼ばれる更新処理
  end
  
  def draw
    # 毎フレーム呼ばれる描画処理
  end
  
  def button_down(id)
    # キーやマウスが押されたときの処理
  end
  
  def button_up(id)
    # キーやマウスが離されたときの処理
  end
end

window = KeyGetsTest.new
window.show  # ウィンドウ表示・ゲームループ開始
```

#### 2. フォント（Gosu::Font）
```ruby
# フォント作成
@font = Gosu::Font.new(50, name: "fonts/NotoSansJP-Regular.ttf")
@font = Gosu::Font.new(20)  # デフォルトフォント

# 文字描画
@font.draw_text("表示文字", x座標, y座標, z座標, x拡大率, y拡大率, 色)
@font.draw_text("Hello", 100, 50, 2, 1.0, 1.0, Gosu::Color::WHITE)
```

#### 3. 色（Gosu::Color）
```ruby
# 定義済み色定数
Gosu::Color::WHITE    # 白
Gosu::Color::RED      # 赤
Gosu::Color::GREEN    # 緑
Gosu::Color::BLUE     # 青
Gosu::Color::YELLOW   # 黄
Gosu::Color::CYAN     # シアン

# カスタム色作成（アルファ, 赤, 緑, 青）
custom_color = Gosu::Color.new(255, 255, 0, 255)  # マゼンタ
```

#### 4. 矩形描画（Gosu.draw_rect）
```ruby
# 矩形描画
Gosu.draw_rect(x座標, y座標, 幅, 高さ, 色, z座標)
Gosu.draw_rect(50, 50, 200, 100, Gosu::Color::RED, 3)
```

#### 5. テキスト入力（Gosu::TextInput）
```ruby
# テキスト入力オブジェクト作成
@text_input = Gosu::TextInput.new

# テキスト入力モード開始
self.text_input = @text_input

# 入力されたテキスト取得
input_text = @text_input.text

# テキスト入力モード終了
self.text_input = nil
```

#### 6. マウス座標取得
```ruby
mouse_x = self.mouse_x  # マウスのX座標
mouse_y = self.mouse_y  # マウスのY座標
```

### キーボード・マウス定数

#### キーボード定数
```ruby
Gosu::KB_RETURN    # Enterキー
Gosu::KB_ESCAPE    # Escapeキー
Gosu::KB_TAB       # Tabキー
Gosu::KB_LEFT      # 左矢印キー
Gosu::KB_RIGHT     # 右矢印キー
Gosu::KB_UP        # 上矢印キー
Gosu::KB_DOWN      # 下矢印キー
Gosu::KB_SPACE     # スペースキー
```

#### マウス定数
```ruby
Gosu::MS_LEFT      # 左マウスボタン
Gosu::MS_RIGHT     # 右マウスボタン
Gosu::MS_MIDDLE    # 中央マウスボタン（ホイール）
```

### 画像処理

#### 画像読み込み・描画
```ruby
# 画像読み込み
@image = Gosu::Image.new("path/to/image.png")
@image = Gosu::Image.new("image.png", tileable: true)  # タイル可能

# 画像描画
@image.draw(x座標, y座標, z座標)
@image.draw(100, 50, 2)

# バイナリデータから画像作成
@image = Gosu::Image.from_blob(幅, 高さ, RGBAデータ)
```

### よく使われるパターン

#### 1. ゲームループの基本構造
```ruby
def update
  # 1. 入力処理（自動で button_down/up が呼ばれる）
  # 2. ゲーム状態更新
  # 3. 当たり判定など
end

def draw
  # 1. 背景描画
  # 2. オブジェクト描画
  # 3. UI描画
end
```

#### 2. 条件分岐による状態管理
```ruby
def update
  case @game_state
  when :menu
    update_menu
  when :playing
    update_game
  when :paused
    update_pause
  end
end

def draw
  case @game_state
  when :menu
    draw_menu
  when :playing
    draw_game
  when :paused
    draw_pause
  end
end
```

#### 3. キー入力処理の典型例
```ruby
def button_down(id)
  case id
  when Gosu::KB_RETURN
    # Enterキーの処理
  when Gosu::KB_ESCAPE
    # Escapeキーの処理
  when Gosu::KB_LEFT
    # 左キーの処理
  when Gosu::KB_RIGHT
    # 右キーの処理
  end
end
```

#### 4. Z座標（描画順序）の使い方
```ruby
# 背景: 0-1
# ゲームオブジェクト: 2-5
# UI: 6-10
@font.draw_text("背景テキスト", x, y, 1)
@font.draw_text("オブジェクト", x, y, 3)
@font.draw_text("UI", x, y, 7)
```

### パフォーマンス最適化のコツ

#### 1. フォントの事前作成
```ruby
# ❌ 悪い例（毎フレーム作成）
def draw
  font = Gosu::Font.new(20)
  font.draw_text("text", x, y, z)
end

# ✅ 良い例（初期化時に作成）
def initialize
  @font = Gosu::Font.new(20)
end

def draw
  @font.draw_text("text", x, y, z)
end
```

#### 2. 条件付き描画
```ruby
# 必要な時だけ描画
def draw
  if @show_menu
    draw_menu
  end
  
  unless @paused
    draw_game_objects
  end
end
```

#### 3. 座標計算の最適化
```ruby
# ❌ 毎フレーム計算
def draw
  center_x = width / 2
  center_y = height / 2
  @font.draw_text("text", center_x, center_y, 2)
end

# ✅ 事前計算
def initialize
  @center_x = width / 2
  @center_y = height / 2
end

def draw
  @font.draw_text("text", @center_x, @center_y, 2)
end
```

### このプロジェクトでの応用例

このプログラムでは以下のGosu機能を効果的に活用しています：

1. **ウィンドウ管理**: 800x600の固定サイズウィンドウ
2. **フォント最適化**: 3種類のフォントを事前作成
3. **入力処理**: キーボードとマウスの両方に対応
4. **状態管理**: 通常モードとフォームモードの切り替え
5. **UI描画**: 矩形とテキストを組み合わせたフォーム表示
6. **テキスト入力**: リアルタイムテキスト入力機能
7. **パフォーマンス**: 条件付き描画によるFPS向上

これらの技術により、60FPSで動作するスムーズなGUIアプリケーションを実現しています。
