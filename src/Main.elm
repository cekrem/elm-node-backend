port module Main exposing (main)

import Api
import Json.Decode as Decode
import Json.Encode as Encode
import Platform
import Routes



-- PORTS


port request : (Decode.Value -> msg) -> Sub msg


port response : Encode.Value -> Cmd msg



-- MODEL


{-| Stateless worker - all request handling is synchronous
-}
type alias Model =
    ()


type Msg
    = GotRequest Decode.Value



-- PROGRAM


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( (), Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    request GotRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotRequest value ->
            let
                result =
                    Api.decodeRequest value
                        |> Result.map Routes.route
            in
            case result of
                Result.Ok res ->
                    ( model, response (Api.encodeResponse res) )

                Result.Err badRequestResponse ->
                    ( model, response (Api.encodeResponse badRequestResponse) )
