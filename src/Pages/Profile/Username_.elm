module Pages.Profile.Username_ exposing (Model, Msg(..), page)

import Api.Article exposing (Article)
import Api.Article.Filters as Filters
import Api.Data exposing (Data)
import Api.Profile exposing (Profile)
import Api.User exposing (User)
import Bridge exposing (..)
import Components.ArticleList
import Components.IconButton as IconButton
import Components.NotFound
import Gen.Params.Profile.Username_ exposing (Params)
import Html exposing (..)
import Html.Attributes exposing (class, classList, src)
import Html.Events as Events
import Page
import Request
import Shared
import Utils.Maybe
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.element
        { init = init shared req
        , update = update shared
        , subscriptions = subscriptions
        , view = view shared
        }



-- INIT


type alias Model =
    { username : String
    , profile : Data Profile
    , listing : Data Api.Article.Listing
    , selectedTab : Tab
    , page : Int
    }


type Tab
    = MyArticles
    | FavoritedArticles


init : Shared.Model -> Request.With Params -> ( Model, Cmd Msg )
init shared { params } =
    ( { username = params.username
      , profile = Api.Data.Loading
      , listing = Api.Data.Loading
      , selectedTab = MyArticles
      , page = 1
      }
    , Cmd.batch
        [ ProfileGet_Profile__Username_
            { username = params.username
            }
            |> sendToBackend
        , fetchArticlesBy params.username 1
        ]
    )


fetchArticlesBy : String -> Int -> Cmd Msg
fetchArticlesBy username page_ =
    ArticleList_Username_
        { page = page_
        , filters = Filters.create |> Filters.withAuthor username
        }
        |> sendToBackend


fetchArticlesFavoritedBy : String -> Int -> Cmd Msg
fetchArticlesFavoritedBy username page_ =
    ArticleList_Username_
        { page = page_
        , filters =
            Filters.create |> Filters.favoritedBy username
        }
        |> sendToBackend



-- UPDATE


type Msg
    = GotProfile (Data Profile)
    | GotArticles (Data Api.Article.Listing)
    | Clicked Tab
    | ClickedFavorite User Article
    | ClickedUnfavorite User Article
    | UpdatedArticle (Data Article)
    | ClickedFollow User Profile
    | ClickedUnfollow User Profile
    | ClickedPage Int


update : Shared.Model -> Msg -> Model -> ( Model, Cmd Msg )
update shared msg model =
    case msg of
        GotProfile profile ->
            ( { model | profile = profile }
            , Cmd.none
            )

        ClickedFollow user profile ->
            ( model
            , ProfileFollow_Profile__Username_
                { username = profile.username
                }
                |> sendToBackend
            )

        ClickedUnfollow user profile ->
            ( model
            , ProfileUnfollow_Profile__Username_
                { username = profile.username
                }
                |> sendToBackend
            )

        GotArticles listing ->
            ( { model | listing = listing }
            , Cmd.none
            )

        Clicked MyArticles ->
            ( { model
                | selectedTab = MyArticles
                , listing = Api.Data.Loading
                , page = 1
              }
            , fetchArticlesBy model.username 1
            )

        Clicked FavoritedArticles ->
            ( { model
                | selectedTab = FavoritedArticles
                , listing = Api.Data.Loading
                , page = 1
              }
            , fetchArticlesFavoritedBy model.username 1
            )

        ClickedFavorite user article ->
            ( model
            , ArticleFavorite_Profile__Username_
                { slug = article.slug
                }
                |> sendToBackend
            )

        ClickedUnfavorite user article ->
            ( model
            , ArticleUnfavorite_Profile__Username_
                { slug = article.slug
                }
                |> sendToBackend
            )

        ClickedPage page_ ->
            let
                fetch : String -> Int -> Cmd Msg
                fetch =
                    case model.selectedTab of
                        MyArticles ->
                            fetchArticlesBy

                        FavoritedArticles ->
                            fetchArticlesFavoritedBy
            in
            ( { model
                | listing = Api.Data.Loading
                , page = page_
              }
            , fetch
                model.username
                page_
            )

        UpdatedArticle (Api.Data.Success article) ->
            ( { model
                | listing =
                    Api.Data.map (Api.Article.updateArticle article)
                        model.listing
              }
            , Cmd.none
            )

        UpdatedArticle _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = "Profile"
    , body =
        case model.profile of
            Api.Data.Success profile ->
                [ viewProfile shared profile model ]

            Api.Data.Failure _ ->
                [ Components.NotFound.view ]

            _ ->
                []
    }


viewProfile : Shared.Model -> Profile -> Model -> Html Msg
viewProfile shared profile model =
    let
        isViewingOwnProfile : Bool
        isViewingOwnProfile =
            Maybe.map .username shared.user == Just profile.username

        viewUserInfo : Html Msg
        viewUserInfo =
            div [ class "user-info" ]
                [ div [ class "container" ]
                    [ div [ class "row" ]
                        [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                            [ img [ class "user-img", src profile.image ] []
                            , h4 [] [ text profile.username ]
                            , Utils.Maybe.view profile.bio
                                (\bio -> p [] [ text bio ])
                            , if isViewingOwnProfile then
                                text ""

                              else
                                Utils.Maybe.view shared.user <|
                                    \user ->
                                        if profile.following then
                                            IconButton.view
                                                { color = IconButton.FilledGray
                                                , icon = IconButton.Plus
                                                , label = "Unfollow " ++ profile.username
                                                , onClick = ClickedUnfollow user profile
                                                }

                                        else
                                            IconButton.view
                                                { color = IconButton.OutlinedGray
                                                , icon = IconButton.Plus
                                                , label = "Follow " ++ profile.username
                                                , onClick = ClickedFollow user profile
                                                }
                            ]
                        ]
                    ]
                ]

        viewTabRow : Html Msg
        viewTabRow =
            div [ class "articles-toggle" ]
                [ ul [ class "nav nav-pills outline-active" ]
                    (List.map viewTab [ MyArticles, FavoritedArticles ])
                ]

        viewTab : Tab -> Html Msg
        viewTab tab =
            li [ class "nav-item" ]
                [ button
                    [ class "nav-link"
                    , Events.onClick (Clicked tab)
                    , classList [ ( "active", tab == model.selectedTab ) ]
                    ]
                    [ text
                        (case tab of
                            MyArticles ->
                                "My Articles"

                            FavoritedArticles ->
                                "Favorited Articles"
                        )
                    ]
                ]
    in
    div [ class "profile-page" ]
        [ viewUserInfo
        , div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                    (viewTabRow
                        :: Components.ArticleList.view
                            { user = shared.user
                            , articleListing = model.listing
                            , onFavorite = ClickedFavorite
                            , onUnfavorite = ClickedUnfavorite
                            , onPageClick = ClickedPage
                            }
                    )
                ]
            ]
        ]
