module Gen.Route exposing
    ( Route(..)
    , fromUrl
    , toHref
    )

import Gen.Params.Editor
import Gen.Params.Home_
import Gen.Params.Login
import Gen.Params.NotFound
import Gen.Params.Register
import Gen.Params.Settings
import Gen.Params.Article.Slug_
import Gen.Params.Editor.ArticleSlug_
import Gen.Params.Profile.Username_
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Editor
    | Home_
    | Login
    | NotFound
    | Register
    | Settings
    | Article__Slug_ { slug : String }
    | Editor__ArticleSlug_ { articleSlug : String }
    | Profile__Username_ { username : String }


fromUrl : Url -> Route
fromUrl =
    Parser.parse (Parser.oneOf routes) >> Maybe.withDefault NotFound


routes : List (Parser (Route -> a) a)
routes =
    [ Parser.map Home_ Gen.Params.Home_.parser
    , Parser.map Editor Gen.Params.Editor.parser
    , Parser.map Login Gen.Params.Login.parser
    , Parser.map NotFound Gen.Params.NotFound.parser
    , Parser.map Register Gen.Params.Register.parser
    , Parser.map Settings Gen.Params.Settings.parser
    , Parser.map Editor__ArticleSlug_ Gen.Params.Editor.ArticleSlug_.parser
    , Parser.map Article__Slug_ Gen.Params.Article.Slug_.parser
    , Parser.map Profile__Username_ Gen.Params.Profile.Username_.parser
    ]


toHref : Route -> String
toHref route =
    let
        joinAsHref : List String -> String
        joinAsHref segments =
            "/" ++ String.join "/" segments
    in
    case route of
        Editor ->
            joinAsHref [ "editor" ]
    
        Home_ ->
            joinAsHref []
    
        Login ->
            joinAsHref [ "login" ]
    
        NotFound ->
            joinAsHref [ "not-found" ]
    
        Register ->
            joinAsHref [ "register" ]
    
        Settings ->
            joinAsHref [ "settings" ]
    
        Article__Slug_ params ->
            joinAsHref [ "article", params.slug ]
    
        Editor__ArticleSlug_ params ->
            joinAsHref [ "editor", params.articleSlug ]
    
        Profile__Username_ params ->
            joinAsHref [ "profile", params.username ]

