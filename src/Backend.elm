module Backend exposing (..)

import Api.Data exposing (Data(..))
import Bridge exposing (..)
import Gen.Msg
import Html
import Lamdera exposing (..)
import Pages.Article.Slug_
import Pages.Editor
import Pages.Editor.ArticleSlug_
import Pages.Home_
import Pages.Profile.Username_
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
        GetTags_Home_ ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Home_ (Pages.Home_.GotTags (Success [ "testing" ])))) )

        ArticleList_Home_ { token, filters, page } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Home_ (Pages.Home_.GotArticles (Success stubListing)))) )

        ArticleFeed_Home_ { token, page } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Home_ (Pages.Home_.GotArticles (Success stubListing)))) )

        ArticleList_Username_ { token, filters, page } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.GotArticles (Success stubListing)))) )

        ArticleGet_Editor__ArticleSlug_ { slug, token } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Editor__ArticleSlug_ (Pages.Editor.ArticleSlug_.LoadedInitialArticle (Success stubArticle)))) )

        ArticleUpdate_Editor__ArticleSlug_ { token, slug, article } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Editor__ArticleSlug_ (Pages.Editor.ArticleSlug_.UpdatedArticle (Success stubArticle)))) )

        ArticleGet_Article__Slug_ { slug, token } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotArticle (Success stubArticle)))) )

        ArticleCreate_Editor { token, article } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Editor (Pages.Editor.GotArticle (Success <| stubArticleCreate article)))) )

        ArticleDelete_Article__Slug_ { token, slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.DeletedArticle (Success stubArticle)))) )

        ArticleFavorite_Profile__Username_ { token, slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.UpdatedArticle (Success stubArticle)))) )

        ArticleUnfavorite_Profile__Username_ { token, slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.UpdatedArticle (Success stubArticle)))) )

        ArticleFavorite_Home_ { token, slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Home_ (Pages.Home_.UpdatedArticle (Success stubArticle)))) )

        ArticleUnfavorite_Home_ { token, slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Home_ (Pages.Home_.UpdatedArticle (Success stubArticle)))) )

        ArticleFavorite_Article__Slug_ { token, slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotArticle (Success stubArticle)))) )

        ArticleUnfavorite_Article__Slug_ { token, slug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotArticle (Success stubArticle)))) )

        ArticleCommentGet_Article__Slug_ { token, articleSlug } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotComments (Success stubComments)))) )

        ArticleCommentCreate_Article__Slug_ { token, articleSlug, comment } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.CreatedComment (Success stubComment)))) )

        ArticleCommentDelete_Article__Slug_ { token, articleSlug, commentId } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.DeletedComment (Success commentId)))) )

        ProfileGet_Profile__Username_ { token, username } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.GotProfile (Success stubProfile)))) )

        ProfileFollow_Profile__Username_ { token, username } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.GotProfile (Success stubProfile)))) )

        ProfileUnfollow_Profile__Username_ { token, username } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.GotProfile (Success stubProfile)))) )

        ProfileFollow_Article__Slug_ { token, username } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotAuthor (Success stubProfile)))) )

        ProfileUnfollow_Article__Slug_ { token, username } ->
            ( model, sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotAuthor (Success stubProfile)))) )

        NoOpToBackend ->
            ( model, Cmd.none )
