module Api.Movie.Videos exposing (Video, fetch)

import Api.Id
import Api.Video.Site
import Api.Video.Type
import Effect exposing (Effect)
import Http
import Json.Decode


type alias Video =
    { name : String
    , site : Api.Video.Site.Site
    , type_ : Api.Video.Type.Type
    }


videoDecoder : Json.Decode.Decoder Video
videoDecoder =
    Json.Decode.map3 Video
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "site" Api.Video.Site.decoder)
        (Json.Decode.field "type" Api.Video.Type.decoder)


fetch :
    { id : Api.Id.Id
    , onResponse : Result Http.Error (List Video) -> msg
    }
    -> Effect msg
fetch options =
    let
        decoder : Json.Decode.Decoder (List Video)
        decoder =
            Json.Decode.field "results"
                (Json.Decode.list videoDecoder)
    in
    Effect.sendApiRequest
        { endpoint = "/movie/" ++ Api.Id.toString options.id ++ "/videos"
        , onResponse = options.onResponse
        , decoder = decoder
        }
