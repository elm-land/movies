module Api.Movie.Details exposing (Movie, fetch)

import Api.CastMember exposing (CastMember)
import Api.Duration
import Api.Id
import Api.ImageUrl
import Api.Movie
import Effect exposing (Effect)
import Extra.Json
import Http
import Json.Decode


type alias Movie =
    { id : Api.Id.Id
    , title : String
    , vote_average : Float
    , imageUrl : Api.ImageUrl.ImageUrl
    , release_date : String
    , overview : String
    , duration : Api.Duration.Duration
    , director : Maybe CrewMember
    , budget : Float
    , revenue : Float
    , genre : List Genre
    , cast : List CastMember
    , similarMovies : List Api.Movie.Movie
    }


movieDecoder : Json.Decode.Decoder Movie
movieDecoder =
    Extra.Json.new Movie
        |> Extra.Json.withField "id" Api.Id.decoder
        |> Extra.Json.withField "title" Json.Decode.string
        |> Extra.Json.withField "vote_average" Json.Decode.float
        |> Extra.Json.withField "poster_path" Api.ImageUrl.movie
        |> Extra.Json.withField "release_date" Json.Decode.string
        |> Extra.Json.withField "overview" Json.Decode.string
        |> Extra.Json.withField "runtime" Api.Duration.decoder
        |> Extra.Json.with directorDecoder
        |> Extra.Json.withField "budget" Json.Decode.float
        |> Extra.Json.withField "revenue" Json.Decode.float
        |> Extra.Json.withField "genres" (Json.Decode.list genreDecoder)
        |> Extra.Json.with castMembersDecoder
        |> Extra.Json.with similarMoviesDecoder


type alias Genre =
    { id : Api.Id.Id
    , name : String
    }


genreDecoder : Json.Decode.Decoder Genre
genreDecoder =
    Json.Decode.map2 Genre
        (Json.Decode.field "id" Api.Id.decoder)
        (Json.Decode.field "name" Json.Decode.string)


type alias CrewMember =
    { id : Api.Id.Id
    , name : String
    , job : String
    }


crewMemberDecoder : Json.Decode.Decoder CrewMember
crewMemberDecoder =
    Json.Decode.map3 CrewMember
        (Json.Decode.field "id" Api.Id.decoder)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "job" Json.Decode.string)


directorDecoder : Json.Decode.Decoder (Maybe CrewMember)
directorDecoder =
    let
        crewMembersDecoder : Json.Decode.Decoder (List CrewMember)
        crewMembersDecoder =
            Json.Decode.at [ "credits", "crew" ]
                (Json.Decode.list crewMemberDecoder)

        toMaybeDirector : List CrewMember -> Maybe CrewMember
        toMaybeDirector crewMembers =
            crewMembers
                |> List.filter hasDirectorJob
                |> List.head

        hasDirectorJob : CrewMember -> Bool
        hasDirectorJob member =
            member.job == "Director"
    in
    crewMembersDecoder
        |> Json.Decode.map toMaybeDirector


castMembersDecoder : Json.Decode.Decoder (List CastMember)
castMembersDecoder =
    Json.Decode.at
        [ "credits", "cast" ]
        (Json.Decode.list Api.CastMember.decoder)


similarMoviesDecoder : Json.Decode.Decoder (List Api.Movie.Movie)
similarMoviesDecoder =
    Json.Decode.at [ "similar", "results" ]
        (Json.Decode.list Api.Movie.decoder)


fetch :
    { id : Api.Id.Id
    , onResponse : Result Http.Error Movie -> msg
    }
    -> Effect msg
fetch options =
    Effect.sendApiRequest
        { endpoint = "/movie/" ++ Api.Id.toString options.id ++ "?append_to_response=credits,similar"
        , onResponse = options.onResponse
        , decoder = movieDecoder
        }
