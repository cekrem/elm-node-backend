module Routes exposing (route)

import Types exposing (Method(..), Request, Response, Status(..))



-- ROUTING


route : Request -> Response
route req =
    case ( req.method, req.path ) of
        ( Get, "/" ) ->
            homeHandler req

        ( Get, "/hello" ) ->
            helloHandler req

        ( Post, "/echo" ) ->
            echoHandler req

        _ ->
            notFoundHandler req



-- HANDLERS


homeHandler : Request -> Response
homeHandler =
    respond Success "Welcome to Elm Backend!"


helloHandler : Request -> Response
helloHandler =
    respond Success "Hello from Elm!"


echoHandler : Request -> Response
echoHandler req =
    respond Success req.body req


notFoundHandler : Request -> Response
notFoundHandler =
    respond NotFound "Not Found"



-- HELPERS


respond : Status -> String -> Request -> Response
respond status body req =
    { id = req.id
    , status = status
    , body = body
    }
