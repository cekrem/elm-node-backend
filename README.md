# elm-node-backend

Minimal Elm backend on Node.js. Elm handles routing via ports; Node handles HTTP.

## Run

```bash
npm ci
npm start
```

## How it works

```
HTTP Request → Node → port request → Elm → port response → Node → HTTP Response
```

The Node.js response object is passed through Elm as an opaque `Decode.Value`, eliminating the need for request tracking or ID correlation. When Elm processes a request, it returns the same opaque response object, allowing Node to write directly to the correct HTTP response.

## Project structure

```
src/
├── Main.elm    -- Program wiring (ports, subscriptions) - don't touch
├── Api.elm     -- Stable types and JSON encoding - don't touch
└── Routes.elm  -- Your routes and handlers - edit this!
```

**Only `Routes.elm` needs editing.** Add routes by extending the `case` expression and writing handlers:

```elm
route : Request -> Response
route req =
    case ( req.method, req.path ) of
        ( Get, "/" ) ->
            homeHandler req

        ( Get, "/hello" ) ->
            helloHandler req

        ( Post, "/echo" ) ->
            echoHandler req

        -- Add new routes here

        _ ->
            notFoundHandler req
```
