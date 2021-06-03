module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Api.User exposing (User)
import Bridge exposing (..)
import Components.Footer
import Components.Navbar
import Html exposing (..)
import Html.Attributes exposing (class, href, rel)
import Request exposing (Request)
import Utils.Route
import View exposing (View)



-- INIT


type alias Flags =
    ()


type alias Model =
    { user : Maybe User
    }


init : Request -> Flags -> ( Model, Cmd Msg )
init _ json =
    ( Model Nothing
    , Cmd.none
    )



-- UPDATE


type Msg
    = ClickedSignOut
    | SignedInUser User


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        SignedInUser user ->
            ( { model | user = Just user }
            , Cmd.none
            )

        ClickedSignOut ->
            ( { model | user = Nothing }
            , model.user |> Maybe.map (\user -> sendToBackend (SignedOut user)) |> Maybe.withDefault Cmd.none
            )


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none



-- VIEW


view :
    Request
    -> { page : View msg, toMsg : Msg -> msg }
    -> Model
    -> View msg
view req { page, toMsg } model =
    { title =
        if String.isEmpty page.title then
            "Conduit"

        else
            page.title ++ " | Conduit"
    , body =
        css
            ++ [ div [ class "layout" ]
                    [ Components.Navbar.view
                        { user = model.user
                        , currentRoute = Utils.Route.fromUrl req.url
                        , onSignOut = toMsg ClickedSignOut
                        }
                    , div [ class "page" ] page.body
                    , Components.Footer.view
                    ]
               ]
    }


css =
    -- Import Ionicon icons & Google Fonts our Bootstrap theme relies on
    [ Html.node "link" [ rel "stylesheet", href "//code.ionicframework.com/ionicons/2.0.1/css/ionicons.min.css" ] []
    , Html.node "link" [ rel "stylesheet", href "//fonts.googleapis.com/css?family=Titillium+Web:700|Source+Serif+Pro:400,700|Merriweather+Sans:400,700|Source+Sans+Pro:400,300,600,700,300italic,400italic,600italic,700italic" ] []

    -- Import the custom Bootstrap 4 theme from our hosted CDN
    , Html.node "link" [ rel "stylesheet", href "//demo.productionready.io/main.css" ] []
    , Html.node "link" [ rel "stylesheet", href "/style.css" ] []
    ]
