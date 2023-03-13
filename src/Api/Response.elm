module Api.Response exposing
    ( Response(..), fromResult
    , map
    , toMaybe, toFailureReason
    )

{-|

@docs Response, fromResult
@docs map
@docs toMaybe, toFailureReason

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


toFailureReason : Response value -> Maybe Http.Error
toFailureReason response =
    case response of
        Loading ->
            Nothing

        Success value ->
            Nothing

        Failure httpError ->
            Just httpError
