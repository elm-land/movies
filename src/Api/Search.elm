module Api.Search exposing
    ( SearchResult(..)
    , Movie, TvShow, Person
    , get
    )

{-|

@docs SearchResult
@docs Movie, TvShow, Person

@docs get

-}

import Api.Id
import Api.ImageUrl
import Api.Movie
import Effect exposing (Effect)
import Http
import Json.Decode
import Url.Builder


type SearchResult
    = On_Person Person
    | On_Movie Movie
    | On_TvShow TvShow


searchResultDecoder : Json.Decode.Decoder SearchResult
searchResultDecoder =
    let
        toSearchResultDecoder : String -> Json.Decode.Decoder SearchResult
        toSearchResultDecoder mediaType =
            case mediaType of
                "person" ->
                    personDecoder |> Json.Decode.map On_Person

                "movie" ->
                    movieDecoder |> Json.Decode.map On_Movie

                "tv" ->
                    tvShowDecoder |> Json.Decode.map On_TvShow

                _ ->
                    Json.Decode.fail ("Unrecognized media_type: " ++ mediaType)
    in
    Json.Decode.field "media_type" Json.Decode.string
        |> Json.Decode.andThen toSearchResultDecoder


type alias Movie =
    { id : Api.Id.Id
    , title : String
    , vote_average : Float
    , imageUrl : Api.ImageUrl.ImageUrl
    , release_date : String
    }


movieDecoder : Json.Decode.Decoder Movie
movieDecoder =
    Json.Decode.map5 Movie
        (Json.Decode.field "id" Api.Id.decoder)
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "vote_average" Json.Decode.float)
        (Json.Decode.field "poster_path" Api.ImageUrl.movie)
        (Json.Decode.field "release_date" Json.Decode.string)


type alias TvShow =
    { id : Api.Id.Id
    , title : String
    , vote_average : Float
    , imageUrl : Api.ImageUrl.ImageUrl
    , first_air_date : String
    }


tvShowDecoder : Json.Decode.Decoder TvShow
tvShowDecoder =
    Json.Decode.map5 TvShow
        (Json.Decode.field "id" Api.Id.decoder)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "vote_average" Json.Decode.float)
        (Json.Decode.field "poster_path" Api.ImageUrl.tvShow)
        (Json.Decode.field "first_air_date" Json.Decode.string)


type alias Person =
    { id : Api.Id.Id
    , name : String
    , known_for_department : String
    , imageUrl : Api.ImageUrl.ImageUrl
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map4 Person
        (Json.Decode.field "id" Api.Id.decoder)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "known_for_department" Json.Decode.string)
        (Json.Decode.field "profile_path" Api.ImageUrl.person)


get :
    { query : String
    , onResponse : Result Http.Error (List SearchResult) -> msg
    }
    -> Effect msg
get options =
    let
        decoder : Json.Decode.Decoder (List SearchResult)
        decoder =
            Json.Decode.field "results"
                (Json.Decode.list searchResultDecoder)
    in
    Effect.sendApiRequest
        { endpoint =
            "/search/multi"
                ++ Url.Builder.toQuery
                    [ Url.Builder.string "query" options.query
                    , Url.Builder.string "include_adult" "false"
                    , Url.Builder.string "language" "en-US"
                    ]
        , onResponse = options.onResponse
        , decoder = decoder
        }
