module FPMatsuri.Logo exposing (logoMarkWithOptions)

import Html.Attributes exposing (attribute)
import Svg exposing (Svg, defs, g, linearGradient, path, rect, stop, svg)
import Svg.Attributes exposing (d, fill, gradientTransform, height, id, offset, rx, ry, stopColor, viewBox, width, x, y)


logoMarkWithOptions : Int -> ( String, String ) -> Svg msg
logoMarkWithOptions index ( color1, color2 ) =
    let
        id_ =
            "id_" ++ String.fromInt index

        clipPath =
            Svg.clipPath [ id "logo_outline" ]
                [ path [ d "M176.51,152c17.23,0,31.2-13.97,31.2-31.2V48h-104C46.27,48-.29,94.56-.29,152H-.29v312h104v-104h72.8c17.23,0,31.2-13.97,31.2-31.2v-41.6c0-17.23-13.97-31.2-31.2-31.2h-72.8v-104h72.8Z" ] []
                , path [ d "M311.71,48h72.8c17.23,0,31.2,13.97,31.2,31.2v52c0,11.49-9.31,20.8-20.8,20.8h-62.4c-11.49,0-20.8-9.31-20.8-20.8V48Z" ] []
                , path [ d "M207.71,152h83.2c11.49,0,20.8,9.31,20.8,20.8v62.4c0,11.49-9.31,20.8-20.8,20.8h-83.2v-104Z" ] []
                , rect [ x "415.71", y "152", width "104", height "104", rx "52", ry "52" ] []
                , path [ d "M332.51,256h62.4c11.49,0,20.8,9.31,20.8,20.8v52c0,17.23-13.97,31.2-31.2,31.2h-72.8v-83.2c0-11.49,9.31-20.8,20.8-20.8Z" ] []
                , path [ d "M207.71,360h83.2c11.49,0,20.8,9.31,20.8,20.8v83.2h-104v-104Z:" ] []
                ]

        gradient =
            linearGradient [ id ("gradient_" ++ id_), gradientTransform "rotate(45)" ]
                [ stop [ offset "0%", stopColor color1 ] []
                , stop [ offset "100%", stopColor color2 ] []
                ]
    in
    svg [ width "100", height "100", viewBox "0 0 520 520", attribute "xmlns" "http://www.w3.org/2000/svg" ]
        [ defs [] [ clipPath, gradient ]
        , g [ Svg.Attributes.clipPath "url(#logo_outline)", fill ("url(#gradient_" ++ id_ ++ ")") ]
            [ rect [ width "520", height "520" ] [] ]
        ]
