module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Browser.Events
import Css exposing (..)
import Css.Extra exposing (columnGap, fr, grid, gridColumn, gridRow, gridTemplateColumns, gridTemplateRows, rowGap)
import Css.Global exposing (children, descendants)
import Css.Media as Media exposing (only, screen, withMedia)
import Data.Sponsor as Sponsor exposing (Plan(..))
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import FpMatsuri.BackgroundTexture as BackgroundTexture
import FpMatsuri.Logo
import Head
import Head.Seo
import Html.Styled as Html exposing (Attribute, Html, a, div, h1, h2, h3, iframe, img, li, p, section, span, tbody, td, text, th, thead, tr, ul)
import Html.Styled.Attributes as Attributes exposing (alt, attribute, class, css, href, rel, src)
import PagesMsg exposing (PagesMsg)
import Random
import Route.Sponsors as Sponsors
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import Site
import Time exposing (Posix)
import UrlPath
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
            , subscriptions = subscriptions
            }



-- INIT


type alias Model =
    { seed : Int
    , time : Float
    }


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( { seed = 0, time = 0 }
    , Effect.fromCmd (Random.generate GotRandomSeed (Random.int 0 100))
    )



-- UPDATE


type Msg
    = GotRandomSeed Int
    | Tick Posix


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        GotRandomSeed newSeed ->
            ( { model | seed = newSeed }, Effect.none )

        Tick newTime ->
            ( { model | time = Time.posixToMillis newTime |> toFloat }, Effect.none )



-- DATA


type alias Data =
    { sponsors : Sponsors.Data }


type alias ActionData =
    {}


data : BackendTask FatalError Data
data =
    BackendTask.map Data Sponsors.data


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
view app _ model =
    { title = ""
    , body =
        [ hero model.seed model.time app.data.sponsors
        , newsSection
        , aboutSection
        , overviewSection
        , sponsorsSection model.seed app.data.sponsors
        , teamSection
        ]
    }


hero : Int -> Float -> Sponsors.Data -> Html msg
hero seed time sponsorsData =
    let
        cellSize =
            25

        { gridRows, gridColumns } =
            { gridRows = 20, gridColumns = 81 }

        -- Get platinum sponsors for hero section
        platinumSponsors =
            sponsorsData.platinumSponsors
                |> List.map
                    (\article ->
                        { name = article.metadata.name
                        , image = article.metadata.id ++ ".png"
                        , href = article.metadata.href
                        }
                    )
                |> Sponsor.shuffle seed
    in
    div
        [ css
            [ padding3 zero (px 10) (px 10)
            , display grid
            ]
        ]
        [ div
            [ css
                [ overflow hidden
                , height (px (cellSize * 20))
                , borderRadius (px 10)
                , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                    [ height (px (cellSize * 20)) ]
                ]
            ]
            [ div
                [ css
                    [ display grid
                    , gridTemplateColumns (List.repeat gridColumns (px cellSize))
                    , gridTemplateRows (List.repeat gridRows (px cellSize))
                    , justifyContent center
                    ]
                ]
                [ div [ css [ property "display" "contents" ] ] <|
                    div [ css [ gridColumn "1 / -1", gridRow "1 / -1", backgroundColor (hsl 226 0.05 0.9) ] ] []
                        :: BackgroundTexture.textureGrid seed time { rows = gridRows, columns = gridColumns }
                , div
                    [ css
                        [ gridColumn "38/-38"
                        , gridRow "3/8"
                        , backgroundColor (hsl 226 0.05 0.9)
                        , padding (px cellSize)
                        , zIndex (int 1)
                        , children [ Css.Global.svg [ width (px (cellSize * 5)), height (px (cellSize * 4)) ] ]
                        , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                            [ gridRow "4/9" ]
                        ]
                    ]
                    [ Html.fromUnstyled <| FpMatsuri.Logo.logoMark ]
                , div
                    [ css
                        [ gridColumn "35/-35"
                        , gridRow "8/13"
                        , backgroundColor (hsl 226 0.05 0.9)
                        , zIndex (int 1)
                        , displayFlex
                        , property "place-items" "center"
                        , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                            [ gridRow "9/14" ]
                        ]
                    ]
                    [ logotypeAndDate ]
                , div
                    [ css
                        [ gridColumn "37/-37"
                        , gridRow "14/17"
                        , zIndex (int 1)
                        , displayFlex
                        , property "place-items" "center"
                        , backgroundColor (hsl 226 0.05 0.9)
                        , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                            [ gridRow "15/17" ]
                        ]
                    ]
                    [ heroSponsorsBlock platinumSponsors ]
                ]
            ]
        ]


