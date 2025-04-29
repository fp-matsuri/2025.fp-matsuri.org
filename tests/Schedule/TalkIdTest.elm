module Schedule.TalkIdTest exposing (suite)

import Data.Schedule exposing (TimetableItem(..), Track(..), getCommonProps)
import Data.Schedule.TalkId exposing (calcTalkId, calcTalkIdWithOverride)
import Expect
import Route.Schedule exposing (overrideTalkId)
import ScheduleTest exposing (dummyItems, dummyTalkProps, parseIso8601)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "calcTalkId 関数"
        [ describe "基本パターン - トラック、日付、順番による計算"
            [ test "TrackA, 1日目, 最初のトーク" <|
                \_ ->
                    let
                        allItems =
                            [ Talk
                                { type_ = "talk"
                                , uuid = "test-A-101"
                                , title = "テストトークA1"
                                , track = TrackA
                                , startsAt = parseIso8601 "2025-06-14T10:00:00+09:00"
                                , lengthMin = 30
                                }
                                dummyTalkProps
                            , Talk
                                { type_ = "talk"
                                , uuid = "test-A-102"
                                , title = "テストトークA2"
                                , track = TrackA
                                , startsAt = parseIso8601 "2025-06-14T11:00:00+09:00"
                                , lengthMin = 30
                                }
                                dummyTalkProps
                            ]
                    in
                    calcTalkId allItems ( TrackA, parseIso8601 "2025-06-14T10:00:00+09:00" )
                        |> Expect.equal "A-101"
            , test "TrackA, 1日目, 2番目のトーク" <|
                \_ ->
                    let
                        allItems =
                            [ Talk
                                { type_ = "talk"
                                , uuid = "test-A-101"
                                , title = "テストトークA1"
                                , track = TrackA
                                , startsAt = parseIso8601 "2025-06-14T10:00:00+09:00"
                                , lengthMin = 30
                                }
                                dummyTalkProps
                            , Talk
                                { type_ = "talk"
                                , uuid = "test-A-102"
                                , title = "テストトークA2"
                                , track = TrackA
                                , startsAt = parseIso8601 "2025-06-14T11:00:00+09:00"
                                , lengthMin = 30
                                }
                                dummyTalkProps
                            ]
                    in
                    calcTalkId allItems ( TrackA, parseIso8601 "2025-06-14T11:00:00+09:00" )
                        |> Expect.equal "A-102"
            , describe "Timeslotを除外する"
                [ test "Timeslotは計算から除外される" <|
                    \_ ->
                        let
                            allItems =
                                [ Timeslot
                                    { type_ = "timeslot"
                                    , uuid = "timeslot-1"
                                    , title = "休憩"
                                    , track = TrackA
                                    , startsAt = parseIso8601 "2025-06-14T09:30:00+09:00"
                                    , lengthMin = 30
                                    }
                                , Talk
                                    { type_ = "talk"
                                    , uuid = "test-A-101"
                                    , title = "テストトークA1"
                                    , track = TrackA
                                    , startsAt = parseIso8601 "2025-06-14T10:00:00+09:00"
                                    , lengthMin = 30
                                    }
                                    dummyTalkProps
                                , Talk
                                    { type_ = "talk"
                                    , uuid = "test-A-102"
                                    , title = "テストトークA2"
                                    , track = TrackA
                                    , startsAt = parseIso8601 "2025-06-14T11:00:00+09:00"
                                    , lengthMin = 30
                                    }
                                    dummyTalkProps
                                ]
                        in
                        -- timeslotを含めても計算結果は変わらない
                        calcTalkId allItems ( TrackA, parseIso8601 "2025-06-14T11:00:00+09:00" )
                            |> Expect.equal "A-102"
                ]
            , describe "Track.Allの扱い"
                [ test "Track.AllはTrack.Aと同じになり、All/Aは両方とも同じカウントに入る" <|
                    \_ ->
                        let
                            allItems =
                                [ Talk
                                    { type_ = "talk"
                                    , uuid = "test-A-101"
                                    , title = "テストトークA1"
                                    , track = TrackA
                                    , startsAt = parseIso8601 "2025-06-14T10:00:00+09:00"
                                    , lengthMin = 30
                                    }
                                    dummyTalkProps
                                , Talk
                                    { type_ = "talk"
                                    , uuid = "test-All"
                                    , title = "テストトークAll"
                                    , track = All
                                    , startsAt = parseIso8601 "2025-06-14T11:00:00+09:00"
                                    , lengthMin = 50
                                    }
                                    dummyTalkProps
                                , Talk
                                    { type_ = "talk"
                                    , uuid = "test-A-103"
                                    , title = "テストトークA3"
                                    , track = TrackA
                                    , startsAt = parseIso8601 "2025-06-14T12:00:00+09:00"
                                    , lengthMin = 30
                                    }
                                    dummyTalkProps
                                ]
                        in
                        Expect.all
                            [ \_ -> calcTalkId allItems ( TrackA, parseIso8601 "2025-06-14T10:00:00+09:00" ) |> Expect.equal "A-101"
                            , \_ -> calcTalkId allItems ( All, parseIso8601 "2025-06-14T11:00:00+09:00" ) |> Expect.equal "A-102"
                            , \_ -> calcTalkId allItems ( TrackA, parseIso8601 "2025-06-14T12:00:00+09:00" ) |> Expect.equal "A-103"
                            ]
                            ()
                ]
            , describe "日付による区別"
                [ test "2日目は「2」の接頭辞が付く" <|
                    \_ ->
                        let
                            allItems =
                                [ Talk
                                    { type_ = "talk"
                                    , uuid = "test-B-101"
                                    , title = "テストトークB1日目"
                                    , track = TrackB
                                    , startsAt = parseIso8601 "2025-06-14T10:00:00+09:00"
                                    , lengthMin = 30
                                    }
                                    dummyTalkProps
                                , Talk
                                    { type_ = "talk"
                                    , uuid = "test-B-201"
                                    , title = "テストトークB2日目"
                                    , track = TrackB
                                    , startsAt = parseIso8601 "2025-06-15T10:00:00+09:00"
                                    , lengthMin = 30
                                    }
                                    dummyTalkProps
                                ]
                        in
                        Expect.all
                            [ \_ -> calcTalkId allItems ( TrackB, parseIso8601 "2025-06-14T10:00:00+09:00" ) |> Expect.equal "B-101"
                            , \_ -> calcTalkId allItems ( TrackB, parseIso8601 "2025-06-15T10:00:00+09:00" ) |> Expect.equal "B-201"
                            ]
                            ()
                ]
            , test "dummyItemsの全てのTalkについて、calcTalkIdWithOverrideが正しいtalkIdを返すこと" <|
                \_ ->
                    let
                        calcTalkIdByUUID items uuid =
                            findCommonPropsByUUID items uuid
                                |> Maybe.map (calcTalkIdWithOverride items overrideTalkId)
                                |> Maybe.withDefault ""

                        findCommonPropsByUUID items uuid =
                            items
                                |> List.filterMap
                                    (\item ->
                                        let
                                            props =
                                                getCommonProps item
                                        in
                                        if props.uuid == uuid then
                                            Just props

                                        else
                                            Nothing
                                    )
                                |> List.head
                    in
                    Expect.all
                        [ \_ -> calcTalkIdByUUID dummyItems "5699c262-e04d-4f58-a6f5-34c390f36d0d" |> Expect.equal "A-101"
                        , \_ -> calcTalkIdByUUID dummyItems "a8cd6d02-37c5-4009-90a4-9495c3189420" |> Expect.equal "A-102"
                        , \_ -> calcTalkIdByUUID dummyItems "76a0de1e-bf79-4c82-b50e-86caedaf1eb9" |> Expect.equal "A-103"
                        , \_ -> calcTalkIdByUUID dummyItems "034e486c-9a1c-48d7-910a-14aa82237eaa" |> Expect.equal "A-104"
                        , \_ -> calcTalkIdByUUID dummyItems "67557418-7561-47ec-8594-9d6c0926a6ab" |> Expect.equal "A-105"
                        , \_ -> calcTalkIdByUUID dummyItems "ea9fd8fc-4ae3-40c7-8ef5-1a8041e64606" |> Expect.equal "A-106"

                        -- , \_ -> calcTalkIdByUUID dummyItems "scott" |> Expect.equal "A-107"
                        , \_ -> calcTalkIdByUUID dummyItems "61fb241f-cfaa-448a-892d-277e93577198" |> Expect.equal "A-201"
                        , \_ -> calcTalkIdByUUID dummyItems "ad0d29f8-46a2-463b-beeb-39257f9c5306" |> Expect.equal "A-202"
                        , \_ -> calcTalkIdByUUID dummyItems "3bdbadb9-7d77-4de0-aa37-5a7a38c577c3" |> Expect.equal "A-203"
                        , \_ -> calcTalkIdByUUID dummyItems "75644660-9bf1-473f-8d6d-01f2202bf2f2" |> Expect.equal "A-204"
                        , \_ -> calcTalkIdByUUID dummyItems "a6badfbb-ca70-474d-9abd-f285f24d9380" |> Expect.equal "A-205"
                        , \_ -> calcTalkIdByUUID dummyItems "e9df1f36-cf2f-4a85-aa36-4e07ae742a69" |> Expect.equal "A-206"
                        , \_ -> calcTalkIdByUUID dummyItems "02f89c3a-672e-4294-ae31-69e02e049005" |> Expect.equal "A-207"
                        , \_ -> calcTalkIdByUUID dummyItems "8bb407b5-5df3-48bb-a934-0ca6ca628c9a" |> Expect.equal "A-208"
                        , \_ -> calcTalkIdByUUID dummyItems "b952a4f0-7db5-4d67-a911-a7a5d8a840ac" |> Expect.equal "B-101"
                        , \_ -> calcTalkIdByUUID dummyItems "b7a97e49-8624-4eae-848a-68f70205ad2a" |> Expect.equal "B-102"
                        , \_ -> calcTalkIdByUUID dummyItems "6109f011-c590-4c89-9add-89ad12cc9631" |> Expect.equal "B-103"
                        , \_ -> calcTalkIdByUUID dummyItems "f75e5cab-c677-44bb-a77a-2acf36083457" |> Expect.equal "B-104"
                        , \_ -> calcTalkIdByUUID dummyItems "6edaa6b5-b591-490c-855f-731a9d318192" |> Expect.equal "B-105"
                        , \_ -> calcTalkIdByUUID dummyItems "8acfb03f-19ea-476a-b6e6-0cb4b03fec1f" |> Expect.equal "B-106"
                        , \_ -> calcTalkIdByUUID dummyItems "73b09de0-c72e-4bbd-9089-af5c002f9506" |> Expect.equal "B-107"
                        , \_ -> calcTalkIdByUUID dummyItems "d19de11e-d9a2-4b22-866e-2f95b8ac5c95" |> Expect.equal "B-201"
                        , \_ -> calcTalkIdByUUID dummyItems "b69688cf-06a2-4070-839c-4a6ec299c39c" |> Expect.equal "B-202"
                        , \_ -> calcTalkIdByUUID dummyItems "4ca1dabd-dbbe-47ca-a813-bc4c9700ccc9" |> Expect.equal "B-203"
                        , \_ -> calcTalkIdByUUID dummyItems "af94193a-4acb-4079-82a9-36bacfae3a20" |> Expect.equal "B-204"
                        , \_ -> calcTalkIdByUUID dummyItems "82478074-a43b-4d46-87a8-0742ed790e86" |> Expect.equal "B-205"
                        , \_ -> calcTalkIdByUUID dummyItems "2ceb7498-b203-44ee-b064-c0fbbe4a6948" |> Expect.equal "B-206"
                        , \_ -> calcTalkIdByUUID dummyItems "e7f30174-d4b9-40a7-9398-9f15c71009a9" |> Expect.equal "B-207"
                        , \_ -> calcTalkIdByUUID dummyItems "92b697d1-206c-426a-90c9-9ff3486cce6f" |> Expect.equal "B-208"
                        , \_ -> calcTalkIdByUUID dummyItems "e436393d-c322-477d-b8cb-0e6ac8ce8cc6" |> Expect.equal "B-209"
                        , \_ -> calcTalkIdByUUID dummyItems "f3a8809b-d498-4ac2-bf42-5c32ce1595ea" |> Expect.equal "C-101"
                        , \_ -> calcTalkIdByUUID dummyItems "f7646b8b-29b0-4ac4-8ec3-46cabaa8ef1a" |> Expect.equal "C-102"
                        , \_ -> calcTalkIdByUUID dummyItems "56b9175d-1468-4ab0-8063-180491bb16ed" |> Expect.equal "C-103"
                        , \_ -> calcTalkIdByUUID dummyItems "3760ed3e-5b38-48b9-9db2-f101af1e580f" |> Expect.equal "C-104"
                        , \_ -> calcTalkIdByUUID dummyItems "350e2f70-0b02-4b79-b9f6-254a9d614706" |> Expect.equal "C-105"
                        , \_ -> calcTalkIdByUUID dummyItems "37899705-7d88-4ca4-bd5b-f674fc372d4e" |> Expect.equal "C-106"
                        , \_ -> calcTalkIdByUUID dummyItems "8dcaecb5-4541-4262-a047-3e330a7bcdb8" |> Expect.equal "C-107"
                        , \_ -> calcTalkIdByUUID dummyItems "a916dd5a-7342-416a-980d-84f180a8e0a2" |> Expect.equal "C-201"
                        , \_ -> calcTalkIdByUUID dummyItems "7a342a71-90d4-43f9-9c4a-ce801fc9b49a" |> Expect.equal "C-202"
                        , \_ -> calcTalkIdByUUID dummyItems "7cc6ecef-94c8-4add-abc0-23b500dbf498" |> Expect.equal "C-204"
                        , \_ -> calcTalkIdByUUID dummyItems "71fbd521-9dc5-458d-89f6-cbff8e84e3cc" |> Expect.equal "C-205"
                        , \_ -> calcTalkIdByUUID dummyItems "a82127a7-f84a-43c1-a3de-483e1d973a94" |> Expect.equal "C-206"
                        , \_ -> calcTalkIdByUUID dummyItems "81cea14c-255c-46ff-929d-5141c5715832" |> Expect.equal "C-207"
                        , \_ -> calcTalkIdByUUID dummyItems "e0274da9-d863-47fe-a945-42eb04185bb9" |> Expect.equal "C-208"
                        , \_ -> calcTalkIdByUUID dummyItems "267ff4c1-8f3c-473b-8cab-e62d0d468af5" |> Expect.equal "C-209"
                        , \_ -> calcTalkIdByUUID dummyItems "983d1021-3636-4778-be58-149f1995e8a5" |> Expect.equal "C-210"
                        , \_ -> calcTalkIdByUUID dummyItems "b6c70e2d-856b-47c5-9107-481883527634" |> Expect.equal "C-211"
                        ]
                        ()
            ]
        ]
