module Api.Article exposing (..)

{-|

@docs Article, Listing, updateArticle, itemsPerPage

-}

import Api.Profile exposing (Profile)
import Time


type alias Article =
    { slug : Slug
    , title : String
    , description : String
    , body : String
    , tags : List String
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , favorited : Bool
    , favoritesCount : Int
    , author : Profile
    }


type alias ArticleStore =
    { slug : Slug
    , title : String
    , description : String
    , body : String
    , tags : List String
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , userId : Int
    }


type alias Slug =
    String


type alias Listing =
    { articles : List Article
    , page : Int
    , totalPages : Int
    }


updateArticle : Article -> Listing -> Listing
updateArticle article listing =
    let
        articles : List Article
        articles =
            List.map
                (\a ->
                    if a.slug == article.slug then
                        article

                    else
                        a
                )
                listing.articles
    in
    { listing | articles = articles }



-- INTERNALS


itemsPerPage : Int
itemsPerPage =
    25
