module Route.Sponsors exposing (ActionData, Data, Model, Msg, data, route)

import BackendTask exposing (BackendTask)
import BackendTask.Glob as Glob
import Css exposing (..)
import Css.Extra exposing (columnGap, grid, paddingBlock, rowGap)
import Css.Global
import Css.Media as Media exposing (only, screen, withMedia)
import Data.Sponsor as Sponsor exposing (IframeData(..), Plan(..), SponsorArticle, metadataDecoder, planToBadge)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Head.Seo
import Html as PlainHtml
import Html.Attributes as PlainAttributes
import Html.Styled as Html exposing (Html, a, aside, div, iframe, img, text)
import Html.Styled.Attributes as Attributes exposing (alt, attribute, class, css, href, src)
import Json.Decode as Decode
import Markdown.Block exposing (Block)
import Markdown.Html
import Markdown.Renderer exposing (Renderer)
import PagesMsg exposing (PagesMsg)
import Plugin.MarkdownCodec
import Random
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import Site
import Svg.Styled.Attributes exposing (style)
import View exposing (View)


type alias Model =
    { seed : Int }


type Msg
    = GotRandomSeed Int


type alias RouteParams =
    {}


type alias Data =
    { platinumSponsors : List SponsorArticle
    , goldSponsors : List SponsorArticle
    , silverSponsors : List SponsorArticle
    , logoSponsors : List SponsorArticle
    , supportSponsors : List SponsorArticle
    , personalSupporters : List SponsorArticle
    }


type alias ActionData =
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


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( { seed = 0 }
    , Effect.fromCmd (Random.generate GotRandomSeed (Random.int 0 100))
    )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        GotRandomSeed newSeed ->
            ( { model | seed = newSeed }, Effect.none )


data : BackendTask FatalError Data
data =
    sponsorsData


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head _ =
    Site.summaryLarge { pageTitle = "スポンサー" }
        |> Head.Seo.website



-- DATA


{-| スポンサーデータを取得します。
各プランごとに別々にディレクトリからデータを取得し、それぞれ格納します。
-}
sponsorsData : BackendTask FatalError Data
sponsorsData =
    BackendTask.map6 Data
        (getSponsorsByPlan "platinum")
        (getSponsorsByPlan "gold")
        (getSponsorsByPlan "silver")
        (getSponsorsByPlan "logo")
        (getSponsorsByPlan "support")
        (getSponsorsByPlan "personal_supporter")


processSponsorFile : { filePath : String, slug : String } -> BackendTask FatalError SponsorArticle
processSponsorFile d =
    Plugin.MarkdownCodec.withFrontmatter SponsorArticle
        metadataDecoder
        customizedHtmlRenderer
        d.filePath
        |> BackendTask.mapError
            (\codecError ->
                case codecError of
                    Plugin.MarkdownCodec.FileDoesNotExist ->
                        FatalError.fromString ("Sponsor file not found: " ++ d.filePath)

                    Plugin.MarkdownCodec.FileReadFailure msg ->
                        FatalError.fromString ("Internal error processing sponsor file: " ++ d.filePath ++ " - " ++ msg)

                    Plugin.MarkdownCodec.FrontmatterDecodingFailure decodeError ->
                        FatalError.fromString ("Frontmatter decoding error in sponsor file: " ++ d.filePath ++ " - " ++ Decode.errorToString decodeError)

                    Plugin.MarkdownCodec.MarkdownProcessingFailure fatalError ->
                        fatalError
            )


{-| プラン名からスポンサー記事リストを取得して処理する
-}
getSponsorsByPlan : String -> BackendTask FatalError (List SponsorArticle)
getSponsorsByPlan planName =
    sponsorFilesByPlan planName
        |> BackendTask.andThen
            (\files ->
                files
                    |> List.map
                        processSponsorFile
                    |> BackendTask.combine
            )
        |> BackendTask.map (List.sortBy (.metadata >> .postedAt))


{-| 指定されたプランのスポンサーMarkdownファイルを取得するためのBackendTask
-}
sponsorFilesByPlan : String -> BackendTask FatalError (List { filePath : String, slug : String })
sponsorFilesByPlan planName =
    Glob.succeed (\f s -> { filePath = f, slug = s })
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal ("content/sponsors/" ++ planName ++ "/"))
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toBackendTask



