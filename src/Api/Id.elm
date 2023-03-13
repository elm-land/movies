module Api.Id exposing (Id, decoder, fromInt, fromString, toString)

import Json.Decode


type Id
    = Id String


fromString : String -> Id
fromString id =
    Id id


fromInt : Int -> Id
fromInt intId =
    Id (String.fromInt intId)


toString : Id -> String
toString (Id id) =
    id


decoder : Json.Decode.Decoder Id
decoder =
    Json.Decode.map Id
        (Json.Decode.oneOf
            [ Json.Decode.string
            , Json.Decode.int |> Json.Decode.map String.fromInt
            ]
        )
