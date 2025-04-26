module FpMatsuri.BackgroundTexture exposing (makeShapes)

import Css exposing (..)
import Css.Extra exposing (gridColumn, gridRow)
import Html.Styled exposing (Html, div, text)
import Html.Styled.Attributes exposing (css)
import Random


type Shape
    = Circle
    | RoundedRect Corners
    | NoShape


type alias Corners =
    { topLeft : Int
    , topRight : Int
    , bottomRight : Int
    , bottomLeft : Int
    }


makeShapes : Int -> Float -> { rows : Int, columns : Int } -> List (Html msg)
makeShapes seed time { rows, columns } =
    let
        initialSeed =
            Random.initialSeed seed

        shapeGenerator : Random.Generator Shape
        shapeGenerator =
            let
                cornersGenerator =
                    Random.map4 Corners
                        cornerGenerator
                        cornerGenerator
                        cornerGenerator
                        cornerGenerator

                cornerGenerator =
                    Random.uniform 0 [ 5, 10 ]
            in
            Random.weighted ( 2, Random.constant Circle )
                [ ( 18, Random.map RoundedRect cornersGenerator )
                , ( 80, Random.constant NoShape )
                ]
                |> Random.andThen identity

        -- グリッド内の全セルの位置リストを生成
        allCellPositions : List ( Int, Int )
        allCellPositions =
            List.concatMap
                (\row ->
                    List.map
                        (\col -> ( col, row ))
                        (List.range 1 columns)
                )
                (List.range 1 rows)

        -- 各セルに図形タイプを割り当てるジェネレーター
        cellShapeTypeGenerator : Random.Generator (List ( ( Int, Int ), Shape ))
        cellShapeTypeGenerator =
            let
                cellCount =
                    List.length allCellPositions
            in
            Random.map
                (\shapeTypes -> List.map2 Tuple.pair allCellPositions shapeTypes)
                (Random.list cellCount shapeGenerator)

        -- 各セルに図形を割り当てた結果
        ( cellShapes, _ ) =
            Random.step cellShapeTypeGenerator initialSeed
    in
    List.map (makeShape time) cellShapes


makeShape : Float -> ( ( Int, Int ), Shape ) -> Html msg
makeShape time ( ( column, row ), shape ) =
    let
        -- 市松模様のパターン強化：より大きなブロックでグループ化（2x2のブロック）
        blockPattern =
            modBy 2 (column // 2 + row // 2)

        -- 波状に広がるパターンを追加（中心から外側に広がる波）
        centerDistancePhase =
            let
                centerX =
                    40

                -- グリッドの中央付近の列
                centerY =
                    11

                -- グリッドの中央付近の行
                distance =
                    sqrt (toFloat ((column - centerX) ^ 2 + (row - centerY) ^ 2))
            in
            -- 距離を位相に変換（離れるほど位相が遅れる）
            distance * 0.3

        -- アニメーションの計算
        animationPhase =
            (time / 350)
                + -- 市松模様のパターンで位相をずらす
                  (if blockPattern == 0 then
                    0

                   else
                    pi
                  )
                + -- 中心からの波状の広がりを追加
                  centerDistancePhase

        -- フェードイン・フェードアウト効果（透明度）
        -- 透明度の変動範囲を最大に（0.0〜1.0）
        -- sin関数をそのまま使うのではなく、より鋭い変化のためにべき乗を使用
        fadeEffect =
            sin (animationPhase * 0.3)

        opacity =
            -- fadeEffectを2乗して変化を強調（0〜1の範囲を保持）
            fadeEffect * fadeEffect

        commonShape uniqueStyles =
            div
                [ css
                    (List.append uniqueStyles
                        [ width (pct 100)
                        , height (pct 100)
                        , gridColumn (String.fromInt column)
                        , gridRow (String.fromInt row)
                        , Css.opacity (num opacity)
                        , property "transition" "opacity 0.15s ease"
                        ]
                    )
                ]
                []
    in
    case shape of
        Circle ->
            commonShape
                [ property "background-color" "hsla(0, 0%, 100%, 0.3)"
                , borderRadius (pct 50)
                ]

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
            commonShape
                [ property "background"
                    ("linear-gradient("
                        ++ String.fromInt (((column * 13) + (row * 17) + floor (time / 35)) |> modBy 360)
                        ++ "deg, "
                        ++ gradientColors
                        ++ ")"
                    )
                , borderRadius4 (px (toFloat topLeft))
                    (px (toFloat topRight))
                    (px (toFloat bottomRight))
                    (px (toFloat bottomLeft))
                ]

        NoShape ->
            text ""
