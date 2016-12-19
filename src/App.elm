module App exposing (..)

import Html exposing (Html, div)
import Collage exposing (collage, groupTransform)
import Transform exposing (identity, rotation, translation)
import Element exposing (toHtml)
import Vector2 as V2 exposing (distance)
import AnimationFrame
import Window
import Task
import Draw exposing (sizeCanvas, canvasBackground, drawPlayer, drawBarrel)


type alias Vector =
    ( Float, Float )


type alias Player =
    { location : Vector
    , velocity : Vector
    , collisionRadius : Int
    }


type alias Barrel =
    { location : Vector
    , angle : Float
    , collisionRadius : Int
    }


type alias Model =
    { windowSize : Window.Size
    , player : Player
    , barrel : Barrel
    , controling : ActiveElement
    }


type ActiveElement
    = ThePlayer
    | ThisBarrel Barrel


type alias DeltaTime =
    Float


initialModel : Model
initialModel =
    { windowSize = { width = 0, height = 0 }
    , player = Player ( -100, 100 ) ( 0, 0 ) 35
    , barrel = Barrel ( -100, -100 ) (pi / 4) 35
    , controling = ThePlayer
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Task.perform (\size -> SetCanvasSize size) Window.size )


type Msg
    = NoOp
    | SetCanvasSize Window.Size
    | Tick DeltaTime


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetCanvasSize size ->
            ( { model
                | windowSize = size
              }
            , Cmd.none
            )

        Tick dt ->
            ( { model
                | player = updatePlayer dt model.controling model.player
                , controling = calculateActiveElement model.player model.barrel
              }
            , Cmd.none
            )


calculateActiveElement : Player -> Barrel -> ActiveElement
calculateActiveElement player barrel =
    if hasCollided player barrel then
        ThisBarrel barrel
    else
        ThePlayer


hasCollided : Player -> Barrel -> Bool
hasCollided player barrel =
    let
        distanceBetween =
            distance player.location barrel.location

        collectiveRadius =
            player.collisionRadius + barrel.collisionRadius
    in
        distanceBetween < toFloat collectiveRadius


updatePlayer : DeltaTime -> ActiveElement -> Player -> Player
updatePlayer dt activeElement player =
    let
        gravity =
            V2.scale dt ( 0, -0.001 )

        newVelocity =
            V2.add player.velocity gravity
    in
        case activeElement of
            ThePlayer ->
                { player
                    | location = V2.add player.location newVelocity
                    , velocity = newVelocity
                }

            ThisBarrel barrel ->
                { player
                    | location = barrel.location
                    , velocity = ( 0, 0 )
                }


view : Model -> Html Msg
view model =
    let
        ( canvasWidth, canvasHeight ) =
            sizeCanvas model.windowSize

        gameScale =
            toFloat canvasHeight / 720

        gameTransformation =
            Transform.scale gameScale
    in
        div []
            [ toHtml <|
                collage
                    canvasWidth
                    canvasHeight
                    [ groupTransform gameTransformation
                        [ canvasBackground
                        , drawPlayer model.player
                        , drawBarrel model.barrel
                        ]
                    ]
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs Tick
        , Window.resizes (\size -> SetCanvasSize size)
        ]
