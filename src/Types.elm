module Types exposing (..)

import Api.Data exposing (..)
import Bridge
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Gen.Pages as Pages
import Shared
import Url exposing (Url)


type alias FrontendModel =
    { url : Url
    , key : Key
    , shared : Shared.Model
    , page : Pages.Model
    }


type alias BackendModel =
    { message : String
    }


type FrontendMsg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | Shared Shared.Msg
    | Page Pages.Msg
    | Noop


type alias ToBackend =
    Bridge.ToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = PageMsg Pages.Msg
    | NoOpToFrontend
