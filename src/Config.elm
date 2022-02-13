module Config exposing (..)

import Env


githubOAuthClientId =
    case Env.mode of
        Env.Production ->
            Env.githubOAuthClientId

        _ ->
            ""


githubOAuthClientSecret =
    case Env.mode of
        Env.Production ->
            Env.githubOAuthClientSecret

        _ ->
            ""
