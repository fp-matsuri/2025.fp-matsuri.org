module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Css exposing (..)
import Css.Extra exposing (columnGap, fr, grid, gridColumn, gridTemplateColumns, rowGap)
import Css.Global exposing (descendants)
import Css.Media as Media exposing (only, screen, withMedia)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Head.Seo
import Html.Styled as Html exposing (Html, a, div, h1, h2, h3, iframe, img, li, p, section, span, tbody, td, text, th, thead, tr, ul)
import Html.Styled.Attributes as Attributes exposing (alt, attribute, class, css, href, rel, src, style)
import PagesMsg exposing (PagesMsg)
import Random
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import Site
import View exposing (View)


type alias RouteParams =
    {}


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildWithLocalState
            { init = init
            , update = update
            , view = view
            , subscriptions = \_ _ _ _ -> Sub.none
            }



-- INIT


type alias Model =
    { seed : Int
    }


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( { seed = 0 }
    , Effect.fromCmd (Random.generate GotRandomSeed (Random.int 0 100))
    )



-- UPDATE


type Msg
    = GotRandomSeed Int


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        GotRandomSeed newSeed ->
            ( { model | seed = newSeed }, Effect.none )



-- DATA


type alias Data =
    {}


type alias ActionData =
    {}


data : BackendTask FatalError Data
data =
    BackendTask.succeed Data


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head _ =
    Site.summaryLarge { pageTitle = "" }
        |> Head.Seo.website



-- VIEW


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view _ _ model =
    { title = ""
    , body =
        [ hero
        , newsSection
        , aboutSection
        , overviewSection
        , sponsorsSection model.seed
        , teamSection
        , proposalSection
        ]
    }


hero : Html msg
hero =
    let
        date =
            div [ class "date" ]
                [ text "2025.6.14"
                , span [ style "font-size" "70%" ] [ text " sat" ]
                , text " – 15"
                , span [ style "font-size" "70%" ] [ text " sun" ]
                ]

        iconButton item =
            a [ class "icon-button", href item.href ]
                [ img [ class item.id, src item.icon ] [] ]
    in
    div [ class "hero" ]
        [ div [ class "hero-main" ]
            [ img [ class "logomark", src "images/logomark.svg" ] []
            , h1 [] [ text "関数型まつり" ]
            , date
            ]
        , ul [ class "links" ] (List.map (\link -> li [] [ iconButton link ]) links)
        ]


links : List { id : String, icon : String, href : String }
links =
    [ { id = "x"
      , icon = "images/x.svg"
      , href = "https://x.com/fp_matsuri"
      }
    , { id = "hatena_blog"
      , icon = "images/hatenablog.svg"
      , href = "https://blog.fp-matsuri.org/"
      }
    , { id = "fortee"
      , icon = "images/fortee.svg"
      , href = "https://fortee.jp/2025fp-matsuri"
      }
    ]


newsSection : Html msg
newsSection =
    section "News"
        [ news
            [ { date = "2025-04-06"
              , label = "🎉 注目のプログラムがついに公開！そしてチケット販売開始しました！！"
              , url = "https://blog.fp-matsuri.org/entry/2025/04/06/101230"
              }
            , { date = "2025-03-30"
              , label = "セッション採択結果を公開しました"
              , url = "https://fortee.jp/2025fp-matsuri/proposal/accepted"
              }
            , { date = "2025-03-02"
              , label = "公募セッションの応募を締め切りました"
              , url = ""
              }
            , { date = "2025-01-20"
              , label = "公募セッションの応募を開始しました"
              , url = ""
              }
            ]
        ]


type alias NewsItem =
    { date : String
    , label : String
    , url : String
    }


news : List NewsItem -> Html msg
news items =
    let
        newsItem { date, label, url } =
            div
                -- PCの時だけ二段組にします。モバイルの時は一段組ですが日付と内容の間にgapが付きません。
                [ css
                    [ display grid
                    , gridColumn "1 / -1"
                    , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                        [ property "grid-template-columns " "subgrid"
                        , alignItems center
                        ]
                    ]
                ]
                [ div [] [ text date ]
                , div []
                    [ if String.isEmpty url then
                        text label

                      else
                        a [ href url, Attributes.target "_blank", rel "noopener noreferrer" ] [ text label ]
                    ]
                ]
    in
    div
        [ css
            [ display grid
            , maxWidth (em 32.5)
            , rowGap (px 15)
            , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                [ property "grid-template-columns " "max-content 1fr"
                , columnGap (px 10)
                , rowGap (px 10)
                ]
            ]
        ]
        (List.map newsItem items)


