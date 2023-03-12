module Components.Hero exposing (view)

import Components.Stars
import Html exposing (..)
import Html.Attributes as Attr
import Route.Path


view :
    { title : String
    , category : String
    , link : Maybe Route.Path.Path
    , description : String
    , rating : Float
    , year : Int
    , duration : String
    , backgroundImageUrl : String
    }
    -> Html msg
view props =
    let
        backgroundImage : String
        backgroundImage =
            "url('${imageUrl}')"
                |> String.replace "${imageUrl}" props.backgroundImageUrl

        content : List (Html msg)
        content =
            [ p [ Attr.class "hero__category" ] [ text props.category ]
            , h1 [ Attr.class "hero__title font-h1 textshadow" ] [ text props.title ]
            , div [ Attr.class "row gap-px16" ]
                [ Components.Stars.view { rating = props.rating }
                , span [ Attr.class "textshadow" ] [ text (String.fromInt props.year) ]
                , span [ Attr.class "textshadow" ] [ text props.duration ]
                ]
            , p [ Attr.class "font-paragraph hero__description" ] [ text props.description ]
            ]
    in
    case props.link of
        Just routePath ->
            a
                [ Attr.class "hero hero--interactive"
                , Attr.style "background-image" backgroundImage
                , Route.Path.href routePath
                , Attr.attribute "aria-label" props.title
                ]
                content

        Nothing ->
            section
                [ Attr.class "hero"
                , Attr.style "background-image" backgroundImage
                ]
                content
