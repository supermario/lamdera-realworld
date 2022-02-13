module Gen.Model exposing (Model(..))

import Gen.Params.Editor
import Gen.Params.Home_
import Gen.Params.Login
import Gen.Params.NotFound
import Gen.Params.Settings
import Gen.Params.Article.Slug_
import Gen.Params.Editor.ArticleSlug_
import Gen.Params.Login.Provider_.Callback
import Gen.Params.Profile.Username_
import Pages.Editor
import Pages.Home_
import Pages.Login
import Pages.NotFound
import Pages.Settings
import Pages.Article.Slug_
import Pages.Editor.ArticleSlug_
import Pages.Login.Provider_.Callback
import Pages.Profile.Username_


type Model
    = Redirecting_
    | Editor Gen.Params.Editor.Params Pages.Editor.Model
    | Home_ Gen.Params.Home_.Params Pages.Home_.Model
    | Login Gen.Params.Login.Params Pages.Login.Model
    | NotFound Gen.Params.NotFound.Params
    | Settings Gen.Params.Settings.Params Pages.Settings.Model
    | Article__Slug_ Gen.Params.Article.Slug_.Params Pages.Article.Slug_.Model
    | Editor__ArticleSlug_ Gen.Params.Editor.ArticleSlug_.Params Pages.Editor.ArticleSlug_.Model
    | Login__Provider___Callback Gen.Params.Login.Provider_.Callback.Params Pages.Login.Provider_.Callback.Model
    | Profile__Username_ Gen.Params.Profile.Username_.Params Pages.Profile.Username_.Model

