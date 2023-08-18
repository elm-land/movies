module Components.Hero exposing
    ( viewHttpError
    , viewMovie
    , viewTvShow
    )

import Api.Id
import Components.Stars
import Html exposing (..)
import Html.Attributes as Attr
import Http
import Route.Path


viewTvShow :
    { title : String
    , showIdLink : Maybe Api.Id.Id
    , description : String
    , rating : Float
    , year : Int
    , duration : String
    , backgroundImageUrl : String
    }
    -> Html msg
viewTvShow props =
    view
        { category = Just "Tv Show"
        , title = props.title
        , description = props.description
        , link =
            case props.showIdLink of
                Just id ->
                    Just
                        (Route.Path.Tv_ShowId_
                            { showId = Api.Id.toString id
                            }
                        )

                Nothing ->
                    Nothing
        , backgroundImageUrl = Just props.backgroundImageUrl
        , subheader =
            Just
                (div [ Attr.class "row gap-px16" ]
                    [ Components.Stars.view { rating = props.rating }
                    , span [ Attr.class "textshadow" ] [ text (String.fromInt props.year) ]
                    , span [ Attr.class "textshadow" ] [ text props.duration ]
                    ]
                )
        }


viewMovie :
    { title : String
    , movieIdLink : Maybe Api.Id.Id
    , description : String
    , rating : Float
    , year : Int
    , duration : String
    , backgroundImageUrl : String
    }
    -> Html msg
viewMovie props =
    view
        { category = Just "Movie"
        , title = props.title
        , description = props.description
        , link =
            case props.movieIdLink of
                Just id ->
                    Just
                        (Route.Path.Movies_MovieId_
                            { movieId = Api.Id.toString id
                            }
                        )

                Nothing ->
                    Nothing
        , backgroundImageUrl = Just props.backgroundImageUrl
        , subheader =
            Just
                (div [ Attr.class "row gap-px16" ]
                    [ Components.Stars.view { rating = props.rating }
                    , span [ Attr.class "textshadow" ] [ text (String.fromInt props.year) ]
                    , span [ Attr.class "textshadow" ] [ text props.duration ]
                    ]
                )
        }


viewHttpError : { httpError : Http.Error, on404 : { title : String, description : String } } -> Html msg
viewHttpError props =
    case props.httpError of
        Http.BadStatus 404 ->
            viewSimpleHero
                { title = props.on404.title
                , description = props.on404.description
                , backgroundImageUrl = Just "/images/404.gif"
                }

        Http.BadStatus 401 ->
            viewSimpleHero
                { title = "Invalid API key"
                , description = "This can happen when the TMDB API thinks our API key isn't valid."
                , backgroundImageUrl = Nothing
                }

        Http.BadStatus statusCode ->
            viewSimpleHero
                { title = String.fromInt statusCode ++ " error?"
                , description =
                    "The Movie Database API returned a ${code} error with this request. Please try again later!"
                        |> String.replace "${code}" (String.fromInt statusCode)
                , backgroundImageUrl = Nothing
                }

        Http.BadBody _ ->
            viewSimpleHero
                { title = "Unexpected API response"
                , description = "This page didn't understand the data that was returned from the API. Please report this issue!"
                , backgroundImageUrl = Nothing
                }

        Http.NetworkError ->
            viewSimpleHero
                { title = "Couldn't reach TMDB"
                , description = "This can happen if the TMDB API is offline, or if your device is not connected to the internet. Please try again."
                , backgroundImageUrl = Nothing
                }

        Http.Timeout ->
            viewSimpleHero
                { title = "Request timed out"
                , description = "This can happen if the TMDB API is offline, or if your device is not connected to the internet. Please try again."
                , backgroundImageUrl = Nothing
                }

        Http.BadUrl _ ->
            viewSimpleHero
                { title = "Bad URL"
                , description = "Oh no, it looks like this page sent a invalid request to the API. Please report this issue!"
                , backgroundImageUrl = Nothing
                }


viewSimpleHero :
    { title : String
    , description : String
    , backgroundImageUrl : Maybe String
    }
    -> Html msg
viewSimpleHero props =
    view
        { category = Nothing
        , title = props.title
        , description = props.description
        , link = Nothing
        , backgroundImageUrl = props.backgroundImageUrl
        , subheader = Nothing
        }


view :
    { title : String
    , description : String
    , category : Maybe String
    , link : Maybe Route.Path.Path
    , subheader : Maybe (Html msg)
    , backgroundImageUrl : Maybe String
    }
    -> Html msg
view props =
    let
        backgroundImage : String
        backgroundImage =
            case props.backgroundImageUrl of
                Just imageUrl ->
                    "url('${imageUrl}')"
                        |> String.replace "${imageUrl}" imageUrl

                Nothing ->
                    "none"

        content : List (Html msg)
        content =
            [ p [ Attr.class "hero__category" ] [ text (props.category |> Maybe.withDefault "") ]
            , h1 [ Attr.class "hero__title font-h1 textshadow" ] [ text props.title ]
            , props.subheader |> Maybe.withDefault (text "")
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
