module Pages.Article.Slug_ exposing (Model, Msg(..), page)

import Api.Article exposing (Article)
import Api.Article.Comment exposing (Comment)
import Api.Data exposing (Data)
import Api.Profile exposing (Profile)
import Api.User exposing (User)
import Bridge exposing (..)
import Components.IconButton as IconButton
import Gen.Params.Article.Slug_ exposing (Params)
import Gen.Route as Route
import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, placeholder, src, value)
import Html.Events as Events
import Markdown
import Page
import Request
import Shared
import Utils.Maybe
import Utils.Route
import Utils.Time
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.element
        { init = init shared req
        , update = update req
        , subscriptions = subscriptions
        , view = view shared
        }



-- INIT


type alias Model =
    { article : Data Article
    , comments : Data (List Comment)
    , commentText : String
    }


init : Shared.Model -> Request.With Params -> ( Model, Cmd Msg )
init shared { params } =
    ( { article = Api.Data.Loading
      , comments = Api.Data.Loading
      , commentText = ""
      }
    , Cmd.batch
        [ ArticleGet_Article__Slug_
            { slug = params.slug
            }
            |> sendToBackend
        , ArticleCommentGet_Article__Slug_
            { articleSlug = params.slug
            }
            |> sendToBackend
        ]
    )



-- UPDATE


type Msg
    = GotArticle (Data Article)
    | ClickedFavorite User Article
    | ClickedUnfavorite User Article
    | ClickedDeleteArticle User Article
    | DeletedArticle (Data Article)
    | GotAuthor (Data Profile)
    | ClickedFollow User Profile
    | ClickedUnfollow User Profile
    | GotComments (Data (List Comment))
    | ClickedDeleteComment User Article Comment
    | DeletedComment (Data Int)
    | SubmittedCommentForm User Article
    | CreatedComment (Data Comment)
    | UpdatedCommentText String


