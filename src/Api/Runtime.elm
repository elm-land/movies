module Api.Runtime exposing (Runtime, decoder, toString)

import Json.Decode


type Runtime
    = Runtime Int


decoder : Json.Decode.Decoder Runtime
decoder =
    Json.Decode.map Runtime
        Json.Decode.int


toString : Runtime -> String
toString (Runtime totalRuntimeInMinutes) =
    if totalRuntimeInMinutes < 60 then
        String.fromInt totalRuntimeInMinutes ++ "m"

    else
        let
            hours =
                totalRuntimeInMinutes // 60

            minutes =
                Basics.modBy 60 totalRuntimeInMinutes
        in
        "${hours}h ${minutes}m"
            |> String.replace "${hours}" (String.fromInt hours)
            |> String.replace "${minutes}" (String.fromInt minutes)