-- VIEW


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view d _ model =
    { title = "スポンサー"
    , body =
        [ Html.section
            [ css
                [ withMedia [ only screen [ Media.minWidth (px 1024) ] ]
                    [ margin2 zero auto
                    , display grid
                    , property "grid-template-columns" "19em 35em"
                    , justifyContent center
                    , alignItems start
                    , columnGap (em 5)
                    ]
                ]
            ]
            [ div
                [ css
                    [ withMedia [ only screen [ Media.minWidth (px 1024) ] ]
                        [ position sticky
                        , top (rem 2)
                        ]
                    ]
                ]
                [ tableOfContents model.seed d.data ]
            , sponsorsSection model.seed d.data
            ]
        ]
    }


tableOfContents : Int -> Data -> Html msg
tableOfContents seed pageData =
    let
        sponsorGroups =
            [ ( "プラチナスポンサー", pageData.platinumSponsors |> List.filter (\s -> s.body /= []) |> Sponsor.shuffle seed )
            , ( "ゴールドスポンサー", pageData.goldSponsors |> List.filter (\s -> s.body /= []) |> Sponsor.shuffle seed )
            , ( "シルバースポンサー", pageData.silverSponsors |> List.filter (\s -> s.body /= []) |> Sponsor.shuffle seed )
            ]
                |> List.filter (\( _, sponsors ) -> not (List.isEmpty sponsors))

        tocItem sponsor =
            a
                [ href ("#" ++ sponsor.metadata.id)
                , css
                    [ display block
                    , paddingBlock (px 4)
                    , textDecoration none
                    , hover [ textDecoration underline ]
                    , fontSize (px 14)
                    ]
                ]
                [ text sponsor.metadata.name ]

        tocGroup ( planName, sponsors ) =
            div [ css [ display grid, rowGap (em 0.5) ] ]
                [ div [ css [ fontSize (px 16), fontWeight bold, color (rgb 68 68 68) ] ]
                    [ text planName ]
                , div [] (List.map tocItem sponsors)
                ]
    in
    aside
        [ css
            [ padding (em 1.5)
            , display grid
            , rowGap (em 1)
            , borderRadius (px 8)
            , backgroundColor (rgb 248 249 250)
            ]
        ]
        (List.map tocGroup sponsorGroups)


sponsorsSection : Int -> Data -> Html msg
sponsorsSection seed pageData =
    div
        []
        (List.map
            (\f ->
                div
                    [ css
                        [ paddingBlock (px 40)
                        , borderTop3 (px 5) solid (rgb 246 246 246)
                        ]
                    , Attributes.id f.metadata.id
                    ]
                    [ div [ css [ marginBottom (px 30), textAlign center ] ]
                        [ sponsorLogo f.metadata.id f.metadata.name ]
                    , div []
                        [ div [] [ planToBadge f.metadata.plan ]
                        , div
                            [ css
                                [ marginTop (px 15)
                                , fontSize (px 28)
                                ]
                            ]
                            [ text f.metadata.name ]
                        , div
                            [ css [ marginTop (px 20) ], class "markdown-html-workaround" ]
                            (sponsorBody customizedHtmlRenderer f.body)
                        , div
                            [ css [ marginTop (px 40) ] ]
                            (f.metadata.iframe
                                |> Maybe.map (List.map sponsorIframe)
                                |> Maybe.withDefault []
                            )
                        ]
                    ]
            )
            ([ pageData.platinumSponsors
             , pageData.goldSponsors
             , pageData.silverSponsors
             ]
                |> List.map (List.filter (\s -> s.body /= []) >> Sponsor.shuffle seed)
                |> List.concat
            )
        )


sponsorLogo : String -> String -> Html msg
sponsorLogo image name =
    img
        [ src ("/images/sponsors/" ++ image ++ ".png")
        , css
            [ backgroundColor (rgb 255 255 255)
            , borderRadius (px 10)
            , width (pct 100)
            , maxWidth (px 250)
            ]
        , alt name
        ]
        []


sponsorBody : Markdown.Renderer.Renderer (PlainHtml.Html msg) -> List Block -> List (Html msg)
sponsorBody renderer body =
    body
        |> Markdown.Renderer.render renderer
        |> Result.map
            (List.map
                (\x ->
                    Html.div
                        [ css
                            [ Css.Global.descendants
                                [ Css.Global.selector "iframe"
                                    [ maxWidth (pct 100)
                                    , width (pct 100)
                                    , property "aspect-ratio" "16 / 9"
                                    , height auto
                                    ]
                                ]
                            ]
                        ]
                        [ Html.fromUnstyled x ]
                )
            )
        |> (\r ->
                case r of
                    Err e ->
                        [ text e ]

                    Ok m ->
                        m
           )


