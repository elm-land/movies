module Components.Carousel exposing
    ( Msg, update
    , viewMovie, viewTvShow
    , viewCastMember
    , viewPersonPhotos, viewPersonCredits
    , Item, ItemDetails(..)
    , viewCarouselItem
    )

{-|

@docs Msg, update

@docs viewMovie, viewTvShow
@docs viewCastMember
@docs viewPersonPhotos, viewPersonCredits

@docs Item, ItemDetails
@docs viewCarouselItem

-}

import Api.Error
import Api.Id
import Api.ImageUrl
import Api.Person.Credits
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
                Just <|
                    Route.Path.Movies_MovieId_
                        { movieId = Api.Id.toString movie.id
                        }
            , title = Just movie.title
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


viewTvShow :
    { title : String
    , id : String
    , exploreMore : Maybe Route.Path.Path
    , items :
        Api.Response.Response
            (List
                { tvShow
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
viewTvShow props =
    let
        toCarouselItem :
            { tvShow
                | id : Api.Id.Id
                , title : String
                , vote_average : Float
                , imageUrl : Api.ImageUrl.ImageUrl
            }
            -> Item
        toCarouselItem tvShow =
            { route =
                Just <|
                    Route.Path.Tv_ShowId_
                        { showId = Api.Id.toString tvShow.id
                        }
            , title = Just tvShow.title
            , image = tvShow.imageUrl
            , details = Rating (tvShow.vote_average * 10)
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


viewPersonPhotos :
    { title : String
    , id : String
    , exploreMore : Maybe Route.Path.Path
    , items :
        Api.Response.Response
            (List
                { person
                    | imageUrl : String
                    , id : Api.Id.Id
                }
            )
    , noResultsMessage : String
    , onMsg : Msg -> msg
    }
    -> Html msg
viewPersonPhotos props =
    let
        toCarouselItem : { person | imageUrl : String, id : Api.Id.Id } -> Item
        toCarouselItem person =
            { title = Nothing
            , image = person.imageUrl
            , route = Nothing
            , details = None
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


viewPersonCredits :
    { title : String
    , id : String
    , exploreMore : Maybe Route.Path.Path
    , items :
        Api.Response.Response
            (List
                { credit
                    | id : Api.Id.Id
                    , imageUrl : String
                    , title : String
                    , character : String
                    , kind : Api.Person.Credits.Kind
                }
            )
    , noResultsMessage : String
    , onMsg : Msg -> msg
    }
    -> Html msg
viewPersonCredits props =
    let
        toCarouselItem :
            { credit
                | id : Api.Id.Id
                , imageUrl : String
                , title : String
                , character : String
                , kind : Api.Person.Credits.Kind
            }
            -> Item
        toCarouselItem credit =
            { title = Just credit.title
            , image = credit.imageUrl
            , route =
                case credit.kind of
                    Api.Person.Credits.Movie ->
                        Route.Path.Movies_MovieId_ { movieId = Api.Id.toString credit.id }
                            |> Just

                    Api.Person.Credits.TvShow ->
                        Route.Path.Tv_ShowId_ { showId = Api.Id.toString credit.id }
                            |> Just
            , details = Caption credit.character
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


viewCastMember :
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
viewCastMember props =
    let
        toCarouselItem : { person | name : String, imageUrl : String, id : Api.Id.Id } -> Item
        toCarouselItem person =
            { title = Just person.name
            , image = person.imageUrl
            , route =
                Just <|
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
    { title : Maybe String
    , image : String
    , route : Maybe Route.Path.Path
    , details : ItemDetails
    }


type ItemDetails
    = None
    | Rating Float
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


viewCarouselItem : Item -> Html msg
viewCarouselItem item =
    let
        imageUrl : String
        imageUrl =
            "url('${url}')"
                |> String.replace "${url}" item.image

        viewElement : List (Html msg) -> Html msg
        viewElement children =
            case item.route of
                Nothing ->
                    span [ Attr.class "carousel__item" ] children

                Just route ->
                    a
                        [ Attr.class "carousel__item"
                        , Attr.attribute "aria-label" (item.title |> Maybe.withDefault "")
                        , Route.Path.href route
                        ]
                        children

        viewCarouselContent : String -> Html msg
        viewCarouselContent title =
            div [ Attr.class "carousel__content" ]
                [ h4 [ Attr.title title, Attr.class "font-h4 max-lines-2" ] [ text title ]
                , case item.details of
                    None ->
                        text ""

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
    in
    viewElement
        [ div [ Attr.class "carousel__image", Attr.style "background-image" imageUrl ] []
        , case item.title of
            Just title ->
                viewCarouselContent title

            Nothing ->
                text ""
        ]
