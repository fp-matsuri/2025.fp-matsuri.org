module Route.Schedule exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import BackendTask.Http
import Css exposing (..)
import Css.Extra exposing (columnGap, fr, gap, grid, gridColumn, gridRow, gridTemplateColumns, rowGap)
import Css.Media as Media exposing (only, screen, withMedia)
import Dict
import Dict.Extra
import FatalError exposing (FatalError)
import Head
import Head.Seo
import Html.Styled as Html exposing (Html, a, div, h1, header, img, span, text)
import Html.Styled.Attributes as Attributes exposing (alt, css, href, rel, src)
import Iso8601
import Json.Decode as Decode exposing (Decoder, bool, field, maybe, string)
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


type TimetableItem
    = Talk CommonProps TalkProps
    | Timeslot CommonProps


type alias CommonProps =
    { type_ : String
    , uuid : String
    , title : String
    , track : Track
    , startsAt : Posix
    , lengthMin : Int
    }


type alias TalkProps =
    { url : String
    , abstract : String
    , accepted : Bool
    , tags : List Tag
    , speaker : Speaker
    }


type alias Tag =
    { name : String
    , colorText : String
    , colorBackground : String
    }


type alias Speaker =
    { name : String
    , kana : String
    , twitter : Maybe String
    , avatarUrl : Maybe String
    }


type Track
    = All
    | TrackA
    | TrackB
    | TrackC


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


timetableItemDecoder : Decoder TimetableItem
timetableItemDecoder =
    Decode.oneOf [ talkDecoder, timeslotDecoder ]


talkDecoder : Decoder TimetableItem
talkDecoder =
    Decode.map2 Talk
        commonDecoder
        (Decode.map5 TalkProps
            (field "url" string)
            (field "abstract" string)
            (field "accepted" bool)
            (field "tags" (Decode.list tagDecoder))
            (field "speaker" speakerDecoder)
        )


timeslotDecoder : Decoder TimetableItem
timeslotDecoder =
    Decode.map Timeslot commonDecoder


commonDecoder : Decoder CommonProps
commonDecoder =
    Decode.map6 CommonProps
        (field "type" string)
        (field "uuid" string)
        (field "title" string)
        (field "track" trackDecoder)
        (field "starts_at" iso8601Decoder)
        (field "length_min" Decode.int)


tagDecoder : Decoder Tag
tagDecoder =
    Decode.map3 Tag
        (field "name" string)
        (field "color_text" string)
        (field "color_background" string)


speakerDecoder : Decoder Speaker
speakerDecoder =
    Decode.map4 Speaker
        (field "name" string)
        (field "kana" string)
        (maybe (field "twitter" string))
        (maybe (field "avatar_url" string))


trackDecoder : Decoder Track
trackDecoder =
    field "name" string
        |> Decode.andThen
            (\str ->
                case str of
                    "Track A" ->
                        Decode.succeed TrackA

                    "Track B" ->
                        Decode.succeed TrackB

                    "Track C" ->
                        Decode.succeed TrackC

                    _ ->
                        Decode.fail "Unknown track name"
            )


iso8601Decoder : Decoder Posix
iso8601Decoder =
    string
        |> Decode.andThen
            (\str ->
                case Iso8601.toTime str of
                    Ok posix ->
                        Decode.succeed posix

                    Err _ ->
                        Decode.fail "Invalid ISO8601 date format"
            )


parseIso8601 : String -> Posix
parseIso8601 isoString =
    Iso8601.toTime isoString
        |> Result.withDefault (Time.millisToPosix 0)


