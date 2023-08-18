module Api.TvShow.AiringToday exposing (TvShow, fetch)

import Api.TvShow
import Effect exposing (Effect)
import Http
import Json.Decode


type alias TvShow =
    Api.TvShow.TvShow


fetch :
    { onResponse : Result Http.Error (List TvShow) -> msg
    }
    -> Effect msg
fetch options =
    let
        decoder : Json.Decode.Decoder (List TvShow)
        decoder =
            Json.Decode.field "results"
                (Json.Decode.list Api.TvShow.decoder)
    in
    Effect.sendApiRequest
        { endpoint = "/tv/airing_today"
        , onResponse = options.onResponse
        , decoder = decoder
        }
