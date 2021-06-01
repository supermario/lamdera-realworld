module Api.User exposing (..)

{-|

@docs User, UserFull, Email

-}

import Api.Profile exposing (Profile)


type alias User =
    { email : Email
    , username : String
    , bio : Maybe String
    , image : String
    }


type alias UserFull =
    { email : Email
    , username : String
    , bio : Maybe String
    , image : String
    , password : String
    , favorites : List String -- Slugs
    }


toUser : UserFull -> User
toUser u =
    { email = u.email
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
