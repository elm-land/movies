module Pages.Home_ exposing (Model, Msg, page)

import Api.Movie.Details
import Api.Movie.Popular
import Api.Response
import Api.Runtime
import Api.Tv.Popular
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


toLayout : Model -> Layouts.Layout
toLayout model =
    Layouts.Default { default = {} }



-- INIT


type alias Model =
    { featuredMovie : Api.Response.Response Api.Movie.Details.Movie
    , popularMovies : Api.Response.Response (List Api.Movie.Popular.Movie)
    , popularTvShows : Api.Response.Response (List Api.Tv.Popular.TvShow)
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
        , Api.Tv.Popular.fetch
            { onResponse = ApiPopularTvShowsResponded
            }
        ]
    )



-- UPDATE


type Msg
    = PopularMoviesCarouselSent Components.Carousel.Msg
    | PopularTvShowsCarouselSent Components.Carousel.Msg
    | ApiPopularMoviesResponded (Result Http.Error (List Api.Movie.Popular.Movie))
    | ApiPopularTvShowsResponded (Result Http.Error (List Api.Tv.Popular.TvShow))
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
    { title = "Elm Land Movies"
    , body =
        [ case Api.Response.toMaybe model.featuredMovie of
            Just featuredMovie ->
                Components.Hero.view
                    { title = featuredMovie.title
                    , category = "Movies"
                    , link = Just (Route.Path.Movie_MovieId_ { movieId = String.fromInt featuredMovie.id })
                    , description = featuredMovie.overview
                    , rating = featuredMovie.vote_average * 10
                    , year =
                        featuredMovie.release_date
                            |> String.left 4
                            |> String.toInt
                            |> Maybe.withDefault 2020
                    , duration = Api.Runtime.toString featuredMovie.runtime
                    , backgroundImageUrl = toImageUrl featuredMovie
                    }

            _ ->
                div [ Attr.class "hero hero--invisible" ] []
        , Components.Carousel.view
            { title = "Popular Movies"
            , id = "popular-movies"
            , route = Route.Path.Movie
            , items =
                model.popularMovies
                    |> Api.Response.map (List.map fromMovieToItem)
            , onMsg = PopularMoviesCarouselSent
            }
        , Components.Carousel.view
            { title = "Popular TV"
            , id = "popular-tv-shows"
            , route = Route.Path.Tv
            , items =
                model.popularTvShows
                    |> Api.Response.map (List.map fromTvShowToItem)
            , onMsg = PopularTvShowsCarouselSent
            }
        ]
    }


fromMovieToItem : Api.Movie.Popular.Movie -> Components.Carousel.Item
fromMovieToItem movie =
    { route =
        Route.Path.Movie_MovieId_
            { movieId = String.fromInt movie.id
            }
    , title = movie.title
    , rating = movie.vote_average * 10
    , image = toImageUrl movie
    }


fromTvShowToItem : Api.Tv.Popular.TvShow -> Components.Carousel.Item
fromTvShowToItem show =
    { route =
        Route.Path.Tv_ShowId_
            { showId = String.fromInt show.id
            }
    , title = show.name
    , rating = show.vote_average * 10
    , image = toImageUrl show
    }


toImageUrl : { item | poster_path : String } -> String
toImageUrl { poster_path } =
    "https://www.themoviedb.org/t/p/w440_and_h660_face" ++ poster_path
