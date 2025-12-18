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
