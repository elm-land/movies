module Components.Carousel exposing
    ( Msg, update
    , view
    , Item
    )

{-|

@docs Msg, update
@docs view

@docs Item

-}

import Browser.Dom
import Components.Icon
import Components.Stars
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events
import Route.Path
import Task exposing (Task)



-- UPDATE


type Msg
    = ClickedLeftArrow { id : String }
    | ClickedRightArrow { id : String }
    | BrowserFinishedScrolling (Result Browser.Dom.Error Browser.Dom.Element)


update :
    { msg : Msg
    , model : model
    , toMsg : Msg -> msg
    }
    -> ( model, Effect msg )
update { msg, model, toMsg } =
    case msg of
        ClickedLeftArrow { id } ->
            ( model
            , Effect.scrollElementLeft { id = id }
                |> Effect.map toMsg
            )

        ClickedRightArrow { id } ->
            ( model
            , Effect.scrollElementRight { id = id }
                |> Effect.map toMsg
            )

        BrowserFinishedScrolling result ->
            ( model
            , Effect.none
            )


scrollLeft : String -> Cmd Msg
scrollLeft id =
    scrollWithOffset -600 id


scrollToRight : String -> Cmd Msg
scrollToRight id =
    scrollWithOffset 600 id


scrollWithOffset : Float -> String -> Cmd Msg
scrollWithOffset offset id =
    let
        fromElementToTask : Browser.Dom.Element -> Task Browser.Dom.Error Browser.Dom.Element
        fromElementToTask element =
            Browser.Dom.setViewportOf
                ("scroll_" ++ id)
                (element.viewport.width + element.viewport.x)
                element.viewport.y
                |> Task.map (\_ -> element)
    in
    Browser.Dom.getElement ("content_" ++ id)
        |> Task.andThen fromElementToTask
        |> Task.attempt BrowserFinishedScrolling



-- VIEW


type alias Item =
    { title : String
    , image : String
    , route : Route.Path.Path
    , rating : Float
    }


view :
    { title : String
    , id : String
    , route : Route.Path.Path
    , items : List Item
    , onMsg : Msg -> msg
    }
    -> Html msg
view props =
    Html.map props.onMsg <|
        section [ Attr.class "carousel" ]
            [ div [ Attr.class "carousel__header" ]
                [ h3 [ Attr.class "font-h3" ] [ text props.title ]
                , a [ Attr.class "font-link", Route.Path.href props.route ] [ text "Explore more" ]
                ]
            , if List.isEmpty props.items then
                p [ Attr.class "carousel__no-results" ]
                    [ text "No results found."
                    ]

              else
                div [ Attr.class "carousel__body" ]
                    [ button
                        [ Attr.class "carousel__arrow carousel__arrow--left"
                        , Html.Events.onClick (ClickedLeftArrow { id = props.id })
                        ]
                        [ Components.Icon.view
                            { icon = Components.Icon.arrowLeft
                            , isFilled = False
                            }
                        ]
                    , div [ Attr.id props.id, Attr.class "carousel__items-container" ]
                        [ div [ Attr.class "carousel__items" ]
                            (List.map viewCarouselItem props.items)
                        ]
                    , button
                        [ Attr.class "carousel__arrow carousel__arrow--right"
                        , Html.Events.onClick (ClickedRightArrow { id = props.id })
                        ]
                        [ Components.Icon.view
                            { icon = Components.Icon.arrowRight
                            , isFilled = False
                            }
                        ]
                    ]
            ]


viewCarouselItem : Item -> Html Msg
viewCarouselItem item =
    let
        imageUrl =
            "url('${url}')"
                |> String.replace "${url}" item.image

        ratingDecimal : String
        ratingDecimal =
            (item.rating / 10)
                |> String.fromFloat
                |> String.left 3
    in
    a
        [ Attr.class "carousel__item"
        , Attr.attribute "aria-label" item.title
        , Route.Path.href item.route
        ]
        [ div [ Attr.class "carousel__image", Attr.style "background-image" imageUrl ] []
        , div [ Attr.class "carousel__content" ]
            [ h4 [ Attr.title item.title, Attr.class "font-h4 max-lines-2" ] [ text item.title ]
            , div [ Attr.class "row gap-px8" ]
                [ Components.Stars.view { rating = item.rating }
                , span [ Attr.class "font-body" ] [ text ratingDecimal ]
                ]
            ]
        ]
