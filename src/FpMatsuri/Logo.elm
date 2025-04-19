module FpMatsuri.Logo exposing (logoMark)

import Html.Attributes exposing (attribute)
import Svg exposing (Svg, defs, linearGradient, path, rect, stop, svg)
import Svg.Attributes exposing (d, fill, gradientUnits, height, id, offset, rx, ry, stopColor, viewBox, width, x, x1, x2, xlinkHref, y, y1, y2)


logoMark : Svg msg
logoMark =
    let
        gradientDefault =
            linearGradient [ id "gradient_default", x1 "145.34", y1 "-115.32", x2 "602.01", y2 "341.35", gradientUnits "userSpaceOnUse" ]
                [ stop [ offset "0%", stopColor "#f4da0b" ] []
                , stop [ offset "18%", stopColor "#eeb756" ] []
                , stop [ offset "40%", stopColor "#e26264" ] []
                , stop [ offset "60%", stopColor "#d26058" ] []
                , stop [ offset "78%", stopColor "#745ba2" ] []
                , stop [ offset "100%", stopColor "#5352a0" ] []
                ]

        gradient_41 =
            linearGradient [ id "gradient_41", x1 "39.82", y1 "-9.8", x2 "496.49", y2 "446.87", xlinkHref "#gradient_default" ] []

        gradient_42 =
            linearGradient [ id "gradient_42", x1 "39.82", y1 "-9.8", x2 "496.49", y2 "446.87", xlinkHref "#gradient_default" ] []

        gradient_43 =
            linearGradient [ id "gradient_43", x1 "-61.13", y1 "91.16", x2 "395.53", y2 "547.82", xlinkHref "#gradient_default" ] []

        gradient_44 =
            linearGradient [ id "gradient_44", x1 "-64.18", y1 "94.2", x2 "392.49", y2 "550.87", xlinkHref "#gradient_default" ] []
    in
    svg [ width "100", height "100", viewBox "0 0 520 520", attribute "xmlns" "http://www.w3.org/2000/svg" ]
        [ defs [] [ gradientDefault, gradient_41, gradient_42, gradient_43, gradient_44 ]
        , path [ fill "url(#gradient_43)", d "M176.51,152c17.23,0,31.2-13.97,31.2-31.2V48h-104C46.27,48-.29,94.56-.29,152H-.29v312h104v-104h72.8c17.23,0,31.2-13.97,31.2-31.2v-41.6c0-17.23-13.97-31.2-31.2-31.2h-72.8v-104h72.8Z" ] []
        , path [ fill "url(#gradient_default)", d "M311.71,48h72.8c17.23,0,31.2,13.97,31.2,31.2v52c0,11.49-9.31,20.8-20.8,20.8h-62.4c-11.49,0-20.8-9.31-20.8-20.8V48Z" ] []
        , path [ fill "url(#gradient_41)", d "M207.71,152h83.2c11.49,0,20.8,9.31,20.8,20.8v62.4c0,11.49-9.31,20.8-20.8,20.8h-83.2v-104Z" ] []
        , rect [ fill "#ce3f3d", x "415.71", y "152", width "104", height "104", rx "52", ry "52" ] []
        , path [ fill "url(#gradient_42)", d "M332.51,256h62.4c11.49,0,20.8,9.31,20.8,20.8v52c0,17.23-13.97,31.2-31.2,31.2h-72.8v-83.2c0-11.49,9.31-20.8,20.8-20.8Z" ] []
        , path [ fill "url(#gradient_44)", d "M207.71,360h83.2c11.49,0,20.8,9.31,20.8,20.8v83.2h-104v-104Z:" ] []
        ]
