module Route.Schedule exposing (ActionData, Data, Model, Msg, overrideTalkId, route)

import BackendTask exposing (BackendTask)
import BackendTask.Http
import Css exposing (..)
import Css.Extra exposing (columnGap, fr, gap, grid, gridColumn, gridRow, gridTemplateColumns, rowGap)
import Css.Media as Media exposing (only, screen, withMedia)
import Data.Schedule exposing (TimetableItem(..), Track(..), getCommonProps, timetableItemDecoder)
import Data.Schedule.TalkId exposing (calcTalkIdWithOverride)
import Dict
import Dict.Extra
import FatalError exposing (FatalError)
import Head
import Head.Seo
import Html.Styled as Html exposing (Html, a, div, h1, header, img, span, text)
import Html.Styled.Attributes as Attributes exposing (alt, css, href, rel, src)
import Iso8601
import Json.Decode as Decode
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Site
import Time exposing (Month(..), Posix)
import Time.Extra exposing (Interval(..))
import TimeZone
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    { timetable : List TimetableItem }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.Http.getJson "https://fortee.jp/2025fp-matsuri/api/timetable"
        (Decode.map Data (Decode.field "timetable" (Decode.list timetableItemDecoder)))
        |> BackendTask.onError (\_ -> BackendTask.succeed { timetable = [] })


parseIso8601 : String -> Posix
parseIso8601 isoString =
    Iso8601.toTime isoString
        |> Result.withDefault (Time.millisToPosix 0)


