port module Main exposing (main)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Platform



-- PORTS (request in, response out via callback)


port request : (Decode.Value -> msg) -> Sub msg


port response : Encode.Value -> Cmd msg



-- TYPES


type alias Request =
    { id : String
    , method : String
    , path : String
    , body : String
    , headers : Dict String String
    }


type alias Response =
    { id : String
    , status : Int
    , body : String
    }


type alias Model =
    ()


type Msg
    = GotRequest Decode.Value



-- ROUTES


type alias Handler =
    Request -> Response


routes : Dict ( String, String ) Handler
routes =
    Dict.fromList
        [ ( ( "GET", "/" ), homeHandler )
        , ( ( "GET", "/hello" ), helloHandler )
        , ( ( "POST", "/echo" ), echoHandler )
        ]


homeHandler : Handler
homeHandler req =
    { id = req.id, status = 200, body = "Welcome to Elm Backend!" }


helloHandler : Handler
helloHandler req =
    { id = req.id, status = 200, body = "Hello from Elm!" }


echoHandler : Handler
echoHandler req =
    { id = req.id, status = 200, body = req.body }


notFound : Handler
notFound req =
    { id = req.id, status = 404, body = "Not Found" }



-- PROGRAM


main : Program () Model Msg
main =
    Platform.worker
        { init = \_ -> ( (), Cmd.none )
        , update = update
        , subscriptions = \_ -> request GotRequest
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotRequest value ->
            case Decode.decodeValue requestDecoder value of
                Ok req ->
                    let
                        handler =
                            Dict.get ( req.method, req.path ) routes
                                |> Maybe.withDefault notFound
                    in
                    ( model, response (encodeResponse (handler req)) )

                Err err ->
                    ( model
                    , response
                        (encodeResponse
                            { id = "error"
                            , status = 500
                            , body = Decode.errorToString err
                            }
                        )
                    )



-- JSON ENCODERS/DECODERS


requestDecoder : Decoder Request
requestDecoder =
    Decode.map5 Request
        (Decode.field "id" Decode.string)
        (Decode.field "method" Decode.string)
        (Decode.field "path" Decode.string)
        (Decode.field "body" Decode.string)
        (Decode.field "headers" (Decode.dict Decode.string))


encodeResponse : Response -> Encode.Value
encodeResponse resp =
    Encode.object
        [ ( "id", Encode.string resp.id )
        , ( "status", Encode.int resp.status )
        , ( "body", Encode.string resp.body )
        ]
