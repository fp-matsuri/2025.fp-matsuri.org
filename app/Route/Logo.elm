module Route.Logo exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Head.Seo
import Html exposing (div)
import Html.Attributes exposing (attribute, class)
import PagesMsg exposing (PagesMsg)
import Random exposing (Generator)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import Site
import Svg exposing (Svg, defs, g, linearGradient, path, rect, stop, svg)
import Svg.Attributes exposing (d, fill, gradientTransform, height, id, offset, rx, stopColor, transform, viewBox, width, x, y)
import View exposing (View)


type alias RouteParams =
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



-- MODEL


type alias Model =
    { gradients : List ( String, String ) }


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( { gradients = [] }
    , Random.generate NewGradients (Random.list 20 gradientGenerator)
        |> Effect.fromCmd
    )


gradientGenerator : Generator ( String, String )
gradientGenerator =
    Random.pair colorGerenator colorGerenator


colorGerenator : Generator String
colorGerenator =
    Random.map3
        (\r g b -> "hsl(" ++ String.fromInt r ++ " " ++ String.fromInt g ++ "% " ++ String.fromInt b ++ "%)")
        (Random.int 0 359)
        (Random.int 0 100)
        (Random.int 25 90)



-- UPDATE


type Msg
    = NewGradients (List ( String, String ))


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        NewGradients gradients ->
            ( { model | gradients = gradients }, Effect.none )



-- DATA


type alias Data =
    {}


type alias ActionData =
    {}


data : BackendTask FatalError Data
data =
    BackendTask.succeed Data


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head _ =
    Site.summaryLarge { pageTitle = "" }
        |> Head.Seo.website



-- VIEW


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view _ _ model =
    { title = ""
    , body =
        [ div [ class "logo-study" ]
            (List.indexedMap logoMark model.gradients)
        ]
    }


logoMark : Int -> ( String, String ) -> Svg msg
logoMark index ( color1, color2 ) =
    let
        id_ =
            "id_" ++ String.fromInt index

        clipPath =
            Svg.clipPath [ id "logo_outline" ]
                [ path [ d "M0 50C0 22.3858 22.3858 0 50 0V50H0Z" ] []
                , rect [ width "50", height "50", transform "translate(50)" ] []
                , rect [ width "50", height "50", transform "translate(150)" ] []
                , rect [ width "50", height "50", transform "translate(0 50)" ] []
                , rect [ width "50", height "50", transform "translate(100 50)" ] []
                , rect [ x "200", y "50", width "50", height "50", rx "25" ] []
                , rect [ width "50", height "50", transform "translate(0 100)" ] []
                , rect [ width "50", height "50", transform "translate(50 100)" ] []
                , rect [ width "50", height "50", transform "translate(150 100)" ] []
                , rect [ width "50", height "50", transform "translate(0 150)" ] []
                , rect [ width "50", height "50", transform "translate(100 150)" ] []
                ]

        gradient =
            linearGradient [ id ("gradient_" ++ id_), gradientTransform "rotate(45)" ]
                [ stop [ offset "0%", stopColor color1 ] []
                , stop [ offset "100%", stopColor color2 ] []
                ]
    in
    svg [ width "125", height "100", viewBox "0 0 250 200", attribute "xmlns" "http://www.w3.org/2000/svg" ]
        [ defs [] [ clipPath, gradient ]
        , g [ Svg.Attributes.clipPath "url(#logo_outline)", fill ("url(#gradient_" ++ id_ ++ ")") ]
            [ rect [ width "250", height "200" ] [] ]
        ]
