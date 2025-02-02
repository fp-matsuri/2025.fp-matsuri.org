module Route.Slug_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import BackendTask.Glob as Glob
import FatalError exposing (FatalError)
import Head
import Head.Seo
import Html exposing (Html, a, div, figure, h2, iframe, section, text)
import Html.Attributes exposing (attribute, class, height, href, src, target, width)
import Json.Decode as Decode exposing (Decoder)
import Markdown.Block exposing (Block)
import Markdown.Renderer
import MarkdownCodec
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
    { slug : String }


type alias Data =
    { metadata : ArticleMetadata
    , body : List Block
    }


type alias ArticleMetadata =
    { title : String }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRender { data = data, head = head, pages = pages }
        |> RouteBuilder.buildNoState { view = view }


pages : BackendTask FatalError (List RouteParams)
pages =
    pagesGlob
        |> BackendTask.map
            (List.map
                (\globData ->
                    { slug = globData.slug }
                )
            )


pagesGlob : BackendTask.BackendTask error (List Page)
pagesGlob =
    Glob.succeed Page
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toBackendTask


type alias Page =
    { filePath : String
    , slug : String
    }


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    MarkdownCodec.withFrontmatter Data
        frontmatterDecoder
        Markdown.Renderer.defaultHtmlRenderer
        ("content/" ++ routeParams.slug ++ ".md")


frontmatterDecoder : Decoder ArticleMetadata
frontmatterDecoder =
    Decode.map ArticleMetadata
        (Decode.field "title" Decode.string)


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
view app shared =
    let
        metadata =
            app.data.metadata
    in
    { title = metadata.title
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
        , section [ class "coc" ]
            [ div []
                (app.data.body
                    |> Markdown.Renderer.render Markdown.Renderer.defaultHtmlRenderer
                    |> Result.withDefault []
                )
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
