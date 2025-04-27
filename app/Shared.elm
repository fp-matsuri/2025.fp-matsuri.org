module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

{-| <https://elm-pages.com/docs/file-structure#shared.elm>
-}

import BackendTask exposing (BackendTask)
import Css exposing (..)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Html exposing (Html)
import Html.Styled exposing (a, br, div, footer, h4, header, img, main_, nav, text)
import Html.Styled.Attributes as Attr exposing (alt, class, css, href, rel, src)
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import UrlPath exposing (UrlPath)
import View exposing (View)


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Nothing
    }


type Msg
    = SharedMsg SharedMsg


type alias Data =
    ()


type SharedMsg
    = NoOp


type alias Model =
    {}


init :
    Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : UrlPath
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Effect Msg )
init _ _ =
    ( {}, Effect.none )


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SharedMsg _ ->
            ( model, Effect.none )


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


view :
    Data
    ->
        { path : UrlPath
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : List (Html msg), title : String }
view _ { route } _ _ pageView =
    { body =
        List.map Html.Styled.toUnstyled
            [ header [ class "site-header" ]
                [ a [ class "site-logo", href "/" ]
                    [ img
                        [ src "/images/logotype.svg"
                        , alt "関数型まつり"
                        ]
                        []
                    ]
                , nav []
                    [ a [ href "/code-of-conduct/" ] [ text "行動規範" ]
                    , a [ href "/schedule" ] [ text "スケジュール" ]
                    , a [ href "/sponsors" ] [ text "スポンサー" ]
                    ]
                ]
            , main_
                [ css
                    [ case route of
                        Just Route.Index ->
                            padding zero

                        _ ->
                            padding3 zero (px 15) (px 30)
                    ]
                ]
                pageView.body
            , footer [ class "site-footer" ]
                [ nav []
                    [ h4 [] [ text "サイトマップ" ]
                    , div [] [ a [ href "/" ] [ text "トップページ" ] ]
                    , div [] [ a [ href "/sponsors" ] [ text "スポンサー" ] ]
                    , div [] [ a [ href "/code-of-conduct/" ] [ text "行動規範" ] ]
                    , br [] []
                    , h4 [] [ text "公式アカウント" ]
                    , div [] [ a [ href "https://x.com/fp_matsuri", rel "noopener noreferrer", Attr.target "_blank" ] [ text "X" ] ]
                    , div [] [ a [ href "https://bsky.app/profile/fp-matsuri.bsky.social", rel "noopener noreferrer", Attr.target "_blank" ] [ text "Bluesky" ] ]
                    , div [] [ a [ href "https://blog.fp-matsuri.org/", rel "noopener noreferrer", Attr.target "_blank" ] [ text "ブログ" ] ]
                    , div [] [ a [ href "https://fortee.jp/2025fp-matsuri", rel "noopener noreferrer", Attr.target "_blank" ] [ text "fortee" ] ]
                    , br [] []
                    ]
                , text "© 2025 関数型まつり準備委員会"
                ]
            ]
    , title =
        if pageView.title /= "" then
            pageView.title ++ " | 関数型まつり"

        else
            "関数型まつり"
    }
