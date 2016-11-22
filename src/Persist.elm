module Persist exposing (PersistentModel, fromPersistentModel, toPersistentModel)

import Material
import Player
import Types exposing (Model, Settings)


type alias PersistentModel =
    { persistentPlayer1 : Player.PersistentModel
    , persistentPlayer2 : Player.PersistentModel
    , gameSettings : Settings
    }


fromPersistentModel : PersistentModel -> Model
fromPersistentModel persistentModel =
    { player1 = Player.fromPersistentModel persistentModel.persistentPlayer1
    , player2 = Player.fromPersistentModel persistentModel.persistentPlayer2
    , startingPlayer = Nothing
    , confirmResetGame = False
    , gameSettings = persistentModel.gameSettings
    , mdl = Material.model
    }


toPersistentModel : Model -> PersistentModel
toPersistentModel model =
    { persistentPlayer1 = Player.toPersistentModel model.player1
    , persistentPlayer2 = Player.toPersistentModel model.player2
    , gameSettings = model.gameSettings
    }
