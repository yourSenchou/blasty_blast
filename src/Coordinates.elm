module Coordinates exposing (convertTouchCoorToGameCoor, convertToGameUnits, gameSize)

import GameTypes exposing (Vector)
import Vector2 as V2 exposing (distance, normalize, setX, getX, getY)
import Game.TwoD.Camera as Camera exposing (Camera, getViewSize, getPosition)


gameSize : Vector
gameSize =
    ( 1280, 720 )


convertTouchCoorToGameCoor : Camera -> Vector -> Vector
convertTouchCoorToGameCoor camera touchLocation =
    touchLocation
        |> offSetOrigin
        |> offSetByCamera camera
        |> flipY


flipY : Vector -> Vector
flipY ( x, y ) =
    ( x, -y )


convertToGameUnits : Float -> Vector -> Vector
convertToGameUnits canvasWidth touchLocation =
    V2.scale (getX gameSize / canvasWidth) touchLocation


offSetOrigin : Vector -> Vector
offSetOrigin touchLocation =
    gameSize
        |> V2.scale 0.5
        |> V2.sub touchLocation


offSetByCamera : Camera -> Vector -> Vector
offSetByCamera camera touchLocation =
    camera
        |> getPosition
        |> flipY
        |> V2.add touchLocation
