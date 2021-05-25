module View exposing (View, map, none, placeholder, toBrowserDocument)

import Browser
import Html exposing (Html)
import Html.Attributes exposing (href, rel, type_)


type alias View msg =
    { title : String
    , body : List (Html msg)
    }


placeholder : String -> View msg
placeholder str =
    { title = str
    , body = [ Html.text str ]
    }


none : View msg
none =
    placeholder ""


map : (a -> b) -> View a -> View b
map fn view =
    { title = view.title
    , body = List.map (Html.map fn) view.body
    }


toBrowserDocument : View msg -> Browser.Document msg
toBrowserDocument view =
    { title = view.title
    , body = css ++ view.body
    }


css =
    -- Import Ionicon icons & Google Fonts our Bootstrap theme relies on
    [ Html.node "link" [ rel "stylesheet", href "//code.ionicframework.com/ionicons/2.0.1/css/ionicons.min.css" ] []
    , Html.node "link" [ rel "stylesheet", href "//fonts.googleapis.com/css?family=Titillium+Web:700|Source+Serif+Pro:400,700|Merriweather+Sans:400,700|Source+Sans+Pro:400,300,600,700,300italic,400italic,600italic,700italic" ] []

    -- Import the custom Bootstrap 4 theme from our hosted CDN
    , Html.node "link" [ rel "stylesheet", href "//demo.productionready.io/main.css" ] []
    , Html.node "link" [ rel "stylesheet", href "/style.css" ] []
    ]
