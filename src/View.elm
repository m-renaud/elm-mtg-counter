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

import Types exposing (Model, Msg(..))

import Player

view : Model -> Html Msg
view model =
    Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
            , Layout.selectedTab model.selectedTab
            , Layout.onSelectTab SelectTab
            ]
            { header = header model
            , drawer = drawer
            , tabs = ([], [])
            , main =
                  [ Options.div
                        [ css "text-align" "center"
                        ]
                        [ startingPlayerCard model.startingPlayer
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


drawer : List (Html Msg)
drawer =
    [ Layout.title [] [ text "Game Options" ]
    , Layout.navigation
        []
        [ Layout.link
              [ Layout.href "#"
              , Layout.onClick <| SelectStartingPlayerClick
              ]
              [ text "Pick starting player" ]
        ]
    ]


resetButton : Model -> Html Msg
resetButton model =
    Button.render Mdl [2] model.mdl
        [ Button.onClick Reset
        , Button.colored
        , css "width" "100%"
        , css "margin" "0 auto"
        , css "position" "fixed"
        , css "bottom" "5px"
        ]
    [ text "Reset"
    , Icon.view "replay" [ Icon.size24 ] ]


-- The card showing which player should go first.
startingPlayerCard : Maybe Int -> Html Msg
startingPlayerCard startingPlayer =
    case startingPlayer of
        Just player ->
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
            , Card.text [] [ text <| if player == 1 then "Player 1" else "Player 2" ]
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

    in
        Options.div
            -- Styling
            gridDivStyle

            -- Content
            [ Grid.grid [ Grid.noSpacing ]
                  [ Grid.cell cellStyle
                        [ Player.view model.player1 |> Html.App.map Player1Msg
                        ]
                  , Grid.cell cellStyle
                        [ Player.view model.player2 |> Html.App.map Player2Msg
                        ]
                  ]
            ]
