module Types exposing
    ( Method(..)
    , Request
    , RequestId
    , Response
    , Status(..)
    , decodeRequest
    , encodeResponse
    , errorResponse
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode



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
    = Success
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



-- JSON DECODERS


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



-- JSON ENCODERS


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
            Success ->
                200

            BadRequest ->
                400

            NotFound ->
                404

            InternalError ->
                500
        )



-- ERROR HANDLING


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
