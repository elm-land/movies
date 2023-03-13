module Api.Movie.Images exposing (Image, fetch)

import Api.Id
import Api.ImageUrl
import Effect exposing (Effect)
import Http
import Json.Decode


type alias Image =
    { url : Api.ImageUrl.ImageUrl
    , aspectRatio : Float
    }


imageDecoder : Json.Decode.Decoder Image
imageDecoder =
    Json.Decode.map2 Image
        (Json.Decode.field "file_path" Api.ImageUrl.movie)
        (Json.Decode.field "aspect_ratio" Json.Decode.float)


fetch :
    { id : Api.Id.Id
    , onResponse : Result Http.Error (List Image) -> msg
    }
    -> Effect msg
fetch options =
    let
        decoder : Json.Decode.Decoder (List Image)
        decoder =
            Json.Decode.field "backdrops"
                (Json.Decode.list imageDecoder)
    in
    Effect.sendApiRequest
        { endpoint = "/movie/" ++ Api.Id.toString options.id ++ "/images"
        , onResponse = options.onResponse
        , decoder = decoder
        }
