module Pages.People.PersonId_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Route exposing (Route)
import Html
import Page exposing (Page)
import Shared
import View exposing (View)


page : Shared.Model -> Route { personId : String } -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
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


view : Model -> View Msg
view model =
    { title = "Pages.People.PersonId_"
    , body = [ Html.text "/people/:personId" ]
    }