update : Request.With Params -> Msg -> Model -> ( Model, Cmd Msg )
update req msg model =
    case msg of
        GotArticle article ->
            ( { model | article = article }
            , Cmd.none
            )

        ClickedFavorite user article ->
            ( model
            , ArticleFavorite_Article__Slug_
                { slug = article.slug
                }
                |> sendToBackend
            )

        ClickedUnfavorite user article ->
            ( model
            , ArticleUnfavorite_Article__Slug_
                { slug = article.slug
                }
                |> sendToBackend
            )

        ClickedDeleteArticle user article ->
            ( model
            , ArticleDelete_Article__Slug_
                { slug = article.slug
                }
                |> sendToBackend
            )

        DeletedArticle _ ->
            ( model
            , Utils.Route.navigate req.key Route.Home_
            )

        GotAuthor profile ->
            let
                updateAuthor : Article -> Article
                updateAuthor article =
                    case profile of
                        Api.Data.Success author ->
                            { article | author = author }

                        _ ->
                            article
            in
            ( { model | article = Api.Data.map updateAuthor model.article }
            , Cmd.none
            )

        ClickedFollow user profile ->
            ( model
            , ProfileFollow_Article__Slug_
                { username = profile.username
                }
                |> sendToBackend
            )

        ClickedUnfollow user profile ->
            ( model
            , ProfileUnfollow_Article__Slug_
                { username = profile.username
                }
                |> sendToBackend
            )

        GotComments comments ->
            ( { model | comments = comments }
            , Cmd.none
            )

        UpdatedCommentText text ->
            ( { model | commentText = text }
            , Cmd.none
            )

        SubmittedCommentForm user article ->
            if String.isEmpty model.commentText then
                ( model, Cmd.none )

            else
                ( { model | commentText = "" }
                , ArticleCommentCreate_Article__Slug_
                    { articleSlug = article.slug
                    , comment = { body = model.commentText }
                    }
                    |> sendToBackend
                )

        CreatedComment comment ->
            ( case comment of
                Api.Data.Success c ->
                    { model | comments = Api.Data.map (\comments -> c :: comments) model.comments }

                _ ->
                    model
            , Cmd.none
            )

        ClickedDeleteComment user article comment ->
            ( model
            , ArticleCommentDelete_Article__Slug_
                { articleSlug = article.slug
                , commentId = comment.id
                }
                |> sendToBackend
            )

        DeletedComment id ->
            let
                removeComment : List Comment -> List Comment
                removeComment =
                    List.filter (\comment -> Api.Data.Success comment.id /= id)
            in
            ( { model | comments = Api.Data.map removeComment model.comments }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    case model.article of
        Api.Data.Success article ->
            { title = article.title
            , body = [ viewArticle shared model article ]
            }

        _ ->
            { title = "Article"
            , body = []
            }


viewArticle : Shared.Model -> Model -> Article -> Html Msg
viewArticle shared model article =
    div [ class "article-page" ]
        [ div [ class "banner" ]
            [ div [ class "container" ]
                [ h1 [] [ text article.title ]
                , viewArticleMeta shared model article
                ]
            ]
        , div [ class "container page" ]
            [ div [ class "row article-content" ]
                [ div [ class "col-md-12" ]
                    [ Markdown.toHtml [] article.body ]
                , if List.isEmpty article.tags then
                    text ""

                  else
                    ul [ class "tag-list" ]
                        (List.map
                            (\tag -> li [ class "tag-default tag-pill tag-outline" ] [ text tag ])
                            article.tags
                        )
                ]
            , hr [] []
            , div [ class "article-actions" ] [ viewArticleMeta shared model article ]
            , viewCommentSection shared model article
            ]
        ]


viewArticleMeta : Shared.Model -> Model -> Article -> Html Msg
viewArticleMeta shared model article =
    div [ class "article-meta" ] <|
        List.concat
            [ [ a [ href ("/profile/" ++ article.author.username) ]
                    [ img [ src article.author.image ] []
                    ]
              , div [ class "info" ]
                    [ a [ class "author", href ("/profile/" ++ article.author.username) ] [ text article.author.username ]
                    , span [ class "date" ] [ text (Utils.Time.formatDate article.createdAt) ]
                    ]
              ]
            , case shared.user of
                Just user ->
                    viewControls article user

                Nothing ->
                    []
            ]


viewControls : Article -> User -> List (Html Msg)
viewControls article user =
    if article.author.username == user.username then
        [ a
            [ class "btn btn-outline-secondary btn-sm"
            , href ("/editor/" ++ article.slug)
            ]
            [ i [ class "ion-edit" ] []
            , text "Edit article"
            ]
        , IconButton.view
            { color = IconButton.OutlinedRed
            , icon = IconButton.Trash
            , label = "Delete article"
            , onClick = ClickedDeleteArticle user article
            }
        ]

    else
        [ if article.author.following then
            IconButton.view
                { color = IconButton.FilledGray
                , icon = IconButton.Plus
                , label = "Unfollow " ++ article.author.username
                , onClick = ClickedUnfollow user article.author
                }

          else
            IconButton.view
                { color = IconButton.OutlinedGray
                , icon = IconButton.Plus
                , label = "Follow " ++ article.author.username
                , onClick = ClickedFollow user article.author
                }
        , if article.favorited then
            IconButton.view
                { color = IconButton.FilledGreen
                , icon = IconButton.Heart
                , label = "Unfavorite Post (" ++ String.fromInt article.favoritesCount ++ ")"
                , onClick = ClickedUnfavorite user article
                }

          else
            IconButton.view
                { color = IconButton.OutlinedGreen
                , icon = IconButton.Heart
                , label = "Favorite Post (" ++ String.fromInt article.favoritesCount ++ ")"
                , onClick = ClickedFavorite user article
                }
        ]


viewCommentSection : Shared.Model -> Model -> Article -> Html Msg
viewCommentSection shared model article =
    div [ class "row" ]
        [ div [ class "col-xs-12 col-md-8 offset-md-2" ] <|
            List.concat
                [ case shared.user of
                    Just user ->
                        [ viewCommentForm model user article ]

                    Nothing ->
                        []
                , case model.comments of
                    Api.Data.Success comments ->
                        List.map (viewComment shared.user article) comments

                    _ ->
                        []
                ]
        ]


viewCommentForm : Model -> User -> Article -> Html Msg
viewCommentForm model user article =
    form [ class "card comment-form", Events.onSubmit (SubmittedCommentForm user article) ]
        [ div [ class "card-block" ]
            [ textarea
                [ class "form-control"
                , placeholder "Write a comment..."
                , attribute "rows" "3"
                , value model.commentText
                , Events.onInput UpdatedCommentText
                ]
                []
            ]
        , div [ class "card-footer" ]
            [ img [ class "comment-author-img", src user.image ] []
            , button [ class "btn btn-sm btn-primary" ] [ text "Post Comment" ]
            ]
        ]


viewComment : Maybe User -> Article -> Comment -> Html Msg
viewComment currentUser article comment =
    let
        viewCommentActions =
            Utils.Maybe.view currentUser <|
                \user ->
                    if user.username == comment.author.username then
                        span
                            [ class "mod-options"
                            , Events.onClick (ClickedDeleteComment user article comment)
                            ]
                            [ i [ class "ion-trash-a" ] [] ]

                    else
                        text ""
    in
    div [ class "card" ]
        [ div [ class "card-block" ]
            [ p [ class "card-text" ] [ text comment.body ] ]
        , div [ class "card-footer" ]
            [ a
                [ class "comment-author"
                , href ("/profile/" ++ comment.author.username)
                ]
                [ img [ class "comment-author-img", src comment.author.image ] []
                , text comment.author.username
                ]
            , span [ class "date-posted" ] [ text (Utils.Time.formatDate comment.createdAt) ]
            , viewCommentActions
            ]
        ]
