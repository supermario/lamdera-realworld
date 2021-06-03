module Backend exposing (..)

import Api.Article exposing (Article, ArticleStore, Slug)
import Api.Article.Filters as Filters exposing (Filters(..))
import Api.Data exposing (Data(..))
import Api.Profile exposing (Profile)
import Api.User exposing (Email, UserFull)
import Bridge exposing (..)
import Dict
import Dict.Extra as Dict
import Gen.Msg
import Lamdera exposing (..)
import List.Extra as List
import Pages.Article.Slug_
import Pages.Editor
import Pages.Editor.ArticleSlug_
import Pages.Home_
import Pages.Login
import Pages.Profile.Username_
import Pages.Register
import Pages.Settings
import Task
import Time
import Time.Extra as Time
import Types exposing (BackendModel, BackendMsg(..), FrontendMsg(..), ToFrontend(..))


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> onConnect CheckSession
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { sessions = Dict.empty
      , users = Dict.empty
      , articles = Dict.empty
      , comments = Dict.empty
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        CheckSession sid cid ->
            model
                |> getSessionUser sid
                |> Maybe.map (\user -> ( model, sendToFrontend cid (ActiveSession (Api.User.toUser user)) ))
                |> Maybe.withDefault ( model, Cmd.none )

        RenewSession uid sid cid now ->
            ( { model | sessions = model.sessions |> Dict.update sid (always (Just { userId = uid, expires = now |> Time.add Time.Day 30 Time.utc })) }
            , Time.now |> Task.perform (always (CheckSession sid cid))
            )

        ArticleCreated t userM clientId article ->
            case userM of
                Just user ->
                    let
                        article_ =
                            { slug = uniqueSlug model article.title 1
                            , title = article.title
                            , description = article.description
                            , body = article.body
                            , tags = article.tags
                            , createdAt = t
                            , updatedAt = t
                            , userId = user.id
                            }

                        res =
                            Success <| loadArticleFromStore model userM article_
                    in
                    ( { model | articles = model.articles |> Dict.insert article_.slug article_ }
                    , sendToFrontend clientId (PageMsg (Gen.Msg.Editor (Pages.Editor.GotArticle res)))
                    )

                Nothing ->
                    ( model
                    , sendToFrontend clientId (PageMsg (Gen.Msg.Editor (Pages.Editor.GotArticle (Failure [ "invalid session" ]))))
                    )

        ArticleCommentCreated t userM clientId slug commentBody ->
            case userM of
                Just user ->
                    let
                        comment =
                            { id = Time.posixToMillis t
                            , createdAt = t
                            , updatedAt = t
                            , body = commentBody.body
                            , author = Api.User.toProfile user
                            }

                        newComments =
                            model.comments
                                |> Dict.update slug
                                    (\commentsM ->
                                        case commentsM of
                                            Just comments ->
                                                Just (comments |> Dict.insert comment.id comment)

                                            Nothing ->
                                                Just <| Dict.singleton comment.id comment
                                    )
                    in
                    ( { model | comments = newComments }
                    , sendToFrontend clientId (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.CreatedComment (Success comment))))
                    )

                Nothing ->
                    ( model
                    , sendToFrontend clientId (PageMsg (Gen.Msg.Editor (Pages.Editor.GotArticle (Failure [ "invalid session" ]))))
                    )

        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    let
        send v =
            ( model, send_ v )

        send_ v =
            sendToFrontend clientId v

        onlyWhenArticleOwner slug fn =
            onlyWhenArticleOwner_ slug (\r -> ( model, sendToFrontend clientId (fn r) ))

        onlyWhenArticleOwner_ slug fn =
            let
                res =
                    model |> loadArticleBySlug slug sessionId

                userM =
                    model |> getSessionUser sessionId
            in
            fn <|
                case ( res, userM ) of
                    ( Success article, Just user ) ->
                        if article.author.username == user.email then
                            res

                        else
                            Failure [ "you do not have permission for this article" ]

                    _ ->
                        Failure [ "you do not have permission for this article" ]
    in
    case msg of
        SignedOut user ->
            ( { model | sessions = model.sessions |> Dict.remove sessionId }, Cmd.none )

        GetTags_Home_ ->
            let
                allTags =
                    model.articles |> Dict.foldl (\slug article tags -> tags ++ article.tags) [] |> List.unique
            in
            send (PageMsg (Gen.Msg.Home_ (Pages.Home_.GotTags (Success allTags))))

        ArticleList_Home_ { filters, page } ->
            let
                articleList =
                    getListing model sessionId filters page
            in
            send (PageMsg (Gen.Msg.Home_ (Pages.Home_.GotArticles (Success articleList))))

        ArticleFeed_Home_ { page } ->
            let
                userM =
                    model |> getSessionUser sessionId

                articleList =
                    case userM of
                        Just user ->
                            let
                                filtered =
                                    model.articles
                                        |> Dict.filter (\slug article -> List.member article.userId user.following)

                                enriched =
                                    filtered |> Dict.map (\slug article -> loadArticleFromStore model userM article)

                                grouped =
                                    enriched |> Dict.values |> List.greedyGroupsOf Api.Article.itemsPerPage

                                articles =
                                    grouped |> List.getAt (page - 1) |> Maybe.withDefault []
                            in
                            { articles = articles
                            , page = page
                            , totalPages = grouped |> List.length
                            }

                        Nothing ->
                            { articles = [], page = 0, totalPages = 0 }
            in
            send (PageMsg (Gen.Msg.Home_ (Pages.Home_.GotArticles (Success articleList))))

        ArticleList_Username_ { filters, page } ->
            let
                articleList =
                    getListing model sessionId filters page
            in
            send (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.GotArticles (Success articleList))))

        ArticleGet_Editor__ArticleSlug_ { slug } ->
            onlyWhenArticleOwner slug
                (\r -> PageMsg (Gen.Msg.Editor__ArticleSlug_ (Pages.Editor.ArticleSlug_.LoadedInitialArticle r)))

        ArticleUpdate_Editor__ArticleSlug_ { slug, updates } ->
            let
                articles =
                    model.articles
                        |> Dict.update slug
                            (Maybe.map
                                (\a -> { a | title = updates.title, body = updates.body, tags = updates.tags })
                            )

                res =
                    articles
                        |> Dict.get slug
                        |> Maybe.map Success
                        |> Maybe.withDefault (Failure [ "no article with slug: " ++ slug ])
                        |> Api.Data.map (loadArticleFromStore model (model |> getSessionUser sessionId))
            in
            ( { model | articles = articles }, send_ (PageMsg (Gen.Msg.Editor__ArticleSlug_ (Pages.Editor.ArticleSlug_.UpdatedArticle res))) )

        ArticleGet_Article__Slug_ { slug } ->
            let
                res =
                    model |> loadArticleBySlug slug sessionId
            in
            send (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotArticle res)))

        ArticleCreate_Editor { article } ->
            let
                userM =
                    model |> getSessionUser sessionId
            in
            ( model, Time.now |> Task.perform (\t -> ArticleCreated t userM clientId article) )

        ArticleDelete_Article__Slug_ { slug } ->
            onlyWhenArticleOwner_ slug
                (\r ->
                    ( { model | articles = model.articles |> Dict.remove slug }
                    , send_ (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.DeletedArticle r)))
                    )
                )

        ArticleFavorite_Profile__Username_ { slug } ->
            favoriteArticle sessionId
                slug
                model
                (\r -> send_ (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.UpdatedArticle r))))

        ArticleUnfavorite_Profile__Username_ { slug } ->
            unfavoriteArticle sessionId
                slug
                model
                (\r -> send_ (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.UpdatedArticle r))))

        ArticleFavorite_Home_ { slug } ->
            favoriteArticle sessionId
                slug
                model
                (\r -> send_ (PageMsg (Gen.Msg.Home_ (Pages.Home_.UpdatedArticle r))))

        ArticleUnfavorite_Home_ { slug } ->
            unfavoriteArticle sessionId
                slug
                model
                (\r -> send_ (PageMsg (Gen.Msg.Home_ (Pages.Home_.UpdatedArticle r))))

        ArticleFavorite_Article__Slug_ { slug } ->
            favoriteArticle sessionId
                slug
                model
                (\r -> send_ (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotArticle r))))

        ArticleUnfavorite_Article__Slug_ { slug } ->
            unfavoriteArticle sessionId
                slug
                model
                (\r -> send_ (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotArticle r))))

        ArticleCommentGet_Article__Slug_ { articleSlug } ->
            let
                res =
                    model.comments
                        |> Dict.get articleSlug
                        |> Maybe.map Dict.values
                        |> Maybe.map (List.sortBy .id)
                        |> Maybe.map List.reverse
                        |> Maybe.map Success
                        |> Maybe.withDefault (Success [])
            in
            send (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotComments res)))

        ArticleCommentCreate_Article__Slug_ { articleSlug, comment } ->
            let
                userM =
                    model |> getSessionUser sessionId
            in
            ( model, Time.now |> Task.perform (\t -> ArticleCommentCreated t userM clientId articleSlug comment) )

        ArticleCommentDelete_Article__Slug_ { articleSlug, commentId } ->
            let
                newComments =
                    model.comments
                        |> Dict.update articleSlug (Maybe.map (\comments -> Dict.remove commentId comments))
            in
            ( { model | comments = newComments }
            , send_ (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.DeletedComment (Success commentId))))
            )

        ProfileGet_Profile__Username_ { username } ->
            let
                res =
                    profileByUsername username model
                        |> Maybe.map Success
                        |> Maybe.withDefault (Failure [ "user not found" ])
            in
            send (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.GotProfile res)))

        ProfileFollow_Profile__Username_ { username } ->
            followUser sessionId
                username
                model
                (\r -> send_ (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.GotProfile r))))

        ProfileUnfollow_Profile__Username_ { username } ->
            unfollowUser sessionId
                username
                model
                (\r -> send_ (PageMsg (Gen.Msg.Profile__Username_ (Pages.Profile.Username_.GotProfile r))))

        ProfileFollow_Article__Slug_ { username } ->
            followUser sessionId
                username
                model
                (\r -> send_ (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotAuthor r))))

        ProfileUnfollow_Article__Slug_ { username } ->
            unfollowUser sessionId
                username
                model
                (\r -> send_ (PageMsg (Gen.Msg.Article__Slug_ (Pages.Article.Slug_.GotAuthor r))))

        UserAuthentication_Login { params } ->
            let
                ( response, cmd ) =
                    model.users
                        |> Dict.find (\k u -> u.email == params.email)
                        |> Maybe.map
                            (\( k, u ) ->
                                if u.password == params.password then
                                    ( Success (Api.User.toUser u), renewSession u.id sessionId clientId )

                                else
                                    ( Failure [ "email or password is invalid" ], Cmd.none )
                            )
                        |> Maybe.withDefault ( Failure [ "email or password is invalid" ], Cmd.none )
            in
            ( model, Cmd.batch [ send_ (PageMsg (Gen.Msg.Login (Pages.Login.GotUser response))), cmd ] )

        UserRegistration_Register { params } ->
            let
                ( model_, cmd, res ) =
                    if model.users |> Dict.any (\k u -> u.email == params.email) then
                        ( model, Cmd.none, Failure [ "email address already taken" ] )

                    else
                        let
                            user_ =
                                { id = Dict.size model.users
                                , email = params.email
                                , username = params.username
                                , bio = Nothing
                                , image = "https://static.productionready.io/images/smiley-cyrus.jpg"
                                , password = params.password
                                , favorites = []
                                , following = []
                                }
                        in
                        ( { model | users = model.users |> Dict.insert user_.id user_ }
                        , renewSession user_.id sessionId clientId
                        , Success (Api.User.toUser user_)
                        )
            in
            ( model_, Cmd.batch [ cmd, send_ (PageMsg (Gen.Msg.Register (Pages.Register.GotUser res))) ] )

        UserUpdate_Settings { params } ->
            let
                ( model_, res ) =
                    case model |> getSessionUser sessionId of
                        Just user ->
                            let
                                user_ =
                                    { user
                                        | username = params.username

                                        -- , email = params.email
                                        , password = params.password |> Maybe.withDefault user.password
                                        , image = params.image
                                        , bio = Just params.bio
                                    }
                            in
                            ( model |> updateUser user_, Success (Api.User.toUser user_) )

                        Nothing ->
                            ( model, Failure [ "you do not have permission for this user" ] )
            in
            ( model_, send_ (PageMsg (Gen.Msg.Settings (Pages.Settings.GotUser res))) )

        NoOpToBackend ->
            ( model, Cmd.none )


