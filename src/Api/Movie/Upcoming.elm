module Api.Movie.Upcoming exposing (Movie, fetch)

import Api.Movie
import Effect exposing (Effect)
import Http
import Json.Decode


type alias Movie =
    Api.Movie.Movie


fetch :
    { onResponse : Result Http.Error (List Movie) -> msg
    }
    -> Effect msg
fetch options =
    let
        decoder : Json.Decode.Decoder (List Movie)
        decoder =
            Json.Decode.field "results"
                (Json.Decode.list Api.Movie.decoder)
    in
    Effect.sendApiRequest
        { endpoint = "/movie/upcoming"
        , onResponse = options.onResponse
        , decoder = decoder
        }
