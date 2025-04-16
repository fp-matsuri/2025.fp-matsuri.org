module Data.Schedule.TalkId exposing (calcTalkId, calcTalkIdWithOverride)

import Data.Schedule exposing (CommonProps, TimetableItem(..), Track(..), getStartsAtMillis)
import List.Extra
import Time exposing (Month(..), Posix)
import Time.Extra
import TimeZone


calcTalkId : List TimetableItem -> ( Track, Posix ) -> String
calcTalkId allItems ( track, startsAt ) =
    trackPrefix track ++ "-" ++ dayPrefix startsAt ++ indexStr allItems ( track, startsAt )


trackPrefix : Track -> String
trackPrefix track =
    case track of
        TrackA ->
            "A"

        TrackB ->
            "B"

        TrackC ->
            "C"

        All ->
            "A"


dayPrefix : Posix -> String
dayPrefix startsAt =
    let
        jst =
            TimeZone.asia__tokyo ()

        { year, month, day } =
            Time.Extra.posixToParts jst startsAt
    in
    if year == 2025 && month == Jun && day == 14 then
        "1"

    else if year == 2025 && month == Jun && day == 15 then
        "2"

    else
        "_"


indexStr : List TimetableItem -> ( Track, Posix ) -> String
indexStr allItems ( track, startsAt ) =
    let
        jst =
            TimeZone.asia__tokyo ()

        date =
            Time.Extra.posixToParts jst startsAt

        isSameTrackAndDay item =
            case item of
                Talk cp _ ->
                    let
                        itemDate =
                            Time.Extra.posixToParts jst cp.startsAt
                    in
                    isSameTrack cp.track track && isSameDay itemDate date

                Timeslot _ ->
                    False

        isSameTrack t1 t2 =
            let
                normalize track_ =
                    case track_ of
                        All ->
                            TrackA

                        _ ->
                            track_
            in
            t1 == t2 || normalize t1 == normalize t2

        isSameDay d1 d2 =
            d1.year == d2.year && d1.month == d2.month && d1.day == d2.day
    in
    allItems
        |> List.filter isSameTrackAndDay
        |> List.sortBy getStartsAtMillis
        |> List.Extra.findIndex (\item -> getStartsAtMillis item == Time.posixToMillis startsAt)
        |> Maybe.map (\index -> String.fromInt (index + 1) |> String.padLeft 2 '0')
        |> Maybe.withDefault "XX"


calcTalkIdWithOverride : List TimetableItem -> ({ uuid : String } -> String -> String) -> CommonProps -> String
calcTalkIdWithOverride allItems overrideFn { uuid, track, startsAt } =
    calcTalkId allItems ( track, startsAt )
        |> overrideFn { uuid = uuid }
