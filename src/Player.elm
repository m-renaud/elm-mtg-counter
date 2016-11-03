module Player exposing (Model, Msg(..), init, update, view, setLifeTotal)


import Html exposing (..)

import Material
import Material.Button as Button
import Material.Card as Card
import Material.Color as Color
import Material.Elevation as Elevation
import Material.Options as Options exposing (Style, css)
import Material.Typography as Typography


-- MODEL


type alias PlayerName = String


type alias Model =
    { name : PlayerName
    , lifeTotal : Int
    , mdl : Material.Model
    }


init : PlayerName -> Int -> Model
init playerName initialLife =
    { name = playerName
    , lifeTotal = initialLife
    , mdl = Material.model
    }


setLifeTotal : Int -> Model -> Model
setLifeTotal life model =
    { model | lifeTotal = life }


-- UPDATE


type Msg
    = IncreaseLife
    | DecreaseLife
    | Mdl (Material.Msg Msg)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        IncreaseLife ->
            { model | lifeTotal = model.lifeTotal + 1 } ! []

        DecreaseLife ->
            { model | lifeTotal = model.lifeTotal - 1 } ! []

        Mdl mdlMsg ->
            Material.update mdlMsg model


-- VIEW


-- Background color goes from green->orange->red->black as life decreases.
backgroundColorFromLifeTotal : Int -> Color.Color
backgroundColorFromLifeTotal lifeTotal =
    if lifeTotal >= 15 then
        Color.color Color.Green Color.S600
    else if lifeTotal >= 10 then
        Color.color Color.Yellow Color.S800
    else if lifeTotal >= 5 then
        Color.color Color.Orange Color.S800
    else if lifeTotal >= 3 then
        Color.color Color.Red Color.S600
    else if lifeTotal > 0 then
        Color.color Color.Red Color.S900
    else
        Color.black


-- Text color is white when life > 0, and red when <= 0.
textColorFromLifeTotal : Int -> Color.Color
textColorFromLifeTotal lifeTotal =
    if lifeTotal > 0 then
        Color.white
    else
        Color.color Color.Red Color.S600


-- The style for a player card.
cardStyle : Color.Color -> List (Style Msg)
cardStyle backgroundColor =
    [ Color.background backgroundColor
    , Elevation.e2
    , css "width" "100%"
    , css "height" "100%"
    ]


cardTitle : PlayerName -> Card.Block msg
cardTitle playerName =
    Card.title
        [ Color.text Color.white
        , css "font-size" "24px"
        ]

        [ text playerName ]


cardText : Int -> Card.Block msg
cardText lifeTotal =
    Card.text
        [ Typography.center
        , css "font-size" "60px"
        , Color.text <| textColorFromLifeTotal lifeTotal
        ]

        [ text <| toString lifeTotal ]


cardActions : Material.Model -> Card.Block Msg
cardActions mdlModel =
    Card.actions
        [ Options.center
        , css "padding-left" "8px"
        , css "padding-top" "4px"
        ]

        [ Button.render Mdl [1] mdlModel
              [ Button.onClick DecreaseLife
              , Button.fab
              ]
              [ text "-" ]
        , Button.render Mdl [0] mdlModel
              [ Button.onClick IncreaseLife
              , Button.fab
              ]
              [ text "+" ]
        ]


view : Model -> Html Msg
view model =
    Card.view
        (cardStyle <| backgroundColorFromLifeTotal model.lifeTotal)
        [ cardTitle model.name
        , cardText model.lifeTotal
        , cardActions model.mdl
        ]
