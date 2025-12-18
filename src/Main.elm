port module Main exposing (main)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Platform



-- PORTS


port request : (Decode.Value -> msg) -> Sub msg


port response : Encode.Value -> Cmd msg



-- TYPES


type RequestId
    = RequestId String


type Method
    = Get
    | Head
    | Post
    | Put
    | Delete
    | Connect
    | Options
    | Trace
    | Patch


type Status
    = Ok
    | BadRequest
    | NotFound
    | InternalError


type alias Request =
    { id : RequestId
    , method : Method
    , path : String
    , body : String
    }


type alias Response =
    { id : RequestId
    , status : Status
    , body : String
    }


{-| Stateless worker - all request handling is synchronous
-}
type alias Model =
    ()


type Msg
    = GotRequest Decode.Value



-- ROUTING


route : Request -> Response
route req =
    case ( req.method, req.path ) of
        ( Get, "/" ) ->
            respond Ok "Welcome to Elm Backend!" req

        ( Get, "/hello" ) ->
            respond Ok "Hello from Elm!" req

        ( Post, "/echo" ) ->
            respond Ok req.body req

        _ ->
            respond NotFound "Not Found" req


respond : Status -> String -> Request -> Response
respond status body req =
    { id = req.id
    , status = status
    , body = body
    }



-- PROGRAM


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
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
                    decodeRequest value
                        |> Result.map route
                        |> Result.mapError (errorResponse value)
            in
            case result of
                Result.Ok res ->
                    ( model, response (encodeResponse res) )

                Result.Err res ->
                    ( model, response (encodeResponse res) )


{-| Extracts request ID from raw JSON for error correlation
-}
errorResponse : Decode.Value -> Decode.Error -> Response
errorResponse value err =
    let
        maybeId =
            Decode.decodeValue (Decode.field "id" Decode.string) value
                |> Result.toMaybe
                |> Maybe.map RequestId
                |> Maybe.withDefault (RequestId "unknown")
    in
    { id = maybeId
    , status = BadRequest
    , body = Decode.errorToString err
    }



-- JSON ENCODERS/DECODERS


decodeRequest : Decode.Value -> Result Decode.Error Request
decodeRequest =
    Decode.decodeValue requestDecoder


requestDecoder : Decoder Request
requestDecoder =
    Decode.map4 Request
        (Decode.field "id" requestIdDecoder)
        (Decode.field "method" methodDecoder)
        (Decode.field "path" Decode.string)
        (Decode.field "body" Decode.string)


requestIdDecoder : Decoder RequestId
requestIdDecoder =
    Decode.map RequestId Decode.string


methodDecoder : Decoder Method
methodDecoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "GET" ->
                        Decode.succeed Get

                    "HEAD" ->
                        Decode.succeed Head

                    "POST" ->
                        Decode.succeed Post

                    "PUT" ->
                        Decode.succeed Put

                    "DELETE" ->
                        Decode.succeed Delete

                    "CONNECT" ->
                        Decode.succeed Connect

                    "OPTIONS" ->
                        Decode.succeed Options

                    "TRACE" ->
                        Decode.succeed Trace

                    "PATCH" ->
                        Decode.succeed Patch

                    _ ->
                        Decode.fail ("Unknown method: " ++ str)
            )


encodeResponse : Response -> Encode.Value
encodeResponse resp =
    Encode.object
        [ ( "id", encodeRequestId resp.id )
        , ( "status", encodeStatus resp.status )
        , ( "body", Encode.string resp.body )
        ]


encodeRequestId : RequestId -> Encode.Value
encodeRequestId (RequestId id) =
    Encode.string id


encodeStatus : Status -> Encode.Value
encodeStatus status =
    Encode.int
        (case status of
            Ok ->
                200

            BadRequest ->
                400

            NotFound ->
                404

            InternalError ->
                500
        )
