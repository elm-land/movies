module Pages.Home_ exposing (Model, Msg, page)

import Components.Carousel
import Components.Footer
import Components.Hero
import Effect exposing (Effect)
import Html
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
    {}


init : () -> ( Model, Effect Msg )
init () =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = PopularMoviesCarouselSent Components.Carousel.Msg
    | PopularTvShowsCarouselSent Components.Carousel.Msg


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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Elm Land Movies"
    , body =
        [ Components.Hero.view
            { title = "Knock at the Cabin"
            , link = Just (Route.Path.Movie_MovieId_ { movieId = "123" })
            , description = "While vacationing at a remote cabin, a young girl and her two fathers are taken hostage by four armed strangers who demand that the family make an unthinkable choice to avert the apocalypse. With limited access to the outside world, the family must decide what they believe before all is lost."
            , rating = 73.3434
            , year = 2023
            , duration = "1h 40m"
            , backgroundImageUrl = "https://movies-proxy.vercel.app/ipx/f_webp&s_600x900/tmdb/dm06L9pxDOL9jNSK4Cb6y139rrG.jpg"
            }
        , Components.Carousel.view
            { title = "Popular Movies"
            , id = "popular-movies"
            , route = Route.Path.Movie
            , items =
                List.concat <|
                    List.repeat 20
                        [ { title = "Knock at the Cabin"
                          , route = Route.Path.Movie_MovieId_ { movieId = "123" }
                          , image = "https://movies-proxy.vercel.app/ipx/f_webp&s_400x600/tmdb/dm06L9pxDOL9jNSK4Cb6y139rrG.jpg"
                          , rating = 65
                          }
                        ]
            , onMsg = PopularMoviesCarouselSent
            }
        , Components.Carousel.view
            { title = "Popular TV"
            , id = "popular-tv-shows"
            , route = Route.Path.Tv
            , items =
                List.concat <|
                    List.repeat 20
                        [ { title = "The Last of Us"
                          , route = Route.Path.Tv_ShowId_ { showId = "123" }
                          , image = "https://movies-proxy.vercel.app/ipx/f_webp&s_400x600/tmdb/dm06L9pxDOL9jNSK4Cb6y139rrG.jpg"
                          , rating = 65
                          }
                        ]
            , onMsg = PopularTvShowsCarouselSent
            }
        , Components.Footer.view
        ]
    }
