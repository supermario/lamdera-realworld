module Api.Profile exposing (Profile)

{-|

@docs Profile

-}


type alias Profile =
    { username : String
    , bio : Maybe String
    , image : String
    , following : Bool
    }
