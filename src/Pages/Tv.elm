module Pages.Tv exposing (Model, Msg, page)

import Api.Duration
import Api.Id
import Api.Response
import Api.TvShow
import Api.TvShow.AiringToday
import Api.TvShow.Details
import Api.TvShow.Popular
import Api.TvShow.TopRated
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
    { featuredTvShow : Api.Response.Response Api.TvShow.Details.TvShow
    , popularTvShows : Api.Response.Response (List Api.TvShow.Popular.TvShow)
    , topRatedTvShows : Api.Response.Response (List Api.TvShow.TopRated.TvShow)
    , airingTodayTvShows : Api.Response.Response (List Api.TvShow.AiringToday.TvShow)
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { featuredTvShow = Api.Response.Loading
      , popularTvShows = Api.Response.Loading
      , topRatedTvShows = Api.Response.Loading
      , airingTodayTvShows = Api.Response.Loading
      }
    , Effect.batch
        [ Api.TvShow.Popular.fetch
            { onResponse = ApiPopularTvShowsResponded
            }
        , Api.TvShow.TopRated.fetch
            { onResponse = ApiTopRatedTvShowsResponded
            }
        , Api.TvShow.AiringToday.fetch
            { onResponse = ApiAiringTodayTvShowsResponded
            }
        ]
    )



-- UPDATE


type Msg
    = CarouselSent Components.Carousel.Msg
    | ApiPopularTvShowsResponded (Result Http.Error (List Api.TvShow.Popular.TvShow))
    | ApiTopRatedTvShowsResponded (Result Http.Error (List Api.TvShow.TopRated.TvShow))
    | ApiAiringTodayTvShowsResponded (Result Http.Error (List Api.TvShow.AiringToday.TvShow))
    | ApiFeaturedTvShowResponded (Result Http.Error Api.TvShow.Details.TvShow)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        CarouselSent innerMsg ->
            Components.Carousel.update
                { model = model
                , msg = innerMsg
                , toMsg = CarouselSent
                }

        ApiFeaturedTvShowResponded result ->
            ( { model | featuredTvShow = Api.Response.fromResult result }
            , Effect.none
            )

        ApiPopularTvShowsResponded result ->
            let
                popularTvShows : Api.Response.Response (List Api.TvShow.Popular.TvShow)
                popularTvShows =
                    Api.Response.fromResult result
            in
            case result of
                Ok (firstPopularTvShow :: _) ->
                    ( { model | popularTvShows = popularTvShows }
                    , Api.TvShow.Details.fetch
                        { id = firstPopularTvShow.id
                        , onResponse = ApiFeaturedTvShowResponded
                        }
                    )

                _ ->
                    ( { model | popularTvShows = popularTvShows }
                    , Effect.none
                    )

        ApiTopRatedTvShowsResponded result ->
            ( { model | topRatedTvShows = Api.Response.fromResult result }
            , Effect.none
            )

        ApiAiringTodayTvShowsResponded result ->
            ( { model | airingTodayTvShows = Api.Response.fromResult result }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "TvShows"
    , body =
        [ viewFeaturedTvShow model
        , viewPopularTvShows model
        , viewTopRatedTvShows model
        , viewAiringTodayTvShows model
        ]
    }


viewFeaturedTvShow : Model -> Html Msg
viewFeaturedTvShow model =
    case Api.Response.toMaybe model.featuredTvShow of
        Just featuredTvShow ->
            let
                numberOfSeasons : Int
                numberOfSeasons =
                    List.length featuredTvShow.seasons
            in
            Components.Hero.viewTvShow
                { title = featuredTvShow.name
                , showIdLink = Just featuredTvShow.id
                , description = featuredTvShow.overview
                , rating = featuredTvShow.vote_average * 10
                , year =
                    featuredTvShow.first_air_date
                        |> String.left 4
                        |> String.toInt
                        |> Maybe.withDefault 2020
                , duration =
                    if numberOfSeasons == 1 then
                        "1 season"

                    else
                        String.fromInt numberOfSeasons ++ " seasons"
                , backgroundImageUrl = featuredTvShow.imageUrl
                }

        _ ->
            div [ Attr.class "hero hero--invisible" ] []


viewPopularTvShows : Model -> Html Msg
viewPopularTvShows model =
    Components.Carousel.viewTvShow
        { title = "Popular"
        , id = "popular-movies"
        , exploreMore = Nothing
        , items = model.popularTvShows
        , noResultsMessage = "No movies found"
        , onMsg = CarouselSent
        }


viewTopRatedTvShows : Model -> Html Msg
viewTopRatedTvShows model =
    Components.Carousel.viewTvShow
        { title = "Top Rated"
        , id = "top-rated-movies"
        , exploreMore = Nothing
        , items = model.topRatedTvShows
        , noResultsMessage = "No movies found"
        , onMsg = CarouselSent
        }


viewAiringTodayTvShows : Model -> Html Msg
viewAiringTodayTvShows model =
    Components.Carousel.viewTvShow
        { title = "Airing today"
        , id = "upcoming-movies"
        , exploreMore = Nothing
        , items = model.airingTodayTvShows
        , noResultsMessage = "No movies found"
        , onMsg = CarouselSent
        }
