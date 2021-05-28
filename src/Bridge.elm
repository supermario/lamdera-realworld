module Bridge exposing (..)

import Api.Article.Filters as Filters exposing (Filters)
import Api.Token exposing (Token)
import Lamdera


sendToBackend =
    Lamdera.sendToBackend


type ToBackend
    = GetTags_Home_
    | ArticleList_Home_ { token : Maybe Token, filters : Filters, page : Int }
    | ArticleFeed_Home_ { token : Token, page : Int }
    | ArticleList_Username_ { token : Maybe Token, filters : Filters, page : Int }
    | ArticleGet_Editor__ArticleSlug_ { slug : String, token : Maybe Token }
    | ArticleGet_Article__Slug_ { slug : String, token : Maybe Token }
    | ArticleCreate_Editor
        { token : Token
        , article :
            { title : String, description : String, body : String, tags : List String }
        }
    | ArticleUpdate_Editor__ArticleSlug_
        { token : Token
        , slug : String
        , article :
            { title : String, description : String, body : String, tags : List String }
        }
    | ArticleDelete_Article__Slug_ { token : Token, slug : String }
    | ArticleFavorite_Profile__Username_ { token : Token, slug : String }
    | ArticleUnfavorite_Profile__Username_ { token : Token, slug : String }
    | ArticleFavorite_Home_ { token : Token, slug : String }
    | ArticleUnfavorite_Home_ { token : Token, slug : String }
    | ArticleFavorite_Article__Slug_ { token : Token, slug : String }
    | ArticleUnfavorite_Article__Slug_ { token : Token, slug : String }
    | ArticleCommentGet_Article__Slug_ { token : Maybe Token, articleSlug : String }
    | ArticleCommentCreate_Article__Slug_ { token : Token, articleSlug : String, comment : { body : String } }
    | ArticleCommentDelete_Article__Slug_ { token : Token, articleSlug : String, commentId : Int }
    | NoOpToBackend
