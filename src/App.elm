module App exposing (main)

import Html.App

import State exposing (init, update)
import View exposing (view)

main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , subscriptions = always Sub.none
        , update = update
        }
