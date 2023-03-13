module Api.ImageUrl exposing (ImageUrl, movie, person, tvShow)

import Json.Decode


type alias ImageUrl =
    String


movie : Json.Decode.Decoder ImageUrl
movie =
    decoder
        { fallback = "/images/404.gif"
        }


person : Json.Decode.Decoder ImageUrl
person =
    decoder
        { fallback = "/images/person-placeholder.jpg"
        }


tvShow : Json.Decode.Decoder ImageUrl
tvShow =
    decoder
        { fallback = "/images/404.gif"
        }


decoder : { fallback : String } -> Json.Decode.Decoder ImageUrl
decoder { fallback } =
    Json.Decode.oneOf
        [ Json.Decode.string
            |> Json.Decode.map toImageUrl
        , Json.Decode.succeed fallback
        ]


toImageUrl : String -> String
toImageUrl absolutePath =
    "https://www.themoviedb.org/t/p/w440_and_h660_face" ++ absolutePath
