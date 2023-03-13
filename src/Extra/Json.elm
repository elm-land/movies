module Extra.Json exposing
    ( new
    , with, withField
    )

{-|

@docs new
@docs with, withField

-}

import Json.Decode


new : value -> Json.Decode.Decoder value
new value =
    Json.Decode.succeed value


with :
    Json.Decode.Decoder field
    -> Json.Decode.Decoder (field -> object)
    -> Json.Decode.Decoder object
with fieldDecoder toObjectDecoder =
    Json.Decode.map2 (|>)
        fieldDecoder
        toObjectDecoder


withField :
    String
    -> Json.Decode.Decoder field
    -> Json.Decode.Decoder (field -> object)
    -> Json.Decode.Decoder object
withField fieldName fieldDecoder toObjectDecoder =
    with
        (Json.Decode.field fieldName fieldDecoder)
        toObjectDecoder
