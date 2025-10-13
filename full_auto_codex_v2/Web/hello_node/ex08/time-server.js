'use strict';

const net = require('net');

const port = Number(process.argv[2]);

if (!Number.isInteger(port)) {
  console.error('Usage: node time-server.js <port>');
  process.exit(1);
}

const pad = (value) => String(value).padStart(2, '0');

const formatDate = (date) => {
  const year = date.getFullYear();
  const month = pad(date.getMonth() + 1);
  const day = pad(date.getDate());
  const hours = pad(date.getHours());
  const minutes = pad(date.getMinutes());

  return `${year}-${month}-${day} ${hours}:${minutes}`;
};

const server = net.createServer((socket) => {
  socket.end(`${formatDate(new Date())}\n`);
});

server.on('error', (error) => {
  console.error(error.message);
});

server.listen(port);
