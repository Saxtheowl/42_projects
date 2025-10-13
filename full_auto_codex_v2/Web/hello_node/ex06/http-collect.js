'use strict';

const http = require('http');

const [, , url] = process.argv;

if (!url) {
  console.error('Usage: node http-collect.js <url>');
  process.exit(1);
}

http
  .get(url, (response) => {
    response.setEncoding('utf8');
    let data = '';

    response.on('data', (chunk) => {
      data += chunk;
    });

    response.on('end', () => {
      console.log(data.length);
      console.log(data);
    });

    response.on('error', (error) => {
      console.error(error.message);
    });
  })
  .on('error', (error) => {
    console.error(error.message);
  });
