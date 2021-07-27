module Gen.Msg exposing (Msg(..))

import Gen.Params.Editor
import Gen.Params.Home_
import Gen.Params.Login
import Gen.Params.NotFound
import Gen.Params.Register
import Gen.Params.Settings
import Gen.Params.Article.Slug_
import Gen.Params.Editor.ArticleSlug_
import Gen.Params.Profile.Username_
import Pages.Editor
import Pages.Home_
import Pages.Login
import Pages.NotFound
import Pages.Register
import Pages.Settings
import Pages.Article.Slug_
import Pages.Editor.ArticleSlug_
import Pages.Profile.Username_


type Msg
    = Editor Pages.Editor.Msg
    | Home_ Pages.Home_.Msg
    | Login Pages.Login.Msg
    | Register Pages.Register.Msg
    | Settings Pages.Settings.Msg
    | Article__Slug_ Pages.Article.Slug_.Msg
    | Editor__ArticleSlug_ Pages.Editor.ArticleSlug_.Msg
    | Profile__Username_ Pages.Profile.Username_.Msg

