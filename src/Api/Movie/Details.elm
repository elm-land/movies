module Api.Movie.Details exposing (Movie, fetch)

import Api.Runtime
import Effect exposing (Effect)
import Http
import Json.Decode


type alias Movie =
    { id : Int
    , title : String
    , vote_average : Float
    , poster_path : String
    , release_date : String
    , overview : String
    , runtime : Api.Runtime.Runtime
    }


movieDecoder : Json.Decode.Decoder Movie
movieDecoder =
    Json.Decode.map7 Movie
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "vote_average" Json.Decode.float)
        (Json.Decode.field "poster_path" Json.Decode.string)
        (Json.Decode.field "release_date" Json.Decode.string)
        (Json.Decode.field "overview" Json.Decode.string)
        (Json.Decode.field "runtime" Api.Runtime.decoder)


fetch :
    { id : Int
    , onResponse : Result Http.Error Movie -> msg
    }
    -> Effect msg
fetch options =
    Effect.sendApiRequest
        { endpoint = "/movie/" ++ String.fromInt options.id
        , onResponse = options.onResponse
        , decoder = movieDecoder
        }
