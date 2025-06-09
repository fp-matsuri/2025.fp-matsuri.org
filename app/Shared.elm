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
            , socialLink False X "https://x.com/fp_matsuri"
            , socialLink False Bluesky "https://bsky.app/profile/fp-matsuri.bsky.social"
            , socialLink False Blog "https://blog.fp-matsuri.org/"
            , socialLink False Fortee "https://fortee.jp/2025fp-matsuri"
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
                        [ a [ href "/", withClose ] [ img [ src "/images/logo_horizontal.svg", alt "関数型まつり" ] [] ]
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
                    [ img [ src "/images/logo_horizontal.svg", alt "関数型まつり" ] []
                    ]
                , navMenu toMsg model.menuOpened
                ]
            , main_ [] pageView.body
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
                    , socialLink True X "https://x.com/fp_matsuri"
                    , socialLink True Bluesky "https://bsky.app/profile/fp-matsuri.bsky.social"
                    , socialLink True Blog "https://blog.fp-matsuri.org/"
                    , socialLink True Fortee "https://fortee.jp/2025fp-matsuri"
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



-- SNS


type SNS
    = X
    | Bluesky
    | Blog
    | Fortee


snsToString : SNS -> String
snsToString sns =
    case sns of
        X ->
            "X"

        Bluesky ->
            "Bluesky"

        Blog ->
            "ブログ"

        Fortee ->
            "fortee"


snsIcon : Bool -> SNS -> Html.Styled.Html msg
snsIcon isInverted sns =
    let
        iconStyles =
            [ property "justify-self" "center"
            , if isInverted then
                property "filter" "invert(100%) sepia(1%) saturate(2%) hue-rotate(141deg) brightness(113%) contrast(100%)"

              else
                property "filter" "invert(9%) sepia(41%) saturate(1096%) hue-rotate(151deg) brightness(94%) contrast(88%);"
            ]
    in
    case sns of
        X ->
            img
                [ src "/images/x.svg"
                , alt (snsToString sns)
                , css [ batch iconStyles, width (pct 80) ]
                ]
                []

        Bluesky ->
            img
                [ src "/images/bluesky.svg"
                , alt (snsToString sns)
                , css [ batch iconStyles, width (pct 90) ]
                ]
                []

        Blog ->
            img
                [ src "/images/hatenablog.svg"
                , alt (snsToString sns)
                , css [ batch iconStyles, width (pct 145) ]
                ]
                []

        Fortee ->
            img
                [ src "/images/fortee.svg"
                , alt (snsToString sns)
                , css [ batch iconStyles, width (pct 90) ]
                ]
                []


socialLink : Bool -> SNS -> String -> Html.Styled.Html msg
socialLink isInverted sns url =
    a
        [ href url
        , Attr.target "_blank"
        , rel "noopener noreferrer"
        , css
            [ padding (rem 0.5)
            , property "display" "grid" |> Css.important
            , property "grid-template-columns" "1em 1fr"
            , alignItems center
            , property "column-gap" "0.5em"
            , lineHeight (num 1)
            , textDecoration none
            , color inherit
            ]
        ]
        [ snsIcon isInverted sns
        , text (snsToString sns)
        ]