logotypeAndDate : Html msg
logotypeAndDate =
    let
        -- TODO：ロゴイメージとロゴタイプ1枚の画像にする
        logotype =
            img
                [ src "/images/logotype.svg"
                , alt "関数型まつり"
                , css [ width (rem 12.5) ]
                ]
                []

        date =
            div
                [ css
                    [ property "font-family" "var(--montserrat-sans)"
                    , fontSize (em 1.1)
                    , fontWeight (int 300)
                    ]
                ]
                [ text "2025.6.14"
                , span [ css [ fontSize (pct 70) ] ] [ text " sat" ]
                , text " – 15"
                , span [ css [ fontSize (pct 70) ] ] [ text " sun" ]
                ]
    in
    div
        [ css
            [ width (pct 100)
            , property "display" "grid"
            , property "grid-template-rows" "auto auto"
            , property "place-items" "center"
            , rowGap (em 1)
            , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                [ property "grid-template-rows" "auto auto" ]
            ]
        ]
        [ logotype, date ]


heroSponsorsBlock : List { name : String, image : String, href : String } -> Html msg
heroSponsorsBlock sponsors =
    let
        platinumSponsorLogo sponsor =
            a
                [ href sponsor.href
                , Attributes.rel "noopener noreferrer"
                , Attributes.target "_blank"
                , css
                    [ display block
                    , width (pct 90)
                    ]
                ]
                [ img
                    [ src ("/images/sponsors/" ++ sponsor.image)
                    , css
                        [ display block
                        , borderRadius (px 10)
                        , width (pct 100)
                        ]
                    , alt sponsor.name
                    ]
                    []
                ]
    in
    div [ css [ display grid, property "place-items" "center" ] ] (List.map platinumSponsorLogo sponsors)