trackFromUuid : String -> { code : String, row : String }
trackFromUuid uuid =
    case uuid of
        -- 型システムを知りたい人のための型検査器作成入門
        "5699c262-e04d-4f58-a6f5-34c390f36d0d" ->
            { code = "A-101", row = "3" }

        -- Rust世界の二つのモナド──Rust でも do 式をしてプログラムを直感的に記述する件について
        "a8cd6d02-37c5-4009-90a4-9495c3189420" ->
            { code = "A-102", row = "5" }

        -- 関数型言語を採用し、維持し、継続する
        "76a0de1e-bf79-4c82-b50e-86caedaf1eb9" ->
            { code = "A-103", row = "6" }

        -- 関数プログラミングに見る再帰
        "034e486c-9a1c-48d7-910a-14aa82237eaa" ->
            { code = "A-104", row = "8" }

        -- Effectの双対、Coeffect
        "67557418-7561-47ec-8594-9d6c0926a6ab" ->
            { code = "A-105", row = "9" }

        -- continuations: continued and to be continued
        "ea9fd8fc-4ae3-40c7-8ef5-1a8041e64606" ->
            { code = "A-106", row = "10/12" }

        -- Scott Wlaschinさんによるセッション
        "scott" ->
            { code = "A-107", row = "12" }

        -- SML＃ オープンコンパイラプロジェクト
        "61fb241f-cfaa-448a-892d-277e93577198" ->
            { code = "A-201", row = "3" }

        -- Haskell でアルゴリズムを抽象化する 〜 関数型言語で競技プログラミング
        "ad0d29f8-46a2-463b-beeb-39257f9c5306" ->
            { code = "A-202", row = "4" }

        -- ラムダ計算と抽象機械と非同期ランタイム
        "3bdbadb9-7d77-4de0-aa37-5a7a38c577c3" ->
            { code = "A-203", row = "6" }

        -- より安全で単純な関数定義
        "75644660-9bf1-473f-8d6d-01f2202bf2f2" ->
            { code = "A-204", row = "7" }

        -- 数理論理学からの『型システム入門』入門？
        "a6badfbb-ca70-474d-9abd-f285f24d9380" ->
            { code = "A-205", row = "8" }

        -- Gleamという選択肢
        "e9df1f36-cf2f-4a85-aa36-4e07ae742a69" ->
            { code = "A-206", row = "10" }

        -- Scala の関数型ライブラリを活用した型安全な業務アプリケーション開発
        "02f89c3a-672e-4294-ae31-69e02e049005" ->
            { code = "A-207", row = "11/13" }

        -- AWS と定理証明 〜ポリシー言語 Cedar 開発の舞台裏〜
        "8bb407b5-5df3-48bb-a934-0ca6ca628c9a" ->
            { code = "A-208", row = "13/17" }

        -- Elixir で IoT 開発、 Nerves なら簡単にできる！？
        "b952a4f0-7db5-4d67-a911-a7a5d8a840ac" ->
            { code = "B-101", row = "3" }

        -- Hasktorchで学ぶ関数型ディープラーニング：型安全なニューラルネットワークとその実践
        "b7a97e49-8624-4eae-848a-68f70205ad2a" ->
            { code = "B-102", row = "5" }

        -- `interact`のススメ — できるかぎり「関数的」に書きたいあなたに
        "6109f011-c590-4c89-9add-89ad12cc9631" ->
            { code = "B-103", row = "6" }

        -- 「ElixirでIoT!!」のこれまでとこれから
        "f75e5cab-c677-44bb-a77a-2acf36083457" ->
            { code = "B-104", row = "8" }

        -- 産業機械をElixirで制御する
        "6edaa6b5-b591-490c-855f-731a9d318192" ->
            { code = "B-105", row = "9" }

        -- 成立するElixirの再束縛（再代入）可という選択
        "8acfb03f-19ea-476a-b6e6-0cb4b03fec1f" ->
            { code = "B-106", row = "10" }

        -- Lean言語は新世代の純粋関数型言語になれるか？
        "73b09de0-c72e-4bbd-9089-af5c002f9506" ->
            { code = "B-107", row = "11" }

        -- 「Haskellは純粋関数型言語だから副作用がない」っていうの、そろそろ止めにしませんか？
        "d19de11e-d9a2-4b22-866e-2f95b8ac5c95" ->
            { code = "B-201", row = "3" }

        -- SML#コンパイラを速くする：タスク並列、末尾呼び出し、部分評価機構の開発
        "b69688cf-06a2-4070-839c-4a6ec299c39c" ->
            { code = "B-202", row = "4" }

        -- Julia という言語について
        "4ca1dabd-dbbe-47ca-a813-bc4c9700ccc9" ->
            { code = "B-203", row = "6" }

        -- Leanで正規表現エンジンをつくる。そして正しさを証明する
        "af94193a-4acb-4079-82a9-36bacfae3a20" ->
            { code = "B-204", row = "7" }

        -- 型付きアクターモデルがもたらす分散シミュレーションの未来
        "82478074-a43b-4d46-87a8-0742ed790e86" ->
            { code = "B-205", row = "8" }

        -- Scalaだったらこう書けるのに~Scalaが恋しくて~(TypeScript編、Python編)
        "2ceb7498-b203-44ee-b064-c0fbbe4a6948" ->
            { code = "B-206", row = "10" }

        -- ClojureScript (Squint) で React フロントエンド開発 2025 年版
        "e7f30174-d4b9-40a7-9398-9f15c71009a9" ->
            { code = "B-207", row = "11/13" }

        -- Lispは関数型言語(ではない)
        "92b697d1-206c-426a-90c9-9ff3486cce6f" ->
            { code = "B-208", row = "13/15" }

        -- Kotlinで学ぶSealed classと代数的データ型
        "e436393d-c322-477d-b8cb-0e6ac8ce8cc6" ->
            { code = "B-209", row = "15/17" }

        -- ドメインモデリングにおける抽象の役割、tagless-finalによるDSL構築、そして型安全な最適化
        "f3a8809b-d498-4ac2-bf42-5c32ce1595ea" ->
            { code = "C-101", row = "3" }

        -- 関数型言語テイスティング: Haskell, Scala, Clojure, Elixirを比べて味わう関数型プログラミングの旨さ
        "f7646b8b-29b0-4ac4-8ec3-46cabaa8ef1a" ->
            { code = "C-102", row = "5" }

        -- AIと共に進化する開発手法：形式手法と関数型プログラミングの可能性
        "56b9175d-1468-4ab0-8063-180491bb16ed" ->
            { code = "C-103", row = "6" }

        -- Elmのパフォーマンス、実際どうなの？ベンチマークに入門してみた
        "3760ed3e-5b38-48b9-9db2-f101af1e580f" ->
            { code = "C-104", row = "8" }

        -- 高階関数を用いたI/O方法の公開 - DIコンテナから高階関数への更改 -
        "350e2f70-0b02-4b79-b9f6-254a9d614706" ->
            { code = "C-105", row = "9" }

        -- Excelで関数型プログラミング
        "37899705-7d88-4ca4-bd5b-f674fc372d4e" ->
            { code = "C-106", row = "10" }

        -- XSLTで作るBrainfuck処理系 ― XSLTは関数型言語たり得るか？
        "8dcaecb5-4541-4262-a047-3e330a7bcdb8" ->
            { code = "C-107", row = "11" }

        -- F#の設計と妥協点 - .NET上で実現する関数型パラダイム
        "a916dd5a-7342-416a-980d-84f180a8e0a2" ->
            { code = "C-201", row = "3" }

        -- マイクロサービス内で動くAPIをF#で書いている
        "7a342a71-90d4-43f9-9c4a-ce801fc9b49a" ->
            { code = "C-202", row = "4" }

        -- はじめて関数型言語の機能に触れるエンジニア向けの学び方/教え方
        "7cc6ecef-94c8-4add-abc0-23b500dbf498" ->
            { code = "C-204", row = "7" }

        -- iOSアプリ開発で関数型プログラミングを実現するThe Composable Architectureの紹介
        "71fbd521-9dc5-458d-89f6-cbff8e84e3cc" ->
            { code = "C-205", row = "8" }

        -- デコーダーパターンによる3Dジオメトリの読み込み
        "a82127a7-f84a-43c1-a3de-483e1d973a94" ->
            { code = "C-206", row = "10" }

        -- ラムダ計算って何だっけ？関数型の神髄に迫る
        "81cea14c-255c-46ff-929d-5141c5715832" ->
            { code = "C-207", row = "11" }

        -- Underground 型システム
        "e0274da9-d863-47fe-a945-42eb04185bb9" ->
            { code = "C-208", row = "12" }

        -- 堅牢な認証基盤の実現: TypeScriptで代数的データ型を活用する
        "267ff4c1-8f3c-473b-8cab-e62d0d468af5" ->
            { code = "C-209", row = "13" }

        -- CoqのProgram機構の紹介 〜型を活用した安全なプログラミング〜
        "983d1021-3636-4778-be58-149f1995e8a5" ->
            { code = "C-210", row = "14/16" }

        -- F#で自在につくる静的ブログサイト
        "b6c70e2d-856b-47c5-9107-481883527634" ->
            { code = "C-211", row = "16" }

        _ ->
            { code = "", row = "50" }


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


getCommonProps : TimetableItem -> CommonProps
getCommonProps item =
    case item of
        Talk c _ ->
            c

        Timeslot c ->
            c


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
            (List.map timetableItem items)
        ]


timetableItem : TimetableItem -> Html msg
timetableItem item =
    case item of
        Talk c talk ->
            let
                { code, row } =
                    trackFromUuid c.uuid

                filteredTags =
                    talk.tags
                        |> List.filter (\tag -> List.all (\name -> tag.name /= name) [ "Intermediate", "Advanced" ])
                        |> (\tags ->
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
                    [ viewTag { name = code, colorText = textColor, colorBackground = bgColor }
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
