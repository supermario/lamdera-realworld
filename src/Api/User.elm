module Api.User exposing (..)

{-|

@docs User, UserFull, Email

-}


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
    }


toUser : UserFull -> User
toUser u =
    { email = u.email
    , username = u.username
    , bio = u.bio
    , image = u.image
    }


type alias Email =
    String
