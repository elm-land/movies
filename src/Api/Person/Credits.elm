module Api.Person.Credits exposing (Credit, Kind(..), fetch)

import Api.Id
import Api.ImageUrl
import Effect exposing (Effect)
import Http
import Json.Decode


type alias Credit =
    { kind : Kind
    , id : Api.Id.Id
    , title : String
    , character : String
    , imageUrl : Api.ImageUrl.ImageUrl
    , popularity : Float
    }


type Kind
    = Movie
    | TvShow


creditDecoder : Json.Decode.Decoder Credit
creditDecoder =
    let
        toCreditDecoder : String -> Json.Decode.Decoder Credit
        toCreditDecoder mediaType =
            case mediaType of
                "movie" ->
                    Json.Decode.map6 Credit
                        (Json.Decode.succeed Movie)
                        (Json.Decode.field "id" Api.Id.decoder)
                        (Json.Decode.field "title" Json.Decode.string)
                        (Json.Decode.field "character" Json.Decode.string)
                        (Json.Decode.field "poster_path" Api.ImageUrl.movie)
                        (Json.Decode.field "popularity" Json.Decode.float)

                "tv" ->
                    Json.Decode.map6 Credit
                        (Json.Decode.succeed TvShow)
                        (Json.Decode.field "id" Api.Id.decoder)
                        (Json.Decode.field "name" Json.Decode.string)
                        (Json.Decode.field "character" Json.Decode.string)
                        (Json.Decode.field "poster_path" Api.ImageUrl.tvShow)
                        (Json.Decode.field "popularity" Json.Decode.float)

                _ ->
                    Json.Decode.fail "Unrecognized media type"
    in
    Json.Decode.field "media_type" Json.Decode.string
        |> Json.Decode.andThen toCreditDecoder


fetch :
    { id : Api.Id.Id
    , onResponse : Result Http.Error (List Credit) -> msg
    }
    -> Effect msg
fetch options =
    let
        decoder : Json.Decode.Decoder (List Credit)
        decoder =
            Json.Decode.field "cast"
                (Json.Decode.list creditDecoder)
                |> Json.Decode.map (List.sortBy (.popularity >> negate))
    in
    Effect.sendApiRequest
        { endpoint = "/person/" ++ Api.Id.toString options.id ++ "/combined_credits"
        , onResponse = options.onResponse
        , decoder = decoder
        }
