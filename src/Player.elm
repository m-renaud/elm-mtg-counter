module Player exposing (Model, Msg(..), init, update, view, setLifeTotal)


import Html exposing (..)

import Material
import Material.Button as Button
import Material.Card as Card
import Material.Color as Color
import Material.Elevation as Elevation
import Material.Options as Options exposing (css)
import Material.Typography as Typography


-- MODEL


type alias Model =
    { name : String
    , lifeTotal : Int
    , mdl : Material.Model
    }


init : String -> Int -> Model
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


type alias Mdl =
    Material.Model


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


textColorFromLifeTotal : Int -> Color.Color
textColorFromLifeTotal lifeTotal =
    if lifeTotal > 0 then
        Color.white
    else
        Color.color Color.Red Color.S600


view : Model -> Html Msg
view model =
    Card.view
        [ Color.background <| backgroundColorFromLifeTotal model.lifeTotal
        , Elevation.e2
        , css "width" "100%"
        , css "height" "100%"
        ]
        [ Card.title [ Color.text Color.white
                     , css "font-size" "24px"
                     ]
              [ text model.name ]
        , Card.text
              [ Typography.center
              , css "font-size" "60px"
              , Color.text <| textColorFromLifeTotal model.lifeTotal
              ]
              [ text (toString model.lifeTotal) ]
        , Card.actions
              [ Options.center
              , css "padding-left" "8px"
              , css "padding-top" "4px"
              ]
              [ Button.render Mdl [1] model.mdl
                    [ Button.onClick DecreaseLife
                    , Button.fab
                    ]
                    [ text "-" ]
              , Button.render Mdl [0] model.mdl
                    [ Button.onClick IncreaseLife
                    , Button.fab
                    ]
                    [ text "+" ]
              ]
        ]
