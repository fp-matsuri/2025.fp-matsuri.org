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
import Site
import Sitemap


routes :
    BackendTask FatalError (List Route)
    -> (Maybe { indent : Int, newLines : Bool } -> Html Never -> String)
    -> List (ApiRoute ApiRoute.Response)
routes getStaticRoutes htmlToString =
    [ sitemap <| makeSitemapEntries getStaticRoutes ]



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
