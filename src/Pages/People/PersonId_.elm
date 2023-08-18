module Pages.People.PersonId_ exposing (Model, Msg, page)

import Api.Error
import Api.Id
import Api.Person.Details
import Api.Person.Images
import Api.Response exposing (Response)
import Components.Carousel
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes as Attr
import Http
import Layouts exposing (Layout)
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route { personId : String } -> Page Model Msg
page shared route =
    Page.new
        { init = init route.params
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
    { person : Response Api.Person.Details.Person
    , images : Response (List Api.Person.Images.Image)
    }


init : { personId : String } -> () -> ( Model, Effect Msg )
init params () =
    ( { person = Api.Response.Loading
      , images = Api.Response.Loading
      }
    , Effect.batch
        [ Api.Person.Details.fetch
            { id = Api.Id.fromString params.personId
            , onResponse = ApiPersonResponded
            }
        , Api.Person.Images.fetch
            { id = Api.Id.fromString params.personId
            , onResponse = ApiPersonImagesResponded
            }
        ]
    )



-- UPDATE


type Msg
    = ApiPersonResponded (Result Http.Error Api.Person.Details.Person)
    | ApiPersonImagesResponded (Result Http.Error (List Api.Person.Images.Image))
    | CarouselSent Components.Carousel.Msg


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        CarouselSent innerMsg ->
            Components.Carousel.update
                { msg = innerMsg
                , model = model
                , toMsg = CarouselSent
                }

        ApiPersonResponded (Ok person) ->
            ( { model | person = Api.Response.Success person }
            , Effect.none
            )

        ApiPersonResponded (Err httpError) ->
            ( { model | person = Api.Response.Failure httpError }
            , Effect.none
            )

        ApiPersonImagesResponded (Ok images) ->
            ( { model | images = Api.Response.Success images }
            , Effect.none
            )

        ApiPersonImagesResponded (Err httpError) ->
            ( { model | images = Api.Response.Failure httpError }
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
        [ case ( model.person, model.images ) of
            ( Api.Response.Loading, _ ) ->
                viewLoading

            ( _, Api.Response.Loading ) ->
                viewLoading

            ( Api.Response.Failure httpError, _ ) ->
                viewError httpError

            ( _, Api.Response.Failure httpError ) ->
                viewError httpError

            ( Api.Response.Success person, Api.Response.Success images ) ->
                viewPerson
                    { person = person
                    , images = images
                    }
        ]
    }


viewLoading : Html Msg
viewLoading =
    text "Loading..."


viewError : Http.Error -> Html Msg
viewError httpError =
    text (Api.Error.toHelpfulMessage httpError)


viewPerson :
    { person : Api.Person.Details.Person
    , images : List Api.Person.Images.Image
    }
    -> Html Msg
viewPerson { person, images } =
    let
        bioParagraphs : List (Html msg)
        bioParagraphs =
            person.bio
                |> String.split "\n\n"
                |> List.map (\line -> p [] [ text line ])
    in
    div [ Attr.class "" ]
        [ div [ Attr.class "page--person-detail row responsive gap-px32 mobile-align-center" ]
            [ div [ Attr.class "person__image" ]
                [ case List.head images of
                    Nothing ->
                        text ""

                    Just image ->
                        img [ Attr.src image.url, Attr.class "image" ] []
                ]
            , div [ Attr.class "col gap-px16" ]
                [ h1 [ Attr.class "font-h1" ] [ text person.name ]
                , div [ Attr.class "markdown" ] bioParagraphs
                ]
            ]
        , viewPhotos images
        ]


viewPhotos : List Api.Person.Images.Image -> Html Msg
viewPhotos images =
    Components.Carousel.viewPersonPhotos
        { title = "Photos"
        , id = "photos"
        , exploreMore = Nothing
        , items =
            images
                |> List.map
                    (\image ->
                        { id = Api.Id.fromString image.url
                        , imageUrl = image.url
                        }
                    )
                |> Api.Response.Success
        , noResultsMessage = "No photos found"
        , onMsg = CarouselSent
        }
