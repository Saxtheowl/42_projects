"use strict";

const http = require("http");
const { URL } = require("url");

const port = Number(process.argv[2]);

if (!port) {
  console.error("Usage: node http-json-api-server.js <port>");
  process.exit(1);
}

const server = http.createServer((req, res) => {
  if (!req.url) {
    res.writeHead(400);
    res.end();
    return;
  }

  let url;
  try {
    url = new URL(req.url, `http://localhost:${port}`);
  } catch (error) {
    res.writeHead(400, { "Content-Type": "text/plain" });
    res.end("Invalid URL");
    return;
  }

  const iso = url.searchParams.get("iso");

  if (!iso) {
    res.writeHead(400, { "Content-Type": "text/plain" });
    res.end("Missing iso parameter");
    return;
  }

  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) {
    res.writeHead(400, { "Content-Type": "text/plain" });
    res.end("Invalid iso parameter");
    return;
  }

  let body;
  if (url.pathname === "/api/parsetime") {
    body = {
      hour: date.getHours(),
      minute: date.getMinutes(),
      second: date.getSeconds(),
    };
  } else if (url.pathname === "/api/unixtime") {
    body = {
      unixtime: date.getTime(),
    };
  } else {
    res.writeHead(404, { "Content-Type": "text/plain" });
    res.end("Not found");
    return;
  }

  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify(body));
});

server.on("error", (error) => {
  console.error(`Server error: ${error.message}`);
  process.exit(1);
});

server.listen(port);
