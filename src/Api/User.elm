module Api.User exposing (User)

{-|

@docs User

-}


type alias User =
    { email : String
    , username : String
    , bio : Maybe String
    , image : String
    }
