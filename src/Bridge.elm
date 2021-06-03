module Bridge exposing (..)

import Api.Article.Filters exposing (Filters)
import Api.User exposing (User)
import Lamdera


sendToBackend =
    Lamdera.sendToBackend


type ToBackend
    = SignedOut User
      -- Req/resp paired messages
    | GetTags_Home_
    | ArticleList_Home_ { filters : Filters, page : Int }
    | ArticleFeed_Home_ { page : Int }
    | ArticleList_Username_ { filters : Filters, page : Int }
    | ArticleGet_Editor__ArticleSlug_ { slug : String }
    | ArticleGet_Article__Slug_ { slug : String }
    | ArticleCreate_Editor
        { article :
            { title : String, description : String, body : String, tags : List String }
        }
    | ArticleUpdate_Editor__ArticleSlug_
        { slug : String
        , updates :
            { title : String, description : String, body : String, tags : List String }
        }
    | ArticleDelete_Article__Slug_ { slug : String }
    | ArticleFavorite_Profile__Username_ { slug : String }
    | ArticleUnfavorite_Profile__Username_ { slug : String }
    | ArticleFavorite_Home_ { slug : String }
    | ArticleUnfavorite_Home_ { slug : String }
    | ArticleFavorite_Article__Slug_ { slug : String }
    | ArticleUnfavorite_Article__Slug_ { slug : String }
    | ArticleCommentGet_Article__Slug_ { articleSlug : String }
    | ArticleCommentCreate_Article__Slug_ { articleSlug : String, comment : { body : String } }
    | ArticleCommentDelete_Article__Slug_ { articleSlug : String, commentId : Int }
    | ProfileGet_Profile__Username_ { username : String }
    | ProfileFollow_Profile__Username_ { username : String }
    | ProfileUnfollow_Profile__Username_ { username : String }
    | ProfileFollow_Article__Slug_ { username : String }
    | ProfileUnfollow_Article__Slug_ { username : String }
    | UserAuthentication_Login { params : { email : String, password : String } }
    | UserRegistration_Register { params : { username : String, email : String, password : String } }
    | UserUpdate_Settings
        { params :
            { username : String
            , email : String
            , password : Maybe String
            , image : String
            , bio : String
            }
        }
    | NoOpToBackend
