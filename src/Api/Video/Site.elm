module Api.Video.Site exposing (Site(..), decoder)

import Json.Decode


type Site
    = YouTube
    | Other String


decoder : Json.Decode.Decoder Site
decoder =
    let
        toSite : String -> Site
        toSite string =
            case string of
                "YouTube" ->
                    YouTube

                _ ->
                    Other string
    in
    Json.Decode.string
        |> Json.Decode.map toSite
