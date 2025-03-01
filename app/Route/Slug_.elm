module Route.Slug_ exposing (ActionData, Data, Model, Msg, data, pages, route)

{-|

    ルート直下に配置されたMarkdownファイルを元に、ページ生成するためのモジュールです
    2025年2月時点では「行動規範」ページが該当します

-}

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo
import Html exposing (Html, a, iframe)
import Html.Attributes exposing (attribute, href, rel, src, target)
import Html.Styled exposing (div, section)
import Html.Styled.Attributes exposing (class)
import Markdown.Block exposing (Block)
import Markdown.Html
import Markdown.Renderer exposing (Renderer)
import Page exposing (Metadata)
import PagesMsg exposing (PagesMsg)
import Plugin.MarkdownCodec
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Site
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { slug : String }


{-| elm-pagesがこのページのBackendTaskを実行した結果を格納するための型
2025年2月時点では、Markdownファイルの metadata と body が含まれます
-}
type alias Data =
    { metadata : Metadata
    , body : List Block
    }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRender { data = data, head = head, pages = pages }
        |> RouteBuilder.buildNoState { view = view }


pages : BackendTask FatalError (List RouteParams)
pages =
    Page.pagesGlob
        |> BackendTask.map
            (List.map
                (\globData ->
                    { slug = globData.slug }
                )
            )


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    Plugin.MarkdownCodec.withFrontmatter Data
        Page.frontmatterDecoder
        customizedHtmlRenderer
        ("content/" ++ routeParams.slug ++ ".md")


customizedHtmlRenderer : Renderer (Html msg)
customizedHtmlRenderer =
    Markdown.Renderer.defaultHtmlRenderer
        |> (\renderer ->
                { renderer
                    | link =
                        \{ title, destination } children ->
                            let
                                externalLinkAttrs =
                                    -- Markdown記法で記述されたリンクについて、参照先が外部サイトであれば新しいタブで開くようにする
                                    if isExternalLink destination then
                                        [ target "_blank", rel "noopener" ]

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
                                        |> Maybe.map (\title_ -> [ Html.Attributes.title title_ ])
                                        |> Maybe.withDefault []
                            in
                            a (href destination :: externalLinkAttrs ++ titleAttrs) children
                    , html =
                        Markdown.Html.oneOf
                            -- Markdown記述の中でHTMLの使用を許可する場合には、この部分にタグを指定する。
                            [ -- iframe: 行動規範ページに埋め込まれたYouTube動画を想定
                              Markdown.Html.tag "iframe"
                                (\class_ width_ height_ src_ frameborder_ allow_ allowfullscreen_ children ->
                                    iframe
                                        [ Html.Attributes.class class_
                                        , attribute "width" width_
                                        , attribute "height" height_
                                        , src src_
                                        , attribute "frameborder" frameborder_
                                        , attribute "allow" allow_
                                        , attribute "allowfullscreen" allowfullscreen_
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
                            ]
                }
           )


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    let
        metadata =
            app.data.metadata
    in
    Site.summaryLarge { pageTitle = metadata.title }
        |> Head.Seo.website



-- VIEW


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app _ =
    let
        metadata =
            app.data.metadata
    in
    { title = metadata.title
    , body =
        [ section [ class "coc" ]
            [ div [ class "markdown" ]
                (app.data.body
                    |> Markdown.Renderer.render customizedHtmlRenderer
                    |> Result.map (List.map Html.Styled.fromUnstyled)
                    |> Result.withDefault []
                )
            ]
        ]
    }
