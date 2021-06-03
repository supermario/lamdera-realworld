module Api.User exposing (..)

{-|

@docs User, UserFull, Email

-}

import Api.Article exposing (Slug)
import Api.Profile exposing (Profile)


type alias User =
    { id : Int
    , email : Email
    , username : String
    , bio : Maybe String
    , image : String
    }


type alias UserFull =
    { id : Int
    , email : Email
    , username : String
    , bio : Maybe String
    , image : String
    , password : String
    , favorites : List Slug
    , following : List UserId
    }


type alias UserId =
    Int


toUser : UserFull -> User
toUser u =
    { id = u.id
    , email = u.email
    , username = u.username
    , bio = u.bio
    , image = u.image
    }


toProfile : UserFull -> Profile
toProfile u =
    { username = u.username
    , bio = u.bio
    , image = u.image
    , following = False
    }


type alias Email =
    String
