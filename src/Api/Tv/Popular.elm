module Api.Tv.Popular exposing (TvShow, fetch)

import Api.Id
import Api.ImageUrl
import Effect exposing (Effect)
import Http
import Json.Decode


type alias TvShow =
    { id : Api.Id.Id
    , title : String
    , vote_average : Float
    , imageUrl : Api.ImageUrl.ImageUrl
    , first_air_date : String
    , overview : String
    }


tvShowDecoder : Json.Decode.Decoder TvShow
tvShowDecoder =
    Json.Decode.map6 TvShow
        (Json.Decode.field "id" Api.Id.decoder)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "vote_average" Json.Decode.float)
        (Json.Decode.field "poster_path" Api.ImageUrl.tvShow)
        (Json.Decode.field "first_air_date" Json.Decode.string)
        (Json.Decode.field "overview" Json.Decode.string)


fetch :
    { onResponse : Result Http.Error (List TvShow) -> msg
    }
    -> Effect msg
fetch options =
    let
        decoder : Json.Decode.Decoder (List TvShow)
        decoder =
            Json.Decode.field "results"
                (Json.Decode.list tvShowDecoder)
    in
    Effect.sendApiRequest
        { endpoint = "/tv/popular"
        , onResponse = options.onResponse
        , decoder = decoder
        }
