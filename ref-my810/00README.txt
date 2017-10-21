==== README

My8 バージョン 1.0

バージョン 0.5 → バージョン 1.0 の変更点
・命令を追加した
・外部入力に従うベクトルジャンプと、停止命令のオペコードを変更した
・test/ ディレクトリの追加

アーカイブの状態では、mem の初期化内容は掛け算のデモになっています。

test/ ディレクトリ 以下の内容について

Makefile -- make を実行すると iverilog でコンパイルされた
            シミュレーション実行ファイルを作ります

test_my8.v -- テストベンチの Verilog HDL

mktest.rb -- 以下のディレクトリ中の test.txt を元に NSL の mem の
             初期化記述のコードを出力するためのスクリプト
arith/ -- 算術演算のテスト
logic/ -- 論理演算のテスト（これは test.txt を作っていません）
multiply/ -- 掛け算のデモ

==== 以下同じ

00README.txt -- このファイル
nsl_src/ -- NSL によるソースファイルが入っています
project/ -- その他プロジェクトに必要なファイルが入っています
run_nslc.rb -- NSL による合成を実行する Ruby スクリプト

run_nslc.rb の実行方法について

nslc.exe などが "C:\Program Files\NSL Core" にあることを
前提としてハードコーディングしてあります。
他の場所にある方は、スクリプトを見ればわかると思いますので、
適宜修正してから実行してください。

Ruby 1.9 以上が必要です。ActiveScriptRuby で動作確認してあります。
ActiveScriptRuby による実行方法は次の通りです。

- ActiveScriptRuby をインストール
- メニューなどから ActiveScriptRuby のコンソールを起動
- ActiveScriptRuby の Ruby コンソールの中で、このディレクトリ（この
  00README.txt があるディレクトリ）に CD コマンドで移動
- ruby run_nslc.rb のようにして実行
- logs/ の中にビルド時のメッセージをまとめた .log ファイルが、
  project/ の中に Verilog HDL による出力が作られます

run_nslc は、ソースファイルが更新されていなければビルドしないように
なっていますが、インクルードしているファイルまで含めた依存までは
認識していませんので注意してください。
