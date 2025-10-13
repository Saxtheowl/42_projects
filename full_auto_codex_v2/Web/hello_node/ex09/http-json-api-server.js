'use strict';

const http = require('http');

const port = Number(process.argv[2]);

if (!Number.isInteger(port)) {
  console.error('Usage: node http-json-api-server.js <port>');
  process.exit(1);
}

const buildParseTimePayload = (date) => ({
  hour: date.getHours(),
  minute: date.getMinutes(),
  second: date.getSeconds()
});

const buildUnixTimePayload = (date) => ({
  unixtime: date.getTime()
});

const server = http.createServer((request, response) => {
  if (request.method !== 'GET') {
    response.writeHead(405);
    response.end();
    return;
  }

  const url = new URL(request.url, 'http://localhost');
  const iso = url.searchParams.get('iso');

  if (!iso) {
    response.writeHead(400);
    response.end();
    return;
  }

  const date = new Date(iso);

  if (Number.isNaN(date.getTime())) {
    response.writeHead(400);
    response.end();
    return;
  }

  let payload;

  if (url.pathname === '/api/parsetime') {
    payload = buildParseTimePayload(date);
  } else if (url.pathname === '/api/unixtime') {
    payload = buildUnixTimePayload(date);
  } else {
    response.writeHead(404);
    response.end();
    return;
  }

  response.writeHead(200, { 'Content-Type': 'application/json' });
  response.end(JSON.stringify(payload));
});

server.on('error', (error) => {
  console.error(error.message);
});

server.listen(port);