{-| UUIDからグリッドレイアウト用の行番号を取得する
-}
trackFromUuid : String -> { row : String }
trackFromUuid uuid =
    case uuid of
        -- 型システムを知りたい人のための型検査器作成入門
        "5699c262-e04d-4f58-a6f5-34c390f36d0d" ->
            { row = "3" }

        -- Rust世界の二つのモナド──Rust でも do 式をしてプログラムを直感的に記述する件について
        "a8cd6d02-37c5-4009-90a4-9495c3189420" ->
            { row = "5" }

        -- 関数型言語を採用し、維持し、継続する
        "76a0de1e-bf79-4c82-b50e-86caedaf1eb9" ->
            { row = "6" }

        -- 関数プログラミングに見る再帰
        "034e486c-9a1c-48d7-910a-14aa82237eaa" ->
            { row = "8" }

        -- Effectの双対、Coeffect
        "67557418-7561-47ec-8594-9d6c0926a6ab" ->
            { row = "9" }

        -- continuations: continued and to be continued
        "ea9fd8fc-4ae3-40c7-8ef5-1a8041e64606" ->
            { row = "10/12" }

        -- Scott Wlaschinさんによるセッション
        "scott" ->
            { row = "12" }

        -- SML＃ オープンコンパイラプロジェクト
        "61fb241f-cfaa-448a-892d-277e93577198" ->
            { row = "3" }

        -- Haskell でアルゴリズムを抽象化する 〜 関数型言語で競技プログラミング
        "ad0d29f8-46a2-463b-beeb-39257f9c5306" ->
            { row = "4" }

        -- ラムダ計算と抽象機械と非同期ランタイム
        "3bdbadb9-7d77-4de0-aa37-5a7a38c577c3" ->
            { row = "6" }

        -- より安全で単純な関数定義
        "75644660-9bf1-473f-8d6d-01f2202bf2f2" ->
            { row = "7" }

        -- 数理論理学からの『型システム入門』入門？
        "a6badfbb-ca70-474d-9abd-f285f24d9380" ->
            { row = "8" }

        -- Gleamという選択肢
        "e9df1f36-cf2f-4a85-aa36-4e07ae742a69" ->
            { row = "10" }

        -- Scala の関数型ライブラリを活用した型安全な業務アプリケーション開発
        "02f89c3a-672e-4294-ae31-69e02e049005" ->
            { row = "11/13" }

        -- AWS と定理証明 〜ポリシー言語 Cedar 開発の舞台裏〜
        "8bb407b5-5df3-48bb-a934-0ca6ca628c9a" ->
            { row = "13/17" }

        -- Elixir で IoT 開発、 Nerves なら簡単にできる！？
        "b952a4f0-7db5-4d67-a911-a7a5d8a840ac" ->
            { row = "3" }

        -- Hasktorchで学ぶ関数型ディープラーニング：型安全なニューラルネットワークとその実践
        "b7a97e49-8624-4eae-848a-68f70205ad2a" ->
            { row = "5" }

        -- `interact`のススメ — できるかぎり「関数的」に書きたいあなたに
        "6109f011-c590-4c89-9add-89ad12cc9631" ->
            { row = "6" }

        -- 「ElixirでIoT!!」のこれまでとこれから
        "f75e5cab-c677-44bb-a77a-2acf36083457" ->
            { row = "8" }

        -- 産業機械をElixirで制御する
        "6edaa6b5-b591-490c-855f-731a9d318192" ->
            { row = "9" }

        -- 成立するElixirの再束縛（再代入）可という選択
        "8acfb03f-19ea-476a-b6e6-0cb4b03fec1f" ->
            { row = "10" }

        -- Lean言語は新世代の純粋関数型言語になれるか？
        "73b09de0-c72e-4bbd-9089-af5c002f9506" ->
            { row = "11" }

        -- 「Haskellは純粋関数型言語だから副作用がない」っていうの、そろそろ止めにしませんか？
        "d19de11e-d9a2-4b22-866e-2f95b8ac5c95" ->
            { row = "3" }

        -- SML#コンパイラを速くする：タスク並列、末尾呼び出し、部分評価機構の開発
        "b69688cf-06a2-4070-839c-4a6ec299c39c" ->
            { row = "4" }

        -- Julia という言語について
        "4ca1dabd-dbbe-47ca-a813-bc4c9700ccc9" ->
            { row = "6" }

        -- Leanで正規表現エンジンをつくる。そして正しさを証明する
        "af94193a-4acb-4079-82a9-36bacfae3a20" ->
            { row = "7" }

        -- 型付きアクターモデルがもたらす分散シミュレーションの未来
        "82478074-a43b-4d46-87a8-0742ed790e86" ->
            { row = "8" }

        -- Scalaだったらこう書けるのに~Scalaが恋しくて~(TypeScript編、Python編)
        "2ceb7498-b203-44ee-b064-c0fbbe4a6948" ->
            { row = "10" }

        -- ClojureScript (Squint) で React フロントエンド開発 2025 年版
        "e7f30174-d4b9-40a7-9398-9f15c71009a9" ->
            { row = "11/13" }

        -- Lispは関数型言語(ではない)
        "92b697d1-206c-426a-90c9-9ff3486cce6f" ->
            { row = "13/15" }

        -- Kotlinで学ぶSealed classと代数的データ型
        "e436393d-c322-477d-b8cb-0e6ac8ce8cc6" ->
            { row = "15/17" }

        -- ドメインモデリングにおける抽象の役割、tagless-finalによるDSL構築、そして型安全な最適化
        "f3a8809b-d498-4ac2-bf42-5c32ce1595ea" ->
            { row = "3" }

        -- 関数型言語テイスティング: Haskell, Scala, Clojure, Elixirを比べて味わう関数型プログラミングの旨さ
        "f7646b8b-29b0-4ac4-8ec3-46cabaa8ef1a" ->
            { row = "5" }

        -- AIと共に進化する開発手法：形式手法と関数型プログラミングの可能性
        "56b9175d-1468-4ab0-8063-180491bb16ed" ->
            { row = "6" }

        -- Elmのパフォーマンス、実際どうなの？ベンチマークに入門してみた
        "3760ed3e-5b38-48b9-9db2-f101af1e580f" ->
            { row = "8" }

        -- 高階関数を用いたI/O方法の公開 - DIコンテナから高階関数への更改 -
        "350e2f70-0b02-4b79-b9f6-254a9d614706" ->
            { row = "9" }

        -- Excelで関数型プログラミング
        "37899705-7d88-4ca4-bd5b-f674fc372d4e" ->
            { row = "10" }

        -- XSLTで作るBrainfuck処理系 ― XSLTは関数型言語たり得るか？
        "8dcaecb5-4541-4262-a047-3e330a7bcdb8" ->
            { row = "11" }

        -- F#の設計と妥協点 - .NET上で実現する関数型パラダイム
        "a916dd5a-7342-416a-980d-84f180a8e0a2" ->
            { row = "3" }

        -- マイクロサービス内で動くAPIをF#で書いている
        "7a342a71-90d4-43f9-9c4a-ce801fc9b49a" ->
            { row = "4" }

        -- はじめて関数型言語の機能に触れるエンジニア向けの学び方/教え方
        "7cc6ecef-94c8-4add-abc0-23b500dbf498" ->
            { row = "7" }

        -- iOSアプリ開発で関数型プログラミングを実現するThe Composable Architectureの紹介
        "71fbd521-9dc5-458d-89f6-cbff8e84e3cc" ->
            { row = "8" }

        -- デコーダーパターンによる3Dジオメトリの読み込み
        "a82127a7-f84a-43c1-a3de-483e1d973a94" ->
            { row = "10" }

        -- ラムダ計算って何だっけ？関数型の神髄に迫る
        "81cea14c-255c-46ff-929d-5141c5715832" ->
            { row = "11" }

        -- Underground 型システム
        "e0274da9-d863-47fe-a945-42eb04185bb9" ->
            { row = "12" }

        -- 堅牢な認証基盤の実現: TypeScriptで代数的データ型を活用する
        "267ff4c1-8f3c-473b-8cab-e62d0d468af5" ->
            { row = "13" }

        -- CoqのProgram機構の紹介 〜型を活用した安全なプログラミング〜
        "983d1021-3636-4778-be58-149f1995e8a5" ->
            { row = "14/16" }

        -- F#で自在につくる静的ブログサイト
        "b6c70e2d-856b-47c5-9107-481883527634" ->
            { row = "16" }

        _ ->
            { row = "50" }


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Site.summaryLarge { pageTitle = "開催スケジュール" }
        |> Head.Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg ())
