module Pages.Login.Provider_.Callback exposing (Model, Msg(..), page)

import Api.Data exposing (Data)
import Api.User exposing (User)
import Auth.Common
import Auth.Flow
import Bridge exposing (..)
import Browser.Navigation as Nav exposing (Key)
import Effect exposing (Effect)
import Gen.Params.Login.Provider_.Callback exposing (Params)
import Gen.Route as Route
import Html exposing (..)
import Html.Attributes exposing (class)
import Lamdera
import Page
import Request
import Shared
import Url exposing (Url)
import Utils.Route
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init req
        , update = update req
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { authFlow : Auth.Common.Flow
    , authRedirectBaseUrl : Url
    }


init : Request.With Params -> ( Model, Effect Msg )
init req =
    let
        model =
            { authFlow = Auth.Common.Idle
            , authRedirectBaseUrl = { url | query = Nothing, fragment = Nothing }
            }

        url =
            req.url

        onFrontendCallbackInit model_ methodId origin navigationKey toBackendFn =
            Debug.todo "onFrontendCallbackInit"

        ( authM, authCmd ) =
            Auth.Flow.init model
                req.params.provider
                url
                req.key
                (\msg -> Lamdera.sendToBackend (AuthToBackend msg))
    in
    ( authM
    , Effect.fromCmd authCmd
    )



-- UPDATE


type Msg
    = GotUser (Data User)


update : Request.With Params -> Msg -> Model -> ( Model, Effect Msg )
update req msg model =
    case msg of
        GotUser user ->
            case Api.Data.toMaybe user of
                Just user_ ->
                    ( model
                    , Effect.batch
                        [ Effect.fromCmd (Utils.Route.navigate req.key Route.Home_)
                        , Effect.fromShared (Shared.SignedInUser user_)
                        ]
                    )

                Nothing ->
                    ( model
                    , Effect.none
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Sign in"
    , body =
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-6 offset-md-3 col-xs-12 text-center" ]
                    [ text "Loading..."
                    ]
                ]
            ]
        ]
    }
