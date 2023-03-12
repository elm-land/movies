module Api.Movie.Popular exposing (Movie, fetch)

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
    }


movieDecoder : Json.Decode.Decoder Movie
movieDecoder =
    Json.Decode.map6 Movie
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "vote_average" Json.Decode.float)
        (Json.Decode.field "poster_path" Json.Decode.string)
        (Json.Decode.field "release_date" Json.Decode.string)
        (Json.Decode.field "overview" Json.Decode.string)


fetch :
    { onResponse : Result Http.Error (List Movie) -> msg
    }
    -> Effect msg
fetch options =
    let
        decoder : Json.Decode.Decoder (List Movie)
        decoder =
            Json.Decode.field "results"
                (Json.Decode.list movieDecoder)
    in
    Effect.sendApiRequest
        { endpoint = "/movie/popular"
        , onResponse = options.onResponse
        , decoder = decoder
        }
