module Api.Duration exposing (Duration, decoder, toString)

import Json.Decode


type Duration
    = Duration Int


decoder : Json.Decode.Decoder Duration
decoder =
    Json.Decode.map Duration
        Json.Decode.int


toString : Duration -> String
toString (Duration totalDurationInMinutes) =
    if totalDurationInMinutes < 60 then
        String.fromInt totalDurationInMinutes ++ "min"

    else
        let
            hours =
                totalDurationInMinutes // 60

            minutes =
                Basics.modBy 60 totalDurationInMinutes
        in
        "${hours}h ${minutes}min"
            |> String.replace "${hours}" (String.fromInt hours)
            |> String.replace "${minutes}" (String.fromInt minutes)
