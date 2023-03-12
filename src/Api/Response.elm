module Api.Response exposing
    ( Response(..), fromResult
    , map
    , toMaybe
    )

{-|

@docs Response, fromResult
@docs map
@docs toMaybe

-}

import Http


type Response value
    = Loading
    | Success value
    | Failure Http.Error


fromResult : Result Http.Error value -> Response value
fromResult result =
    case result of
        Ok value ->
            Success value

        Err reason ->
            Failure reason


map : (value1 -> value2) -> Response value1 -> Response value2
map fn response =
    case response of
        Loading ->
            Loading

        Success value ->
            Success (fn value)

        Failure reason ->
            Failure reason


toMaybe : Response value -> Maybe value
toMaybe response =
    case response of
        Loading ->
            Nothing

        Success value ->
            Just value

        Failure reason ->
            Nothing
