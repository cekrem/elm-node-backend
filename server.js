const http = require("http");
const { Elm } = require("./elm.js");

const app = Elm.Main.init();

app.ports.response.subscribe(({ responseHandler, ...payload }) => {
  responseHandler.writeHead(payload.status);
  responseHandler.end(payload.body);
});

const serverPort = process.env.PORT || 8080;

http
  .createServer((request, responseHandler) => {
    let body = "";
    request.on("data", (chunk) => (body += chunk));
    request.on("end", () => {
      app.ports.request.send({
        method: request.method,
        path: request.url,
        body,
        responseHandler,
        headers: Object.fromEntries(
          Object.entries(request.headers).map(([k, v]) => [k, String(v)]),
        ),
      });
    });
  })
  .listen(serverPort, () =>
    console.log(`Server running on http://localhost:${serverPort}`),
  );
