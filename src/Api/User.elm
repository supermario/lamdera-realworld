module Api.User exposing
    ( User
    , decoder, encode
    )

{-|

@docs User

-}

import Api.Token exposing (Token)
import Json.Decode as Json
import Json.Encode as Encode
import Utils.Json


type alias User =
    { email : String
    , token : Token
    , username : String
    , bio : Maybe String
    , image : String
    }


decoder : Json.Decoder User
decoder =
    Json.map5 User
        (Json.field "email" Json.string)
        (Json.field "token" Api.Token.decoder)
        (Json.field "username" Json.string)
        (Json.field "bio" (Json.maybe Json.string))
        (Json.field "image" (Json.string |> Utils.Json.withDefault "https://static.productionready.io/images/smiley-cyrus.jpg"))


encode : User -> Json.Value
encode user =
    Encode.object
        [ ( "username", Encode.string user.username )
        , ( "email", Encode.string user.email )
        , ( "token", Api.Token.encode user.token )
        , ( "image", Encode.string user.image )
        , ( "bio", Utils.Json.maybe Encode.string user.bio )
        ]
