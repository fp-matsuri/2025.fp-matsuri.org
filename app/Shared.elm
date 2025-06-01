module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

{-| <https://elm-pages.com/docs/file-structure#shared.elm>
-}

import BackendTask exposing (BackendTask)
import Css exposing (..)
import Css.Media as Media
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Html exposing (Html)
import Html.Styled exposing (a, br, div, footer, h4, header, img, main_, nav, text)
import Html.Styled.Attributes as Attr exposing (alt, class, css, href, rel, src)
import Html.Styled.Events as Events
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
    , onPageChange = Just onPageChange
    }


type Msg
    = SharedMsg SharedMsg


type alias Data =
    ()


type SharedMsg
    = CloseMenu
    | OpenMenu


type alias Model =
    { menuOpened : Bool }


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
    ( { menuOpened = False }
    , Effect.none
    )


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SharedMsg sharedMsg ->
            case sharedMsg of
                CloseMenu ->
                    ( { model | menuOpened = False }
                    , Effect.none
                    )

                OpenMenu ->
                    ( { model | menuOpened = True }
                    , Effect.none
                    )


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


onPageChange :
    { path : UrlPath
    , query : Maybe String
    , fragment : Maybe String
    }
    -> Msg
onPageChange _ =
    SharedMsg CloseMenu


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


navMenu : (Msg -> msg) -> Bool -> Html.Styled.Html msg
navMenu toMsg menuOpened =
    let
        mediaQueryForMobile =
            Media.withMedia [ Media.only Media.screen [ Media.maxWidth (px 768) ] ]

        mediaQueryForPC =
            Media.withMedia [ Media.only Media.screen [ Media.minWidth (px 769) ] ]

        pcMenuContent =
            nav [ css [ mediaQueryForPC [ Css.displayFlex ], mediaQueryForMobile [ Css.display Css.none ] ] ]
                [ a [ href "/code-of-conduct/" ] [ text "行動規範" ]
                , a [ href "/schedule" ] [ text "スケジュール" ]
                , a [ href "/sponsors" ] [ text "スポンサー" ]
                ]

        hamburger =
            Html.Styled.span
                [ css [ display block, width (px 20), height (px 2), backgroundColor (rgb 0 0 0), margin (px 4) ]
                ]
                []
                |> List.repeat 3

        hamburgerButton =
            Html.Styled.button
                [ Events.onClick (toMsg (SharedMsg OpenMenu))
                , css [ mediaQueryForPC [ Css.display Css.none ], mediaQueryForMobile [ Css.display Css.inlineBlock ] ]
                ]
                hamburger

        withClose =
            Events.onClick (toMsg (SharedMsg CloseMenu))

        sitemap =
            [ div [ class "hr-with-text" ] [ text "サイトマップ" ]
            , div [] [ a [ href "/", withClose ] [ text "トップページ" ] ]
            , div [] [ a [ href "/schedule", withClose ] [ text "スケジュール" ] ]
            , div [] [ a [ href "/sponsors", withClose ] [ text "スポンサー" ] ]
            , div [] [ a [ href "/code-of-conduct/", withClose ] [ text "行動規範" ] ]
            , div [] [ a [ href "https://scalajp.notion.site/19c6d12253aa8068958ee110dbe8d38d", withClose, Attr.target "_blank" ] [ text "お問い合わせ" ] ]
            ]

        accounts =
            [ div [ class "hr-with-text" ] [ text "公式アカウント" ]
            , div [] [ a [ href "https://x.com/fp_matsuri", rel "noopener noreferrer", Attr.target "_blank" ] [ text "X" ] ]
            , div [] [ a [ href "https://bsky.app/profile/fp-matsuri.bsky.social", rel "noopener noreferrer", Attr.target "_blank" ] [ text "Bluesky" ] ]
            , div [] [ a [ href "https://blog.fp-matsuri.org/", rel "noopener noreferrer", Attr.target "_blank" ] [ text "ブログ" ] ]
            , div [] [ a [ href "https://fortee.jp/2025fp-matsuri", rel "noopener noreferrer", Attr.target "_blank" ] [ text "fortee" ] ]
            ]

        hamburgerMenuContents =
            if not menuOpened then
                []

            else
                [ div [ class "menu-overlay", withClose ] []
                , nav
                    [ class "mobile-menu-content"
                    , css [ mediaQueryForPC [ Css.display Css.none ], mediaQueryForMobile [ Css.display Css.block ] ]
                    ]
                    [ div [ class "menu-header" ]
                        [ a [ href "/", withClose ] [ img [ src "/images/logotype.svg", alt "関数型まつり" ] [] ]
                        , div [ class "menu-close-button", withClose ] [ text "✕" ]
                        ]
                    , div [] sitemap
                    , div [] accounts
                    ]
                ]
    in
    div [ class "site-menu" ]
        (pcMenuContent :: hamburgerButton :: hamburgerMenuContents)


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
view _ { route } model toMsg pageView =
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
                , navMenu toMsg model.menuOpened
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
                    , div [] [ a [ href "/schedule" ] [ text "スケジュール" ] ]
                    , div [] [ a [ href "/sponsors" ] [ text "スポンサー" ] ]
                    , div [] [ a [ href "/code-of-conduct/" ] [ text "行動規範" ] ]
                    , div [] [ a [ href "https://scalajp.notion.site/19c6d12253aa8068958ee110dbe8d38d", Attr.target "_blank" ] [ text "お問い合わせ" ] ]
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