view app _ =
    { title = "開催スケジュール"
    , body =
        [ div
            [ css
                [ maxWidth (px 850)
                , margin2 zero auto
                , display grid
                , rowGap (px 30)
                ]
            ]
            [ h1 [] [ text "開催スケジュール" ]
            , timetable "Day 1：2025年6月14日"
                (app.data.timetable
                    |> List.filter (isItemOnDate 2025 Jun 14)
                    |> filterDuplicateTimeslots
                    |> List.filter (getCommonProps >> .title >> (/=) "Scott Wlaschinさんによるセッション")
                    |> (::)
                        (Talk
                            { type_ = "talk"
                            , uuid = "scott"
                            , title = "Scott Wlaschinさんによるセッション"
                            , track = All
                            , startsAt = parseIso8601 "2025-06-14T18:00:00+09:00"
                            , lengthMin = 50
                            }
                            { url = ""
                            , abstract = "Domain Modeling Made Functional (『関数型ドメインモデリング』)の著者として知られるScott Wlaschinさんによる招待セッション"
                            , accepted = True
                            , tags = []
                            , speaker = { name = "Scott Wlaschin", kana = "スコット", twitter = Nothing, avatarUrl = Nothing }
                            }
                        )
                    |> List.sortBy timetableItemSortKey
                )
            , timetable "Day 2：2025年6月15日"
                (app.data.timetable
                    |> List.filter (isItemOnDate 2025 Jun 15)
                    |> filterDuplicateTimeslots
                    |> List.sortBy timetableItemSortKey
                )
            ]
        ]
    }


{-| タイムテーブル項目のソートキーを計算する
トークの開始時間とトラック順に基づいてソートする
-}
timetableItemSortKey : TimetableItem -> ( Int, Int )
timetableItemSortKey item =
    let
        { track, startsAt } =
            getCommonProps item

        trackOrder =
            case track of
                All ->
                    0

                TrackA ->
                    1

                TrackB ->
                    2

                TrackC ->
                    3
    in
    ( Time.posixToMillis startsAt, trackOrder )


{-| アイテムが指定した日付かどうかを判定する関数
-}
isItemOnDate : Int -> Month -> Int -> TimetableItem -> Bool
isItemOnDate year month day item =
    let
        startsAt =
            case item of
                Talk c _ ->
                    c.startsAt

                Timeslot c ->
                    c.startsAt

        parts =
            Time.Extra.posixToParts (TimeZone.asia__tokyo ()) startsAt
    in
    parts.year == year && parts.month == month && parts.day == day


{-| 全てのTrackに共通する内容のTimeslotがある場合、重複を削除し、Track.Allに統合する
-}
filterDuplicateTimeslots : List TimetableItem -> List TimetableItem
filterDuplicateTimeslots items =
    items
        -- 同じ内容の　TimetableItem　をグループ化
        |> Dict.Extra.groupBy
            (\item ->
                let
                    c =
                        getCommonProps item
                in
                ( c.title, Time.posixToMillis c.startsAt, c.lengthMin )
            )
        |> Dict.toList
        |> List.concatMap
            -- グループ内のTimeslotが3つある場合、1つを残しTrack.Allとして扱う
            (\( _, items_ ) ->
                case ( List.length items_ >= 3, List.head items_ ) of
                    ( True, Just (Timeslot c) ) ->
                        [ Timeslot { c | track = All } ]

                    _ ->
                        items_
            )


