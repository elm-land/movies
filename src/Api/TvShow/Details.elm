module Api.TvShow.Details exposing (TvShow, fetch)

import Api.CastMember exposing (CastMember)
import Api.Duration
import Api.Id
import Api.ImageUrl
import Api.Season exposing (Season)
import Api.TvShow
import Effect exposing (Effect)
import Extra.Json
import Http
import Json.Decode


type alias TvShow =
    { id : Api.Id.Id
    , name : String
    , vote_average : Float
    , imageUrl : Api.ImageUrl.ImageUrl
    , first_air_date : String
    , overview : String
    , seasons : List Season
    , cast : List CastMember
    , similarTvShows : List Api.TvShow.TvShow
    }


tvShowDecoder : Json.Decode.Decoder TvShow
tvShowDecoder =
    Extra.Json.new TvShow
        |> Extra.Json.withField "id" Api.Id.decoder
        |> Extra.Json.withField "name" Json.Decode.string
        |> Extra.Json.withField "vote_average" Json.Decode.float
        |> Extra.Json.withField "poster_path" Api.ImageUrl.movie
        |> Extra.Json.withField "first_air_date" Json.Decode.string
        |> Extra.Json.withField "overview" Json.Decode.string
        |> Extra.Json.withField "seasons" (Json.Decode.list Api.Season.decoder)
        |> Extra.Json.with castMembersDecoder
        |> Extra.Json.with similarTvShowsDecoder


castMembersDecoder : Json.Decode.Decoder (List CastMember)
castMembersDecoder =
    Json.Decode.at
        [ "credits", "cast" ]
        (Json.Decode.list Api.CastMember.decoder)


similarTvShowsDecoder : Json.Decode.Decoder (List Api.TvShow.TvShow)
similarTvShowsDecoder =
    Json.Decode.at [ "similar", "results" ]
        (Json.Decode.list Api.TvShow.decoder)


fetch :
    { id : Api.Id.Id
    , onResponse : Result Http.Error TvShow -> msg
    }
    -> Effect msg
fetch options =
    Effect.sendApiRequest
        { endpoint = "/tv/" ++ Api.Id.toString options.id ++ "?append_to_response=credits,similar"
        , onResponse = options.onResponse
        , decoder = tvShowDecoder
        }
