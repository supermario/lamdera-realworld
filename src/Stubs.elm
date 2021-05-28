module Stubs exposing (..)

import Api.Article exposing (Article, Listing)
import Api.Article.Comment exposing (Comment)
import Api.Profile exposing (Profile)
import Time


stubListing : Listing
stubListing =
    { articles = [ stubArticle ]
    , page = 1
    , totalPages = 1
    }


stubArticle : Article
stubArticle =
    { slug = "stub"
    , title = "stub"
    , description = "stub"
    , body = "stub"
    , tags = [ "stub" ]
    , createdAt = Time.millisToPosix 0
    , updatedAt = Time.millisToPosix 0
    , favorited = False
    , favoritesCount = 123
    , author = stubProfile
    }


stubArticleCreate : { title : String, description : String, body : String, tags : List String } -> Article
stubArticleCreate p =
    { slug = "stub"
    , title = p.title
    , description = p.description
    , body = p.body
    , tags = p.tags
    , createdAt = Time.millisToPosix 0
    , updatedAt = Time.millisToPosix 0
    , favorited = False
    , favoritesCount = 123
    , author = stubProfile
    }


stubProfile : Profile
stubProfile =
    { username = "test@test.com"
    , bio = Just "testing"
    , image = "https://static.productionready.io/images/smiley-cyrus.jpg"
    , following = False
    }


stubComment : Comment
stubComment =
    { id = 0
    , createdAt = Time.millisToPosix 0
    , updatedAt = Time.millisToPosix 0
    , body = "test comment"
    , author = stubProfile
    }


stubComments =
    [ stubComment ]
