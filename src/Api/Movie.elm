module Api.Movie exposing (Movie, decoder)

import Api.Id
import Api.ImageUrl
import Json.Decode
import Route.Path


{-| A preview of a movie, useful for list pages
-}
type alias Movie =
    { id : Api.Id.Id
    , title : String
    , vote_average : Float
    , imageUrl : Api.ImageUrl.ImageUrl
    , release_date : String
    , overview : String
    }


decoder : Json.Decode.Decoder Movie
decoder =
    Json.Decode.map6 Movie
        (Json.Decode.field "id" Api.Id.decoder)
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "vote_average" Json.Decode.float)
        (Json.Decode.field "poster_path" Api.ImageUrl.movie)
        (Json.Decode.field "release_date" Json.Decode.string)
        (Json.Decode.field "overview" Json.Decode.string)
