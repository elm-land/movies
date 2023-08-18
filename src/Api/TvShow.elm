module Api.TvShow exposing (TvShow, decoder)

import Api.Id
import Api.ImageUrl
import Json.Decode
import Route.Path


{-| A preview of a movie, useful for list pages
-}
type alias TvShow =
    { id : Api.Id.Id
    , title : String
    , vote_average : Float
    , imageUrl : Api.ImageUrl.ImageUrl
    , first_air_date : String
    , overview : String
    }


decoder : Json.Decode.Decoder TvShow
decoder =
    Json.Decode.map6 TvShow
        (Json.Decode.field "id" Api.Id.decoder)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "vote_average" Json.Decode.float)
        (Json.Decode.field "poster_path" Api.ImageUrl.tvShow)
        (Json.Decode.field "first_air_date" Json.Decode.string)
        (Json.Decode.field "overview" Json.Decode.string)
