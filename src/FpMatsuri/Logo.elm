module FpMatsuri.Logo exposing (logoMark)

import Html.Attributes exposing (attribute)
import Svg exposing (Svg, defs, linearGradient, path, rect, stop, svg)
import Svg.Attributes exposing (d, fill, gradientUnits, height, id, offset, rx, ry, stopColor, style, viewBox, width, x, x1, x2, xlinkHref, y, y1, y2)


logoMark : Svg msg
logoMark =
    let
        gradientDefault =
            linearGradient [ id "gradient_default", x1 "145.34", y1 "-162.82", x2 "602.01", y2 "293.85", gradientUnits "userSpaceOnUse" ]
                [ stop [ offset "0%", stopColor "#F4DA0B", style "stop-color:#F4DA0B;stop-color:color(display-p3 0.9569 0.8549 0.0431);stop-opacity:1;" ] []
                , stop [ offset "18%", stopColor "#EEB756", style "stop-color:#EEB756;stop-color:color(display-p3 0.9333 0.7176 0.3373);stop-opacity:1;" ] []
                , stop [ offset "40%", stopColor "#E26264", style "stop-color:#E26264;stop-color:color(display-p3 0.8863 0.3843 0.3922);stop-opacity:1;" ] []
                , stop [ offset "60%", stopColor "#D26058", style "stop-color:#D26058;stop-color:color(display-p3 0.8235 0.3765 0.3451);stop-opacity:1;" ] []
                , stop [ offset "78%", stopColor "#745BA2", style "stop-color:#745BA2;stop-color:color(display-p3 0.4549 0.3569 0.6353);stop-opacity:1;" ] []
                , stop [ offset "100%", stopColor "#5352A0", style "stop-color:#5352A0;stop-color:color(display-p3 0.3255 0.3216 0.6275);stop-opacity:1;" ] []
                ]

        gradient_41 =
            linearGradient [ id "gradient_41", x1 "39.82", y1 "-57.3", x2 "496.49", y2 "399.37", xlinkHref "#gradient_default" ] []

        gradient_42 =
            linearGradient [ id "gradient_42", x1 "39.82", y1 "-57.3", x2 "496.49", y2 "399.37", xlinkHref "#gradient_default" ] []

        gradient_43 =
            linearGradient [ id "gradient_43", x1 "-61.13", y1 "43.66", x2 "395.53", y2 "500.32", xlinkHref "#gradient_default" ] []

        gradient_44 =
            linearGradient [ id "gradient_44", x1 "-64.18", y1 "46.7", x2 "392.49", y2 "503.37", xlinkHref "#gradient_default" ] []
    in
    svg [ width "520", height "417", viewBox "0 0 520 417", attribute "xmlns" "http://www.w3.org/2000/svg" ]
        [ defs [] [ gradientDefault, gradient_41, gradient_42, gradient_43, gradient_44 ]
        , path [ fill "url(#gradient_43)", d "M176.51,104.5c17.23,0,31.2-13.97,31.2-31.2V0.5h-104c-57.44,0-104,46.56-104,104V416.5h104v-104h72.8c17.23,0,31.2-13.97,31.2-31.2v-41.6c0-17.23-13.97-31.2-31.2-31.2h-72.8v-104h72.8Z" ] []
        , path [ fill "url(#gradient_default)", d "M311.71,0.5h72.8c17.23,0,31.2,13.97,31.2,31.2v52c0,11.49-9.31,20.8-20.8,20.8h-62.4c-11.49,0-20.8-9.31-20.8-20.8V0.5Z" ] []
        , path [ fill "url(#gradient_41)", d "M207.71,104.5h83.2c11.49,0,20.8,9.31,20.8,20.8v62.4c0,11.49-9.31,20.8-20.8,20.8h-83.2v-104Z" ] []
        , rect [ fill "#CE3F3D", style "fill:#CE3F3D;fill:color(display-p3 0.8078 0.2471 0.2392);fill-opacity:1;", x "415.71", y "104.5", width "104", height "104", rx "52", ry "52" ] []
        , path [ fill "url(#gradient_42)", d "M332.51,208.5h62.4c11.49,0,20.8,9.31,20.8,20.8v52c0,17.23-13.97,31.2-31.2,31.2h-72.8v-83.2c0-11.49,9.31-20.8,20.8-20.8Z" ] []
        , path [ fill "url(#gradient_44)", d "M207.71,312.5h83.2c11.49,0,20.8,9.31,20.8,20.8v83.2h-104v-104Z" ] []
        ]
