module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Css exposing (..)
import Css.Extra exposing (columnGap, content_, fr, grid, gridColumn, gridRow, gridTemplateColumns, marginBlock, rowGap)
import Css.Global exposing (withClass)
import Css.Media as Media exposing (only, screen, withMedia)
import FatalError exposing (FatalError)
import Head
import Head.Seo
import Html.Styled as Html exposing (Html, a, div, h1, h2, h3, iframe, img, li, p, section, span, text, ul)
import Html.Styled.Attributes as Attributes exposing (alt, attribute, class, css, href, rel, src, style)
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Site
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    {}


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


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
    -> View (PagesMsg Msg)
view _ _ =
    { title = ""
    , body =
        [ hero
        , newsSection
        , aboutSection
        , overviewSection
        , sponsorsSection
        , scheduleSection
        , teamSection
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

        announcement =
            div [ class "announcement" ]
                [ div [ style "text-align" "center", style "word-break" "auto-phrase" ]
                    [ text "セッション採択結果を公開しました。" ]
                , div [ class "buttons" ]
                    [ a [ class "button", href "https://fortee.jp/2025fp-matsuri/proposal/accepted", Attributes.target "_blank" ]
                        [ text "セッション一覧を見る" ]
                    ]
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
        , announcement
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
    let
        newsItem date contents =
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
                [ div [] [ text date ], div [] contents ]
    in
    section "News"
        [ div
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
            [ newsItem "2025-03-30"
                [ a [ href "https://fortee.jp/2025fp-matsuri/proposal/accepted", Attributes.target "_blank", rel "noopener noreferrer" ]
                    [ text "セッション採択結果を公開しました" ]
                ]
            , newsItem "2025-03-02" [ text "公募セッションの応募を締め切りました" ]
            , newsItem "2025-01-20" [ text "公募セッションの応募を開始しました" ]
            ]
        ]


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
        item key value =
            div [ style "min-width" "18rem" ]
                [ h3 [ class "font-semibold" ] [ text key ]
                , p [] [ text value ]
                ]
    in
    section "Overview"
        [ div [ class "markdown overview" ]
            [ item "Dates"
                "2025.6.14(土)〜15(日)"
            , item "Place"
                "中野セントラルパーク カンファレンス"
            ]
        , iframe
            [ class "map"
            , src "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d25918.24822641297!2d139.64379899847268!3d35.707005772578796!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x6018f34668e0bc27%3A0x7d66caba722762c5!2z5Lit6YeO44K744Oz44OI44Op44Or44OR44O844Kv44Kr44Oz44OV44Kh44Os44Oz44K5!5e0!3m2!1sen!2sjp!4v1736684092765!5m2!1sen!2sjp"
            , attribute "width" "100%"
            , Attributes.height 400
            , style "border" "0"
            , attribute "allowfullscreen" ""
            , attribute "loading" "lazy"
            , attribute "referrerpolicy" "no-referrer-when-downgrade"
            ]
            []
        ]


sponsorsSection : Html msg
sponsorsSection =
    section "Sponsors"
        [ div [ class "markdown sponsors" ]
            [ h3 [ class "text-3xl font-bold text-center py-8" ] [ text "スポンサー募集中！" ]
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
        , sponsorLogos
        ]



-- 各種スポンサーデータ


type alias Sponsor =
    { name : String
    , image : String
    , href : String
    }


goldSponsors : List Sponsor
goldSponsors =
    [ Sponsor "株式会社kubell（旧Chatwork株式会社）" "kubell.png" "https://www.kubell.com/recruit/engineer/"
    ]


silverSponsors : List Sponsor
silverSponsors =
    [ Sponsor "株式会社はてな" "hatena.png" "https://hatena.co.jp"
    , Sponsor "合同会社ザウエル" "zauel.png" "https://zauel.co.jp"
    ]


logoSponsors : List Sponsor
logoSponsors =
    [ Sponsor "合同会社Ignission" "ignission.png" "https://ignission.tech/"
    , Sponsor "株式会社ギークニア" "geekneer.png" "https://geekneer.com/"
    ]


sponsorLogos : Html msg
sponsorLogos =
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
    div [ css [ width (pct 100) ] ]
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
            (List.map sponsorLogo goldSponsors)
        , sponsorPlanHeader "シルバースポンサー"
        , div
            [ css
                [ logoGridStyle
                , paddingBottom (px 40)
                , gridTemplateColumns [ fr 1, fr 1, fr 1 ]
                , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                    [ gridTemplateColumns [ px 163, px 163 ] ]
                ]
            ]
            (List.map sponsorLogo silverSponsors)
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
            (List.map sponsorLogo logoSponsors)
        ]


sponsorLogo : Sponsor -> Html msg
sponsorLogo s =
    a
        [ href s.href
        , Attributes.rel "noopener noreferrer"
        , Attributes.target "_blank"
        , css
            [ textAlign center
            , textDecoration none
            , color inherit
            , fontSize (pt 10)
            , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                [ fontSize (pt 12) ]
            ]
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
            , columnGap (px 5)
            ]
        ]
        [ div [ css [ backgroundColor (rgba 30 44 88 0.1), height (px 1) ] ] []
        , div
            [ css
                [ color (rgb 0x66 0x66 0x66)
                , fontWeight bold
                , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                    [ fontSize (pt 16) ]
                ]
            ]
            [ text name ]
        , div [ css [ backgroundColor (rgba 30 44 88 0.1), height (px 1) ] ] []
        ]


scheduleSection : Html msg
scheduleSection =
    section "Schedule"
        [ schedule events
        , note "記載されているスケジュールの一部は予告なく変更されることがございます。"
        ]


schedule : List (Event msg) -> Html msg
schedule events_ =
    let
        listItem event =
            li
                [ class "event"
                , css
                    [ display grid
                    , property "grid-template-columns " "18px 1fr"
                    , property "grid-template-rows" "2rem repeat(2, auto) 2rem"
                    , columnGap (px 40)
                    , listStyleType none
                    , -- タイムラインの軸部分
                      before
                        [ gridColumn "1"
                        , gridRow "1 / -1"
                        , content_ ""
                        , display block
                        , width (pct 100)
                        , height (pct 100)
                        , property "background-color" "var(--color-primary)"
                        ]
                    , -- タイムラインのドット部分
                      after
                        [ gridColumn "1"
                        , gridRow "1 / -1"
                        , alignSelf center
                        , property "justify-self" "center"
                        , content_ ""
                        , display block
                        , width (px 14)
                        , height (px 14)
                        , borderRadius (pct 100)
                        , property "background-color" "var(--color-on-primary)"
                        ]
                    , firstChild
                        [ before
                            [ alignSelf end
                            , height (calc (pct 50) plus (px 9))
                            , borderRadius4 (px 9) (px 9) zero zero
                            ]
                        ]
                    , lastChild
                        [ before
                            [ height (calc (pct 50) plus (px 9))
                            , borderRadius4 zero zero (px 9) (px 9)
                            ]
                        ]
                    ]
                ]
                [ h3
                    [ class (highlight event.highlight)
                    , css
                        [ gridColumn "2"
                        , gridRow "2"
                        , marginBlock zero
                        , fontSize (rem 1.125)
                        , fontWeight normal
                        , withClass "highlight"
                            [ fontSize (rem 1.875) ]
                        ]
                    ]
                    [ event.label ]
                , p
                    [ css
                        [ gridColumn "2"
                        , gridRow "3"
                        , marginBlock zero
                        , fontSize (rem 0.875)
                        ]
                    ]
                    [ text event.at ]
                ]

        highlight bool =
            if bool then
                "highlight"

            else
                ""
    in
    ul
        [ css
            [ margin zero
            , padding zero
            , displayFlex
            , flexDirection column
            ]
        ]
        (List.map listItem events_)


note : String -> Html msg
note description =
    p
        [ css
            [ fontSize (rem 0.875)
            , color (rgb 64 64 64)
            , before [ content_ "※" ]
            ]
        ]
        [ text description ]


type alias Event msg =
    { label : Html msg
    , at : String
    , highlight : Bool
    }


events : List (Event msg)
events =
    [ { label = text "セッション応募開始"
      , at = "2025年1月20日"
      , highlight = False
      }
    , { label = text "セッション採択結果発表"
      , at = "2025年3月30日"
      , highlight = False
      }
    , { label = text "チケット販売開始"
      , at = "2025年春頃"
      , highlight = False
      }
    , { label = text "関数型まつり開催"
      , at = "2025年6月14-15日"
      , highlight = True
      }
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
