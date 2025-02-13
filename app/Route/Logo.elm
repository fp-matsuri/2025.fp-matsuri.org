module Route.Logo exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Effect exposing (Effect)
import FPMatsuri.Logo as FPMatsuri
import FatalError exposing (FatalError)
import Head
import Head.Seo
import Html exposing (div)
import Html.Attributes exposing (class)
import PagesMsg exposing (PagesMsg)
import Random exposing (Generator)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import Site
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
        (Random.int 50 100)
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
            (List.indexedMap FPMatsuri.logoMark model.gradients)
        ]
    }
