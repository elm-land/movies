module Components.Carousel exposing
    ( Msg, update
    , viewPerson, viewMovie
    )

{-|

@docs Msg, update
@docs viewPerson, viewMovie

-}

import Api.Error
import Api.Id
import Api.ImageUrl
import Api.Response
import Browser.Dom
import Components.Icon
import Components.Stars
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events
import Http
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


viewMovie :
    { title : String
    , id : String
    , exploreMore : Maybe Route.Path.Path
    , items :
        Api.Response.Response
            (List
                { movie
                    | id : Api.Id.Id
                    , title : String
                    , vote_average : Float
                    , imageUrl : Api.ImageUrl.ImageUrl
                }
            )
    , noResultsMessage : String
    , onMsg : Msg -> msg
    }
    -> Html msg
viewMovie props =
    let
        toCarouselItem :
            { movie
                | id : Api.Id.Id
                , title : String
                , vote_average : Float
                , imageUrl : Api.ImageUrl.ImageUrl
            }
            -> Item
        toCarouselItem movie =
            { route =
                Route.Path.Movies_MovieId_
                    { movieId = Api.Id.toString movie.id
                    }
            , title = movie.title
            , image = movie.imageUrl
            , details = Rating (movie.vote_average * 10)
            }
    in
    view
        { title = props.title
        , id = props.id
        , exploreMore = props.exploreMore
        , items = props.items |> Api.Response.map (List.map toCarouselItem)
        , noResultsMessage = props.noResultsMessage
        , onMsg = props.onMsg
        }


viewPerson :
    { title : String
    , id : String
    , exploreMore : Maybe Route.Path.Path
    , items :
        Api.Response.Response
            (List
                { person
                    | name : String
                    , imageUrl : String
                    , id : Api.Id.Id
                }
            )
    , toSubheader :
        { person
            | name : String
            , imageUrl : String
            , id : Api.Id.Id
        }
        -> String
    , noResultsMessage : String
    , onMsg : Msg -> msg
    }
    -> Html msg
viewPerson props =
    let
        toCarouselItem : { person | name : String, imageUrl : String, id : Api.Id.Id } -> Item
        toCarouselItem person =
            { title = person.name
            , image = person.imageUrl
            , route =
                Route.Path.People_PersonId_
                    { personId = Api.Id.toString person.id
                    }
            , details = Caption (props.toSubheader person)
            }
    in
    view
        { title = props.title
        , id = props.id
        , exploreMore = props.exploreMore
        , items = props.items |> Api.Response.map (List.map toCarouselItem)
        , noResultsMessage = props.noResultsMessage
        , onMsg = props.onMsg
        }



-- INTERNAL VIEW STUFF


type alias Item =
    { title : String
    , image : String
    , route : Route.Path.Path
    , details : ItemDetails
    }


type ItemDetails
    = Rating Float
    | Caption String


view :
    { title : String
    , id : String
    , exploreMore : Maybe Route.Path.Path
    , items : Api.Response.Response (List Item)
    , noResultsMessage : String
    , onMsg : Msg -> msg
    }
    -> Html msg
view props =
    let
        viewHeader : Html Msg
        viewHeader =
            div [ Attr.class "carousel__header" ]
                [ h3 [ Attr.class "font-h3" ] [ text props.title ]
                , case props.exploreMore of
                    Just route ->
                        a [ Attr.class "font-link", Route.Path.href route ] [ text "Explore more" ]

                    Nothing ->
                        text ""
                ]

        viewLeftArrow : Html Msg
        viewLeftArrow =
            button
                [ Attr.class "carousel__arrow carousel__arrow--left"
                , Html.Events.onClick (ClickedLeftArrow { id = props.id })
                ]
                [ Components.Icon.view
                    { icon = Components.Icon.arrowLeft
                    , isFilled = False
                    }
                ]

        viewRightArrow : Html Msg
        viewRightArrow =
            button
                [ Attr.class "carousel__arrow carousel__arrow--right"
                , Html.Events.onClick (ClickedRightArrow { id = props.id })
                ]
                [ Components.Icon.view
                    { icon = Components.Icon.arrowRight
                    , isFilled = False
                    }
                ]

        viewErrorMessage : String -> Html Msg
        viewErrorMessage message =
            p [ Attr.class "carousel__no-results" ]
                [ text message
                ]

        viewLoadingPlaceholder : Html Msg
        viewLoadingPlaceholder =
            div [ Attr.style "height" "469px" ] []
    in
    Html.map props.onMsg
        (section [ Attr.class "carousel" ]
            [ viewHeader
            , case props.items of
                Api.Response.Loading ->
                    viewLoadingPlaceholder

                Api.Response.Failure httpError ->
                    viewErrorMessage (Api.Error.toHelpfulMessage httpError)

                Api.Response.Success [] ->
                    viewErrorMessage props.noResultsMessage

                Api.Response.Success items ->
                    div [ Attr.class "carousel__body" ]
                        [ viewLeftArrow
                        , div [ Attr.id props.id, Attr.class "carousel__items-container" ]
                            [ div [ Attr.class "carousel__items" ]
                                (List.map viewCarouselItem items)
                            ]
                        , viewRightArrow
                        ]
            ]
        )


viewCarouselItem : Item -> Html Msg
viewCarouselItem item =
    let
        imageUrl : String
        imageUrl =
            "url('${url}')"
                |> String.replace "${url}" item.image
    in
    a
        [ Attr.class "carousel__item"
        , Attr.attribute "aria-label" item.title
        , Route.Path.href item.route
        ]
        [ div [ Attr.class "carousel__image", Attr.style "background-image" imageUrl ] []
        , div [ Attr.class "carousel__content" ]
            [ h4 [ Attr.title item.title, Attr.class "font-h4 max-lines-2" ] [ text item.title ]
            , case item.details of
                Rating rating ->
                    let
                        ratingDecimal : String
                        ratingDecimal =
                            (rating / 20)
                                |> String.fromFloat
                                |> String.left 3
                    in
                    div [ Attr.class "row gap-px8" ]
                        [ Components.Stars.view { rating = rating }
                        , span [ Attr.class "font-body" ] [ text ratingDecimal ]
                        ]

                Caption caption ->
                    p [ Attr.class "carousel__caption" ] [ text caption ]
            ]
        ]
