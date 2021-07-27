module Gen.Params.Profile.Username_ exposing (Params, parser)

import Url.Parser as Parser exposing ((</>), Parser)


type alias Params =
    { username : String }


parser =
    Parser.map Params (Parser.s "profile" </> Parser.string)

