# 関数型まつり 2025 公式サイト

2025年6月に開催を予定している『[関数型まつり]』の公式サイトです。<br>
『関数型まつり』ということで、サイトの構築には [elm-pages] を使用しています。

- [elm-pagesについて](#elm-pagesについて)
    - [elm-Elm について](#elm-について)
- [環境構築](#環境構築)

[関数型まつり]: https://2025.fp-matsuri.org/
[elm-pages]: https://elm-pages.com/


## elm-pagesについて

- 関数型言語 [Elm] 製のフレームワークです
    - v2までは、SSG（静的サイトジェネレータ）として提供されていました
    - 2023年にリリースされたv3からはハイドレーションなどにも対応しています
- 関連リンク
    - [ドキュメント](https://elm-pages.com/docs)
    - [リポジトリ](https://github.com/dillonkearns/elm-pages)

[Elm]: https://elm-lang.org/

### Elm について

- Elm は JavaScript にコンパイルできる関数型プログラミング言語です
- 関連リンク
    - [公式ガイド（日本語版）](https://guide.elm-lang.jp/)


## 開発環境

### 環境構築

実行には [Node.js] の環境が必要です。

```zsh
$ npm install
$ npm start
```

起動に成功すると、 http://localhost:1234/ でアクセスできます。

### VSCode拡張機能など

Elmの開発を快適にするために、VSCode拡張機能をインストールすることをお勧めします。

- [Elm](https://marketplace.visualstudio.com/items?itemName=elmTooling.elm-ls-vscode)
  - コード補完、エラーチェック、自動整形などの機能を提供します
  - コードの自動整形には [elm-format] が使われています
    - VSCode以外のエディタで開発する場合には、`npx elm-format app` を実行して適宜フォーマットしてください

[Node.js]: https://nodejs.org/ja
[elm-format]: https://github.com/avh4/elm-format

## サイトへの反映

- Webサイトは GitHub Pages を使ってホスティングしています
- 追加や修正があれば、mainブランチに向けてPRを出してください
- PRをmainブランチへマージすると [GitHub Actionsのワークフロー](https://github.com/fp-matsuri/2025.fp-matsuri.org/blob/main/.github/workflows/publish.yaml) が動作し、サイトへ反映されます


## サイトの管理

### スポンサーページ

- （実装予定）


## 開発

### CSSによるスタイル記述

2025年3月時点では2つの方法を併用しています。
段階的に CSS in JS への移行を進めていきますが、現時点では各自が使いやすい方法を選択して構いません。

- style.css に記述する
  - オーソドックスな方法だが、サイトのデザインが複雑化するとCSS設計などの手法で管理する必要が生じる
- CSS in JS スタイル
  - [rtfeldman/elm-css] を使用しています
  - 「ゼロランタイムCSS in JS」ではありませんが、関数型まつりの規模でパフォーマンスに困ることもないはず
  - 全てのCSSプロパティをサポートしている訳ではないので、適宜 `Css.Extra` モジュールに関数を追加していきます

[rtfeldman/elm-css]: https://package.elm-lang.org/packages/rtfeldman/elm-css/latest/


### Elm Packages

- パッケージの検索やインストールは [Elm Package] から行えます
- パッケージのインストール例:
  ```zsh
  $ npx elm install (作者のid)/(パッケージ名)
  ```
- 使用するパッケージは `elm.json` で管理されます

[Elm Package]: https://package.elm-lang.org/