getSessionUser : SessionId -> Model -> Maybe UserFull
getSessionUser sid model =
    model.sessions
        |> Dict.get sid
        |> Maybe.andThen (\session -> model.users |> Dict.get session.userId)


renewSession email sid cid =
    Time.now |> Task.perform (RenewSession email sid cid)


getListing : Model -> SessionId -> Filters -> Int -> Api.Article.Listing
getListing model sessionId (Filters { tag, author, favorited }) page =
    let
        filtered =
            model.articles
                |> Filters.byFavorite favorited model.users
                |> Filters.byTag tag
                |> Filters.byAuthor author model.users

        enriched =
            filtered |> Dict.map (\slug article -> loadArticleFromStore model (model |> getSessionUser sessionId) article)

        grouped =
            enriched |> Dict.values |> List.greedyGroupsOf Api.Article.itemsPerPage

        articles =
            grouped |> List.getAt (page - 1) |> Maybe.withDefault []
    in
    { articles = articles
    , page = page
    , totalPages = grouped |> List.length
    }


loadArticleBySlug : String -> SessionId -> Model -> Data Article
loadArticleBySlug slug sid model =
    model.articles
        |> Dict.get slug
        |> Maybe.map Success
        |> Maybe.withDefault (Failure [ "no article with slug: " ++ slug ])
        |> Api.Data.map (loadArticleFromStore model (model |> getSessionUser sid))


