module Components.Stars exposing (view)

import Components.Icon
import Html exposing (..)
import Html.Attributes as Attr


view :
    { rating : Float
    }
    -> Html msg
view props =
    let
        {- Example: "65%" -}
        percentage : String
        percentage =
            "${percentage}%"
                |> String.replace "${percentage}" (String.fromFloat props.rating)

        {- Example: "6.5" -}
        score : String
        score =
            (props.rating / 10)
                |> String.fromFloat
                |> String.left 3

        {- Example "Rating: 6.5 out of 10" -}
        label : String
        label =
            "Rating: ${score} out of 10"
                |> String.replace "${score}" score
    in
    div
        [ Attr.class "stars"
        , Attr.attribute "role" "img"
        , Attr.attribute "aria-label" label
        ]
        [ div [ Attr.class "stars__image stars__image--outline" ] []
        , div
            [ Attr.class "stars__image stars__image--filled"
            , Attr.style "width" percentage
            ]
            []
        ]
