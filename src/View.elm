module View exposing (view)

import Html exposing (Html, text)
import Html.App
import Html.Events
import Material
import Material.Button as Button
import Material.Card as Card
import Material.Color as Color
import Material.Elevation as Elevation
import Material.Grid as Grid
import Material.Icon as Icon
import Material.Layout as Layout
import Material.Options as Options exposing (Style, css)
import Material.Toggles as Toggles

import Types exposing (Model, Msg(..))

import Player

view : Model -> Html Msg
view model =
    Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
            ]
            { header = header model
            , drawer = drawer model.gameSettings.changeCardColors model.mdl
            , tabs = ([], [])
            , main =
                  [ Options.div
                        [ css "text-align" "center"
                        ]
                        [ startingPlayerCard model.startingPlayer
                        , if model.confirmResetGame then resetCard model.mdl else Options.div [] []
                        , viewBodyGrid model
                        ]
                  , resetButton model
                  ]
            }


header : Model -> List (Html Msg)
header model =
    [ Layout.row
          []
          [ Layout.title [] [ text "MTG Life Counter" ]
          , Layout.spacer
          , Layout.navigation [] []
          ]
    ]


drawer : Bool -> Material.Model -> List (Html Msg)
drawer changeCardColors mdlModel =
    [ Layout.title [] [ text "Actions" ]
    , Options.span [ Options.attribute <| Html.Events.onClick SelectStartingPlayerClick
                   , css "margin-left" "13px"
                   , css "font-size" "16px"
                   ]
          [ Icon.view "casino" [ Icon.size24, css "margin-right" "20px"
                               , css "position" "relative", css "top" "5px" ]
          , text "Pick starting player"
          ]
    , Layout.title [] [ text "Settings" ]
    , Toggles.switch Mdl [0] mdlModel
          [ Toggles.onClick ToggleChangeCardColorsSetting
          , Toggles.ripple
          , Toggles.value changeCardColors
          , css "margin-left" "5px"
          ]
          [ text "Color changing cards" ]
    ]


resetButton : Model -> Html Msg
resetButton model =
    Button.render Mdl [2] model.mdl
        [ Button.onClick Reset
        , Button.accent
        , css "width" "100%"
        , css "margin" "0 auto"
        , css "position" "fixed"
        , css "bottom" "5px"
        ]
    [ text "Reset"
    , Icon.view "replay" [ Icon.size24 ] ]



-- The style for a floating action card. The passed 'msg' is the Msg sent when
-- the card is clicked.
floatingCardStyle : Msg -> List (Style Msg)
floatingCardStyle msg =
    [ Color.background Color.white
    , Options.attribute <| Html.Events.onClick msg
    , Elevation.e8
    , css "width" "60%"
    , css "margin-left" "20%"
    , css "z-index" "2"
    , css "position" "absolute"
    , css "top" "25%"
    ]



floatingCardTitle : String -> Card.Block msg
floatingCardTitle titleText =
    Card.title [ css "display" "flex"
               , css "flex-direction" "row"
               , css "justify-content" "space-between"
               , Color.background Color.accent
               , Color.text Color.white
               ]
        [ text titleText
        , Icon.i "clear"
        ]


floatingCardActions : List (Html msg) -> Card.Block msg
floatingCardActions actions =
    Card.actions
        [ Options.center
        , Card.border
        ]
        actions

resetCard : Material.Model -> Html Msg
resetCard mdlModel =
    Card.view
        (floatingCardStyle CancelReset)
        [ floatingCardTitle "Reset game?"
        , floatingCardActions
              [ Button.render Mdl [0] mdlModel
                    [ Button.onClick CancelReset
                    , Button.raised
                    , css "padding" "0px"
                    , css "margin" "5% 5% 5% 5%"
                    ]
                    [ text "Cancel" ]
              , Button.render Mdl [1] mdlModel
                    [ Button.onClick ConfirmReset
                    , Button.raised
                    , Button.accent
                    , css "padding" "0px"
                    , css "margin" "5% 5% 5% 5%"
                    ]
                    [ text "Reset" ]
              ]
        ]



-- The card showing which player should go first.
startingPlayerCard : Maybe String -> Html Msg
startingPlayerCard maybeStartingPlayer =
    case maybeStartingPlayer of
        Just startingPlayer ->
            Card.view
                [ Color.background Color.white
                , Options.attribute <| Html.Events.onClick HideStartingPlayerCard
                , Elevation.e8
                , css "width" "60%"
                , css "margin-left" "20%"
                , css "z-index" "2"
                , css "position" "absolute"
                , css "top" "25%"
                ]
            [ Card.title [ css "display" "flex"
                         , css "flex-direction" "row"
                         , css "justify-content" "space-between"
                         ]
                  [ text "Starting player"
                  , Icon.i "clear"
                  ]
            , Card.text [] [ text startingPlayer ]
            ]

        Nothing ->
            Options.div [] []


cellStyle : List (Style a)
cellStyle =
    [ Grid.size Grid.Phone 4
    , Grid.size Grid.Desktop 6
    , css "height" "200px"
    , css "padding-left" "4px"
    , css "padding-right" "4px"
    , css "padding-top" "4px"
    ]


viewBodyGrid : Model -> Html Msg
viewBodyGrid model =
    let
        gridDivStyle =
            [ css "margin" "0 auto"
            , css "padding-top" "3%"
            , css "padding-left" "2%"
            , css "padding-right" "2%"
            ]

        cellStyle =
            [ Grid.size Grid.Phone 4
            , Grid.size Grid.Desktop 6
            , css "height" "200px"
            , css "padding-left" "4px"
            , css "padding-right" "4px"
            , css "padding-top" "4px"
            ]

        changeCardColors =
            model.gameSettings.changeCardColors

    in
        Options.div
            -- Styling
            gridDivStyle

            -- Content
            [ Grid.grid [ Grid.noSpacing ]
                  [ Grid.cell cellStyle
                        [ Player.view changeCardColors "1" model.player1
                              |> Html.App.map Player1Msg
                        ]
                  , Grid.cell cellStyle
                        [ Player.view changeCardColors "2" model.player2
                              |> Html.App.map Player2Msg
                        ]
                  ]
            ]