timetable : String -> List TimetableItem -> Html msg
timetable title items =
    let
        stickyHeader =
            header
                [ css
                    [ position sticky
                    , top (px 0)
                    , zIndex (int 1)
                    , padding2 (px 10) zero
                    , display grid
                    , rowGap (px 10)
                    , backgroundColor (hex "#fff")
                    , borderBottom3 (px 1) solid (hsl 226 0.1 0.9)
                    ]
                ]
                [ div [ css [ fontSize (px 18), fontWeight bold ] ]
                    [ text title ]
                , div
                    [ css
                        [ display none
                        , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                            [ display grid
                            , gridTemplateColumns [ fr 1, fr 1, fr 1 ]
                            , columnGap (px 10)
                            ]
                        ]
                    ]
                    [ trackHeader "Track A" { bgColor = hsla 1 0.53 0.53 0.1, textColor = hex "#CE3F3D" }
                    , trackHeader "Track B" { bgColor = hsla 36 1 0.5 0.1, textColor = hex "#ff8f00" }
                    , trackHeader "Track C" { bgColor = hsla 241 0.32 0.47 0.1, textColor = hex "#5352A0" }
                    ]
                ]

        trackHeader label { bgColor, textColor } =
            div
                [ css
                    [ padding (px 5)
                    , borderRadius (px 5)
                    , textAlign center
                    , fontSize (px 14)
                    , backgroundColor bgColor
                    , color textColor
                    ]
                ]
                [ text label ]
    in
    div [ css [ display grid, rowGap (px 15) ] ]
        [ stickyHeader
        , div
            [ css
                [ displayFlex
                , flexDirection column
                , gap (px 10)
                , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                    [ display grid
                    , gridTemplateColumns [ fr 1, fr 1, fr 1 ]
                    ]
                ]
            ]
            (List.map
                (\item ->
                    let
                        talkId =
                            calcTalkIdWithOverride items overrideTalkId (getCommonProps item)
                    in
                    timetableItem talkId item
                )
                items
            )
        ]


{-| トークIDをオーバーライドする関数
特定のUUIDに対して独自のトークIDを設定する
-}
overrideTalkId : { uuid : String } -> String -> String
overrideTalkId { uuid } previousId =
    case uuid of
        -- はじめて関数型言語の機能に触れるエンジニア向けの学び方/教え方
        "7cc6ecef-94c8-4add-abc0-23b500dbf498" ->
            "C-204"

        -- iOSアプリ開発で関数型プログラミングを実現するThe Composable Architectureの紹介
        "71fbd521-9dc5-458d-89f6-cbff8e84e3cc" ->
            "C-205"

        -- デコーダーパターンによる3Dジオメトリの読み込み
        "a82127a7-f84a-43c1-a3de-483e1d973a94" ->
            "C-206"

        -- ラムダ計算って何だっけ？関数型の神髄に迫る
        "81cea14c-255c-46ff-929d-5141c5715832" ->
            "C-207"

        -- Underground 型システム
        "e0274da9-d863-47fe-a945-42eb04185bb9" ->
            "C-208"

        -- 堅牢な認証基盤の実現: TypeScriptで代数的データ型を活用する
        "267ff4c1-8f3c-473b-8cab-e62d0d468af5" ->
            "C-209"

        -- CoqのProgram機構の紹介 〜型を活用した安全なプログラミング〜
        "983d1021-3636-4778-be58-149f1995e8a5" ->
            "C-210"

        -- F#で自在につくる静的ブログサイト
        "b6c70e2d-856b-47c5-9107-481883527634" ->
            "C-211"

        _ ->
            previousId


