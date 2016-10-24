module State exposing (init, update)

import Material
import Material.Layout as Layout
import Random

import Types exposing (Model, Msg(..))

import Player


init : (Model, Cmd Msg)
init =
    let
        model =
            { player1 = Player.init "Player 1" 20
            , player2 = Player.init "Player 2" 20
            , startingPlayer = Nothing
            , mdl = Material.model
            , selectedTab = 0
            }
    in
        model ! []



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        -- Player subcomponent messages.
        Player1Msg playerMsg ->
            let
                (player', cmds) = Player.update playerMsg model.player1
                model' = { model | player1 = player' }
            in
                (model', Cmd.map Player1Msg cmds)

        Player2Msg playerMsg ->
            let
                (player', cmds) = Player.update playerMsg model.player2
                model' = { model | player2 = player' }
            in
                (model', Cmd.map Player2Msg cmds)


        -- Reset the game.
        Reset ->
            ( { model | player1 = Player.setLifeTotal 20 model.player1
                      , player2 = Player.setLifeTotal 20 model.player2
              }
            , Cmd.none
            )


        -- Starting player messages.
        SelectStartingPlayer ->
            let
                (toggleDrawerModel, toggleDrawerCmd) =
                    update (Layout.toggleDrawer Mdl) model
                randomNumCmd = Random.generate ShowStartingPlayer (Random.int 1 2)

            in
                (toggleDrawerModel, Cmd.batch [randomNumCmd, toggleDrawerCmd])


        ShowStartingPlayer player ->
            { model | startingPlayer = Just player } ! []

        HideStartingPlayerCard ->
            { model | startingPlayer = Nothing } ! []


        -- Elm MDL messages.
        SelectTab num ->
            { model | selectedTab = num } ! []

        Mdl msg' ->
            Material.update msg' model
