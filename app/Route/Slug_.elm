module Route.Slug_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import BackendTask.Glob as Glob
import FatalError exposing (FatalError)
import Head
import Head.Seo
import Html exposing (Html, div, iframe, section)
import Html.Attributes exposing (attribute, class, src)
import Json.Decode as Decode exposing (Decoder)
import Markdown.Block exposing (Block)
import Markdown.Html
import Markdown.Renderer exposing (Renderer)
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
    Plugin.MarkdownCodec.withFrontmatter Data
        frontmatterDecoder
        customizedHtmlRenderer
        ("content/" ++ routeParams.slug ++ ".md")


frontmatterDecoder : Decoder ArticleMetadata
frontmatterDecoder =
    Decode.map ArticleMetadata
        (Decode.field "title" Decode.string)


customizedHtmlRenderer : Renderer (Html msg)
customizedHtmlRenderer =
    Markdown.Renderer.defaultHtmlRenderer
        |> (\renderer ->
                { renderer
                    | html =
                        Markdown.Html.oneOf
                            [ Markdown.Html.tag "iframe"
                                (\class_ width_ height_ src_ frameborder_ allow_ allowfullscreen_ children ->
                                    iframe
                                        [ class class_
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
view app shared =
    let
        metadata =
            app.data.metadata
    in
    { title = metadata.title
    , body =
        [ section [ class "coc" ]
            [ div []
                (app.data.body
                    |> Markdown.Renderer.render customizedHtmlRenderer
                    |> Result.withDefault []
                )
            ]
        ]
    }