uniqueSlug : Model -> String -> Int -> String
uniqueSlug model title i =
    let
        slug =
            title |> String.replace " " "-"
    in
    if not (model.articles |> Dict.member slug) then
        slug

    else if not (model.articles |> Dict.member (slug ++ "-" ++ String.fromInt i)) then
        slug ++ "-" ++ String.fromInt i

    else
        uniqueSlug model title (i + 1)


favoriteArticle : SessionId -> Slug -> Model -> (Data Article -> Cmd msg) -> ( Model, Cmd msg )
favoriteArticle sessionId slug model toResponseCmd =
    let
        res =
            model
                |> loadArticleBySlug slug sessionId
                |> Api.Data.map (\a -> { a | favorited = True })
    in
    case model |> getSessionUser sessionId of
        Just user ->
            ( if model.articles |> Dict.member slug then
                model |> updateUser { user | favorites = (slug :: user.favorites) |> List.unique }

              else
                model
            , toResponseCmd res
            )

        Nothing ->
            ( model, toResponseCmd <| Failure [ "invalid session" ] )


unfavoriteArticle : SessionId -> Slug -> Model -> (Data Article -> Cmd msg) -> ( Model, Cmd msg )
unfavoriteArticle sessionId slug model toResponseCmd =
    let
        res =
            model
                |> loadArticleBySlug slug sessionId
                |> Api.Data.map (\a -> { a | favorited = False })
    in
    case model |> getSessionUser sessionId of
        Just user ->
            ( model |> updateUser { user | favorites = user.favorites |> List.remove slug }
            , toResponseCmd res
            )

        Nothing ->
            ( model, toResponseCmd <| Failure [ "invalid session" ] )


