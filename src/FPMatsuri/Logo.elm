module FPMatsuri.Logo exposing (logoMark)

import Html.Attributes exposing (attribute)
import Svg exposing (Svg, defs, g, linearGradient, path, rect, stop, svg)
import Svg.Attributes exposing (d, fill, gradientTransform, height, id, offset, rx, stopColor, transform, viewBox, width, x, y)


logoMark : Int -> ( String, String ) -> Svg msg
logoMark index ( color1, color2 ) =
    let
        id_ =
            "id_" ++ String.fromInt index

        clipPath =
            Svg.clipPath [ id "logo_outline" ]
                [ path [ d "M0 50C0 22.3858 22.3858 0 50 0V0V50H0V50Z" ] []
                , path [ d "M50 0H100V40C100 45.5228 95.5228 50 90 50H50V0Z" ] []
                , path [ d "M150 0H190C195.523 0 200 4.47715 200 10V40C200 45.5228 195.523 50 190 50H160C154.477 50 150 45.5228 150 40V0Z" ] []
                , rect [ width "50", height "50", transform "translate(0 50)" ] []
                , path [ d "M100 50H140C145.523 50 150 54.4772 150 60V90C150 95.5228 145.523 100 140 100H100V50Z" ] []
                , rect [ x "200", y "50", width "50", height "50", rx "25" ] []
                , rect [ width "50", height "50", transform "translate(0 100)" ] []
                , path [ d "M50 100H90C95.5228 100 100 104.477 100 110V140C100 145.523 95.5228 150 90 150H50V100Z" ] []
                , path [ d "M150 110C150 104.477 154.477 100 160 100H190C195.523 100 200 104.477 200 110V140C200 145.523 195.523 150 190 150H150V110Z" ] []
                , rect [ width "50", height "50", transform "translate(0 150)" ] []
                , path [ d "M100 150H140C145.523 150 150 154.477 150 160V200H100V150Z" ] []
                ]

        gradient =
            linearGradient [ id ("gradient_" ++ id_), gradientTransform "rotate(45)" ]
                [ stop [ offset "0%", stopColor color1 ] []
                , stop [ offset "100%", stopColor color2 ] []
                ]
    in
    svg [ width "125", height "100", viewBox "0 0 250 200", attribute "xmlns" "http://www.w3.org/2000/svg" ]
        [ defs [] [ clipPath, gradient ]
        , g [ Svg.Attributes.clipPath "url(#logo_outline)", fill ("url(#gradient_" ++ id_ ++ ")") ]
            [ rect [ width "250", height "200" ] [] ]
        ]