sponsorIframe : IframeData -> Html msg
sponsorIframe iframeData =
    case iframeData of
        SpeakerDeck value ->
            iframe
                [ class "speakerdeck-iframe"
                , attribute "frameborder" "0"
                , src ("https://speakerdeck.com/player/" ++ value)
                , style "border: 0px; background: padding-box padding-box rgba(0, 0, 0, 0.1); margin: 0px; padding: 0px; border-radius: 6px; width: 100%; height: auto; aspect-ratio: 560 / 315;"
                , attribute "data-ratio" "1.7777777777777777"
                , attribute "allowfullscreen" "true"
                ]
                []


{-| スポンサー記事のmarkdownからHTMLに変換するためのRendererです。

Slug\_.mdにあるcustomizedHtmlRendererとほぼ同じですが、以下が異なります。

  - いくつかの対応タグの追加
  - importのコンフリクトよけのためPlain〜という名前を使用

-}
customizedHtmlRenderer : Renderer (PlainHtml.Html msg)
customizedHtmlRenderer =
    let
        renderer =
            Markdown.Renderer.defaultHtmlRenderer
    in
    { renderer
        | link =
            \{ title, destination } children ->
                let
                    externalLinkAttrs =
                        -- Markdown記法で記述されたリンクについて、参照先が外部サイトであれば新しいタブで開くようにする
                        if isExternalLink destination then
                            [ PlainAttributes.target "_blank", PlainAttributes.rel "noopener" ]

                        else
                            []

                    isExternalLink url =
                        let
                            isProduction =
                                String.startsWith url "https://2025.fp-matsuri.org"

                            isLocalDevelopment =
                                String.startsWith url "/"
                        in
                        not (isProduction || isLocalDevelopment)

                    titleAttrs =
                        title
                            |> Maybe.map (\title_ -> [ PlainAttributes.title title_ ])
                            |> Maybe.withDefault []
                in
                PlainHtml.a (PlainAttributes.href destination :: externalLinkAttrs ++ titleAttrs) children
        , html =
            Markdown.Html.oneOf
                -- Markdown記述の中でHTMLの使用を許可する場合には、この部分にタグを指定する。
                [ -- iframe: 行動規範ページに埋め込まれたYouTube動画を想定
                  Markdown.Html.tag "iframe"
                    (\class_ width_ height_ src_ frameborder_ allow_ allowfullscreen_ children ->
                        PlainHtml.iframe
                            [ PlainAttributes.class class_
                            , PlainAttributes.attribute "width" width_
                            , PlainAttributes.attribute "height" height_
                            , PlainAttributes.src src_
                            , PlainAttributes.attribute "frameborder" frameborder_
                            , PlainAttributes.attribute "allow" allow_
                            , PlainAttributes.attribute "allowfullscreen" allowfullscreen_
                            ]
                            children
                    )
                    |> Markdown.Html.withAttribute "class"
                    |> Markdown.Html.withAttribute "width"
                    |> Markdown.Html.withAttribute "height"
                    |> Markdown.Html.withAttribute "src"
                    |> Markdown.Html.withAttribute "frameborder"
                    |> Markdown.Html.withAttribute "allow"
                    |> Markdown.Html.withAttribute "allowfullscreen"

                -- スポンサー記事向けに追加
                , Markdown.Html.tag "h3" (\children -> PlainHtml.h3 [] children)
                , Markdown.Html.tag "p" (\children -> PlainHtml.p [] children)
                , Markdown.Html.tag "b" (\children -> PlainHtml.b [] children)
                , Markdown.Html.tag "li" (\children -> PlainHtml.li [] children)
                , Markdown.Html.tag "ul" (\children -> PlainHtml.ul [] children)
                , Markdown.Html.tag "br" (\children -> PlainHtml.br [] children)
                , Markdown.Html.tag "a"
                    (\href_ children ->
                        PlainHtml.a
                            [ PlainAttributes.href href_
                            , PlainAttributes.target "_blank"
                            , PlainAttributes.rel "noopener"
                            ]
                            children
                    )
                    |> Markdown.Html.withAttribute "href"
                , Markdown.Html.tag "strong" (\children -> PlainHtml.strong [] children)
                ]
    }
