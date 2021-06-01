module Stubs exposing (..)

import Api.Article exposing (Article, Listing)
import Api.Article.Comment exposing (Comment)
import Api.Profile exposing (Profile)
import Api.User exposing (..)
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


stubArticle2 : Article
stubArticle2 =
    { slug = "stub"
    , title = "stub"
    , description = "stub"
    , body = "stub"
    , tags = [ "stub" ]
    , createdAt = Time.millisToPosix 0
    , updatedAt = Time.millisToPosix 0
    , favorited = False
    , favoritesCount = 123
    , author = { stubProfile | username = "bob@bob.com" }
    }


stubArticle_ : Int -> Article
stubArticle_ i =
    let
        iden =
            "stub-" ++ String.fromInt i
    in
    { slug = iden
    , title = iden
    , description = "stub"
    , body = iden
    , tags = [ iden ]
    , createdAt = Time.millisToPosix 1234567890123
    , updatedAt = Time.millisToPosix 1234567890123
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


stubUser : User
stubUser =
    { email = "test@test.com"
    , username = "test@test.com"
    , bio = Just "test bio"
    , image = "https://static.productionready.io/images/smiley-cyrus.jpg"
    }


stubUserFull : UserFull
stubUserFull =
    { email = "test@test.com"
    , username = "test@test.com"
    , bio = Just "test bio"
    , image = "https://static.productionready.io/images/smiley-cyrus.jpg"
    , password = "test"
    , favorites = []
    , following = []
    }


stubUserFull2 : UserFull
stubUserFull2 =
    { email = "bob@bob.com"
    , username = "bob@bob.com"
    , bio = Just "just bob"
    , image = "https://static.productionready.io/images/smiley-cyrus.jpg"
    , password = "bob"
    , favorites = []
    , following = []
    }


stubUsersFull : List UserFull
stubUsersFull =
    [ stubUserFull
    , stubUserFull2
    ]


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
