module Route.CodeOfConduct exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo
import Html exposing (Html, a, blockquote, br, div, figure, h2, iframe, li, p, section, text, ul)
import Html.Attributes exposing (attribute, class, height, href, src, target, width)
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
    Site.summaryLarge { pageTitle = "行動規範" }
        |> Head.Seo.website



-- VIEW


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app shared =
    { title = "行動規範"
    , body =
        [ block "行動規範マナー動画"
            [ div [ class "section_note" ]
                [ text "関数型まつりの行動規範は"
                , a [ href "https://scalamatsuri.org/", target "_blank" ] [ text "ScalaMatsuri" ]
                , text "の行動規範に基づいています。ScalaMatsuri の行動規範は動画で見る事ができます。"
                , figure [ class "section_figure" ]
                    [ iframe
                        [ class "section_movie"
                        , width 900
                        , height 450
                        , src "https://www.youtube.com/embed/lIfOQNTWdxI"
                        , attribute "frameborder" "0"
                        , attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                        , attribute "allowfullscreen" ""
                        ]
                        []
                    ]
                ]
            ]
        , block "はじめに"
            [ p []
                [ text "関数型まつりは、様々な地域やコミュニティから集う技術者に対して開かれたカンファレンスを目指しています。"
                , text "そのためには、性別や人種など多様な背景を持つ、普段の生活では会わない人々同士でも、互いに敬意を払って楽しい時間を過ごせることが重要だと考えています。"
                , br [] []
                , br [] []
                , text "以下の行動規範は、意図せずそういった配慮の行き届かない発言や行為をしてしまうことを防ぐためのガイドラインです。"
                , text "関数型まつりの主催者は、発表者や参加者、スポンサーの皆様に行動規範を守っていただくことをお願いしており、その場にそぐわない発言や行為を未然に防ぐための手助けをしています。"
                ]
            ]
        , block "本文"
            [ p []
                [ text "多様な背景を持つ人々が参加する技術カンファレンスにおいて、そこで交わされるコミュニケーションは技術的な発表と交流の場に相応しいものであって欲しいと願っています。"
                , text "関数型まつりは、カンファレンスの参加者に対するいかなるハラスメント行為も歓迎しません。"
                , br [] []
                , br [] []
                , text "関数型まつりは、会場内および関連するソーシャルイベント、SNS上でのコミュニケーションの全てにおいて、参加者、発表者、スポンサー、ブース出展者など、全ての関係者の皆様に対して本行動規範の遵守を求めます。"
                , text "カンファレンスの参加者および関係者は、自身のハラスメント行為（意識的、無意識的を問わず）について他者から指摘を受けた場合は、直ちにその行動を中止することを期待されています。"
                , br [] []
                , br [] []
                , text "ハラスメント行為の一例には以下のようなものがあります:"
                ]
            , ul [ class "section_note" ]
                (List.map (\itemString -> li [ class "section_note_item" ] [ text itemString ])
                    [ "他の参加者に対するナンパ行為 (容姿に関する発言、恋愛・性的興味を目的とした発言) や不適切な身体的接触を行うこと"
                    , "ジェンダー、性自認、ジェンダーの表出、性的指向、障がい、容貎、身体の大きさ、年齢、人種、国籍、民族、宗教について、当人が不快に感じる発言や差別を助長する言動を行うこと"
                    , "公共の場に性的な画像を掲示したり、見せびらかしたりすること"
                    , "他の参加者に対して、故意の威嚇やストーキング、つきまとい、本人が嫌がらせと感じるような写真撮影や録音録画を行うこと"
                    , "カンファレンスの発表や、その他のイベントを継続的に妨害し続けること"
                    , "カンファレンスの発表において、発表資料に性的な画像や素材などを使用したり、性的な演出を行うこと"
                    , "会場内のブースや掲示物において、出展スタッフやボランティアが性的な服装、制服、コスチュームを着用したり、その他の方法で性的な雰囲気を演出すること"
                    ]
                )
            , p []
                [ text "関数型まつりの主催者は、本行動規範の趣旨に反してハラスメント行為を行う参加者に対して注意や警告を行います。"
                , text "警告に従わずハラスメント行為を繰り返す場合や悪質な場合など、明らかな迷惑行為であると判断できる場合には、発表の中止やカンファレンス会場からの退場の指示を主催者の裁量で行うことがあります。"
                , br [] []
                , br [] []
                , text "当カンファレンスの参加者、発表者、スポンサー、ブースの出展者は、主催者の指示に即時かつ無条件に従ってもらえることを期待します。"
                , text "また、主催者の裁量によって会場から退場を指示された場合、該当者に対する参加料等の金銭の払い戻しは行わないものとします。"
                , br [] []
                , br [] []
                , text "同種の行動規範は、ハラスメントの無いカンファレンスを提供することを目指して、例年 PNW Scala、NE Scala、Scala Days、ScalaMatsuri などでも採用されており、関数型まつりもその精神に賛同します。"
                , br [] []
                , br [] []
                , text "この行動規範はより適切な運用を行うために随時更新される可能性があります。"
                ]
            ]
        , block "運用方法"
            [ p []
                [ text "関数型まつりでは、行動規範について以下の通り運用します。"
                , text "また必要に応じて、新たなプロセスを設ける可能性が有ります。"
                ]
            , ul [ class "section_note" ]
                (List.map (\itemString -> li [ class "section_note_item" ] [ text itemString ])
                    [ "インシデントの報告窓口をオンライン及びオフラインで設けます。インシデントが報告された場合、主催者は同様のインシデントが繰り返し発生しないように努め、必要に応じて注意や警告を行います。"
                    , "関数型まつりの全てのスポンサーに対し、スポンサー申込時に行動規範準拠の同意を確認しています。また、スライドやCMといった上映コンテンツの事前チェックによる行動規範準拠の確認、そして必要な場合は修正を依頼しています。"
                    , "カンファレンスにおける全ての発表者に対し、CFPへの応募時に行動規範準拠の同意を確認しています。また、スライドの事前チェックによる行動規範準拠の確認、そして必要な場合は修正を依頼しています。"
                    , "会場のお手洗いは、ご本人が自己宣言したジェンダーアイデンティティに基づいて利用していただいています。非バイナリジェンダーの方は、どのお手洗いでも利用可能としています。"
                    ]
                )
            ]
        , block "会期中の報告窓口"
            [ div []
                [ text "自分や他の人がハラスメントを受けている場合には以下のフォームにてご連絡ください。"
                , br [] []
                , br [] []
                , a [ href "https://forms.gle/4NZfofiHZzBcyZjRA", target "_blank" ] [ text "ハラスメント インシデント報告フォーム" ]
                ]
            ]
        , block "ライセンスと帰属に関して"
            [ blockquote [ class "section_note" ]
                [ p []
                    [ text "本規範は"
                    , a [ href "http://scalamatsuri.org/", target "_blank" ] [ text "ScalaMatsuri" ]
                    , text " の規範に基いています。"
                    , text "ScalaMatsuri の行動規範は、Geek Feminism wiki の規範例から派生しており、PNW Scala、NE Scala、および Scala Days の影響を受けています。"
                    ]
                ]
            ]
        ]
    }


block : String -> List (Html msg) -> Html msg
block title children =
    let
        heading =
            h2 [] [ text title ]
    in
    section [ class "coc" ] (heading :: children)
