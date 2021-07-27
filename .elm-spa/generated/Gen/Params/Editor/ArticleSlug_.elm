module Gen.Params.Editor.ArticleSlug_ exposing (Params, parser)

import Url.Parser as Parser exposing ((</>), Parser)


type alias Params =
    { articleSlug : String }


parser =
    Parser.map Params (Parser.s "editor" </> Parser.string)

