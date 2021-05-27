module Backend exposing (..)

import Api.Data exposing (Data(..))
import Bridge exposing (..)
import Gen.Msg
import Html
import Lamdera exposing (..)
import Pages.Home_
import Types exposing (BackendModel, BackendMsg(..), FrontendModel, FrontendMsg(..), ToFrontend(..))


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { message = "Hello!" }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        GetTags ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Home_ (Pages.Home_.GotTags (Success [ "testing" ])))) )

        NoOpToBackend ->
            ( model, Cmd.none )
