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


## 環境構築

- 実行には [Node.js] の環境が必要です。

```javascript
npm install
npm start
```

起動に成功すると、 http://localhost:1234/ でアクセスできます。

[Node.js]: https://nodejs.org/ja

## サイトへの反映

- Webサイトは GitHub Pages を使ってホスティングしています
- 追加や修正があれば、mainブランチに向けてPRを出してください
- PRをmainブランチへマージすると [GitHub Actionsのワークフロー](https://github.com/fp-matsuri/2025.fp-matsuri.org/blob/main/.github/workflows/publish.yaml) が動作し、サイトへ反映されます


## サイトの管理

### スポンサーページ

- （実装予定）
