'use strict';

const http = require('http');

const [, , url] = process.argv;

if (!url) {
  console.error('Usage: node http-client.js <url>');
  process.exit(1);
}

http
  .get(url, (response) => {
    response.setEncoding('utf8');

    response.on('data', (chunk) => {
      console.log(chunk);
    });

    response.on('error', (error) => {
      console.error(error.message);
    });
  })
  .on('error', (error) => {
    console.error(error.message);
  });
