module Pages.Movies.MovieId_ exposing (Model, Msg, page)

import Api.Duration
import Api.Id
import Api.Movie
import Api.Movie.Details
import Api.Movie.Images
import Api.Movie.Videos
import Api.Response
import Components.Carousel
import Components.Hero
import Components.Tabs
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes as Attr
import Http
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


type alias Params =
    { movieId : String }


page : Shared.Model -> Route Params -> Page Model Msg
page shared route =
    Page.new
        { init = init route.params
        , update = update route.params
        , subscriptions = subscriptions
        , view = view route
        }
        |> Page.withLayout toLayout


toLayout : Model -> Layouts.Layout
toLayout model =
    Layouts.Default { default = {} }



-- INIT


type alias Model =
    { tab : Tab
    , movie : Api.Response.Response Api.Movie.Details.Movie
    , videos : Maybe (Api.Response.Response (List Api.Movie.Videos.Video))
    , images : Maybe (Api.Response.Response (List Api.Movie.Images.Image))
    }


init : Params -> () -> ( Model, Effect Msg )
init params () =
    ( { tab = Overview
      , movie = Api.Response.Loading
      , videos = Nothing
      , images = Nothing
      }
    , Api.Movie.Details.fetch
        { id = Api.Id.fromString params.movieId
        , onResponse = ApiMovieResponded
        }
    )



-- UPDATE


type Msg
    = TabChanged Tab
    | CarouselSent Components.Carousel.Msg
    | ApiMovieResponded (Result Http.Error Api.Movie.Details.Movie)
    | ApiMovieVideosResponsed (Result Http.Error (List Api.Movie.Videos.Video))
    | ApiMovieImagesResponsed (Result Http.Error (List Api.Movie.Images.Image))


update : Params -> Msg -> Model -> ( Model, Effect Msg )
update params msg model =
    case msg of
        TabChanged Overview ->
            ( { model | tab = Overview }
            , Effect.none
            )

        CarouselSent innerMsg ->
            Components.Carousel.update
                { msg = innerMsg
                , model = model
                , toMsg = CarouselSent
                }

        TabChanged Videos ->
            case model.videos of
                Nothing ->
                    ( { model | tab = Videos, videos = Just Api.Response.Loading }
                    , Api.Movie.Videos.fetch
                        { id = Api.Id.fromString params.movieId
                        , onResponse = ApiMovieVideosResponsed
                        }
                    )

                Just response ->
                    ( { model | tab = Videos }
                    , Effect.none
                    )

        TabChanged Photos ->
            case model.videos of
                Nothing ->
                    ( { model | tab = Photos, images = Just Api.Response.Loading }
                    , Api.Movie.Images.fetch
                        { id = Api.Id.fromString params.movieId
                        , onResponse = ApiMovieImagesResponsed
                        }
                    )

                Just response ->
                    ( { model | tab = Photos }
                    , Effect.none
                    )

        ApiMovieResponded result ->
            ( { model | movie = Api.Response.fromResult result }
            , Effect.none
            )

        ApiMovieVideosResponsed result ->
            ( { model | videos = Just (Api.Response.fromResult result) }
            , Effect.none
            )

        ApiMovieImagesResponsed result ->
            ( { model | images = Just (Api.Response.fromResult result) }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Route Params -> Model -> View Msg
view route model =
    { title = toTitle model
    , body =
        case Api.Response.toFailureReason model.movie of
            Just httpError ->
                [ Components.Hero.viewHttpError
                    { httpError = httpError
                    , on404 =
                        { title = "We couldn't find that movie"
                        , description = "This can happen if there's a typo in the URL, or a movie has been deleted from TMDB."
                        }
                    }
                ]

            Nothing ->
                [ viewHero model

                -- , viewTabbedLayout model
                , viewCast model
                , viewSimilarMovies model
                ]
    }


toTitle : Model -> String
toTitle model =
    case model.movie of
        Api.Response.Loading ->
            ""

        Api.Response.Success movie ->
            movie.title

        Api.Response.Failure _ ->
            "404"


viewHero : Model -> Html Msg
viewHero model =
    case Api.Response.toMaybe model.movie of
        Just movie ->
            Components.Hero.viewMovie
                { title = movie.title
                , description = movie.overview
                , movieIdLink = Nothing
                , rating = movie.vote_average * 10
                , year =
                    movie.release_date
                        |> String.left 4
                        |> String.toInt
                        |> Maybe.withDefault 2020
                , duration = Api.Duration.toString movie.duration
                , backgroundImageUrl = movie.imageUrl
                }

        Nothing ->
            div [ Attr.class "hero hero--invisible" ] []



-- TABS


type Tab
    = Overview
    | Videos
    | Photos


fromTabToLabel : Tab -> String
fromTabToLabel tab =
    case tab of
        Overview ->
            "Overview"

        Videos ->
            "Videos"

        Photos ->
            "Photos"


viewTabbedLayout : Model -> Html Msg
viewTabbedLayout model =
    Components.Tabs.view
        { current = model.tab
        , onTabChanged = TabChanged
        , toLabel = fromTabToLabel
        , tabs =
            [ { id = Overview
              , content = viewOverviewTabContent model
              }
            , { id = Videos
              , content = viewVideosTabContent model
              }
            , { id = Photos
              , content = viewPhotosTabContent model
              }
            ]
        }


viewOverviewTabContent : Model -> Html Msg
viewOverviewTabContent model =
    text "Overview content"


viewVideosTabContent : Model -> Html Msg
viewVideosTabContent model =
    text "Videos content"


viewPhotosTabContent : Model -> Html Msg
viewPhotosTabContent model =
    text "Photos content"



-- OTHER SECTIONS


viewCast : Model -> Html Msg
viewCast model =
    Components.Carousel.viewPerson
        { title = "Cast"
        , id = "cast"
        , exploreMore = Nothing
        , items =
            model.movie
                |> Api.Response.map .cast
        , toSubheader = .character
        , noResultsMessage = "No cast members found"
        , onMsg = CarouselSent
        }


viewSimilarMovies : Model -> Html Msg
viewSimilarMovies model =
    Components.Carousel.viewMovie
        { title = "Similar movies"
        , id = "similar"
        , exploreMore = Nothing
        , items =
            model.movie
                |> Api.Response.map .similarMovies
        , noResultsMessage = "No similar movies found"
        , onMsg = CarouselSent
        }
