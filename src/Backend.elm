module Backend exposing (..)

import Api.Data exposing (Data(..))
import Bridge exposing (..)
import Dict
import Gen.Msg
import Html
import Lamdera exposing (..)
import Pages.Article.Slug_
import Pages.Editor
import Pages.Editor.ArticleSlug_
import Pages.Home_
import Pages.Login
import Pages.Profile.Username_
import Pages.Register
import Pages.Settings
import Stubs exposing (..)
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
    ( { sessions = Dict.empty }
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
        SignedOut user ->
            ( { model | sessions = model.sessions |> Dict.remove sessionId }, Cmd.none )

        GetTags_Home_ ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Home_ (Pages.Home_.GotTags (Success [ "testing" ])))) )

        ArticleList_Home_ { filters, page } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Home_ (Pages.Home_.GotArticles (Success stubListing)))) )

        ArticleFeed_Home_ { page } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Home_ (Pages.Home_.GotArticles (Success stubListing)))) )

        ArticleList_Username_ { filters, page } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.GotArticles (Success stubListing)))) )

        ArticleGet_Editor__ArticleSlug_ { slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Editor__ArticleSlug_ (Pages.Editor.ArticleSlug_.LoadedInitialArticle (Success stubArticle)))) )

        ArticleUpdate_Editor__ArticleSlug_ { slug, article } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Editor__ArticleSlug_ (Pages.Editor.ArticleSlug_.UpdatedArticle (Success stubArticle)))) )

        ArticleGet_Article__Slug_ { slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotArticle (Success stubArticle)))) )

        ArticleCreate_Editor { article } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Editor (Pages.Editor.GotArticle (Success <| stubArticleCreate article)))) )

        ArticleDelete_Article__Slug_ { slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.DeletedArticle (Success stubArticle)))) )

        ArticleFavorite_Profile__Username_ { slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.UpdatedArticle (Success stubArticle)))) )

        ArticleUnfavorite_Profile__Username_ { slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.UpdatedArticle (Success stubArticle)))) )

        ArticleFavorite_Home_ { slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Home_ (Pages.Home_.UpdatedArticle (Success stubArticle)))) )

        ArticleUnfavorite_Home_ { slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Home_ (Pages.Home_.UpdatedArticle (Success stubArticle)))) )

        ArticleFavorite_Article__Slug_ { slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotArticle (Success stubArticle)))) )

        ArticleUnfavorite_Article__Slug_ { slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotArticle (Success stubArticle)))) )

        ArticleCommentGet_Article__Slug_ { articleSlug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotComments (Success stubComments)))) )

        ArticleCommentCreate_Article__Slug_ { articleSlug, comment } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.CreatedComment (Success stubComment)))) )

        ArticleCommentDelete_Article__Slug_ { articleSlug, commentId } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.DeletedComment (Success commentId)))) )

        ProfileGet_Profile__Username_ { username } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.GotProfile (Success stubProfile)))) )

        ProfileFollow_Profile__Username_ { username } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.GotProfile (Success stubProfile)))) )

        ProfileUnfollow_Profile__Username_ { username } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.GotProfile (Success stubProfile)))) )

        ProfileFollow_Article__Slug_ { username } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotAuthor (Success stubProfile)))) )

        ProfileUnfollow_Article__Slug_ { username } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotAuthor (Success stubProfile)))) )

        UserAuthentication_Login { user } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Login (Pages.Login.GotUser (Success stubUser)))) )

        UserRegistration_Register { user } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Register (Pages.Register.GotUser (Success stubUser)))) )

        UserUpdate_Settings { user } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Settings (Pages.Settings.GotUser (Success stubUser)))) )

        NoOpToBackend ->
            ( model, Cmd.none )
