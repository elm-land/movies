module Layouts.Default exposing (Model, Msg, Settings, layout)

import Components.ErrorDialog
import Components.Navbar
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes exposing (class)
import Layout exposing (Layout)
import Route exposing (Route)
import Shared
import View exposing (View)


type alias Settings =
    {}


layout : Settings -> Shared.Model -> Route () -> Layout Model Msg mainMsg
layout settings shared route =
    Layout.new
        { init = init
        , update = update
        , view = view shared route
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init _ =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model
            , Effect.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view :
    Shared.Model
    -> Route ()
    -> { fromMsg : Msg -> mainMsg, content : View mainMsg, model : Model }
    -> View mainMsg
view shared route { fromMsg, model, content } =
    { title = content.title
    , body =
        if shared.apiToken == Nothing then
            [ Components.ErrorDialog.view
                { title = "Missing API token"
                , body = """
                    You're seeing this message because the __Elm Land Movies__ application
                    couldn't find an `TMDB_API_TOKEN`.

                    Please visit the README to learn more.
                """
                }
            ]

        else
            [ Html.div [ class "layout" ]
                [ Components.Navbar.view
                    { currentRoute = route
                    }
                , Html.div [ class "layout__page" ] content.body
                ]
            ]
    }
