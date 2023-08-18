module Api.CastMember exposing (CastMember, decoder)

import Api.Id
import Api.ImageUrl
import Json.Decode


type alias CastMember =
    { id : Api.Id.Id
    , name : String
    , character : String
    , imageUrl : Api.ImageUrl.ImageUrl
    }


decoder : Json.Decode.Decoder CastMember
decoder =
    Json.Decode.map4 CastMember
        (Json.Decode.field "id" Api.Id.decoder)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "character" Json.Decode.string)
        (Json.Decode.field "profile_path" Api.ImageUrl.person)
