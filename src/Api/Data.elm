module Api.Data exposing (Data(..), map, toMaybe)

import Http


type Data value
    = NotAsked
    | Loading
    | Failure (List String)
    | Success value


map : (a -> b) -> Data a -> Data b
map fn data =
    case data of
        NotAsked ->
            NotAsked

        Loading ->
            Loading

        Failure reason ->
            Failure reason

        Success value ->
            Success (fn value)


toMaybe : Data value -> Maybe value
toMaybe data =
    case data of
        Success value ->
            Just value

        _ ->
            Nothing


fromResult : Result (List String) value -> Data value
fromResult result =
    case result of
        Ok value ->
            Success value

        Err reasons ->
            Failure reasons
