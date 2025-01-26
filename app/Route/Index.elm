module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (Html, a, div, h1, h2, h3, iframe, img, li, p, section, span, text, ul)
import Html.Attributes exposing (attribute, class, height, href, src, style, target)
import Pages.Url
import PagesMsg exposing (PagesMsg)
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Svg exposing (Svg, path, svg)
import Svg.Attributes exposing (d, fill, viewBox)
import UrlPath
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
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = [ "images", "icon-png.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Welcome to elm-pages!"
        , locale = Nothing
        , title = "elm-pages is running"
        }
        |> Seo.website



-- VIEW


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app shared =
    { title = "elm-pages is running"
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
        iconButton item =
            a
                [ class "icon-button"
                , href item.href
                , style "padding" item.padding
                ]
                [ item.icon ]
    in
    div [ class "hero" ]
        [ h1 [] [ text "関数型まつり" ]
        , div [ class "date" ]
            [ text "2025.6.14"
            , span [ style "font-size" "70%" ] [ text " sat" ]
            , text " – 15"
            , span [ style "font-size" "70%" ] [ text " sun" ]
            ]
        , ul [ class "links" ] (List.map (\link -> li [] [ iconButton link ]) links)
        ]


links :
    List
        { name : String
        , icon : Svg msg
        , href : String
        , padding : String
        }
links =
    [ { name = "X"
      , icon = icon_X
      , href = "https://x.com/fp_matsuri"
      , padding = "10px"
      }
    , { name = "Hatena Blog"
      , icon = icon_hatenablog
      , href = "https://blog.fp-matsuri.org/"
      , padding = "10px"
      }
    ]


icon_X : Svg msg
icon_X =
    svg [ style "height" "100%", viewBox "0 0 512 512" ]
        [ path
            [ fill "currentcolor"
            , d "M389.2 48h70.6L305.6 224.2 487 464H345L233.7 318.6 106.5 464H35.8L200.7 275.5 26.8 48H172.4L272.9 180.9 389.2 48zM364.4 421.8h39.1L151.1 88h-42L364.4 421.8z"
            ]
            []
        ]


icon_hatenablog : Svg msg
icon_hatenablog =
    svg [ style "height" "100%", viewBox "0 0 300 300" ]
        [ path
            [ fill "currentcolor"
            , d "M149.999 248.909c-54.537.0-98.906-44.367-98.906-98.909.0-54.537 44.369-98.909 98.906-98.909 54.545.0 98.908 44.372 98.908 98.909.0 54.542-44.363 98.909-98.908 98.909zm0-185.238c-47.601.0-86.33 38.723-86.33 86.329.0 47.605 38.729 86.332 86.33 86.332 47.61.0 86.338-38.727 86.338-86.332.0-47.606-38.728-86.329-86.338-86.329zM161.52 101.16c-4.832-9.785-7.783-19.3-9.273-24.845v70.055c2.447.917 4.197 3.257 4.197 6.021.0 3.559-2.887 6.442-6.443 6.442-3.56.0-6.443-2.885-6.443-6.442.0-2.896 1.925-5.317 4.558-6.131V76.241c-1.485 5.531-4.438 15.092-9.293 24.919-7.571 15.314-17.009 28.823-17.009 28.823l6.036 82.598s5.736 6.401 22.31 6.41h.023c16.573-.009 22.312-6.41 22.312-6.41l6.035-82.598c-.003.0-9.441-13.508-17.01-28.823z"
            ]
            []
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
                [ h3 [ class (highlight event.highlight) ] [ text event.name ]
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


type alias Event =
    { name : String
    , at : String
    , highlight : Bool
    }


schedule : List Event
schedule =
    [ { name = "セッション応募開始"
      , at = "2025年初め"
      , highlight = False
      }
    , { name = "セッション採択結果発表"
      , at = ""
      , highlight = False
      }
    , { name = "チケット販売開始"
      , at = "2025年春頃"
      , highlight = False
      }
    , { name = "関数型まつり開催"
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