newsSection : Html msg
newsSection =
    section ""
        [ news
            [ { date = "2025-05-28"
              , label = "スポンサーの募集を締め切りました"
              , url = ""
              }
            , { date = "2025-05-20"
              , label = "当日スタッフの募集を締め切りました"
              , url = ""
              }
            , { date = "2025-04-18"
              , label = "当日スタッフの募集を開始しました"
              , url = "/extra-staff"
              }
            , { date = "2025-04-15"
              , label = "当日のタイムテーブルを公開しました"
              , url = "/schedule"
              }
            , { date = "2025-04-06"
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
                        , ConferenceTicket { category = "学生（懇親会なし）", price = "1,000円" }

                        -- 懇親会チケットは販売終了
                        -- , BothTicket { category = "一般（懇親会あり）", price = "8,000円" }
                        -- , BothTicket { category = "学生（懇親会あり）", price = "6,000円" }
                        -- , PartyTicket { category = "懇親会のみ", price = "5,000円" }
                        ]
                    , -- note "Day 1のセッション終了後には、参加者同士の交流を深める懇親会を予定しております。参加される方は「懇親会あり」のチケットをご購入ください。"
                      note "懇親会チケットの販売は終了しました"
                    , buttonLink
                        { label = "チケットを購入（Doorkeeper）"
                        , url = "https://fp-matsuri.doorkeeper.jp/events/182879"
                        }
                    ]
                ]

        item label contents =
            div [] (h3 [] [ text label ] :: contents)

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
                [ src "https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d6706.437024372982!2d139.6603819160998!3d35.70552369324171!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x6018f34668e0bc27%3A0x7d66caba722762c5!2z5Lit6YeO44K744Oz44OI44Op44Or44OR44O844Kv44Kr44Oz44OV44Kh44Os44Oz44K5!5e0!3m2!1sja!2sjp!4v1745237362764!5m2!1sja!2sjp"
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


sponsorsSection : Int -> Sponsors.Data -> Html msg
sponsorsSection seed sponsorsData =
    section "Sponsors"
        [ div [ class "sponsors", css [ property "display" "contents" ] ] []
        , sponsorLogos seed sponsorsData
        ]



-- 各種スポンサーデータ


type alias Sponsor =
    { name : String
    , image : String
    , href : String
    }


sponsorLogos : Int -> Sponsors.Data -> Html msg
sponsorLogos randomSeed sponsorsData =
    let
        -- Extract sponsors by plan and convert to our display format
        sponsorsFromList list =
            list
                |> List.map
                    (\article ->
                        { name = article.metadata.name
                        , image = article.metadata.id ++ ".png"
                        , href = article.metadata.href
                        }
                    )
                |> Sponsor.shuffle randomSeed
    in
    div
        [ css
            [ width (pct 100)
            , maxWidth (em 43)
            , display grid
            , rowGap (px 40)
            ]
        ]
        [ sponsorPlan "プラチナスポンサー"
            { mobileColumnsCount = 1, desktopColumnWidth = "326px" }
            (sponsorsFromList sponsorsData.platinumSponsors)
        , sponsorPlan "ゴールドスポンサー"
            { mobileColumnsCount = 2, desktopColumnWidth = "222px" }
            (sponsorsFromList sponsorsData.goldSponsors)
        , sponsorPlan "シルバースポンサー"
            { mobileColumnsCount = 3, desktopColumnWidth = "163px" }
            (sponsorsFromList sponsorsData.silverSponsors)
        , sponsorPlan "ロゴスポンサー"
            { mobileColumnsCount = 4, desktopColumnWidth = "116px" }
            (sponsorsFromList sponsorsData.logoSponsors)
        , personalSupporterPlan "応援団"
            { mobileColumnsCount = 4, desktopColumnWidth = "100px" }
            -- .png以外の画像を許容するために、拡張子付与の処理を省略しています
            -- TODO: メタデータにimageプロパティを追加する
            (sponsorsData.personalSupporters
                |> List.map (\{ metadata } -> { name = metadata.name, image = metadata.id, href = metadata.href })
                |> Sponsor.shuffle randomSeed
            )
        , sponsorPlan "協力"
            { mobileColumnsCount = 4, desktopColumnWidth = "116px" }
            (sponsorsFromList sponsorsData.supportSponsors)
        ]


sponsorPlan :
    String
    -> { mobileColumnsCount : Int, desktopColumnWidth : String }
    -> List Sponsor
    -> Html msg
sponsorPlan title { mobileColumnsCount, desktopColumnWidth } sponsors =
    div
        [ css
            [ display grid
            , rowGap (px 20)
            , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                [ rowGap (px 30) ]
            ]
        ]
        [ h3 [ css [ color (rgb 0x66 0x66 0x66) ] ] [ text title ]
        , div
            [ css
                [ display grid
                , rowGap (px 10)
                , columnGap (px 10)
                , justifyContent center
                , gridTemplateColumns (List.repeat mobileColumnsCount (fr 1))
                , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                    [ property "grid-template-columns" ("repeat(auto-fit, " ++ desktopColumnWidth ++ ")") ]
                ]
            ]
            (List.map sponsorLogo sponsors)
        ]


sponsorLogo : Sponsor -> Html msg
sponsorLogo s =
    a
        [ href s.href
        , Attributes.rel "noopener noreferrer"
        , Attributes.target "_blank"
        ]
        [ img
            [ src ("/images/sponsors/" ++ s.image)
            , css
                [ backgroundColor (rgb 255 255 255)
                , borderRadius (px 10)
                , width (pct 100)
                ]
            , alt s.name
            ]
            []
        ]


personalSupporterPlan :
    String
    -> { mobileColumnsCount : Int, desktopColumnWidth : String }
    -> List Sponsor
    -> Html msg
personalSupporterPlan title { mobileColumnsCount, desktopColumnWidth } sponsors =
    let
        isCommunity s =
            List.any ((==) s.image)
                [ "piyopiyo_ex.png"
                , "nerves.png"
                , "fukuokaex.png"
                , "LiveViewJP.png"
                , "ElixirImp.png"
                ]

        listItem s =
            let
                commonWrapperStyles =
                    [ displayFlex
                    , flexDirection column
                    , alignItems center
                    , rowGap (em 0.5)
                    , textAlign center
                    , fontSize (px 10)
                    , property "text-wrap" "balance"
                    , textDecoration none
                    , color inherit
                    ]

                contents =
                    [ img
                        [ src ("/images/sponsors/" ++ s.image)
                        , css
                            (if isCommunity s then
                                [ height (px 40), borderRadius (px 2) ]

                             else
                                [ width (px 40)
                                , height (px 40)
                                , property "object-fit" "cover"
                                , borderRadius (pct 50)
                                , border3 (px 1) solid (hsla 0 0 0 0.05)
                                ]
                            )
                        ]
                        []
                    , text s.name
                    ]
            in
            li []
                [ if s.href == "" then
                    div [ css commonWrapperStyles ] contents

                  else
                    a
                        [ href s.href
                        , Attributes.target "_blank"
                        , rel "noopener noreferrer"
                        , css commonWrapperStyles
                        ]
                        contents
                ]
    in
    div
        [ css
            [ display grid
            , rowGap (px 20)
            , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                [ rowGap (px 30) ]
            ]
        ]
        [ h3 [ css [ color (rgb 0x66 0x66 0x66) ] ] [ text title ]
        , ul
            [ css
                [ margin zero
                , padding zero
                , display grid
                , rowGap (px 20)
                , columnGap (px 10)
                , justifyContent center
                , gridTemplateColumns (List.repeat mobileColumnsCount (fr 1))
                , withMedia [ only screen [ Media.minWidth (px 640) ] ]
                    [ property "grid-template-columns" ("repeat(auto-fit, " ++ desktopColumnWidth ++ ")") ]
                , listStyle none
                ]
            ]
            (List.map listItem sponsors)
        ]


teamSection : Html msg
teamSection =
    let
        listItem member =
            li []
                [ a
                    [ href ("https://github.com/" ++ member.id)
                    , Attributes.target "_blank"
                    , css
                        [ margin zero
                        , padding (rem 0.5)
                        , displayFlex
                        , flexDirection column
                        , alignItems center
                        , rowGap (em 0.5)
                        , textAlign center
                        , fontSize (px 10)
                        , textDecoration none
                        , color inherit
                        , borderRadius (px 10)
                        , border3 (px 1) solid transparent
                        , hover
                            [ backgroundColor (hex "f9f9f9")
                            , borderColor (hex "ddd")
                            ]
                        ]
                    ]
                    [ img
                        [ src ("https://github.com/" ++ member.id ++ ".png")
                        , css
                            [ width (px 40)
                            , height (px 40)
                            , property "object-fit" "cover"
                            , borderRadius (pct 50)
                            , border3 (px 1) solid (hsla 0 0 0 0.05)
                            ]
                        ]
                        []
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
        , Member "omiend"
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


section : String -> List (Html msg) -> Html msg
section title children =
    let
        heading =
            if title == "" then
                text ""

            else
                h2 [] [ text title ]
    in
    Html.section [] (heading :: children)


h3 : List (Attribute msg) -> List (Html msg) -> Html msg
h3 attributes children =
    let
        pseudoDividerStyles =
            [ property "content" (qt "")
            , display block
            , height (px 1)
            , backgroundColor (rgba 30 44 88 0.1)
            ]
    in
    Html.styled Html.h3
        [ margin zero
        , display grid
        , property "grid-template-columns " "1fr max-content 1fr"
        , alignItems center
        , columnGap (em 0.5)
        , whiteSpace noWrap
        , fontSize (px 16)
        , fontWeight normal
        , before pseudoDividerStyles
        , after pseudoDividerStyles
        ]
        attributes
        children


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Browser.Events.onAnimationFrame Tick
