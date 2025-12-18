const http = require("http");

const { Elm } = require("./elm.js");

const app = Elm.Main.init();
const pending = new Map();
let requestId = 0;

app.ports.response.subscribe((data) => {
  const resolve = pending.get(data.id);
  if (resolve) {
    pending.delete(data.id);
    resolve(data);
  }
});

http
  .createServer((req, res) => {
    let body = "";
    req.on("data", (chunk) => (body += chunk));
    req.on("end", () => {
      const id = `req-${++requestId}`;

      pending.set(
        id,
        (data) => {
          res.writeHead(data.status);
          res.end(data.body);
        }
      );

      app.ports.request.send({
        id,
        method: req.method,
        path: req.url,
        body,
        headers: Object.fromEntries(
          Object.entries(req.headers).map(([k, v]) => [k, String(v)])
        ),
      });
    });
  })
  .listen(8080, () => console.log("Server running on http://localhost:8080"));
