module Pages.Login exposing (Model, Msg(..), page)

import Api.Data exposing (Data)
import Api.User exposing (User)
import Auth.Common
import Auth.Flow
import Bridge exposing (..)
import Components.UserForm
import Effect exposing (Effect)
import Gen.Route as Route
import Page
import Request exposing (Request)
import Shared
import Url exposing (Url)
import Utils.Route
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init shared req
        , update = update req
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { email : String
    , password : String
    , authFlow : Auth.Common.Flow
    , authRedirectBaseUrl : Url
    }


init : Shared.Model -> Request -> ( Model, Effect Msg )
init shared req =
    let
        url =
            req.url
    in
    ( { email = ""
      , password = ""
      , authFlow = Auth.Common.Idle
      , authRedirectBaseUrl = { url | query = Nothing, fragment = Nothing }
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = Updated Field String
    | GithubSigninRequested


type Field
    = Email
    | Password


update : Request -> Msg -> Model -> ( Model, Effect Msg )
update req msg model =
    case msg of
        Updated Email email ->
            ( { model | email = email }
            , Effect.none
            )

        Updated Password password ->
            ( { model | password = password }
            , Effect.none
            )

        GithubSigninRequested ->
            -- ( model
            -- , (Effect.fromCmd << sendToBackend) <|
            --     UserAuthentication_Login
            --         { params =
            --             { email = model.email
            --             , password = model.password
            --             }
            --         }
            -- )
            Tuple.mapSecond (Effect.fromCmd << sendToBackend << AuthToBackend) <|
                Auth.Flow.signInRequested "OAuthGithub" model Nothing


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Sign in"
    , body =
        [ Components.UserForm.view
            { title = "Login"
            , label = "Login with Github"
            , onFormSubmit = GithubSigninRequested
            , inProgress =
                case model.authFlow of
                    Auth.Common.Idle ->
                        False

                    _ ->
                        True
            }
        ]
    }
