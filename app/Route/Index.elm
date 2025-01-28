module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo
import Html exposing (Html, a, div, h1, h2, h3, iframe, img, li, p, section, span, text, ul)
import Html.Attributes exposing (attribute, class, height, href, src, style, target)
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
head app =
    Site.summaryLarge { pageTitle = "" }
        |> Head.Seo.website



-- VIEW


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app shared =
    { title = ""
    , body =
        [ hero
        , aboutBlock
        , overviewBlock
        , scheduleBlock
        , sponsorsBlock
        , teamBlock
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
                [ text "セッションを募集中です(2025/3/2まで)"
                , div [ class "buttons" ]
                    [ a [ class "button", href "https://fortee.jp/2025fp-matsuri/speaker/proposal/cfp", target "_blank" ]
                        [ text "セッションに応募する" ]
                    , a [ class "button", href "https://fortee.jp/2025fp-matsuri/proposal/all", target "_blank" ]
                        [ text "応募中のセッション一覧を見る" ]
                    ]
                ]

        iconButton item =
            a [ class "icon-button", href item.href ]
                [ img [ class item.id, src item.icon ] [] ]
    in
    div [ class "hero" ]
        [ h1 [] [ text "関数型まつり" ]
        , date
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


aboutBlock : Html msg
aboutBlock =
    block "About"
        [ div []
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


overviewBlock : Html msg
overviewBlock =
    let
        item key value =
            div [ style "min-width" "18rem" ]
                [ h3 [ class "font-semibold" ] [ text key ]
                , p [] [ text value ]
                ]
    in
    block "Overview"
        [ div [ class "prose" ]
            [ item "Dates"
                "2025.6.14(土)〜15(日)"
            , item "Place"
                "中野セントラルパーク カンファレンス"
            ]
        , iframe
            [ class "map"
            , src "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d25918.24822641297!2d139.64379899847268!3d35.707005772578796!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x6018f34668e0bc27%3A0x7d66caba722762c5!2z5Lit6YeO44K744Oz44OI44Op44Or44OR44O844Kv44Kr44Oz44OV44Kh44Os44Oz44K5!5e0!3m2!1sen!2sjp!4v1736684092765!5m2!1sen!2sjp"
            , attribute "width" "100%"
            , height 400
            , style "border" "0"
            , attribute "allowfullscreen" ""
            , attribute "loading" "lazy"
            , attribute "referrerpolicy" "no-referrer-when-downgrade"
            ]
            []
        ]


scheduleBlock : Html msg
scheduleBlock =
    let
        listItem event =
            li [ class "event" ]
                [ h3 [ class (highlight event.highlight) ] [ event.label ]
                , p [] [ text event.at ]
                ]

        highlight bool =
            if bool then
                "highlight"

            else
                ""
    in
    block "Schedule"
        [ ul [ class "schedule" ] (List.map listItem schedule)
        , p [ class "note" ] [ text "記載されているスケジュールの一部は予告なく変更されることがございます。" ]
        ]


type alias Event msg =
    { label : Html msg
    , at : String
    , highlight : Bool
    }


schedule : List (Event msg)
schedule =
    [ { label =
            a [ href "https://fortee.jp/2025fp-matsuri/speaker/proposal/cfp", target "_blank" ]
                [ text "セッション応募開始" ]
      , at = "2025年1月20日"
      , highlight = False
      }
    , { label = text "セッション採択結果発表"
      , at = "2025年3月中"
      , highlight = False
      }
    , { label = text "チケット販売開始"
      , at = "2025年春頃"
      , highlight = False
      }
    , { label = text "関数型まつり開催"
      , at = "2025.6.14-15"
      , highlight = True
      }
    ]


sponsorsBlock : Html msg
sponsorsBlock =
    block "Sponsors"
        [ div [ class "sponsors" ]
            [ h3 [ class "text-3xl font-bold text-center py-8" ] [ text "スポンサー募集中！" ]
            , p []
                [ text "関数型まつりの開催には、みなさまのサポートが必要です！現在、イベントを支援していただけるスポンサー企業を募集しています。関数型プログラミングのコミュニティを一緒に盛り上げていきたいという企業のみなさま、ぜひご検討ください。"
                ]
            , p []
                [ text "スポンサープランの詳細は、2025年初頭に公開を予定しております。"
                , text "ご興味をお持ちの企業様は、ぜひ"
                , a [ href "https://scalajp.notion.site/1566d12253aa80229b3bc0a015497cb4?pvs=105" ] [ text "お問い合わせフォーム" ]
                , text "よりお気軽にご連絡ください。後日、担当者よりご連絡を差し上げます。"
                ]
            ]
        ]


teamBlock : Html msg
teamBlock =
    let
        listItem member =
            li [ class "person" ]
                [ img [ src ("https://github.com/" ++ member.id ++ ".png") ] []
                , a [ href ("https://github.com/" ++ member.id), target "_blank" ] [ text member.id ]
                ]
    in
    block "Team"
        [ div [ class "people" ]
            [ h3 [] [ text "座長" ]
            , ul [] (List.map listItem staff.leader)
            , h3 [] [ text "スタッフ" ]
            , ul [] (List.map listItem staff.members)
            ]
        ]


type alias Member =
    { id : String }


staff : { leader : List Member, members : List Member }
staff =
    { leader =
        [ Member "lagenorhynque"
        , Member "omiend"
        , Member "shomatan"
        , Member "taketora26"
        , Member "yoshihiro503"
        , Member "ysaito8015"
        ]
    , members =
        [ Member "a-skua"
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
        ]
    }


block : String -> List (Html msg) -> Html msg
block title children =
    let
        heading =
            h2 [] [ text title ]
    in
    section [] (heading :: children)
