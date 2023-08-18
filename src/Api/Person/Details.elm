module Api.Person.Details exposing (Person, fetch)

import Api.Duration
import Api.Id
import Api.ImageUrl
import Effect exposing (Effect)
import Extra.Json
import Http
import Json.Decode


type alias Person =
    { id : Api.Id.Id
    , name : String
    , bio : String
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Extra.Json.new Person
        |> Extra.Json.withField "id" Api.Id.decoder
        |> Extra.Json.withField "name" Json.Decode.string
        |> Extra.Json.withField "biography" Json.Decode.string


fetch :
    { id : Api.Id.Id
    , onResponse : Result Http.Error Person -> msg
    }
    -> Effect msg
fetch options =
    Effect.sendApiRequest
        { endpoint = "/person/" ++ Api.Id.toString options.id
        , onResponse = options.onResponse
        , decoder = personDecoder
        }
