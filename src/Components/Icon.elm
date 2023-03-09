module Components.Icon exposing
    ( Icon(..)
    , home, movies, tv, search
    , arrowLeft, arrowRight
    , view
    )

{-|

@docs Icon
@docs home, movies, tv, search
@docs arrowLeft, arrowRight
@docs view

-}

import Html exposing (..)
import Html.Attributes as Attr


type Icon
    = Icon Internals


type alias Internals =
    { fill : String
    , outline : String
    }


home : Icon
home =
    Icon
        { fill = "icon-home-fill"
        , outline = "icon-home-outline"
        }


movies : Icon
movies =
    Icon
        { fill = "icon-movies-fill"
        , outline = "icon-movies-outline"
        }


tv : Icon
tv =
    Icon
        { fill = "icon-tv-fill"
        , outline = "icon-tv-outline"
        }


search : Icon
search =
    Icon
        { fill = "icon-search-fill"
        , outline = "icon-search-outline"
        }


arrowLeft : Icon
arrowLeft =
    Icon
        { fill = "icon-arrow-left"
        , outline = "icon-arrow-left"
        }


arrowRight : Icon
arrowRight =
    Icon
        { fill = "icon-arrow-right"
        , outline = "icon-arrow-right"
        }


view : { icon : Icon, isFilled : Bool } -> Html msg
view props =
    let
        (Icon internals) =
            props.icon
    in
    span
        [ if props.isFilled then
            Attr.class internals.fill

          else
            Attr.class internals.outline
        ]
        []
