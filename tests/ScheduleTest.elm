module ScheduleTest exposing (suite)

import Expect
import Route.Schedule exposing (trackFromUuid)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Route.Schedule"
        [ describe "trackFromUuid 関数"
            [ test "dummyItemsの全てのTalk UUIDに対して正しいrowを返すこと" <|
                \_ ->
                    Expect.all
                        [ -- Track A Day 1
                          \_ -> trackFromUuid "5699c262-e04d-4f58-a6f5-34c390f36d0d" |> Expect.equal { row = "3" } -- 型システムを知りたい人のための型検査器作成入門
                        , \_ -> trackFromUuid "a8cd6d02-37c5-4009-90a4-9495c3189420" |> Expect.equal { row = "5" } -- Rust世界の二つのモナド──Rust でも do 式をしてプログラムを直感的に記述する件について
                        , \_ -> trackFromUuid "76a0de1e-bf79-4c82-b50e-86caedaf1eb9" |> Expect.equal { row = "6" } -- 関数型言語を採用し、維持し、継続する
                        , \_ -> trackFromUuid "034e486c-9a1c-48d7-910a-14aa82237eaa" |> Expect.equal { row = "8" } -- 関数プログラミングに見る再帰
                        , \_ -> trackFromUuid "67557418-7561-47ec-8594-9d6c0926a6ab" |> Expect.equal { row = "9" } -- Effectの双対、Coeffect
                        , \_ -> trackFromUuid "ea9fd8fc-4ae3-40c7-8ef5-1a8041e64606" |> Expect.equal { row = "10/12" } -- continuations: continued and to be continued

                        -- Track A Day 2
                        , \_ -> trackFromUuid "61fb241f-cfaa-448a-892d-277e93577198" |> Expect.equal { row = "3" } -- SML＃ オープンコンパイラプロジェクト
                        , \_ -> trackFromUuid "ad0d29f8-46a2-463b-beeb-39257f9c5306" |> Expect.equal { row = "4" } -- Haskell でアルゴリズムを抽象化する 〜 関数型言語で競技プログラミング
                        , \_ -> trackFromUuid "3bdbadb9-7d77-4de0-aa37-5a7a38c577c3" |> Expect.equal { row = "6" } -- ラムダ計算と抽象機械と非同期ランタイム
                        , \_ -> trackFromUuid "75644660-9bf1-473f-8d6d-01f2202bf2f2" |> Expect.equal { row = "7" } -- より安全で単純な関数定義
                        , \_ -> trackFromUuid "a6badfbb-ca70-474d-9abd-f285f24d9380" |> Expect.equal { row = "8" } -- 数理論理学からの『型システム入門』入門？
                        , \_ -> trackFromUuid "e9df1f36-cf2f-4a85-aa36-4e07ae742a69" |> Expect.equal { row = "10" } -- Gleamという選択肢
                        , \_ -> trackFromUuid "02f89c3a-672e-4294-ae31-69e02e049005" |> Expect.equal { row = "11/13" } -- Scala の関数型ライブラリを活用した型安全な業務アプリケーション開発
                        , \_ -> trackFromUuid "8bb407b5-5df3-48bb-a934-0ca6ca628c9a" |> Expect.equal { row = "13/17" } -- AWS と定理証明 〜ポリシー言語 Cedar 開発の舞台裏〜

                        -- Track B Day 1
                        , \_ -> trackFromUuid "b952a4f0-7db5-4d67-a911-a7a5d8a840ac" |> Expect.equal { row = "3" } -- Elixir で IoT 開発、 Nerves なら簡単にできる！？
                        , \_ -> trackFromUuid "b7a97e49-8624-4eae-848a-68f70205ad2a" |> Expect.equal { row = "5" } -- Hasktorchで学ぶ関数型ディープラーニング：型安全なニューラルネットワークとその実践
                        , \_ -> trackFromUuid "6109f011-c590-4c89-9add-89ad12cc9631" |> Expect.equal { row = "6" } -- `interact`のススメ — できるかぎり「関数的」に書きたいあなたに
                        , \_ -> trackFromUuid "f75e5cab-c677-44bb-a77a-2acf36083457" |> Expect.equal { row = "8" } -- 「ElixirでIoT!!」のこれまでとこれから
                        , \_ -> trackFromUuid "6edaa6b5-b591-490c-855f-731a9d318192" |> Expect.equal { row = "9" } -- 産業機械をElixirで制御する
                        , \_ -> trackFromUuid "8acfb03f-19ea-476a-b6e6-0cb4b03fec1f" |> Expect.equal { row = "10" } -- 成立するElixirの再束縛（再代入）可という選択
                        , \_ -> trackFromUuid "73b09de0-c72e-4bbd-9089-af5c002f9506" |> Expect.equal { row = "11" } -- Lean言語は新世代の純粋関数型言語になれるか？

                        -- Track B Day 2
                        , \_ -> trackFromUuid "d19de11e-d9a2-4b22-866e-2f95b8ac5c95" |> Expect.equal { row = "3" } -- 「Haskellは純粋関数型言語だから副作用がない」っていうの、そろそろ止めにしませんか？
                        , \_ -> trackFromUuid "b69688cf-06a2-4070-839c-4a6ec299c39c" |> Expect.equal { row = "4" } -- SML#コンパイラを速くする：タスク並列、末尾呼び出し、部分評価機構の開発
                        , \_ -> trackFromUuid "4ca1dabd-dbbe-47ca-a813-bc4c9700ccc9" |> Expect.equal { row = "6" } -- Julia という言語について
                        , \_ -> trackFromUuid "af94193a-4acb-4079-82a9-36bacfae3a20" |> Expect.equal { row = "7" } -- Leanで正規表現エンジンをつくる。そして正しさを証明する
                        , \_ -> trackFromUuid "82478074-a43b-4d46-87a8-0742ed790e86" |> Expect.equal { row = "8" } -- 型付きアクターモデルがもたらす分散シミュレーションの未来
                        , \_ -> trackFromUuid "2ceb7498-b203-44ee-b064-c0fbbe4a6948" |> Expect.equal { row = "10" } -- Scalaだったらこう書けるのに~Scalaが恋しくて~(TypeScript編、Python編)
                        , \_ -> trackFromUuid "e7f30174-d4b9-40a7-9398-9f15c71009a9" |> Expect.equal { row = "11/13" } -- ClojureScript (Squint) で React フロントエンド開発 2025 年版
                        , \_ -> trackFromUuid "92b697d1-206c-426a-90c9-9ff3486cce6f" |> Expect.equal { row = "13/15" } -- Lispは関数型言語(ではない)
                        , \_ -> trackFromUuid "e436393d-c322-477d-b8cb-0e6ac8ce8cc6" |> Expect.equal { row = "15/17" } -- Kotlinで学ぶSealed classと代数的データ型

                        -- Track C Day 1
                        , \_ -> trackFromUuid "f3a8809b-d498-4ac2-bf42-5c32ce1595ea" |> Expect.equal { row = "3" } -- ドメインモデリングにおける抽象の役割、tagless-finalによるDSL構築、そして型安全な最適化
                        , \_ -> trackFromUuid "f7646b8b-29b0-4ac4-8ec3-46cabaa8ef1a" |> Expect.equal { row = "5" } -- 関数型言語テイスティング: Haskell, Scala, Clojure, Elixirを比べて味わう関数型プログラミングの旨さ
                        , \_ -> trackFromUuid "56b9175d-1468-4ab0-8063-180491bb16ed" |> Expect.equal { row = "6" } -- AIと共に進化する開発手法：形式手法と関数型プログラミングの可能性
                        , \_ -> trackFromUuid "3760ed3e-5b38-48b9-9db2-f101af1e580f" |> Expect.equal { row = "8" } -- Elmのパフォーマンス、実際どうなの？ベンチマークに入門してみた
                        , \_ -> trackFromUuid "350e2f70-0b02-4b79-b9f6-254a9d614706" |> Expect.equal { row = "9" } -- 高階関数を用いたI/O方法の公開 - DIコンテナから高階関数への更改 -
                        , \_ -> trackFromUuid "37899705-7d88-4ca4-bd5b-f674fc372d4e" |> Expect.equal { row = "10" } -- Excelで関数型プログラミング
                        , \_ -> trackFromUuid "8dcaecb5-4541-4262-a047-3e330a7bcdb8" |> Expect.equal { row = "11" } -- XSLTで作るBrainfuck処理系 ― XSLTは関数型言語たり得るか？

                        -- Track C Day 2
                        , \_ -> trackFromUuid "a916dd5a-7342-416a-980d-84f180a8e0a2" |> Expect.equal { row = "3" } -- F#の設計と妥協点 - .NET上で実現する関数型パラダイム
                        , \_ -> trackFromUuid "7a342a71-90d4-43f9-9c4a-ce801fc9b49a" |> Expect.equal { row = "4" } -- マイクロサービス内で動くAPIをF#で書いている
                        , \_ -> trackFromUuid "7cc6ecef-94c8-4add-abc0-23b500dbf498" |> Expect.equal { row = "7" } -- はじめて関数型言語の機能に触れるエンジニア向けの学び方/教え方
                        , \_ -> trackFromUuid "71fbd521-9dc5-458d-89f6-cbff8e84e3cc" |> Expect.equal { row = "8" } -- iOSアプリ開発で関数型プログラミングを実現するThe Composable Architectureの紹介
                        , \_ -> trackFromUuid "a82127a7-f84a-43c1-a3de-483e1d973a94" |> Expect.equal { row = "10" } -- デコーダーパターンによる3Dジオメトリの読み込み
                        , \_ -> trackFromUuid "81cea14c-255c-46ff-929d-5141c5715832" |> Expect.equal { row = "11" } -- ラムダ計算って何だっけ？関数型の神髄に迫る
                        , \_ -> trackFromUuid "e0274da9-d863-47fe-a945-42eb04185bb9" |> Expect.equal { row = "12" } -- Underground 型システム
                        , \_ -> trackFromUuid "267ff4c1-8f3c-473b-8cab-e62d0d468af5" |> Expect.equal { row = "13" } -- 堅牢な認証基盤の実現: TypeScriptで代数的データ型を活用する
                        , \_ -> trackFromUuid "983d1021-3636-4778-be58-149f1995e8a5" |> Expect.equal { row = "14/16" } -- CoqのProgram機構の紹介 〜型を活用した安全なプログラミング〜
                        , \_ -> trackFromUuid "b6c70e2d-856b-47c5-9107-481883527634" |> Expect.equal { row = "16" } -- F#で自在につくる静的ブログサイト

                        -- Must not happen
                        , \_ -> trackFromUuid "unknown-uuid" |> Expect.equal { row = "50" } -- Unknown UUID (Default Case)
                        ]
                        ()
            ]
        ]
