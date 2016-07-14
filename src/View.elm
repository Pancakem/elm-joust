module View exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Svg exposing (Svg,Attribute)
import Svg.Attributes as Attributes exposing (x,y,width,height,fill,fontSize,fontFamily,textAnchor)
import Svg.Events exposing (onClick)
import Time exposing (Time)
import String

import Model exposing (..)
import Model.Ui exposing (..)
import Model.Scene exposing (..)
import Subscription exposing (..)

import VirtualDom
import Json.Encode as Json


view : Model -> Html Msg
view {ui,scene} =
  case ui.screen of
    StartScreen ->
      renderStartScreen ui.windowSize

    PlayScreen ->
      renderPlayScreen ui.windowSize scene

    GameoverScreen ->
      renderGameoverScreen ui.windowSize


renderStartScreen : (Int,Int) -> Html.Html Msg
renderStartScreen (w,h)  =
  let
      clickHandler = onClick StartGame
      screenAttrs = [ clickHandler ] ++ (svgAttributes (w,h))
      messageAttrs = [ x <| toString (w//2)
                     , y <| toString (h//2)
                     , fontSize <| toString ((normalFontSize w) * 2)
                     , textAnchor "middle"
                     , fontFamily "Verdana,Helvetica,sans"
                     , fill "rgba(255,255,255,.8)"
                     ]
      message = Svg.text' messageAttrs [ Svg.text "Click to start" ]
  in
      Svg.svg
        screenAttrs
        [ message ]


renderPlayScreen : (Int,Int) -> Scene -> Html.Html Msg
renderPlayScreen (w,h) ({t,player1,player2} as scene) =
  let
      windowSize = (w,h)
  in
     Svg.svg (svgAttributes windowSize)
     [ renderIce windowSize
     , renderPlayer windowSize player1
     , renderPlayer windowSize player2
     ]


renderGameoverScreen : (Int,Int) -> Html.Html Msg
renderGameoverScreen (w,h)  =
  let
      screenAttrs = svgAttributes (w,h)
      messageAttrs = [ x <| toString (w//2)
                     , y <| toString (h//2)
                     , fontSize <| toString ((normalFontSize w) * 2)
                     , textAnchor "middle"
                     , fontFamily "Verdana,Helvetica,sans"
                     , fill "rgba(255,255,255,.8)"
                     ]
      submessageAttrs = [ x <| toString (w//2)
                        , y <| toString (h//2 + (normalFontSize w) * 2)
                        , fontSize <| toString (normalFontSize w)
                        , textAnchor "middle"
                        , fontFamily "Verdana,Helvetica,sans"
                        , fill "rgba(255,255,255,.8)"
                        ]
      message = Svg.text' messageAttrs [ Svg.text "Game over" ]
      submessage = Svg.text' submessageAttrs [ Svg.text "Press SPACE to restart" ]
  in
      Svg.svg
        screenAttrs
        [ message, submessage ]


svgAttributes : (Int, Int) -> List (Attribute Msg)
svgAttributes (w, h) =
  [ width (toString w)
  , height (toString h)
  , Attributes.viewBox <| "0 0 " ++ (toString w) ++ " " ++ (toString h)
  , VirtualDom.property "xmlns:xlink" (Json.string "http://www.w3.org/1999/xlink")
  , Attributes.version "1.1"
  , Attributes.style "position: fixed;"
  ]


renderIce : (Int,Int) -> Svg Msg
renderIce (w,h) =
  let
      xString = (toFloat w) * icePosX |> toString
      yString = (toFloat (h-w)) + (toFloat w) * icePosY |> toString
      widthString = (toFloat w) * iceWidth |> toString
      heightString = (toFloat w) * (1-icePosY) |> toString
  in
      Svg.rect
        [ x xString
        , y yString
        , width widthString
        , height heightString
        , fill softWhite
        ]
        []


renderPlayer : (Int,Int) -> Player -> Svg Msg
renderPlayer (w,h) {position} =
  let
      x = (toFloat w) * position.x |> toString
      y = (toFloat (h-w)) + (toFloat w) * (position.y-playerRadius) |> toString
      radius = (toFloat w) * playerRadius |> toString
  in
      Svg.circle
        [ Attributes.cx x
        , Attributes.cy y
        , Attributes.r radius
        , fill softWhite
        ]
        []


softWhite : String
softWhite = "rgba(255,255,255,.2)"


normalFontSize : Int -> Int
normalFontSize w =
  w // 20 |> min 24
