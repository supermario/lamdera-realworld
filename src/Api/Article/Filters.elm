module Api.Article.Filters exposing (..)

import Dict
import Dict.Extra as Dict


{-|

@docs Filters, create
@docs withTag, withAuthor, favoritedBy
@docs byTag, byAuthor

-}
type Filters
    = Filters
        { tag : Maybe String
        , author : Maybe String
        , favorited : Maybe String
        }


create : Filters
create =
    Filters
        { tag = Nothing
        , author = Nothing
        , favorited = Nothing
        }


withTag : String -> Filters -> Filters
withTag tag (Filters filters) =
    Filters { filters | tag = Just tag }


withAuthor : String -> Filters -> Filters
withAuthor username (Filters filters) =
    Filters { filters | author = Just username }


favoritedBy : String -> Filters -> Filters
favoritedBy username (Filters filters) =
    Filters { filters | favorited = Just username }


byTag mTag articles =
    case mTag of
        Just tag ->
            articles |> Dict.filter (\k a -> a.tags |> List.member tag)

        Nothing ->
            articles


byAuthor mAuthor users articles =
    case mAuthor of
        Just username ->
            case users |> Dict.find (\k u -> u.username == username) |> Maybe.map Tuple.second of
                Just user ->
                    articles |> Dict.filter (\k a -> a.userId == user.id)

                Nothing ->
                    articles

        Nothing ->
            articles


byFavorite mUsername users articles =
    case mUsername of
        Just username ->
            case users |> Dict.find (\k u -> u.username == username) |> Maybe.map Tuple.second of
                Just user ->
                    articles |> Dict.filter (\slug a -> List.member slug user.favorites)

                Nothing ->
                    articles

        Nothing ->
            articles