followUser : SessionId -> Email -> Model -> (Data Profile -> Cmd msg) -> ( Model, Cmd msg )
followUser sessionId email model toResponseCmd =
    let
        res =
            profileByEmail email model
                |> Maybe.map (\a -> Success { a | following = True })
                |> Maybe.withDefault (Failure [ "invalid user" ])
    in
    case model |> getSessionUser sessionId of
        Just user ->
            ( case model.users |> Dict.find (\l u -> u.email == email) of
                Just ( _, follow ) ->
                    model |> updateUser { user | following = (follow.id :: user.following) |> List.unique }

                Nothing ->
                    model
            , toResponseCmd res
            )

        Nothing ->
            ( model, toResponseCmd <| Failure [ "invalid session" ] )


unfollowUser : SessionId -> Email -> Model -> (Data Profile -> Cmd msg) -> ( Model, Cmd msg )
unfollowUser sessionId email model toResponseCmd =
    case model.users |> Dict.find (\k u -> u.email == email) of
        Just ( _, followed ) ->
            let
                res =
                    followed
                        |> Api.User.toProfile
                        |> (\a -> Success { a | following = False })
            in
            case model |> getSessionUser sessionId of
                Just user ->
                    ( model |> updateUser { user | following = user.following |> List.remove followed.id }
                    , toResponseCmd res
                    )

                Nothing ->
                    ( model, toResponseCmd <| Failure [ "invalid session" ] )

        Nothing ->
            ( model, toResponseCmd <| Failure [ "invalid user" ] )


updateUser : UserFull -> Model -> Model
updateUser user model =
    { model | users = model.users |> Dict.update user.id (Maybe.map (always user)) }


profileByUsername username model =
    model.users |> Dict.find (\k u -> u.username == username) |> Maybe.map (Tuple.second >> Api.User.toProfile)


profileByEmail email model =
    model.users |> Dict.find (\k u -> u.email == email) |> Maybe.map (Tuple.second >> Api.User.toProfile)


loadArticleFromStore : Model -> Maybe UserFull -> ArticleStore -> Article
loadArticleFromStore model userM store =
    let
        favorited =
            userM |> Maybe.map (\user -> user.favorites |> List.member store.slug) |> Maybe.withDefault False

        author =
            model.users
                |> Dict.get store.userId
                |> Maybe.map Api.User.toProfile
                |> Maybe.withDefault { username = "error: unknown user", bio = Nothing, image = "", following = False }
    in
    { slug = store.slug
    , title = store.title
    , description = store.description
    , body = store.body
    , tags = store.tags
    , createdAt = store.createdAt
    , updatedAt = store.updatedAt
    , favorited = favorited
    , favoritesCount = model.users |> Dict.filter (\_ user -> user.favorites |> List.member store.slug) |> Dict.size
    , author = author
    }
