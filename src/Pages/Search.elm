module Pages.Search exposing (Model, Msg, page)

import Api.Error
import Api.Id
import Api.Response exposing (Response)
import Api.Search
import Components.Carousel
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events
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
    { query : String
    , searchResults : Maybe (Response (List Api.Search.SearchResult))
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { query = ""
      , searchResults = Nothing
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = SearchInputChanged String
    | UserChangedInput String
    | ApiSearchResponded (Result Http.Error (List Api.Search.SearchResult))


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SearchInputChanged value ->
            ( { model
                | query = value
                , searchResults = Just Api.Response.Loading
              }
            , Effect.sendDelayedMsg 500
                (UserChangedInput value)
            )

        UserChangedInput value ->
            ( model
            , if value == model.query then
                Api.Search.get
                    { query = value
                    , onResponse = ApiSearchResponded
                    }

              else
                Effect.none
            )

        ApiSearchResponded result ->
            ( { model | searchResults = Just (Api.Response.fromResult result) }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Search"
    , body =
        [ div [ Attr.class "page--search col gap-px32" ]
            [ label [ Attr.class "input__container col gap-px16" ]
                [ span [ Attr.class "input__label font-h3" ]
                    [ text "Search for movies, TV shows, and people" ]
                , form [ Attr.class "input__search" ]
                    [ span [ Attr.class "icon-search-outline input__icon" ] []
                    , input
                        [ Attr.class "input"
                        , Html.Events.onInput SearchInputChanged
                        , Attr.value model.query
                        ]
                        []
                    ]
                ]
            , case model.searchResults of
                Nothing ->
                    text ""

                Just Api.Response.Loading ->
                    text "Loading..."

                Just (Api.Response.Success results) ->
                    viewSearchResults results

                Just (Api.Response.Failure httpError) ->
                    text (Api.Error.toHelpfulMessage httpError)
            ]
        ]
    }


viewSearchResults : List Api.Search.SearchResult -> Html msg
viewSearchResults searchResults =
    div [ Attr.class "grid gap-px32" ]
        (List.map viewSearchResult searchResults)


viewSearchResult : Api.Search.SearchResult -> Html msg
viewSearchResult searchResult =
    case searchResult of
        Api.Search.On_Movie movie ->
            Components.Carousel.viewCarouselItem
                { title = Just movie.title
                , image = movie.imageUrl
                , route =
                    Just
                        (Route.Path.Movies_MovieId_
                            { movieId = Api.Id.toString movie.id
                            }
                        )
                , details = Components.Carousel.Caption "Movie"
                }

        Api.Search.On_TvShow show ->
            Components.Carousel.viewCarouselItem
                { title = Just show.title
                , image = show.imageUrl
                , route =
                    Just
                        (Route.Path.Tv_ShowId_
                            { showId = Api.Id.toString show.id
                            }
                        )
                , details = Components.Carousel.Caption "TV Show"
                }

        Api.Search.On_Person person ->
            Components.Carousel.viewCarouselItem
                { title = Just person.name
                , image = person.imageUrl
                , route =
                    Just
                        (Route.Path.People_PersonId_
                            { personId = Api.Id.toString person.id
                            }
                        )
                , details = Components.Carousel.Caption "Person"
                }
