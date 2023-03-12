module Components.Footer exposing (view)

import Html exposing (..)
import Html.Attributes as Attr


view : Html msg
view =
    footer [ Attr.class "footer" ]
        [ p []
            [ text "Made with "
            , a
                [ Attr.target "_blank"
                , Attr.rel "noopener"
                , Attr.href "https://elm.land"
                ]
                [ div [ Attr.attribute "role" "img", Attr.class "logo", Attr.alt "Elm Land" ] [] ]
            ]
        , p []
            [ text "Data provided by "
            , a
                [ Attr.target "_blank"
                , Attr.rel "noopener"
                , Attr.href "https://www.themoviedb.org/"
                ]
                [ img [ Attr.src "https://www.themoviedb.org/assets/2/v4/logos/v2/blue_short-8e7b30f73a4020692ccca9c88bafe5dcb6f8a62a4c6bc55cd9ba82bb2cd95f6c.svg", Attr.alt "The Movie Database" ] [] ]
            ]
        , p [ Attr.class "disclaimer" ]
            [ text "This project uses the TMDB API but is not endorsed or certified by TMDB."
            ]
        ]
