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

The `id` field correlates responses back to the correct pending HTTP request.

## Project structure

```
src/
├── Main.elm    -- Program wiring (ports, subscriptions) - don't touch
├── Types.elm   -- Stable types and JSON encoding - don't touch
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
