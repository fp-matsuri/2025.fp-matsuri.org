module Route.Schedule exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import BackendTask.Http
import Css exposing (..)
import Css.Extra exposing (fr, gap, grid, gridTemplateColumns)
import FatalError exposing (FatalError)
import Head
import Head.Seo
import Html.Styled as Html exposing (Html, div, h1, text)
import Html.Styled.Attributes exposing (css)
import Json.Decode as Decode exposing (Decoder, bool, field, maybe, nullable, string)
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
    {}


type alias Data =
    { timetable : List TimetableItem }


type alias TimetableItem =
    { --  type_ : String
      uuid : String
    , url : Maybe String
    , title : String

    -- , abstract : Maybe String
    -- , accepted : Maybe Bool
    , tags : Maybe (List Tag)
    , speaker : Maybe Speaker
    , track : Maybe Track
    , startsAt : Maybe String
    , lengthMin : Maybe Int
    }


type alias Tag =
    { name : String
    , colorText : String
    , colorBackground : String
    }


type alias Speaker =
    { name : String
    , kana : String
    , twitter : Maybe String
    , avatarUrl : Maybe String
    }


type alias Track =
    { name : String, sort : Int }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.Http.getJson "https://fortee.jp/2025fp-matsuri/api/timetable"
        (Decode.map Data (Decode.field "timetable" (Decode.list timetableItemDecoder)))
        |> BackendTask.onError (\_ -> BackendTask.succeed { timetable = [] })


timetableItemDecoder : Decoder TimetableItem
timetableItemDecoder =
    Decode.map8 TimetableItem
        -- (field "type" string)
        (field "uuid" string)
        (maybe (field "url" string))
        (field "title" string)
        -- (field "abstract" (nullable string))
        -- (maybe (field "accepted" bool))
        (maybe (field "tags" (Decode.list tagDecoder)))
        (maybe (field "speaker" speakerDecoder))
        (maybe (field "track" trackDecoder))
        (maybe (field "starts_at" string))
        (maybe (field "length_min" Decode.int))


tagDecoder : Decoder Tag
tagDecoder =
    Decode.map3 Tag
        (field "name" string)
        (field "color_text" string)
        (field "color_background" string)


speakerDecoder : Decoder Speaker
speakerDecoder =
    Decode.map4 Speaker
        (field "name" string)
        (field "kana" string)
        (maybe (field "twitter" string))
        (maybe (field "avatar_url" string))


trackDecoder : Decoder Track
trackDecoder =
    Decode.map2 Track
        (field "name" string)
        (field "sort" Decode.int)


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Site.summaryLarge { pageTitle = "開催スケジュール" }
        |> Head.Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg ())
view app _ =
    { title = "開催スケジュール"
    , body =
        [ div
            [ css
                [ Css.maxWidth (Css.px 800)
                , Css.margin2 Css.zero Css.auto
                ]
            ]
            [ h1 [ css [ Css.marginBottom (Css.px 32) ] ]
                [ text "開催スケジュール" ]
            , div
                [ css
                    [ display grid
                    , gridTemplateColumns [ fr 1, fr 1, fr 1 ]
                    , gap (px 10)
                    ]
                ]
                (List.map viewTimetableItem app.data.timetable)
            ]
        ]
    }


viewTimetableItem : TimetableItem -> Html msg
viewTimetableItem timetableItem =
    div
        [ css
            [ padding (px 10)
            , borderRadius (px 10)
            , fontSize (px 14)
            , property "background-color" "var(--color-grey095)"
            ]
        ]
        [ div [ css [ Css.marginBottom (Css.px 8) ] ]
            [ text timetableItem.title ]
        , div [ css [ Css.color (Css.rgb 75 85 99) ] ]
            [ text ("発表者: " ++ (Maybe.withDefault "" <| Maybe.map .name timetableItem.speaker)) ]
        ]
