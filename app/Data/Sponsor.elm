module Data.Sponsor exposing
    ( SponsorArticle
    , SponsorMetadata, metadataDecoder
    , Plan(..), planToBadge
    , IframeData(..)
    )

{-|

@docs SponsorArticle
@docs SponsorMetadata, metadataDecoder
@docs Plan, planToBadge
@docs IframeData

-}

import Css exposing (block, display, px, width)
import Html.Styled as Html exposing (Html, img, text)
import Html.Styled.Attributes exposing (css, src)
import Json.Decode as Decode exposing (Decoder)
import Markdown.Block exposing (Block)


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
    (case plan of
        Platinum ->
            Just "platinum.svg"

        Gold ->
            Just "gold.svg"

        Silver ->
            Just "silver.svg"

        _ ->
            Nothing
    )
        |> Maybe.map (\badgeImage -> img [ src ("/images/sponsor-labels/" ++ badgeImage), css [ display block, width (px 80) ] ] [])
        |> Maybe.withDefault (text "")