timetableItem : String -> TimetableItem -> Html msg
timetableItem talkId item =
    case item of
        Talk c talk ->
            let
                { row } =
                    trackFromUuid c.uuid

                filteredTags =
                    talk.tags
                        -- 重要度の低いタグを除外（TODO：必要に応じて解禁する）
                        |> List.filter (\tag -> List.all (\name -> tag.name /= name) [ "Intermediate", "Advanced" ])
                        |> (\tags ->
                                -- 招待セッションの場合はタグを追加
                                if
                                    List.any (\id -> c.uuid == id)
                                        [ "scott"
                                        , "5699c262-e04d-4f58-a6f5-34c390f36d0d"
                                        , "61fb241f-cfaa-448a-892d-277e93577198"
                                        ]
                                then
                                    { name = "招待セッション", colorText = "#ffffff", colorBackground = "#ff8f00" } :: tags

                                else
                                    tags
                           )
                        |> List.map (\tag -> { name = tag.name, colorBackground = hex "#f1f2f4", colorText = hex "#454854" })

                { bgColor, textColor } =
                    trackColorConfig c.track

                wrapper =
                    if talk.url == "" then
                        div
                            [ css wrapperStyles ]

                    else
                        a
                            [ href talk.url
                            , Attributes.target "_blank"
                            , rel "noopener noreferrer"
                            , css (wrapperStyles ++ [ hover [ borderColor (hsl 20 0.8 0.6) ] ])
                            ]

                wrapperStyles =
                    [ gridColumn (columnFromTrack c.track)
                    , gridRow row
                    , padding (px 10)
                    , display grid
                    , property "grid-template-rows" "auto auto auto 1fr"
                    , alignItems start
                    , rowGap (px 5)
                    , borderRadius (px 10)
                    , fontSize (px 14)
                    , textDecoration none
                    , border3 (px 1.5) solid (hsl 226 0.1 0.9)
                    , color inherit
                    ]
            in
            wrapper
                [ header [ css [ displayFlex, gap (px 5), alignItems center ] ]
                    [ viewTag { name = talkId, colorText = textColor, colorBackground = bgColor }
                    , div []
                        [ span [ css [ fontWeight bold ] ] [ text (formatTimeRange c.startsAt c.lengthMin) ]
                        , span [ css [ fontSize (px 12) ] ] [ text ("（" ++ String.fromInt c.lengthMin ++ "min）") ]
                        ]
                    ]
                , div [] [ text c.title ]
                , div
                    [ css
                        [ displayFlex
                        , alignItems center
                        , columnGap (px 5)
                        , property "color" "#454854"
                        ]
                    ]
                    [ case talk.speaker.avatarUrl of
                        Just avatarUrl ->
                            img
                                [ src avatarUrl
                                , alt talk.speaker.name
                                , css
                                    [ width (px 20)
                                    , height (px 20)
                                    , borderRadius (pct 50)
                                    , border3 (px 1) solid (hsla 0 0 0 0.05)
                                    ]
                                ]
                                []

                        Nothing ->
                            text ""
                    , div [] [ text talk.speaker.name ]
                    ]
                , div [ css [ displayFlex, flexWrap wrap, gap (px 4) ] ]
                    (List.map viewTag filteredTags)
                ]

        Timeslot c ->
            div
                [ css
                    [ gridColumn (columnFromTrack c.track)
                    , padding (px 10)
                    , display grid
                    , property "grid-template-columns" "auto 1fr"
                    , alignItems center
                    , columnGap (px 10)
                    , borderRadius (px 10)
                    , fontSize (px 14)
                    , backgroundColor (hsl 226 0.1 0.92)
                    ]
                ]
                [ div [ css [ fontWeight bold ] ] [ text (formatTimeRange c.startsAt c.lengthMin) ]
                , text c.title
                ]


{-| トラックからグリッドの列指定を取得する
-}
columnFromTrack : Track -> String
columnFromTrack track =
    case track of
        All ->
            "1/-1"

        TrackA ->
            "1"

        TrackB ->
            "2"

        TrackC ->
            "3"


viewTag : { name : String, colorText : Css.Color, colorBackground : Css.Color } -> Html msg
viewTag tag =
    div
        [ css
            [ display inlineBlock
            , padding2 (px 2) (px 6)
            , borderRadius (px 4)
            , whiteSpace noWrap
            , fontSize (px 12)
            , backgroundColor tag.colorBackground
            , color tag.colorText
            ]
        ]
        [ text tag.name ]


{-| 開始時刻と長さから時間範囲を「HH:MM-HH:MM」形式でフォーマットする
-}
formatTimeRange : Posix -> Int -> String
formatTimeRange startPosix lengthMin =
    let
        jst =
            TimeZone.asia__tokyo ()

        endPosix =
            Time.Extra.add Minute lengthMin jst startPosix

        formatTime posix =
            let
                hour =
                    Time.toHour jst posix
                        |> String.fromInt
                        |> String.padLeft 2 '0'

                minute =
                    Time.toMinute jst posix
                        |> String.fromInt
                        |> String.padLeft 2 '0'
            in
            hour ++ ":" ++ minute
    in
    formatTime startPosix ++ "-" ++ formatTime endPosix


{-| トラックに応じた色設定を取得する
-}
trackColorConfig : Track -> { bgColor : Css.Color, textColor : Css.Color }
trackColorConfig track =
    case track of
        All ->
            { bgColor = hex "#CE3F3D", textColor = hex "#FFFFFF" }

        TrackA ->
            { bgColor = hex "#CE3F3D", textColor = hex "#FFFFFF" }

        TrackB ->
            { bgColor = hex "#ff8f00", textColor = hex "#FFFFFF" }

        TrackC ->
            { bgColor = hex "#5352A0", textColor = hex "#FFFFFF" }
