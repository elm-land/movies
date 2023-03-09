module Components.ErrorDialog exposing (view)

import Components.Markdown
import Html exposing (..)
import Html.Attributes as Attr


view :
    { title : String
    , body : String
    }
    -> Html msg
view props =
    div [ Attr.class "error-dialog" ]
        [ h3 [ Attr.class "error-title font-h3" ] [ text props.title ]
        , Components.Markdown.view props.body
        ]
