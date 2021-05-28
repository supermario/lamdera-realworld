module Api.Article.Comment exposing (Comment)

{-|

@docs Comment

-}

import Api.Profile exposing (Profile)
import Time


type alias Comment =
    { id : Int
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , body : String
    , author : Profile
    }
