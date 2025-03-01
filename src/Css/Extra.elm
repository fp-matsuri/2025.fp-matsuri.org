module Css.Extra exposing
    ( content_
    , marginBlock, marginInline, paddingBlock, paddingInline
    , fr
    , gap, rowGap, columnGap
    , grid, gridTemplateColumns, gridTemplateRows, gridAutoColumns, gridAutoRows, gridColumn, gridRow
    )

{-| elm-css には含まれていないCSSプロパティや値を提供するモジュール

@docs content_
@docs marginBlock, marginInline, paddingBlock, paddingInline

@docs fr
@docs gap, rowGap, columnGap
@docs grid, gridTemplateColumns, gridTemplateRows, gridAutoColumns, gridAutoRows, gridColumn, gridRow

-}

import Css exposing (..)



-- COMPATIBLE


dummyCompatible : Compatible
dummyCompatible =
    Css.initial.all



-- LENGTHS


type alias Fr =
    ExplicitLength FrUnits


fr : Float -> Fr
fr =
    lengthConverter_ FrUnits "fr"


type FrUnits
    = FrUnits


lengthConverter_ : units -> String -> Float -> ExplicitLength units
lengthConverter_ units unitLabel numericValue =
    { value = String.fromFloat numericValue ++ unitLabel
    , numericValue = numericValue
    , units = units
    , unitLabel = unitLabel
    , length = dummyCompatible
    , lengthOrAuto = dummyCompatible
    , lengthOrNumber = dummyCompatible
    , lengthOrNone = dummyCompatible
    , lengthOrMinMaxDimension = dummyCompatible
    , lengthOrNoneOrMinMaxDimension = dummyCompatible
    , textIndent = dummyCompatible
    , flexBasis = dummyCompatible
    , lengthOrNumberOrAutoOrNoneOrContent = dummyCompatible
    , fontSize = dummyCompatible
    , absoluteLength = dummyCompatible
    , lengthOrAutoOrCoverOrContain = dummyCompatible
    , lineHeight = dummyCompatible
    , calc = dummyCompatible
    }



-- PROPERTIES


prop1 : String -> Value a -> Style
prop1 key arg =
    property key arg.value


content_ : String -> Style
content_ =
    qt >> property "content"


marginBlock : LengthOrAuto compatible -> Style
marginBlock { value } =
    property "margin-block" value


marginInline : LengthOrAuto compatible -> Style
marginInline { value } =
    property "margin-inline" value


paddingBlock : LengthOrAuto compatible -> Style
paddingBlock { value } =
    property "padding-block" value


paddingInline : LengthOrAuto compatible -> Style
paddingInline { value } =
    property "padding-inline" value


gap : Length compatible units -> Style
gap { value } =
    property "gap" value


rowGap : Length compatible units -> Style
rowGap { value } =
    property "row-gap" value


columnGap : Length compatible units -> Style
columnGap { value } =
    property "column-gap" value



-- GRID LAYOUT


grid : Display {}
grid =
    { value = "grid", display = dummyCompatible }


gridTemplateColumns : List (Length compatible units) -> Style
gridTemplateColumns units =
    property "grid-template-columns" (String.join " " <| List.map .value units)


gridTemplateRows : List (Length compatible units) -> Style
gridTemplateRows units =
    property "grid-template-rows" (String.join " " <| List.map .value units)


gridAutoColumns : Length compatible units -> Style
gridAutoColumns =
    prop1 "grid-auto-columns"


gridAutoRows : Length compatible units -> Style
gridAutoRows =
    prop1 "grid-auto-rows"


gridColumn : String -> Style
gridColumn =
    property "grid-column"


gridRow : String -> Style
gridRow =
    property "grid-row"
