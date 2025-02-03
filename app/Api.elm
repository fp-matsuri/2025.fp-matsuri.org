module Api exposing (routes)

{-| elm-pages でのビルド時に実行されるAPIの定義
-}

import ApiRoute exposing (ApiRoute)
import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Html exposing (Html)
import Iso8601
import Pages
import Route exposing (Route(..))
import Route.Slug_ as Route__slug_
import Rss
import Site
import Sitemap


routes :
    BackendTask FatalError (List Route)
    -> (Maybe { indent : Int, newLines : Bool } -> Html Never -> String)
    -> List (ApiRoute ApiRoute.Response)
routes getStaticRoutes htmlToString =
    [ -- rss <| BackendTask.map (List.map makeArticleRssItem) builtPages
      sitemap <| makeSitemapEntries getStaticRoutes
    ]



-- RSS


rss : BackendTask FatalError (List Rss.Item) -> ApiRoute.ApiRoute ApiRoute.Response
rss itemsSource =
    ApiRoute.succeed
        (itemsSource
            |> BackendTask.map
                (\items ->
                    Rss.generate
                        { title = Site.eventName
                        , description = Site.tagline
                        , url = Site.config.canonicalUrl ++ "/"
                        , lastBuildTime = Pages.builtAt
                        , generator = Just "elm-pages"
                        , items = items
                        , siteUrl = Site.config.canonicalUrl
                        }
                )
        )
        |> ApiRoute.literal "feed.xml"
        |> ApiRoute.single


type alias BuiltPage =
    ( Route, Route__slug_.Data )


makeArticleRssItem : BuiltPage -> Rss.Item
makeArticleRssItem ( route, page ) =
    { title = page.metadata.title
    , description = "article.body.excerpt"
    , url = String.join "/" (Route.routeToPath route)
    , categories = []
    , author = "関数型まつり"
    , pubDate = Rss.DateTime Pages.builtAt
    , content = Nothing
    , contentEncoded = Nothing
    , enclosure = Nothing
    }


builtPages : BackendTask FatalError (List BuiltPage)
builtPages =
    let
        build routeParam =
            Route__slug_.data routeParam
                |> BackendTask.map (Tuple.pair (Route.Slug_ routeParam))
    in
    Route__slug_.pages
        |> BackendTask.map (List.map build)
        |> BackendTask.resolve
        |> BackendTask.map identity



-- SITEMAP


sitemap :
    BackendTask FatalError (List Sitemap.Entry)
    -> ApiRoute.ApiRoute ApiRoute.Response
sitemap entriesSource =
    ApiRoute.succeed
        (entriesSource
            |> BackendTask.map
                (\entries ->
                    [ """<?xml version="1.0" encoding="UTF-8"?>"""
                    , Sitemap.build { siteUrl = Site.config.canonicalUrl } entries
                    ]
                        |> String.join "\n"
                )
        )
        |> ApiRoute.literal "sitemap.xml"
        |> ApiRoute.single


makeSitemapEntries : BackendTask FatalError (List Route) -> BackendTask FatalError (List Sitemap.Entry)
makeSitemapEntries getStaticRoutes =
    let
        build route =
            let
                routeSource lastMod =
                    BackendTask.succeed
                        { path = String.join "/" (Route.routeToPath route)
                        , lastMod = Just lastMod
                        }
            in
            case route of
                Slug_ routeParam ->
                    Route__slug_.data routeParam
                        |> BackendTask.andThen (\data -> routeSource (Iso8601.fromTime Pages.builtAt))
                        |> Just

                Index ->
                    Just <| routeSource <| Iso8601.fromTime <| Pages.builtAt
    in
    getStaticRoutes
        |> BackendTask.map (List.filterMap build)
        |> BackendTask.resolve
