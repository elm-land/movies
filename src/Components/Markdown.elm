module Components.Markdown exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Markdown
import String.Extra


view : String -> Html msg
view content =
    content
        |> String.Extra.unindent
        |> Markdown.toHtml [ Attr.class "markdown" ]
