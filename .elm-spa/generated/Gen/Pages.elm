module Gen.Pages exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation exposing (Key)
import Effect exposing (Effect)
import ElmSpa.Page
import Gen.Params.Editor
import Gen.Params.Home_
import Gen.Params.Login
import Gen.Params.NotFound
import Gen.Params.Register
import Gen.Params.Settings
import Gen.Params.Article.Slug_
import Gen.Params.Editor.ArticleSlug_
import Gen.Params.Profile.Username_
import Gen.Model as Model
import Gen.Msg as Msg
import Gen.Route as Route exposing (Route)
import Page exposing (Page)
import Pages.Editor
import Pages.Home_
import Pages.Login
import Pages.NotFound
import Pages.Register
import Pages.Settings
import Pages.Article.Slug_
import Pages.Editor.ArticleSlug_
import Pages.Profile.Username_
import Request exposing (Request)
import Shared
import Task
import Url exposing (Url)
import View exposing (View)


type alias Model =
    Model.Model


type alias Msg =
    Msg.Msg


init : Route -> Shared.Model -> Url -> Key -> ( Model, Effect Msg )
init route =
    case route of
        Route.Editor ->
            pages.editor.init ()
    
        Route.Home_ ->
            pages.home_.init ()
    
        Route.Login ->
            pages.login.init ()
    
        Route.NotFound ->
            pages.notFound.init ()
    
        Route.Register ->
            pages.register.init ()
    
        Route.Settings ->
            pages.settings.init ()
    
        Route.Article__Slug_ params ->
            pages.article__slug_.init params
    
        Route.Editor__ArticleSlug_ params ->
            pages.editor__articleSlug_.init params
    
        Route.Profile__Username_ params ->
            pages.profile__username_.init params


update : Msg -> Model -> Shared.Model -> Url -> Key -> ( Model, Effect Msg )
update msg_ model_ =
    case ( msg_, model_ ) of
        ( Msg.Editor msg, Model.Editor params model ) ->
            pages.editor.update params msg model
    
        ( Msg.Home_ msg, Model.Home_ params model ) ->
            pages.home_.update params msg model
    
        ( Msg.Login msg, Model.Login params model ) ->
            pages.login.update params msg model
    
        ( Msg.Register msg, Model.Register params model ) ->
            pages.register.update params msg model
    
        ( Msg.Settings msg, Model.Settings params model ) ->
            pages.settings.update params msg model
    
        ( Msg.Article__Slug_ msg, Model.Article__Slug_ params model ) ->
            pages.article__slug_.update params msg model
    
        ( Msg.Editor__ArticleSlug_ msg, Model.Editor__ArticleSlug_ params model ) ->
            pages.editor__articleSlug_.update params msg model
    
        ( Msg.Profile__Username_ msg, Model.Profile__Username_ params model ) ->
            pages.profile__username_.update params msg model

        _ ->
            \_ _ _ -> ( model_, Effect.none )


view : Model -> Shared.Model -> Url -> Key -> View Msg
view model_ =
    case model_ of
        Model.Redirecting_ ->
            \_ _ _ -> View.none
    
        Model.Editor params model ->
            pages.editor.view params model
    
        Model.Home_ params model ->
            pages.home_.view params model
    
        Model.Login params model ->
            pages.login.view params model
    
        Model.NotFound params ->
            pages.notFound.view params ()
    
        Model.Register params model ->
            pages.register.view params model
    
        Model.Settings params model ->
            pages.settings.view params model
    
        Model.Article__Slug_ params model ->
            pages.article__slug_.view params model
    
        Model.Editor__ArticleSlug_ params model ->
            pages.editor__articleSlug_.view params model
    
        Model.Profile__Username_ params model ->
            pages.profile__username_.view params model


subscriptions : Model -> Shared.Model -> Url -> Key -> Sub Msg
subscriptions model_ =
    case model_ of
        Model.Redirecting_ ->
            \_ _ _ -> Sub.none
    
        Model.Editor params model ->
            pages.editor.subscriptions params model
    
        Model.Home_ params model ->
            pages.home_.subscriptions params model
    
        Model.Login params model ->
            pages.login.subscriptions params model
    
        Model.NotFound params ->
            pages.notFound.subscriptions params ()
    
        Model.Register params model ->
            pages.register.subscriptions params model
    
        Model.Settings params model ->
            pages.settings.subscriptions params model
    
        Model.Article__Slug_ params model ->
            pages.article__slug_.subscriptions params model
    
        Model.Editor__ArticleSlug_ params model ->
            pages.editor__articleSlug_.subscriptions params model
    
        Model.Profile__Username_ params model ->
            pages.profile__username_.subscriptions params model



-- INTERNALS


pages :
    { editor : Bundle Gen.Params.Editor.Params Pages.Editor.Model Pages.Editor.Msg
    , home_ : Bundle Gen.Params.Home_.Params Pages.Home_.Model Pages.Home_.Msg
    , login : Bundle Gen.Params.Login.Params Pages.Login.Model Pages.Login.Msg
    , notFound : Static Gen.Params.NotFound.Params
    , register : Bundle Gen.Params.Register.Params Pages.Register.Model Pages.Register.Msg
    , settings : Bundle Gen.Params.Settings.Params Pages.Settings.Model Pages.Settings.Msg
    , article__slug_ : Bundle Gen.Params.Article.Slug_.Params Pages.Article.Slug_.Model Pages.Article.Slug_.Msg
    , editor__articleSlug_ : Bundle Gen.Params.Editor.ArticleSlug_.Params Pages.Editor.ArticleSlug_.Model Pages.Editor.ArticleSlug_.Msg
    , profile__username_ : Bundle Gen.Params.Profile.Username_.Params Pages.Profile.Username_.Model Pages.Profile.Username_.Msg
    }
pages =
    { editor = bundle Pages.Editor.page Model.Editor Msg.Editor
    , home_ = bundle Pages.Home_.page Model.Home_ Msg.Home_
    , login = bundle Pages.Login.page Model.Login Msg.Login
    , notFound = static Pages.NotFound.view Model.NotFound
    , register = bundle Pages.Register.page Model.Register Msg.Register
    , settings = bundle Pages.Settings.page Model.Settings Msg.Settings
    , article__slug_ = bundle Pages.Article.Slug_.page Model.Article__Slug_ Msg.Article__Slug_
    , editor__articleSlug_ = bundle Pages.Editor.ArticleSlug_.page Model.Editor__ArticleSlug_ Msg.Editor__ArticleSlug_
    , profile__username_ = bundle Pages.Profile.Username_.page Model.Profile__Username_ Msg.Profile__Username_
    }


type alias Bundle params model msg =
    ElmSpa.Page.Bundle params model msg Shared.Model (Effect Msg) Model Msg (View Msg)


bundle page toModel toMsg =
    ElmSpa.Page.bundle
        { redirecting =
            { model = Model.Redirecting_
            , view = View.none
            }
        , toRoute = Route.fromUrl
        , toUrl = Route.toHref
        , fromCmd = Effect.fromCmd
        , mapEffect = Effect.map toMsg
        , mapView = View.map toMsg
        , toModel = toModel
        , toMsg = toMsg
        , page = page
        }


type alias Static params =
    Bundle params () Never


static : View Never -> (params -> Model) -> Static params
static view_ toModel =
    { init = \params _ _ _ -> ( toModel params, Effect.none )
    , update = \params _ _ _ _ _ -> ( toModel params, Effect.none )
    , view = \_ _ _ _ _ -> View.map never view_
    , subscriptions = \_ _ _ _ _ -> Sub.none
    }
    
