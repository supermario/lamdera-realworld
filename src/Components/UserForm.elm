module Components.UserForm exposing (Field, view)

import Api.Data exposing (Data)
import Api.User exposing (User)
import Components.ErrorList
import Gen.Route as Route exposing (Route)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, placeholder, type_, value)
import Html.Events as Events


type alias Field msg =
    { label : String
    , type_ : String
    , value : String
    , onInput : String -> msg
    }


view :
    { label : String
    , onFormSubmit : msg
    , title : String
    , inProgress : Bool
    }
    -> Html msg
view options =
    div [ class "auth-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-4 offset-md-4 col-xs-12" ]
                    [ h1 [] [ text options.title ]
                    , if options.inProgress then
                        button [ class "btn btn-lg btn-primary", attribute "disabled" "" ]
                            [ text options.label
                            , span [ class "spinner-white" ] []
                            ]

                      else
                        button [ class "btn btn-lg btn-primary", Events.onClick options.onFormSubmit ]
                            [ text options.label
                            ]
                    ]
                ]
            ]
        ]


viewField : Field msg -> Html msg
viewField options =
    fieldset [ class "form-group" ]
        [ input
            [ class "form-control form-control-lg"
            , placeholder options.label
            , type_ options.type_
            , value options.value
            , Events.onInput options.onInput
            ]
            []
        ]
