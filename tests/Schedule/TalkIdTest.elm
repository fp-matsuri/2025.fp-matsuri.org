module Schedule.TalkIdTest exposing (suite)

import Data.Schedule exposing (Speaker, TalkProps, TimetableItem(..), Track(..), getCommonProps)
import Data.Schedule.TalkId exposing (calcTalkId, calcTalkIdWithOverride)
import Expect
import Iso8601
import Route.Schedule exposing (overrideTalkId)
import Test exposing (Test, describe, test)
import Time exposing (Posix)


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


dummyTalkProps : TalkProps
dummyTalkProps =
    { url = ""
    , abstract = ""
    , accepted = True
    , tags = []
    , speaker = dummySpeaker
    }


dummySpeaker : Speaker
dummySpeaker =
    { name = "テスト太郎", kana = "てすとたろう", twitter = Nothing, avatarUrl = Nothing }


parseIso8601 : String -> Posix
parseIso8601 isoString =
    Iso8601.toTime isoString
        |> Result.withDefault (Time.millisToPosix 0)


dummyItems : List TimetableItem
dummyItems =
    [ Timeslot
        { type_ = "timeslot"
        , uuid = "76740964-196a-4868-aef7-56f389a3384f"
        , title = "開場"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-14T10:30:00+09:00"
        , lengthMin = 5
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "98eb8059-6301-48fa-a042-621e983e82aa"
        , title = "開場"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-14T10:30:00+09:00"
        , lengthMin = 5
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "4a17be0a-2ddc-4f7a-8dba-eff4ae1cafd1"
        , title = "開場"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-14T10:30:00+09:00"
        , lengthMin = 5
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "8e69f6f6-7231-48e6-b356-4b260c3126b1"
        , title = "Day 1オープニング"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-14T11:00:00+09:00"
        , lengthMin = 15
        }
    , Talk
        { type_ = "talk"
        , uuid = "5699c262-e04d-4f58-a6f5-34c390f36d0d"
        , title = "型システムを知りたい人のための型検査器作成入門"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-14T11:30:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "b952a4f0-7db5-4d67-a911-a7a5d8a840ac"
        , title = "Elixir で IoT 開発、 Nerves なら簡単にできる！？"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-14T11:30:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "f3a8809b-d498-4ac2-bf42-5c32ce1595ea"
        , title = "ドメインモデリングにおける抽象の役割、tagless-finalによるDSL構築、そして型安全な最適化"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-14T11:30:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Timeslot
        { type_ = "timeslot"
        , uuid = "76b6ecdc-a819-4afd-a186-d0eb67df0120"
        , title = "昼休憩"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-14T12:30:00+09:00"
        , lengthMin = 90
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "0ae9415b-387e-4213-8444-addcd2703f27"
        , title = "昼休憩"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-14T12:30:00+09:00"
        , lengthMin = 90
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "0646e839-71fa-45bc-b7f7-e56d7c1ed1d9"
        , title = "昼休憩"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-14T12:30:00+09:00"
        , lengthMin = 90
        }
    , Talk
        { type_ = "talk"
        , uuid = "a8cd6d02-37c5-4009-90a4-9495c3189420"
        , title = "Rust世界の二つのモナド──Rust でも do 式をしてプログラムを直感的に記述する件について"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-14T14:00:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "f7646b8b-29b0-4ac4-8ec3-46cabaa8ef1a"
        , title = "関数型言語テイスティング: Haskell, Scala, Clojure, Elixirを比べて味わう関数型プログラミングの旨さ"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-14T14:00:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "b7a97e49-8624-4eae-848a-68f70205ad2a"
        , title = "Hasktorchで学ぶ関数型ディープラーニング：型安全なニューラルネットワークとその実践"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-14T14:00:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "76a0de1e-bf79-4c82-b50e-86caedaf1eb9"
        , title = "関数型言語を採用し、維持し、継続する"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-14T15:00:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "6109f011-c590-4c89-9add-89ad12cc9631"
        , title = "`interact`のススメ — できるかぎり「関数的」に書きたいあなたに"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-14T15:00:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "56b9175d-1468-4ab0-8063-180491bb16ed"
        , title = "AIと共に進化する開発手法：形式手法と関数型プログラミングの可能性"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-14T15:00:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Timeslot
        { type_ = "timeslot"
        , uuid = "86ac02eb-3d96-49fb-a231-016f63b45266"
        , title = "休憩"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-14T16:00:00+09:00"
        , lengthMin = 30
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "36cabe30-8a76-4797-858b-46c68c158261"
        , title = "休憩"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-14T16:00:00+09:00"
        , lengthMin = 30
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "a5756486-013f-49fe-8916-d90d4d5d0071"
        , title = "休憩"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-14T16:00:00+09:00"
        , lengthMin = 30
        }
    , Talk
        { type_ = "talk"
        , uuid = "f75e5cab-c677-44bb-a77a-2acf36083457"
        , title = "「ElixirでIoT!!」のこれまでとこれから"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-14T16:30:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "034e486c-9a1c-48d7-910a-14aa82237eaa"
        , title = "関数プログラミングに見る再帰"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-14T16:30:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "3760ed3e-5b38-48b9-9db2-f101af1e580f"
        , title = "Elmのパフォーマンス、実際どうなの？ベンチマークに入門してみた"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-14T16:30:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "67557418-7561-47ec-8594-9d6c0926a6ab"
        , title = "Effectの双対、Coeffect"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-14T17:00:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "6edaa6b5-b591-490c-855f-731a9d318192"
        , title = "産業機械をElixirで制御する"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-14T17:00:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "350e2f70-0b02-4b79-b9f6-254a9d614706"
        , title = "高階関数を用いたI/O方法の公開 - DIコンテナから高階関数への更改 -"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-14T17:00:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "8acfb03f-19ea-476a-b6e6-0cb4b03fec1f"
        , title = "成立するElixirの再束縛（再代入）可という選択"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-14T17:30:00+09:00"
        , lengthMin = 10
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "ea9fd8fc-4ae3-40c7-8ef5-1a8041e64606"
        , title = "continuations: continued and to be continued"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-14T17:30:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "37899705-7d88-4ca4-bd5b-f674fc372d4e"
        , title = "Excelで関数型プログラミング"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-14T17:30:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "73b09de0-c72e-4bbd-9089-af5c002f9506"
        , title = "Lean言語は新世代の純粋関数型言語になれるか？"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-14T17:45:00+09:00"
        , lengthMin = 10
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "8dcaecb5-4541-4262-a047-3e330a7bcdb8"
        , title = "XSLTで作るBrainfuck処理系 ― XSLTは関数型言語たり得るか？"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-14T17:45:00+09:00"
        , lengthMin = 10
        }
        dummyTalkProps
    , Timeslot
        { type_ = "timeslot"
        , uuid = "1e8981e6-519a-4a0b-bfa6-4c7d8837fc66"
        , title = "Scott Wlaschinさんによるセッション"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-14T18:00:00+09:00"
        , lengthMin = 50
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "78e53d84-15f5-4517-a927-30736bbe1e1e"
        , title = "Scott Wlaschinさんによるセッション"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-14T18:00:00+09:00"
        , lengthMin = 50
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "b36b612b-03d4-4bd4-bf9e-bb26fa6d50f4"
        , title = "Scott Wlaschinさんによるセッション"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-14T18:00:00+09:00"
        , lengthMin = 50
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "3ca95c69-4f13-42f8-a04c-ee9f15eccaa6"
        , title = "Day 1クロージング"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-14T19:00:00+09:00"
        , lengthMin = 15
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "8ec1d38f-a88a-4b0f-8e9b-00a1f627ad4c"
        , title = "懇親会準備"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-14T19:15:00+09:00"
        , lengthMin = 15
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "b0fa8519-2d07-4289-ac3e-98d87e0989e5"
        , title = "懇親会"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-14T19:30:00+09:00"
        , lengthMin = 90
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "66645261-f1e0-42d3-84b7-29c215f3e1e4"
        , title = "開場"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-15T09:30:00+09:00"
        , lengthMin = 5
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "7a6b5521-2855-4aa3-a457-96fa51dddf75"
        , title = "開場"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-15T09:30:00+09:00"
        , lengthMin = 5
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "12820304-2b8a-40e4-9d6a-1f96b5bf8178"
        , title = "開場"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-15T09:30:00+09:00"
        , lengthMin = 5
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "2f6525d4-0ff2-44f8-8928-3c465f19f124"
        , title = "Day 2オープニング"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-15T10:00:00+09:00"
        , lengthMin = 15
        }
    , Talk
        { type_ = "talk"
        , uuid = "d19de11e-d9a2-4b22-866e-2f95b8ac5c95"
        , title = "「Haskellは純粋関数型言語だから副作用がない」っていうの、そろそろ止めにしませんか？"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-15T10:30:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "61fb241f-cfaa-448a-892d-277e93577198"
        , title = "SML＃ オープンコンパイラプロジェクト"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-15T10:30:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "a916dd5a-7342-416a-980d-84f180a8e0a2"
        , title = "F#の設計と妥協点 - .NET上で実現する関数型パラダイム"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-15T10:30:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "ad0d29f8-46a2-463b-beeb-39257f9c5306"
        , title = "Haskell でアルゴリズムを抽象化する 〜 関数型言語で競技プログラミング"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-15T11:30:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "b69688cf-06a2-4070-839c-4a6ec299c39c"
        , title = "SML#コンパイラを速くする：タスク並列、末尾呼び出し、部分評価機構の開発"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-15T11:30:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "7a342a71-90d4-43f9-9c4a-ce801fc9b49a"
        , title = "マイクロサービス内で動くAPIをF#で書いている"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-15T11:30:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Timeslot
        { type_ = "timeslot"
        , uuid = "b1a32c5b-c504-4022-b719-66d41db2ac39"
        , title = "昼休憩"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-15T12:30:00+09:00"
        , lengthMin = 90
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "6e1c2601-cc6d-464c-9cd5-21272146ca73"
        , title = "昼休憩"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-15T12:30:00+09:00"
        , lengthMin = 90
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "d03a5bd8-f47b-445c-b5fa-6d3ae27b71be"
        , title = "昼休憩"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-15T12:30:00+09:00"
        , lengthMin = 90
        }
    , Talk
        { type_ = "talk"
        , uuid = "4ca1dabd-dbbe-47ca-a813-bc4c9700ccc9"
        , title = "Julia という言語について"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-15T14:00:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "3bdbadb9-7d77-4de0-aa37-5a7a38c577c3"
        , title = "ラムダ計算と抽象機械と非同期ランタイム"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-15T14:00:00+09:00"
        , lengthMin = 50
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "7cc6ecef-94c8-4add-abc0-23b500dbf498"
        , title = "はじめて関数型言語の機能に触れるエンジニア向けの学び方/教え方"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-15T15:00:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "af94193a-4acb-4079-82a9-36bacfae3a20"
        , title = "Leanで正規表現エンジンをつくる。そして正しさを証明する"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-15T15:00:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "75644660-9bf1-473f-8d6d-01f2202bf2f2"
        , title = "より安全で単純な関数定義"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-15T15:00:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "82478074-a43b-4d46-87a8-0742ed790e86"
        , title = "型付きアクターモデルがもたらす分散シミュレーションの未来"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-15T15:30:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "71fbd521-9dc5-458d-89f6-cbff8e84e3cc"
        , title = "iOSアプリ開発で関数型プログラミングを実現するThe Composable Architectureの紹介"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-15T15:30:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "a6badfbb-ca70-474d-9abd-f285f24d9380"
        , title = "数理論理学からの『型システム入門』入門？"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-15T15:30:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Timeslot
        { type_ = "timeslot"
        , uuid = "892878f2-09c3-450d-8312-1c0cf08cf962"
        , title = "休憩"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-15T16:00:00+09:00"
        , lengthMin = 30
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "ba4cff73-c0b7-4a2a-9d3e-335c055ef054"
        , title = "休憩"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-15T16:00:00+09:00"
        , lengthMin = 30
        }
    , Timeslot
        { type_ = "timeslot"
        , uuid = "22839d9e-25e0-433d-9dd2-698a15f07e32"
        , title = "休憩"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-15T16:00:00+09:00"
        , lengthMin = 30
        }
    , Talk
        { type_ = "talk"
        , uuid = "e9df1f36-cf2f-4a85-aa36-4e07ae742a69"
        , title = "Gleamという選択肢"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-15T16:30:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "2ceb7498-b203-44ee-b064-c0fbbe4a6948"
        , title = "Scalaだったらこう書けるのに~Scalaが恋しくて~(TypeScript編、Python編)"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-15T16:30:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "a82127a7-f84a-43c1-a3de-483e1d973a94"
        , title = "デコーダーパターンによる3Dジオメトリの読み込み"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-15T16:30:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "e7f30174-d4b9-40a7-9398-9f15c71009a9"
        , title = "ClojureScript (Squint) で React フロントエンド開発 2025 年版"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-15T17:00:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "81cea14c-255c-46ff-929d-5141c5715832"
        , title = "ラムダ計算って何だっけ？関数型の神髄に迫る"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-15T17:00:00+09:00"
        , lengthMin = 10
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "02f89c3a-672e-4294-ae31-69e02e049005"
        , title = "Scala の関数型ライブラリを活用した型安全な業務アプリケーション開発"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-15T17:00:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "e0274da9-d863-47fe-a945-42eb04185bb9"
        , title = "Underground 型システム"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-15T17:15:00+09:00"
        , lengthMin = 10
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "92b697d1-206c-426a-90c9-9ff3486cce6f"
        , title = "Lispは関数型言語(ではない)"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-15T17:30:00+09:00"
        , lengthMin = 10
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "267ff4c1-8f3c-473b-8cab-e62d0d468af5"
        , title = "堅牢な認証基盤の実現: TypeScriptで代数的データ型を活用する"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-15T17:30:00+09:00"
        , lengthMin = 10
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "8bb407b5-5df3-48bb-a934-0ca6ca628c9a"
        , title = "AWS と定理証明 〜ポリシー言語 Cedar 開発の舞台裏〜"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-15T17:30:00+09:00"
        , lengthMin = 25
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "983d1021-3636-4778-be58-149f1995e8a5"
        , title = "CoqのProgram機構の紹介 〜型を活用した安全なプログラミング〜"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-15T17:40:00+09:00"
        , lengthMin = 10
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "e436393d-c322-477d-b8cb-0e6ac8ce8cc6"
        , title = "Kotlinで学ぶSealed classと代数的データ型"
        , track = TrackB
        , startsAt = parseIso8601 "2025-06-15T17:45:00+09:00"
        , lengthMin = 10
        }
        dummyTalkProps
    , Talk
        { type_ = "talk"
        , uuid = "b6c70e2d-856b-47c5-9107-481883527634"
        , title = "F#で自在につくる静的ブログサイト"
        , track = TrackC
        , startsAt = parseIso8601 "2025-06-15T17:50:00+09:00"
        , lengthMin = 10
        }
        dummyTalkProps
    , Timeslot
        { type_ = "timeslot"
        , uuid = "712bf3f6-d00a-4193-936c-123d2c60adb8"
        , title = "Day 2クロージング"
        , track = TrackA
        , startsAt = parseIso8601 "2025-06-15T18:00:00+09:00"
        , lengthMin = 15
        }
    ]
