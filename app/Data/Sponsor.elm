module Data.Sponsor exposing
    ( SponsorArticle
    , SponsorMetadata, metadataDecoder
    , Plan(..), planToBadge
    , IframeData(..)
    , shuffle
    )

{-|

@docs SponsorArticle
@docs SponsorMetadata, metadataDecoder
@docs Plan, planToBadge
@docs IframeData

@docs shuffle

-}

import Css exposing (..)
import Html.Styled as Html exposing (Html, div, text)
import Html.Styled.Attributes exposing (css)
import Json.Decode as Decode exposing (Decoder)
import Markdown.Block exposing (Block)
import Random
import Random.List


type alias SponsorArticle =
    { metadata : SponsorMetadata
    , body : List Block
    }


type alias SponsorMetadata =
    { id : String
    , name : String
    , href : String
    , plan : Plan
    , postedAt : String
    , iframe : Maybe (List IframeData)
    }


type Plan
    = Platinum
    | Gold
    | Silver
    | Logo
    | Support
    | PersonalSupporter


type IframeData
    = SpeakerDeck String


metadataDecoder : Decoder SponsorMetadata
metadataDecoder =
    Decode.map6 SponsorMetadata
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "href" Decode.string)
        (Decode.field "plan" planDecoder)
        (Decode.field "postedAt" Decode.string)
        (Decode.maybe (Decode.field "iframe" (Decode.list iframeDecoder)))


planDecoder : Decoder Plan
planDecoder =
    Decode.string
        |> Decode.andThen
            (\value ->
                case value of
                    "プラチナ" ->
                        Decode.succeed Platinum

                    "ゴールド" ->
                        Decode.succeed Gold

                    "シルバー" ->
                        Decode.succeed Silver

                    "ロゴ" ->
                        Decode.succeed Logo

                    "協力" ->
                        Decode.succeed Support

                    "応援団" ->
                        Decode.succeed PersonalSupporter

                    _ ->
                        Decode.fail ("無効なプランです: " ++ value)
            )


iframeDecoder : Decoder IframeData
iframeDecoder =
    Decode.oneOf
        [ Decode.field "speakerDeck" Decode.string
            |> Decode.andThen (\value -> Decode.succeed (SpeakerDeck value))
        ]


planToBadge : Plan -> Html msg
planToBadge plan =
    let
        badge bgGradient textColor text_ =
            div
                [ css
                    [ property "width" "fit-content"
                    , padding2 (px 4) (px 10)
                    , borderRadius (px 5)
                    , fontSize (px 14)
                    , property "background" bgGradient
                    , color textColor
                    ]
                ]
                [ text text_ ]
    in
    case plan of
        Platinum ->
            badge "linear-gradient(95.58deg, #F1F1F4 0%, #F9F9FA 50%, #E3E3E9 100%)"
                (hex "#464653")
                "Platinum"

        Gold ->
            badge "linear-gradient(103.14deg, #FFE448 0.78%, #FFF2AA 50.39%, #EDBD00 100%)"
                (hex "#453B08")
                "Gold"

        Silver ->
            badge "linear-gradient(100.53deg, #E3E3E8 0%, #F1F1F4 50%, #B9B9C7 100%)"
                (hex "#2F2F37")
                "Silver"

        _ ->
            text ""


{-| 与えられたリストの要素をランダムな順序に並べ替えます
-}
shuffle : Int -> List a -> List a
shuffle seed list =
    let
        generator =
            Random.List.shuffle list
    in
    Random.step generator (Random.initialSeed seed)
        |> (\( shuffledList, _ ) -> shuffledList)
