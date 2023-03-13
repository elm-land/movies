module Components.Tabs exposing (view)

{-|

@docs view

-}

import Html exposing (..)
import Html.Attributes as Attr
import Html.Events


type alias Tab id msg =
    { id : id
    , content : Html msg
    }


view :
    { current : id
    , onTabChanged : id -> msg
    , toLabel : id -> String
    , tabs : List (Tab id msg)
    }
    -> Html msg
view props =
    let
        currentTab : Maybe (Tab id msg)
        currentTab =
            props.tabs
                |> List.filter (\tab -> tab.id == props.current)
                |> List.head

        viewTabHeader : Tab id msg -> Html msg
        viewTabHeader tab =
            button
                [ Attr.class "tabs__tab"
                , Attr.classList
                    [ ( "tabs__tab--active", tab.id == props.current )
                    ]
                , Html.Events.onClick (props.onTabChanged tab.id)
                ]
                [ text (props.toLabel tab.id)
                ]
    in
    div [ Attr.class "tabs" ]
        [ div [ Attr.class "tabs__header" ] (List.map viewTabHeader props.tabs)
        , case currentTab of
            Just tab ->
                div [ Attr.class "tabs__content" ] [ tab.content ]

            Nothing ->
                -- NOTE: This can only happen if the `props.tabs` list doesn't include the selected `props.tab`
                div [ Attr.class "tabs__invalid" ] [ text "Something went wrong." ]
        ]
