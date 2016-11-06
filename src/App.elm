port module App exposing (main, setStorage)

import Html.App

import Persist exposing (PersistentModel, toPersistentModel)
import State exposing (init, update)
import Types exposing (Msg, Model)
import View exposing (view)


main : Program (Maybe PersistentModel)
main =
    Html.App.programWithFlags
        { init = init
        , view = view
        , subscriptions = always Sub.none
        , update = updateWithStorage
        }


port setStorage : PersistentModel -> Cmd msg


updateWithStorage : Msg -> Model -> (Model, Cmd Msg)
updateWithStorage msg model =
    let
        (newModel, cmds) =
            update msg model

    in
        ( newModel
        , Cmd.batch [ setStorage (toPersistentModel newModel), cmds ]
        )
