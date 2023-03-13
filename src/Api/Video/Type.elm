module Api.Video.Type exposing (Type(..), decoder)

import Json.Decode


type Type
    = Trailer
    | Other String


decoder : Json.Decode.Decoder Type
decoder =
    let
        toType : String -> Type
        toType string =
            case string of
                "Trailer" ->
                    Trailer

                _ ->
                    Other string
    in
    Json.Decode.string
        |> Json.Decode.map toType
