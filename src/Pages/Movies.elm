module Pages.Movies exposing (Model, Msg, page)

import Api.Duration
import Api.Id
import Api.Movie
import Api.Movie.Details
import Api.Movie.NowPlaying
import Api.Movie.Popular
import Api.Movie.TopRated
import Api.Movie.Upcoming
import Api.Response
import Components.Carousel
import Components.Hero
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


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
        |> Page.withLayout toLayout


toLayout : Model -> Layouts.Layout Msg
toLayout model =
    Layouts.Default {}



-- INIT


type alias Model =
    { featuredMovie : Api.Response.Response Api.Movie.Details.Movie
    , popularMovies : Api.Response.Response (List Api.Movie.Popular.Movie)
    , topRatedMovies : Api.Response.Response (List Api.Movie.Popular.Movie)
    , upcomingMovies : Api.Response.Response (List Api.Movie.Popular.Movie)
    , nowPlayingMovies : Api.Response.Response (List Api.Movie.Popular.Movie)
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { featuredMovie = Api.Response.Loading
      , popularMovies = Api.Response.Loading
      , topRatedMovies = Api.Response.Loading
      , upcomingMovies = Api.Response.Loading
      , nowPlayingMovies = Api.Response.Loading
      }
    , Effect.batch
        [ Api.Movie.Popular.fetch
            { onResponse = ApiPopularMoviesResponded
            }
        , Api.Movie.TopRated.fetch
            { onResponse = ApiTopRatedMoviesResponded
            }
        , Api.Movie.Upcoming.fetch
            { onResponse = ApiUpcomingMoviesResponded
            }
        , Api.Movie.NowPlaying.fetch
            { onResponse = ApiNowPlayingMoviesResponded
            }
        ]
    )



-- UPDATE


type Msg
    = CarouselSent Components.Carousel.Msg
    | ApiPopularMoviesResponded (Result Http.Error (List Api.Movie.Popular.Movie))
    | ApiTopRatedMoviesResponded (Result Http.Error (List Api.Movie.TopRated.Movie))
    | ApiUpcomingMoviesResponded (Result Http.Error (List Api.Movie.Upcoming.Movie))
    | ApiNowPlayingMoviesResponded (Result Http.Error (List Api.Movie.NowPlaying.Movie))
    | ApiFeaturedMovieResponded (Result Http.Error Api.Movie.Details.Movie)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        CarouselSent innerMsg ->
            Components.Carousel.update
                { model = model
                , msg = innerMsg
                , toMsg = CarouselSent
                }

        ApiPopularMoviesResponded result ->
            let
                popularMovies : Api.Response.Response (List Api.Movie.Popular.Movie)
                popularMovies =
                    Api.Response.fromResult result
            in
            case result of
                Ok (firstPopularMovie :: _) ->
                    ( { model | popularMovies = popularMovies }
                    , Api.Movie.Details.fetch
                        { id = firstPopularMovie.id
                        , onResponse = ApiFeaturedMovieResponded
                        }
                    )

                _ ->
                    ( { model | popularMovies = popularMovies }
                    , Effect.none
                    )

        ApiTopRatedMoviesResponded result ->
            ( { model | topRatedMovies = Api.Response.fromResult result }
            , Effect.none
            )

        ApiUpcomingMoviesResponded result ->
            ( { model | upcomingMovies = Api.Response.fromResult result }
            , Effect.none
            )

        ApiNowPlayingMoviesResponded result ->
            ( { model | nowPlayingMovies = Api.Response.fromResult result }
            , Effect.none
            )

        ApiFeaturedMovieResponded result ->
            ( { model | featuredMovie = Api.Response.fromResult result }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Movies"
    , body =
        [ viewFeaturedMovie model
        , viewPopularMovies model
        , viewTopRatedMovies model
        , viewUpcomingMovies model
        , viewNowPlayingMovies model
        ]
    }


viewFeaturedMovie : Model -> Html Msg
viewFeaturedMovie model =
    case Api.Response.toMaybe model.featuredMovie of
        Just featuredMovie ->
            Components.Hero.viewMovie
                { title = featuredMovie.title
                , movieIdLink = Just featuredMovie.id
                , description = featuredMovie.overview
                , rating = featuredMovie.vote_average * 10
                , year =
                    featuredMovie.release_date
                        |> String.left 4
                        |> String.toInt
                        |> Maybe.withDefault 2020
                , duration = Api.Duration.toString featuredMovie.duration
                , backgroundImageUrl = featuredMovie.imageUrl
                }

        _ ->
            div [ Attr.class "hero hero--invisible" ] []


viewPopularMovies : Model -> Html Msg
viewPopularMovies model =
    Components.Carousel.viewMovie
        { title = "Popular Movies"
        , id = "popular-movies"
        , exploreMore = Nothing
        , items = model.popularMovies
        , noResultsMessage = "No movies found"
        , onMsg = CarouselSent
        }


viewTopRatedMovies : Model -> Html Msg
viewTopRatedMovies model =
    Components.Carousel.viewMovie
        { title = "Top Rated Movies"
        , id = "top-rated-movies"
        , exploreMore = Nothing
        , items = model.topRatedMovies
        , noResultsMessage = "No movies found"
        , onMsg = CarouselSent
        }


viewUpcomingMovies : Model -> Html Msg
viewUpcomingMovies model =
    Components.Carousel.viewMovie
        { title = "Upcoming Movies"
        , id = "upcoming-movies"
        , exploreMore = Nothing
        , items = model.upcomingMovies
        , noResultsMessage = "No movies found"
        , onMsg = CarouselSent
        }


viewNowPlayingMovies : Model -> Html Msg
viewNowPlayingMovies model =
    Components.Carousel.viewMovie
        { title = "Now Playing Movies"
        , id = "now-playing-movies"
        , exploreMore = Nothing
        , items = model.nowPlayingMovies
        , noResultsMessage = "No movies found"
        , onMsg = CarouselSent
        }
