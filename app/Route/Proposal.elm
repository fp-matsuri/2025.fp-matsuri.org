module Route.Proposal exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import BackendTask.Http
import Css exposing (..)
import FatalError exposing (FatalError)
import Head
import Head.Seo
import Html.Styled as Html exposing (Html, div, h1, li, text, ul)
import Html.Styled.Attributes exposing (class, css)
import Json.Decode as Decode exposing (Decoder, bool, field, maybe, string)
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
    { proposals : List Proposal }


type alias Proposal =
    { uuid : String
    , title : String
    , abstract : String
    , accepted : Bool
    , speaker : Speaker
    , created : String
    }


type alias Speaker =
    { name : String
    , kana : String
    , twitter : Maybe String
    , avatarUrl : Maybe String
    }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.Http.getJson "https://fortee.jp/2025fp-matsuri/api/proposals"
        (Decode.map Data (Decode.field "proposals" (Decode.list proposalDecoder)))
        |> BackendTask.onError (\_ -> BackendTask.succeed { proposals = [] })


proposalDecoder : Decoder Proposal
proposalDecoder =
    Decode.map6 Proposal
        (field "uuid" string)
        (field "title" string)
        (field "abstract" string)
        (field "accepted" bool)
        (field "speaker" speakerDecoder)
        (field "created" string)


speakerDecoder : Decoder Speaker
speakerDecoder =
    Decode.map4 Speaker
        (field "name" string)
        (field "kana" string)
        (maybe (field "twitter" string))
        (maybe (field "avatar_url" string))


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Site.summaryLarge { pageTitle = "採択された応募一覧" }
        |> Head.Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg ())
view app _ =
    { title = "採択された応募一覧"
    , body =
        [ div
            [ class "container mx-auto px-4 py-8"
            , css
                [ Css.maxWidth (Css.px 800)
                , Css.margin2 Css.zero Css.auto
                ]
            ]
            [ h1
                [ class "text-3xl font-bold mb-8"
                , css [ Css.marginBottom (Css.px 32) ]
                ]
                [ text "採択された応募一覧" ]
            , ul
                [ class "space-y-4"
                , css [ Css.listStyle Css.none, Css.padding Css.zero ]
                ]
                (List.map viewProposal app.data.proposals)
            ]
        ]
    }


viewProposal : Proposal -> Html msg
viewProposal proposal =
    li
        [ class "p-4 border rounded-lg"
        , css
            [ Css.borderColor (Css.rgb 229 231 235)
            , Css.borderWidth (Css.px 1)
            , Css.borderRadius (Css.px 8)
            ]
        ]
        [ div
            [ class "font-bold text-lg mb-2"
            , css [ Css.marginBottom (Css.px 8) ]
            ]
            [ text proposal.title ]
        , div
            [ class "text-gray-600"
            , css [ Css.color (Css.rgb 75 85 99) ]
            ]
            [ text ("発表者: " ++ proposal.speaker.name) ]
        ]
