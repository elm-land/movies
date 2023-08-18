module Pages.Home_ exposing (Model, Msg, page)

import Api.Duration
import Api.Id
import Api.Movie
import Api.Movie.Details
import Api.Movie.Popular
import Api.Response
import Api.TvShow.Popular
import Components.Carousel
import Components.Footer
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
    , popularTvShows : Api.Response.Response (List Api.TvShow.Popular.TvShow)
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { featuredMovie = Api.Response.Loading
      , popularMovies = Api.Response.Loading
      , popularTvShows = Api.Response.Loading
      }
    , Effect.batch
        [ Api.Movie.Popular.fetch
            { onResponse = ApiPopularMoviesResponded
            }
        , Api.TvShow.Popular.fetch
            { onResponse = ApiPopularTvShowsResponded
            }
        ]
    )



-- UPDATE


type Msg
    = PopularMoviesCarouselSent Components.Carousel.Msg
    | PopularTvShowsCarouselSent Components.Carousel.Msg
    | ApiPopularMoviesResponded (Result Http.Error (List Api.Movie.Popular.Movie))
    | ApiPopularTvShowsResponded (Result Http.Error (List Api.TvShow.Popular.TvShow))
    | ApiFeaturedMovieResponded (Result Http.Error Api.Movie.Details.Movie)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        PopularMoviesCarouselSent innerMsg ->
            Components.Carousel.update
                { model = model
                , msg = innerMsg
                , toMsg = PopularMoviesCarouselSent
                }

        PopularTvShowsCarouselSent innerMsg ->
            Components.Carousel.update
                { model = model
                , msg = innerMsg
                , toMsg = PopularTvShowsCarouselSent
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

        ApiPopularTvShowsResponded result ->
            ( { model | popularTvShows = Api.Response.fromResult result }
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
    { title = ""
    , body =
        [ case Api.Response.toMaybe model.featuredMovie of
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
        , Components.Carousel.viewMovie
            { title = "Popular Movies"
            , id = "popular-movies"
            , exploreMore = Just Route.Path.Movies
            , items = model.popularMovies
            , noResultsMessage = "No popular movies found"
            , onMsg = PopularMoviesCarouselSent
            }
        , Components.Carousel.viewTvShow
            { title = "Popular TV"
            , id = "popular-tv-shows"
            , exploreMore = Just Route.Path.Tv
            , items = model.popularTvShows
            , noResultsMessage = "No popular TV shows found"
            , onMsg = PopularTvShowsCarouselSent
            }
        ]
    }