aboutSection : Html msg
aboutSection =
    section "About"
        [ div [ class "markdown about" ]
            [ p [] [ text "関数型プログラミングのカンファレンス「関数型まつり」を開催します！" ]
            , p []
                [ text "関数型プログラミングはメジャーな言語・フレームワークに取り入れられ、広く使われるようになりました。"
                , text "そしてその手法自体も進化し続けています。"
                , text "その一方で「関数型プログラミング」というと「難しい・とっつきにくい」という声もあり、十分普及し切った状態ではありません。"
                ]
            , p []
                [ text "私たちは様々な背景の方々が関数型プログラミングを通じて新しい知見を得て、交流ができるような場を提供することを目指しています。"
                , text "普段から関数型言語を活用している方や関数型プログラミングに興味がある方はもちろん、最先端のソフトウェア開発技術に興味がある方もぜひご参加ください！"
                ]
            ]
        ]


overviewSection : Html msg
overviewSection =
    let
        information =
            div []
                [ item "日程"
                    [ ul [ css [ padding zero, textAlign center, listStyle none ] ]
                        [ li [] [ text "Day1：6月14日（土）11:00〜19:00" ]
                        , li [] [ text "Day2：6月15日（日）10:00〜19:00" ]
                        ]
                    ]
                , item "会場"
                    [ p [ css [ textAlign center ] ] [ text "中野セントラルパーク カンファレンス" ] ]
                , item "チケット"
                    [ ticketTable
                        [ ConferenceTicket { category = "一般（懇親会なし）", price = "3,000円" }
                        , BothTicket { category = "一般（懇親会あり）", price = "8,000円" }
                        , ConferenceTicket { category = "学生（懇親会なし）", price = "1,000円" }
                        , BothTicket { category = "学生（懇親会あり）", price = "6,000円" }
                        , PartyTicket { category = "懇親会のみ", price = "5,000円" }
                        ]
                    , note "Day 1のセッション終了後には、参加者同士の交流を深める懇親会を予定しております。参加される方は「懇親会あり」のチケットをご購入ください。"
                    , buttonLink
                        { label = "チケットを購入（Doorkeeper）"
                        , url = "https://fp-matsuri.doorkeeper.jp/events/182879"
                        }
                    ]
                ]

        item label contents =
            div []
                (h3
                    [ css
                        [ margin zero
                        , display grid
                        , property "grid-template-columns " "1fr max-content 1fr"
                        , alignItems center
                        , columnGap (em 0.5)
                        ]
                    ]
                    [ div [ css [ backgroundColor (rgba 30 44 88 0.1), height (px 1) ] ] []
                    , div
                        [ css
                            [ color (rgb 0x66 0x66 0x66)
                            , whiteSpace noWrap
                            , fontSize (px 16)
                            , fontWeight normal
                            ]
                        ]
                        [ text label ]
                    , div [ css [ backgroundColor (rgba 30 44 88 0.1), height (px 1) ] ] []
                    ]
                    :: contents
                )

        note string =
            p
                [ css
                    [ display grid
                    , property "grid-template-columns" "auto 1fr"
                    , columnGap (em 0.3)
                    , fontSize (px 14)
                    , before
                        [ display block
                        , property "content" (qt "※")
                        , lineHeight (num 1.5)
                        ]
                    ]
                ]
                [ text string ]

        buttonLink { label, url } =
            a
                [ href url
                , Attributes.target "_blank"
                , rel "noopener noreferrer"
                , css
                    [ display block
                    , padding (px 8)
                    , textAlign center
                    , textDecoration none
                    , fontSize (px 16)
                    , borderRadius (px 30)
                    , backgroundColor (rgba 210 96 88 1)
                    , color (rgb 255 255 255)
                    ]
                ]
                [ text label ]

        map =
            iframe
                [ src "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d25918.24822641297!2d139.64379899847268!3d35.707005772578796!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x6018f34668e0bc27%3A0x7d66caba722762c5!2z5Lit6YeO44K744Oz44OI44Op44Or44OR44O844Kv44Kr44Oz44OV44Kh44Os44Oz44K5!5e0!3m2!1sen!2sjp!4v1736684092765!5m2!1sen!2sjp"
                , attribute "allowfullscreen" ""
                , attribute "loading" "lazy"
                , attribute "referrerpolicy" "no-referrer-when-downgrade"
                , css
                    [ width (pct 100)
                    , height (px 400)
                    , borderRadius (px 5)
                    , border zero
                    , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                        [ height (pct 100) ]
                    ]
                ]
                []
    in
    section "Overview"
        [ div
            [ css
                [ display grid
                , rowGap (em 1)
                , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                    [ maxWidth (px 800)
                    , gridTemplateColumns [ fr 1, fr 1 ]
                    , columnGap (em 2)
                    ]
                ]
            ]
            [ information, map ]
        ]


