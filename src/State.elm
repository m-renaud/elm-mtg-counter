module State exposing (init, update)

import Material
import Material.Layout as Layout
import Maybe
import Random
import Persist exposing (PersistentModel, fromPersistentModel)
import Types exposing (Model, Msg(..))
import Player


init : Maybe PersistentModel -> ( Model, Cmd Msg )
init maybePersistentModel =
    let
        initialStartingLife =
            20

        defaultModel =
            { player1 = Player.init "Player 1" initialStartingLife
            , player2 = Player.init "Player 2" initialStartingLife
            , startingPlayer = Nothing
            , confirmResetGame = False
            , gameSettings =
                { startingLife = initialStartingLife
                , changeCardColors = True
                }
            , mdl = Material.model
            }

        maybeModel =
            Maybe.map fromPersistentModel maybePersistentModel

        model =
            Maybe.withDefault defaultModel maybeModel
    in
        model ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Player subcomponent messages.
        Player1Msg playerMsg ->
            let
                ( player_, cmds ) =
                    Player.update playerMsg model.player1

                model_ =
                    { model | player1 = player_ }
            in
                ( model_, Cmd.map Player1Msg cmds )

        Player2Msg playerMsg ->
            let
                ( player_, cmds ) =
                    Player.update playerMsg model.player2

                model_ =
                    { model | player2 = player_ }
            in
                ( model_, Cmd.map Player2Msg cmds )

        -- Reset the game.
        Reset ->
            ( { model
                | confirmResetGame = True
              }
            , Cmd.none
            )

        CancelReset ->
            ( { model | confirmResetGame = False }
            , Cmd.none
            )

        ConfirmReset ->
            ( { model
                | player1 = Player.setLifeTotal model.gameSettings.startingLife model.player1
                , player2 = Player.setLifeTotal model.gameSettings.startingLife model.player2
                , confirmResetGame = False
              }
            , Cmd.none
            )

        -- Starting player messages.
        SelectStartingPlayerClick ->
            msgBatch
                -- The update function.
                update
                -- Messages to batch.
                [ Layout.toggleDrawer Mdl
                , SelectStartingPlayer
                ]
                -- Initial model.
                model

        SelectStartingPlayer ->
            ( model, Random.generate ShowStartingPlayer (Random.int 1 2) )

        ShowStartingPlayer player ->
            let
                startingPlayerName =
                    if player == 1 then
                        model.player1.name
                    else
                        model.player2.name
            in
                { model | startingPlayer = Just startingPlayerName } ! []

        HideStartingPlayerCard ->
            { model | startingPlayer = Nothing } ! []

        -- Game settings.
        ToggleChangeCardColorsSetting ->
            let
                oldGameSettings =
                    model.gameSettings

                newGameSettings =
                    { oldGameSettings
                        | changeCardColors =
                            not oldGameSettings.changeCardColors
                    }
            in
                { model | gameSettings = newGameSettings } ! []

        -- Elm MDL messages.
        Mdl msg_ ->
            Material.update msg_ model



-- Handle each of the passed 'msgs' from left to right.


msgBatch : (Msg -> Model -> ( Model, Cmd Msg )) -> List Msg -> Model -> ( Model, Cmd Msg )
msgBatch updateFunc msgs model =
    let
        updateModelAndCmds : Msg -> ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
        updateModelAndCmds msg ( model, cmds ) =
            let
                ( updatedModel, newCmd ) =
                    updateFunc msg model
            in
                ( updatedModel, newCmd :: cmds )

        ( updatedModel, cmdList ) =
            List.foldl updateModelAndCmds ( model, [] ) msgs
    in
        ( updatedModel, Cmd.batch cmdList )
