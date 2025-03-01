module View exposing (View, map)

{-| elm-pages の動作に必要なボイラープレート

elm/html Html以外の型をviewに使用する場合にこのモジュールで型を合わせる
関数型まつりでは rtfeldman/elm-css が独自に定義したHtml型を使用している

<https://elm-pages.com/docs/file-structure#view.elm>

@docs View, map

-}

import Html.Styled exposing (Html)


{-| -}
type alias View msg =
    { title : String
    , body : List (Html msg)
    }


{-| -}
map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn doc =
    { title = doc.title
    , body = List.map (Html.Styled.map fn) doc.body
    }
