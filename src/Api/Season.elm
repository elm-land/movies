module Api.Season exposing
    ( Season
    , decoder
    , toSeasonCountLabel
    )

import Api.Id
import Extra.Json
import Json.Decode


type alias Season =
    { id : Api.Id.Id
    }


decoder : Json.Decode.Decoder Season
decoder =
    Extra.Json.new Season
        |> Extra.Json.withField "id" Api.Id.decoder


toSeasonCountLabel : List Season -> String
toSeasonCountLabel seasons =
    let
        numberOfSeasons : Int
        numberOfSeasons =
            List.length seasons
    in
    if numberOfSeasons == 1 then
        "1 season"

    else
        String.fromInt numberOfSeasons ++ " seasons"
