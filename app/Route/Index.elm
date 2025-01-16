module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (Html, div, h1, h2, h3, iframe, p, section, text)
import Html.Attributes exposing (attribute, class, height, src, style)
import Pages.Url
import PagesMsg exposing (PagesMsg)
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    { message : String
    }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.succeed Data
        |> BackendTask.andMap
            (BackendTask.succeed "Hello!")


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = [ "images", "icon-png.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Welcome to elm-pages!"
        , locale = Nothing
        , title = "elm-pages is running"
        }
        |> Seo.website



-- VIEW


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app shared =
    { title = "elm-pages is running"
    , body =
        [ h1 [] [ text "elm-pages is up and running!" ]
        , p []
            [ text <| "The message is: " ++ app.data.message
            ]
        , Route.Blog__Slug_ { slug = "hello" }
            |> Route.link [] [ text "My blog post" ]
        , aboutBlock
        , overviewBlock
        ]
    }


aboutBlock : Html msg
aboutBlock =
    block "About"
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


overviewBlock : Html msg
overviewBlock =
    block "Overview"
        [ div [ class "md:flex flex-wrap justify-between gap-x-8" ]
            [ div [ style "min-width" "18rem" ]
                [ h3 [ class "font-semibold" ] [ text "Dates" ]
                , p [] [ text "2025.6.14(土)〜15(日)" ]
                ]
            , div [ style "min-width" "18rem" ]
                [ h3 [ class "font-semibold" ] [ text "Place" ]
                , p [] [ text "中野セントラルパーク カンファレンス" ]
                ]
            ]
        , iframe
            [ src "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d25918.24822641297!2d139.64379899847268!3d35.707005772578796!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x6018f34668e0bc27%3A0x7d66caba722762c5!2z5Lit6YeO44K744Oz44OI44Op44Or44OR44O844Kv44Kr44Oz44OV44Kh44Os44Oz44K5!5e0!3m2!1sen!2sjp!4v1736684092765!5m2!1sen!2sjp"
            , attribute "width" "100%"
            , height 400
            , style "border" "0"
            , attribute "allowfullscreen" ""
            , attribute "loading" "lazy"
            , attribute "referrerpolicy" "no-referrer-when-downgrade"
            ]
            []
        ]


block : String -> List (Html msg) -> Html msg
block title children =
    let
        heading =
            h2 [] [ text title ]
    in
    section [] (heading :: children)
