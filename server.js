const http = require("http");
const { Elm } = require("./elm.js");

const app = Elm.Main.init();

app.ports.response.subscribe(({ res, ...payload }) => {
  res.writeHead(payload.status);
  res.end(payload.body);
});

const serverPort = process.env.PORT || 8080;

http
  .createServer((req, res) => {
    let body = "";
    req.on("data", (chunk) => (body += chunk));
    req.on("end", () => {
      app.ports.request.send({
        method: req.method,
        path: req.url,
        body,
        res,
        headers: Object.fromEntries(
          Object.entries(req.headers).map(([k, v]) => [k, String(v)]),
        ),
      });
    });
  })
  .listen(serverPort, () =>
    console.log(`Server running on http://localhost:${serverPort}`),
  );
