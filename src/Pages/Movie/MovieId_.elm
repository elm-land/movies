module Pages.Movie.MovieId_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


type alias Params =
    { movieId : String }


page : Shared.Model -> Route Params -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view route
        }



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
    = ExampleMsgReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ExampleMsgReplaceMe ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Route Params -> Model -> View Msg
view route model =
    { title = "Pages.Movie.MovieId_"
    , body = [ Html.text ("/movie/" ++ route.params.movieId) ]
    }
