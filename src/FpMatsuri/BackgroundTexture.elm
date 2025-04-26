module FpMatsuri.BackgroundTexture exposing (textureGrid)

import Css exposing (..)
import Css.Extra exposing (gridColumn, gridRow)
import Html.Styled exposing (Html, div, text)
import Html.Styled.Attributes exposing (css)
import Random


type TextureElement
    = Circle
    | RoundedRect BorderRadius
    | NoShape


type alias BorderRadius =
    { topLeft : Int
    , topRight : Int
    , bottomRight : Int
    , bottomLeft : Int
    }


textureGrid : Int -> Float -> { rows : Int, columns : Int } -> List (Html msg)
textureGrid seed time gridDimensions =
    Random.step (elementsGenerator gridDimensions) (Random.initialSeed seed)
        |> Tuple.first
        |> List.map (renderGridCell gridDimensions time)



-- GENERATOR


elementGenerator : Random.Generator TextureElement
elementGenerator =
    let
        borderRadiusGenerator =
            Random.map4 BorderRadius
                cornerGenerator
                cornerGenerator
                cornerGenerator
                cornerGenerator

        cornerGenerator =
            Random.uniform 0 [ 5, 10 ]
    in
    Random.weighted ( 2, Random.constant Circle )
        [ ( 18, Random.map RoundedRect borderRadiusGenerator )
        , ( 80, Random.constant NoShape )
        ]
        |> Random.andThen identity


{-| 各セルに図形タイプを割り当てるジェネレーター
-}
elementsGenerator : { rows : Int, columns : Int } -> Random.Generator (List ( ( Int, Int ), TextureElement ))
elementsGenerator { rows, columns } =
    let
        -- グリッド内の全セルの位置リストを生成
        allCellPositions =
            List.concatMap
                (\row ->
                    List.map
                        (\col -> ( col, row ))
                        (List.range 1 columns)
                )
                (List.range 1 rows)
    in
    Random.list (List.length allCellPositions) elementGenerator
        |> Random.map (\elements -> List.map2 Tuple.pair allCellPositions elements)



-- VIEW


renderGridCell : { rows : Int, columns : Int } -> Float -> ( ( Int, Int ), TextureElement ) -> Html msg
renderGridCell { rows, columns } time ( ( column, row ), element ) =
    let
        -- 市松模様のパターン強化：より大きなブロックでグループ化（2x2のブロック）
        checkerboardPattern =
            modBy 2 (column // 2 + row // 2)

        -- 波状に広がるパターンを追加（中心から外側に広がる波）
        radialWavePhase =
            let
                ( centerX, centerY ) =
                    ( columns // 2 + modBy 2 columns
                    , rows // 2 + modBy 2 rows
                    )

                distance =
                    sqrt (toFloat ((column - centerX) ^ 2 + (row - centerY) ^ 2))
            in
            -- 距離を位相に変換（離れるほど位相が遅れる）
            distance * 0.3

        -- アニメーションの計算
        animationPhase =
            (time / 350)
                + -- 市松模様のパターンで位相をずらす
                  (if checkerboardPattern == 0 then
                    0

                   else
                    pi
                  )
                + -- 中心からの波状の広がりを追加
                  radialWavePhase

        -- フェードイン・フェードアウト効果（透明度）
        -- 透明度の変動範囲を最大に（0.0〜1.0）
        -- sin関数をそのまま使うのではなく、より鋭い変化のためにべき乗を使用
        fadeEffect =
            sin (animationPhase * 0.3)

        opacity =
            -- fadeEffectを2乗して変化を強調（0〜1の範囲を保持）
            fadeEffect * fadeEffect

        commonStyles =
            [ width (pct 100)
            , height (pct 100)
            , gridColumn (String.fromInt column)
            , gridRow (String.fromInt row)
            , Css.opacity (num opacity)
            , property "transition" "opacity 0.15s ease"
            ]
    in
    case element of
        Circle ->
            div
                [ css
                    [ batch commonStyles
                    , property "background-color" "hsla(0, 0%, 100%, 0.3)"
                    , borderRadius (pct 50)
                    ]
                ]
                []

        RoundedRect { topLeft, topRight, bottomRight, bottomLeft } ->
            let
                -- Create variation for gradient colors
                gradientType =
                    ((column * 7) + (row * 11)) |> modBy 5

                gradientColors =
                    case gradientType of
                        0 ->
                            "hsla(0, 0%, 100%, 0.9) 0%, hsla(0, 0%, 100%, 0.6) 100%"

                        1 ->
                            "hsla(0, 0%, 100%, 0.8) 0%, hsla(0, 0%, 100%, 0.5) 100%"

                        2 ->
                            "hsla(0, 0%, 100%, 0.7) 0%, hsla(0, 0%, 100%, 0.4) 100%"

                        3 ->
                            "hsla(0, 0%, 100%, 0.6) 0%, hsla(0, 0%, 100%, 0.3) 100%"

                        _ ->
                            "hsla(0, 0%, 100%, 0.5) 0%, hsla(0, 0%, 100%, 0.2) 100%"
            in
            div
                [ css
                    [ batch commonStyles
                    , property "background"
                        ("linear-gradient("
                            ++ String.fromInt (((column * 13) + (row * 17) + floor (time / 35)) |> modBy 360)
                            ++ "deg, "
                            ++ gradientColors
                            ++ ")"
                        )
                    , borderRadius4
                        (px (toFloat topLeft))
                        (px (toFloat topRight))
                        (px (toFloat bottomRight))
                        (px (toFloat bottomLeft))
                    ]
                ]
                []

        NoShape ->
            text ""
