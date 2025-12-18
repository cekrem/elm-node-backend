module Types exposing
    ( Method(..)
    , Request
    , Response
    , Status(..)
    , decodeRequest
    , encodeResponse
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode



-- TYPES


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
    = Success
    | BadRequest
    | NotFound
    | InternalError


type alias OpaqueResponse =
    Decode.Value


type alias Request =
    { res : OpaqueResponse
    , method : Method
    , path : String
    , body : String
    }


type alias Response =
    { res : OpaqueResponse
    , status : Status
    , body : String
    }



-- JSON DECODERS


decodeRequest : Decode.Value -> Result Decode.Error Request
decodeRequest =
    Decode.decodeValue requestDecoder


requestDecoder : Decoder Request
requestDecoder =
    Decode.map4 Request
        (Decode.field "res" Decode.value)
        (Decode.field "method" methodDecoder)
        (Decode.field "path" Decode.string)
        (Decode.field "body" Decode.string)


requestOpaqueResponseDecoder : Decoder Decode.Value
requestOpaqueResponseDecoder =
    Decode.field "res" Decode.value


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



-- JSON ENCODERS


encodeResponse : Response -> Encode.Value
encodeResponse resp =
    Encode.object
        [ ( "res", resp.res )
        , ( "status", encodeStatus resp.status )
        , ( "body", Encode.string resp.body )
        ]


encodeStatus : Status -> Encode.Value
encodeStatus status =
    Encode.int
        (case status of
            Success ->
                200

            BadRequest ->
                400

            NotFound ->
                404

            InternalError ->
                500
        )
