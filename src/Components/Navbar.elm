module Components.Navbar exposing (view)

import Components.Icon
import Html exposing (..)
import Html.Attributes as Attr
import Route exposing (Route)
import Route.Path


type alias IconLink =
    { label : String
    , icon : Components.Icon.Icon
    , routePath : Route.Path.Path
    }


view : { currentRoute : Route params } -> Html msg
view props =
    let
        isCurrentRoute : IconLink -> Bool
        isCurrentRoute link =
            props.currentRoute.path == link.routePath

        viewIconLink : IconLink -> Html msg
        viewIconLink link =
            a
                [ Attr.class "navbar__icon-link"
                , Attr.classList
                    [ ( "navbar__icon-link--active", isCurrentRoute link )
                    ]
                , Route.Path.href link.routePath
                , Attr.title link.label
                ]
                [ Components.Icon.view
                    { icon = link.icon
                    , isFilled = isCurrentRoute link
                    }
                ]
    in
    nav [ Attr.class "navbar" ]
        (List.map viewIconLink
            [ { label = "Home"
              , icon = Components.Icon.home
              , routePath = Route.Path.Home_
              }
            , { label = "Movies"
              , icon = Components.Icon.movies
              , routePath = Route.Path.Movies
              }
            , { label = "TV Shows"
              , icon = Components.Icon.tv
              , routePath = Route.Path.Tv
              }
            , { label = "Search"
              , icon = Components.Icon.search
              , routePath = Route.Path.Search
              }
            ]
        )
