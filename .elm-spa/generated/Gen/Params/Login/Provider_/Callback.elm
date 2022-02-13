module Gen.Params.Login.Provider_.Callback exposing (Params, parser)

import Url.Parser as Parser exposing ((</>), Parser)


type alias Params =
    { provider : String }


parser =
    Parser.map Params (Parser.s "login" </> Parser.string </> Parser.s "callback")

