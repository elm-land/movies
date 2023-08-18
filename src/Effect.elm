port module Effect exposing
    ( Effect
    , none, batch
    , sendCmd, sendMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , sendApiRequest
    , scrollElementLeft
    , scrollElementRight
    , map, toCmd
    )

{-|

@docs Effect
@docs none, batch
@docs sendCmd, sendMsg
@docs pushRoute, replaceRoute, loadExternalUrl

@docs sendApiRequest

@docs scrollElementLeft
@docs scrollElementRight

@docs map, toCmd

-}

import Browser.Navigation
import Dict exposing (Dict)
import Http
import Json.Decode
import Json.Encode
import Route exposing (Route)
import Route.Path
import Route.Query
import Shared.Model
import Shared.Msg
import Task
import Url exposing (Url)


type Effect msg
    = -- BASICS
      None
    | Batch (List (Effect msg))
    | SendCmd (Cmd msg)
      -- ROUTING
    | PushUrl String
    | ReplaceUrl String
    | LoadExternalUrl String
      -- SHARED
    | SendSharedMsg Shared.Msg.Msg
      -- SCROLLING
    | ScrollElement { id : String, direction : ScrollDirection }
      -- API
    | SendApiRequest
        { endpoint : String
        , decoder : Json.Decode.Decoder msg
        , onMissingToken : msg
        , onHttpError : Http.Error -> msg
        }



-- BASICS


{-| Don't send any effect.
-}
none : Effect msg
none =
    None


{-| Send multiple effects at once.
-}
batch : List (Effect msg) -> Effect msg
batch =
    Batch


{-| Send a normal `Cmd msg` as an effect, something like `Http.get` or `Random.generate`.
-}
sendCmd : Cmd msg -> Effect msg
sendCmd =
    SendCmd


{-| Send a message as an effect. Useful when emitting events from UI components.
-}
sendMsg : msg -> Effect msg
sendMsg msg =
    Task.succeed msg
        |> Task.perform identity
        |> SendCmd



-- ROUTING


{-| Set the new route, and make the back button go back to the current route.
-}
pushRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
pushRoute route =
    PushUrl (Route.toString route)


{-| Set the new route, but replace the previous one, so clicking the back
button **won't** go back to the previous route.
-}
replaceRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
replaceRoute route =
    ReplaceUrl (Route.toString route)


{-| Redirect users to a new URL, somewhere external your web application.
-}
loadExternalUrl : String -> Effect msg
loadExternalUrl =
    LoadExternalUrl



-- SCROLLING


type ScrollDirection
    = Left
    | Right


scrollElementLeft : { id : String } -> Effect msg
scrollElementLeft { id } =
    ScrollElement { id = id, direction = Left }


scrollElementRight : { id : String } -> Effect msg
scrollElementRight { id } =
    ScrollElement { id = id, direction = Right }



-- TMDB API


sendApiRequest : { endpoint : String, decoder : Json.Decode.Decoder value, onResponse : Result Http.Error value -> msg } -> Effect msg
sendApiRequest options =
    SendApiRequest
        { endpoint = options.endpoint
        , decoder =
            Json.Decode.map (Ok >> options.onResponse)
                options.decoder
        , onMissingToken = options.onResponse (Err (Http.BadUrl "Token not provided"))
        , onHttpError = Err >> options.onResponse
        }



-- INTERNALS


{-| Elm Land depends on this function to connect pages and layouts
together into the overall app.
-}
map : (msg1 -> msg2) -> Effect msg1 -> Effect msg2
map fn effect =
    case effect of
        None ->
            None

        Batch list ->
            Batch (List.map (map fn) list)

        SendCmd cmd ->
            SendCmd (Cmd.map fn cmd)

        PushUrl url ->
            PushUrl url

        ReplaceUrl url ->
            ReplaceUrl url

        LoadExternalUrl url ->
            LoadExternalUrl url

        SendSharedMsg sharedMsg ->
            SendSharedMsg sharedMsg

        ScrollElement info ->
            ScrollElement info

        SendApiRequest info ->
            SendApiRequest
                { endpoint = info.endpoint
                , decoder = Json.Decode.map fn info.decoder
                , onMissingToken = fn info.onMissingToken
                , onHttpError = \httpError -> fn (info.onHttpError httpError)
                }


{-| Elm Land depends on this function to perform your effects.
-}
toCmd :
    { key : Browser.Navigation.Key
    , url : Url
    , shared : Shared.Model.Model
    , fromSharedMsg : Shared.Msg.Msg -> msg
    , batch : List msg -> msg
    , toCmd : msg -> Cmd msg
    }
    -> Effect msg
    -> Cmd msg
toCmd options effect =
    case effect of
        None ->
            Cmd.none

        Batch list ->
            Cmd.batch (List.map (toCmd options) list)

        SendCmd cmd ->
            cmd

        PushUrl url ->
            Browser.Navigation.pushUrl options.key url

        ReplaceUrl url ->
            Browser.Navigation.replaceUrl options.key url

        LoadExternalUrl url ->
            Browser.Navigation.load url

        SendSharedMsg sharedMsg ->
            Task.succeed sharedMsg
                |> Task.perform options.fromSharedMsg

        ScrollElement info ->
            outgoing
                { tag = "SCROLL_ELEMENT"
                , data =
                    Json.Encode.object
                        [ ( "id", Json.Encode.string info.id )
                        , ( "direction"
                          , case info.direction of
                                Left ->
                                    Json.Encode.string "left"

                                Right ->
                                    Json.Encode.string "right"
                          )
                        ]
                }

        SendApiRequest request ->
            case options.shared.apiToken of
                Just token ->
                    Http.request
                        { method = "GET"
                        , headers =
                            [ Http.header "Authorization"
                                ("Bearer ${token}"
                                    |> String.replace "${token}" token
                                )
                            ]
                        , url = "https://api.themoviedb.org/3" ++ request.endpoint
                        , body = Http.emptyBody
                        , expect =
                            Http.expectJson
                                (\result ->
                                    case result of
                                        Ok msg ->
                                            msg

                                        Err httpError ->
                                            request.onHttpError httpError
                                )
                                request.decoder
                        , timeout = Nothing
                        , tracker = Nothing
                        }

                Nothing ->
                    Task.succeed ()
                        |> Task.perform (\_ -> request.onMissingToken)


port outgoing :
    { tag : String
    , data : Json.Encode.Value
    }
    -> Cmd msg
