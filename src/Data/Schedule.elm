module Data.Schedule exposing
    ( TimetableItem(..), timetableItemDecoder
    , CommonProps, Track(..)
    , TalkProps, Speaker
    , getCommonProps
    )

{-|

@docs TimetableItem, timetableItemDecoder
@docs CommonProps, Track
@docs TalkProps, Speaker
@docs getCommonProps

-}

import Iso8601
import Json.Decode as Decode exposing (Decoder, bool, field, maybe, string)
import Time exposing (Posix)


type TimetableItem
    = Talk CommonProps TalkProps
    | Timeslot CommonProps


type alias CommonProps =
    { type_ : String
    , uuid : String
    , title : String
    , track : Track
    , startsAt : Posix
    , lengthMin : Int
    }


type alias TalkProps =
    { url : String
    , abstract : String
    , accepted : Bool
    , tags : List Tag
    , speaker : Speaker
    }


type Track
    = All
    | TrackA
    | TrackB
    | TrackC


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


timetableItemDecoder : Decoder TimetableItem
timetableItemDecoder =
    Decode.oneOf [ talkDecoder, timeslotDecoder ]


talkDecoder : Decoder TimetableItem
talkDecoder =
    Decode.map2 Talk
        commonDecoder
        (Decode.map5 TalkProps
            (field "url" string)
            (field "abstract" string)
            (field "accepted" bool)
            (field "tags" (Decode.list tagDecoder))
            (field "speaker" speakerDecoder)
        )


timeslotDecoder : Decoder TimetableItem
timeslotDecoder =
    Decode.map Timeslot commonDecoder


commonDecoder : Decoder CommonProps
commonDecoder =
    Decode.map6 CommonProps
        (field "type" string)
        (field "uuid" string)
        (field "title" string)
        (field "track" trackDecoder)
        (field "starts_at" iso8601Decoder)
        (field "length_min" Decode.int)


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
    field "name" string
        |> Decode.andThen
            (\str ->
                case str of
                    "Track A" ->
                        Decode.succeed TrackA

                    "Track B" ->
                        Decode.succeed TrackB

                    "Track C" ->
                        Decode.succeed TrackC

                    _ ->
                        Decode.fail "Unknown track name"
            )


iso8601Decoder : Decoder Posix
iso8601Decoder =
    string
        |> Decode.andThen
            (\str ->
                case Iso8601.toTime str of
                    Ok posix ->
                        Decode.succeed posix

                    Err _ ->
                        Decode.fail "Invalid ISO8601 date format"
            )


getCommonProps : TimetableItem -> CommonProps
getCommonProps item =
    case item of
        Talk c _ ->
            c

        Timeslot c ->
            c
