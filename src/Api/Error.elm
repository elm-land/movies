module Api.Error exposing (toHelpfulMessage)

import Http


toHelpfulMessage : Http.Error -> String
toHelpfulMessage httpError =
    case httpError of
        Http.BadUrl _ ->
            "Failed to send the request"

        Http.Timeout ->
            "The API request timed out"

        Http.NetworkError ->
            "Couldn't connect to the API"

        Http.BadStatus int ->
            "Received an unexpected status code: " ++ String.fromInt int

        Http.BadBody message ->
            "Received an unexpected API response"
