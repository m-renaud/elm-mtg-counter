module Types exposing (Model, Msg(..))

import Material

import Player


type alias Model =
    { player1 : Player.Model
    , player2 : Player.Model
    , startingPlayer : Maybe String
    , confirmResetGame : Bool
    , mdl : Material.Model
    }



type Msg
    -- Player card subcomponent messages.
    = Player1Msg Player.Msg
    | Player2Msg Player.Msg

    -- Reset the game state (player1 and player2 models)
    | Reset
    | ConfirmReset
    | CancelReset

    -- Messages for randomly selecting the starting player.
    | SelectStartingPlayerClick
    | SelectStartingPlayer
    | ShowStartingPlayer Int
    | HideStartingPlayerCard

    -- Elm MDL message.
    | Mdl (Material.Msg Msg)