type Ticket
    = ConferenceTicket { category : String, price : String }
    | PartyTicket { category : String, price : String }
    | BothTicket { category : String, price : String }


ticketTable : List Ticket -> Html msg
ticketTable tickets =
    Html.table
        [ css
            [ margin2 (em 1) zero
            , width (pct 100)
            , borderCollapse collapse
            , borderSpacing zero
            ]
        ]
        [ thead []
            [ tr
                [ css
                    [ descendants
                        [ Css.Global.th
                            [ paddingBottom (px 5), fontSize (px 12) ]
                        ]
                    ]
                ]
                [ th [ css [ textAlign left ] ] [ text "種別" ]
                , th [ css [ textAlign center ] ] [ text "価格" ]
                , th [ css [ textAlign center ] ] [ text "カンファレンス" ]
                , th [ css [ textAlign center ] ] [ text "懇親会" ]
                ]
            ]
        , tbody [] (List.map tableRow tickets)
        ]


tableRow : Ticket -> Html msg
tableRow ticket =
    let
        { category, price } =
            case ticket of
                ConferenceTicket options ->
                    options

                PartyTicket options ->
                    options

                BothTicket options ->
                    options
    in
    tr []
        [ td [ css [ textAlign left, fontSize (px 14) ] ] [ text category ]
        , td [ css [ textAlign center, fontSize (px 14) ] ] [ text price ]
        , td [ css [ textAlign center, fontSize (px 24) ] ]
            [ text
                (case ticket of
                    ConferenceTicket _ ->
                        "○"

                    PartyTicket _ ->
                        "-"

                    BothTicket _ ->
                        "○"
                )
            ]
        , td [ css [ textAlign center, fontSize (px 24) ] ]
            [ text
                (case ticket of
                    ConferenceTicket _ ->
                        "-"

                    PartyTicket _ ->
                        "○"

                    BothTicket _ ->
                        "○"
                )
            ]
        ]


sponsorsSection : Int -> Html msg
sponsorsSection seed =
    section "Sponsors"
        [ div [ class "markdown sponsors" ]
            [ h3 [] [ text "スポンサー募集中！" ]
            , p []
                [ text "関数型まつりの開催には、みなさまのサポートが必要です！現在、イベントを支援していただけるスポンサー企業を募集しています。関数型プログラミングのコミュニティを一緒に盛り上げていきたいという企業のみなさま、ぜひご検討ください。"
                ]
            , p []
                [ text "スポンサープランの詳細は "
                , a [ href "https://docs.google.com/presentation/d/1zMj4lBBr9ru6oAQEUJ01jrzl9hqX1ajs0zdb-73ngto/edit?usp=sharing", Attributes.target "_blank" ] [ text "スポンサーシップのご案内" ]
                , text " よりご確認いただけます。スポンサーには"
                , a [ href "https://scalajp.notion.site/d5f10ec973fb4e779d96330d13b75e78", Attributes.target "_blank" ] [ text "お申し込みフォーム" ]
                , text " からお申し込みいただけます。"
                ]
            , p []
                [ text "ご不明点などありましたら、ぜひ"
                , a [ href "https://scalajp.notion.site/19c6d12253aa8068958ee110dbe8d38d" ] [ text "お問い合わせフォーム" ]
                , text "よりお気軽にお問い合わせください。"
                ]
            ]
        , sponsorLogos seed
        ]



