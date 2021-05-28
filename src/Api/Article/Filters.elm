module Api.Article.Filters exposing
    ( Filters, create
    , withTag, byAuthor, favoritedBy
    )

{-|

@docs Filters, create
@docs withTag, byAuthor, favoritedBy

-}


type Filters
    = Filters
        { tag : Maybe String
        , author : Maybe String
        , favorited : Maybe String
        }


create : Filters
create =
    Filters
        { tag = Nothing
        , author = Nothing
        , favorited = Nothing
        }


withTag : String -> Filters -> Filters
withTag tag (Filters filters) =
    Filters { filters | tag = Just tag }


byAuthor : String -> Filters -> Filters
byAuthor username (Filters filters) =
    Filters { filters | author = Just username }


favoritedBy : String -> Filters -> Filters
favoritedBy username (Filters filters) =
    Filters { filters | favorited = Just username }
