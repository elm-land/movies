module Pages.Tv.ShowId_ exposing (Model, Msg, page)

import Api.Duration
import Api.Id
import Api.Response
import Api.Season
import Api.TvShow
import Api.TvShow.Details
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
    { showId : String
    }


page : Shared.Model -> Route { showId : String } -> Page Model Msg
page shared route =
    Page.new
        { init = init route.params
        , update = update route.params
        , subscriptions = subscriptions
        , view = view route
        }
        |> Page.withLayout toLayout


toLayout : Model -> Layouts.Layout Msg
toLayout model =
    Layouts.Default {}



-- INIT


type alias Model =
    { show : Api.Response.Response Api.TvShow.Details.TvShow
    }


init : Params -> () -> ( Model, Effect Msg )
init params () =
    ( { show = Api.Response.Loading
      }
    , Api.TvShow.Details.fetch
        { id = Api.Id.fromString params.showId
        , onResponse = ApiTvShowResponded
        }
    )



-- UPDATE


type Msg
    = CarouselSent Components.Carousel.Msg
    | ApiTvShowResponded (Result Http.Error Api.TvShow.Details.TvShow)


update : Params -> Msg -> Model -> ( Model, Effect Msg )
update params msg model =
    case msg of
        CarouselSent innerMsg ->
            Components.Carousel.update
                { msg = innerMsg
                , model = model
                , toMsg = CarouselSent
                }

        ApiTvShowResponded result ->
            ( { model | show = Api.Response.fromResult result }
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
        case Api.Response.toFailureReason model.show of
            Just httpError ->
                [ Components.Hero.viewHttpError
                    { httpError = httpError
                    , on404 =
                        { title = "We couldn't find that show"
                        , description = "This can happen if there's a typo in the URL, or a show has been deleted from TMDB."
                        }
                    }
                ]

            Nothing ->
                [ viewHero model
                , viewCast model
                , viewSimilarTvShows model
                ]
    }


toTitle : Model -> String
toTitle model =
    case model.show of
        Api.Response.Loading ->
            ""

        Api.Response.Success show ->
            show.name

        Api.Response.Failure _ ->
            "404"


viewHero : Model -> Html Msg
viewHero model =
    case Api.Response.toMaybe model.show of
        Just show ->
            Components.Hero.viewTvShow
                { title = show.name
                , description = show.overview
                , showIdLink = Nothing
                , rating = show.vote_average * 10
                , year =
                    show.first_air_date
                        |> String.left 4
                        |> String.toInt
                        |> Maybe.withDefault 2020
                , duration = Api.Season.toSeasonCountLabel show.seasons
                , backgroundImageUrl = show.imageUrl
                }

        Nothing ->
            div [ Attr.class "hero hero--invisible" ] []



-- OTHER SECTIONS


viewCast : Model -> Html Msg
viewCast model =
    Components.Carousel.viewCastMember
        { title = "Cast"
        , id = "cast"
        , exploreMore = Nothing
        , items =
            model.show
                |> Api.Response.map .cast
        , toSubheader = .character
        , noResultsMessage = "No cast members found"
        , onMsg = CarouselSent
        }


viewSimilarTvShows : Model -> Html Msg
viewSimilarTvShows model =
    Components.Carousel.viewTvShow
        { title = "Similar shows"
        , id = "similar"
        , exploreMore = Nothing
        , items =
            model.show
                |> Api.Response.map .similarTvShows
        , noResultsMessage = "No similar shows found"
        , onMsg = CarouselSent
        }