-- 各種スポンサーデータ


type alias Sponsor =
    { name : String
    , image : String
    , href : String
    }


goldSponsorsShuffled : Int -> List Sponsor
goldSponsorsShuffled seed =
    shuffleList seed
        [ Sponsor "株式会社kubell（旧Chatwork株式会社）" "kubell.png" "https://www.kubell.com/recruit/engineer/"
        ]


silverSponsorsShuffled : Int -> List Sponsor
silverSponsorsShuffled seed =
    shuffleList seed
        [ Sponsor "株式会社はてな" "hatena.png" "https://hatena.co.jp"
        , Sponsor "合同会社ザウエル" "zauel.png" "https://zauel.co.jp"
        , Sponsor "株式会社ネクストビート" "nextbeat.png" "https://www.nextbeat.co.jp/"
        , Sponsor "エムスリー株式会社" "m3.png" "https://jobs.m3.com/engineer/"
        ]


logoSponsorsShuffled : Int -> List Sponsor
logoSponsorsShuffled seed =
    shuffleList seed
        [ Sponsor "合同会社Ignission" "ignission.png" "https://ignission.tech/"
        , Sponsor "株式会社ギークニア" "geekneer.png" "https://geekneer.com/"
        ]


{-| 与えられたリストの要素をランダムな順序に並べ替えます

    1. リストの各要素に0〜1のランダムな値を割り当てる
    2. ランダム値でソートすることでリストをシャッフル
    3. ランダム値を取り除いて元の要素だけを返す

-}
shuffleList : Int -> List a -> List a
shuffleList seed list =
    let
        generator =
            Random.list (List.length list) (Random.float 0 1)
    in
    Random.initialSeed seed
        |> Random.step generator
        |> Tuple.first
        |> List.map2 Tuple.pair list
        |> List.sortBy Tuple.second
        |> List.map Tuple.first


sponsorLogos : Int -> Html msg
sponsorLogos seed =
    let
        -- スポンサープランによらない、レイアウト構成を決めるようなスタイルを定義
        logoGridStyle =
            batch
                [ display grid
                , columnGap (px 10)
                , paddingTop (px 20)
                , justifyContent center
                , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                    [ paddingTop (px 30)
                    ]
                ]
    in
    div [ css [ width (pct 100), maxWidth (em 43) ] ]
        [ sponsorPlanHeader "ゴールドスポンサー"
        , div
            [ css
                [ logoGridStyle
                , paddingBottom (px 40)
                , gridTemplateColumns [ fr 1 ]
                , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                    [ gridTemplateColumns [ px 280 ] ]
                ]
            ]
            (List.map sponsorLogo (goldSponsorsShuffled seed))
        , sponsorPlanHeader "シルバースポンサー"
        , div
            [ css
                [ logoGridStyle
                , paddingBottom (px 40)
                , gridTemplateColumns [ fr 1, fr 1, fr 1 ]
                , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                    [ property "grid-template-columns" "repeat(auto-fit, 163px)" ]
                ]
            ]
            (List.map sponsorLogo (silverSponsorsShuffled seed))
        , sponsorPlanHeader "ロゴスポンサー"
        , div
            [ css
                [ logoGridStyle
                , paddingBottom (px 40)
                , gridTemplateColumns [ fr 1, fr 1, fr 1, fr 1 ]
                , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                    [ gridTemplateColumns [ px 116, px 116 ] ]
                ]
            ]
            (List.map sponsorLogo (logoSponsorsShuffled seed))
        ]


sponsorLogo : Sponsor -> Html msg
sponsorLogo s =
    a
        [ href s.href
        , Attributes.rel "noopener noreferrer"
        , Attributes.target "_blank"
        ]
        [ img
            [ src ("images/sponsors/" ++ s.image)
            , css
                [ backgroundColor (rgb 255 255 255)
                , borderRadius (px 10)
                , width (pct 100)
                ]
            , alt s.name
            ]
            []
        ]


