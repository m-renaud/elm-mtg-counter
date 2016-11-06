module Player exposing (Model, Msg(..), init, update, view, setLifeTotal,
                        PersistentModel, fromPersistentModel, toPersistentModel)


import Dom
import Json.Decode as Json
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events
import Task

import Material
import Material.Button as Button
import Material.Card as Card
import Material.Color as Color
import Material.Elevation as Elevation
import Material.Options as Options exposing (Style, css)
import Material.Textfield as Textfield
import Material.Typography as Typography


-- MODEL


type alias PlayerName = String


type alias Model =
    { name : PlayerName
    , lifeTotal : Int
    , editingName : Bool
    , mdl : Material.Model
    }


init : PlayerName -> Int -> Model
init playerName initialLife =
    { name = playerName
    , lifeTotal = initialLife
    , editingName = False
    , mdl = Material.model
    }


setLifeTotal : Int -> Model -> Model
setLifeTotal life model =
    { model | lifeTotal = life }


-- PERSISTENT MODEL


type alias PersistentModel =
    { name : PlayerName
    , lifeTotal : Int
    }


fromPersistentModel : PersistentModel -> Model
fromPersistentModel persistentModel =
    init persistentModel.name persistentModel.lifeTotal


toPersistentModel : Model -> PersistentModel
toPersistentModel model =
    { name = model.name
    , lifeTotal = model.lifeTotal
    }



-- UPDATE


type alias DomIdPiece = String



type Msg
    = NoOp
    | IncreaseLife
    | DecreaseLife
    | EditingName DomIdPiece Bool
    | UpdateName PlayerName
    | Mdl (Material.Msg Msg)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp ->
            model ! []

        IncreaseLife ->
            { model | lifeTotal = model.lifeTotal + 1 } ! []

        DecreaseLife ->
            { model | lifeTotal = model.lifeTotal - 1 } ! []

        EditingName domIdSuffix isEditingName ->
            let
                focus =
                    if
                        isEditingName
                    then
                        Dom.focus ("player-name-" ++ domIdSuffix)
                    else
                        Dom.blur ("player-name-" ++ domIdSuffix)

            in
                { model | editingName = isEditingName }
                    ! [ Task.perform (\_ -> NoOp) (\_ -> NoOp) focus ]

        UpdateName newName ->
            { model | name = newName } ! []

        Mdl mdlMsg ->
            Material.update mdlMsg model


-- VIEW


-- Background color goes from green->orange->red->black as life decreases.
-- Stays green if changeCardColor is False.
backgroundColorFromLifeTotal : Bool -> Int -> Color.Color
backgroundColorFromLifeTotal changeCardColor lifeTotal =
    if (not changeCardColor) || lifeTotal >= 15 then
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
textColorFromLifeTotal : Bool -> Int -> Color.Color
textColorFromLifeTotal changeCardColor lifeTotal =
    if (not changeCardColor) || lifeTotal > 0 then
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


cardTitle : PlayerName -> DomIdPiece -> Material.Model -> Card.Block Msg
cardTitle playerName domIdSuffix mdlModel =
    Card.title
        [ Color.text Color.white
        , css "font-size" "24px"
        , css "margin-top" "0"
        , css "margin-bottom" "0"
        , css "padding-top" "0"
        , css "padding-bottom" "0"
        ]

        [ Textfield.render Mdl [3] mdlModel
              [ Textfield.label "PlayerName"
              , Textfield.value playerName
              , Textfield.style [ css "font-size" "24px"
                                , css "border-bottom" "0px"
                                , Options.attribute <| Attributes.id ("player-name-" ++ domIdSuffix)
                                ]
              , Textfield.onInput UpdateName
              , Textfield.onBlur <| EditingName domIdSuffix False
              , onEnter <| EditingName domIdSuffix False
              ]
        ]


cardText : Bool -> Int -> Card.Block msg
cardText changeCardColor lifeTotal =
    Card.text
        [ Typography.center
        , css "font-size" "60px"
        , Color.text <| textColorFromLifeTotal changeCardColor lifeTotal
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


view : Bool -> DomIdPiece -> Model -> Html Msg
view changeCardColor domIdSuffix model =
    Card.view
        (cardStyle <| backgroundColorFromLifeTotal changeCardColor model.lifeTotal)
        [ cardTitle model.name domIdSuffix model.mdl
        , cardText changeCardColor model.lifeTotal
        , cardActions model.mdl
        ]



-- Utilities




onEnter : Msg -> Textfield.Property Msg
onEnter msg =
    Textfield.on "keydown" (Json.map (always msg) (Json.customDecoder Events.keyCode is13))


is13 : Int -> Result String ()
is13 code =
    if code == 13 then
        Ok ()

    else
        Err "not the right key code"