sponsorPlanHeader : String -> Html msg
sponsorPlanHeader name =
    div
        [ css
            [ display grid
            , property "grid-template-columns " "1fr max-content 1fr"
            , alignItems center
            , columnGap (em 0.5)
            ]
        ]
        [ div [ css [ backgroundColor (rgba 30 44 88 0.1), height (px 1) ] ] []
        , div
            [ css
                [ color (rgb 0x66 0x66 0x66)
                , whiteSpace noWrap
                , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                    [ fontSize (px 16) ]
                ]
            ]
            [ text name ]
        , div [ css [ backgroundColor (rgba 30 44 88 0.1), height (px 1) ] ] []
        ]


teamSection : Html msg
teamSection =
    let
        listItem member =
            li []
                [ a [ class "person", href ("https://github.com/" ++ member.id), Attributes.target "_blank" ]
                    [ img [ src ("https://github.com/" ++ member.id ++ ".png") ] []
                    , text member.id
                    ]
                ]
    in
    section "Team"
        [ div [ class "people leaders" ]
            [ h3 [] [ text "座長" ]
            , ul [] (List.map listItem staff.leader)
            ]
        , div [ class "people staff" ]
            [ h3 [] [ text "スタッフ" ]
            , ul [] (List.map listItem staff.members)
            ]
        ]


type alias Member =
    { id : String }


{-| 公平性のためにアルファベット順で記載しています。
-}
staff : { leader : List Member, members : List Member }
staff =
    { leader =
        [ Member "lagenorhynque"
        , Member "shomatan"
        , Member "taketora26"
        , Member "yoshihiro503"
        , Member "ysaito8015"
        ]
    , members =
        [ Member "a-skua"
        , Member "antimon2"
        , Member "aoiroaoino"
        , Member "ChenCMD"
        , Member "Guvalif"
        , Member "igrep"
        , Member "ik11235"
        , Member "Iwaji"
        , Member "katsujukou"
        , Member "kawagashira"
        , Member "kazup0n"
        , Member "Keita-N"
        , Member "kmizu"
        , Member "lmdexpr"
        , Member "magnolia-k"
        , Member "quantumshiro"
        , Member "rabe1028"
        , Member "takezoux2"
        , Member "tanishiking"
        , Member "tomoco95"
        , Member "Tomoyuki-TAKEZAKI"
        , Member "unarist"
        , Member "usabarashi"
        , Member "wm3"
        , Member "y047aka"
        , Member "yonta"
        , Member "yshnb"
        , Member "omiend"
        ]
    }


section : String -> List (Html msg) -> Html msg
section title children =
    let
        heading =
            h2 [] [ text title ]
    in
    Html.section [] (heading :: children)


proposalSection : Html msg
proposalSection =
    Html.section
        [ class "proposal-section"
        , css
            [ Css.padding2 (Css.px 40) Css.zero
            , Css.backgroundColor (Css.rgb 249 250 251)
            ]
        ]
        [ div
            [ class "container mx-auto px-4"
            , css [ Css.maxWidth (Css.px 800), Css.margin2 Css.zero Css.auto ]
            ]
            [ h2
                [ class "text-2xl font-bold mb-4"
                , css [ Css.marginBottom (Css.px 16) ]
                ]
                [ text "採択された応募" ]
            , p
                [ class "mb-6"
                , css [ Css.marginBottom (Css.px 24) ]
                ]
                [ text "FP Matsuri 2025 で採択された応募の一覧を公開しています。" ]
            , a
                [ href "/proposal"
                , class "inline-block bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors"
                , css
                    [ Css.backgroundColor (Css.rgb 37 99 235)
                    , Css.color (Css.rgb 255 255 255)
                    , Css.padding2 (Css.px 16) (Css.px 24)
                    , Css.borderRadius (Css.px 8)
                    , Css.hover [ Css.backgroundColor (Css.rgb 29 78 216) ]
                    ]
                ]
                [ text "採択された応募一覧を見る" ]
            ]
        ]
