'use strict';

const http = require('http');

const urls = process.argv.slice(2);

if (urls.length === 0) {
  console.error('Usage: node async-http-collect.js <url> <url> <url>');
  process.exit(1);
}

const results = new Array(urls.length);
let completed = 0;

const maybePrintResults = () => {
  if (completed === urls.length) {
    results.forEach((result) => {
      console.log(result);
    });
  }
};

urls.forEach((url, index) => {
  http
    .get(url, (response) => {
      response.setEncoding('utf8');
      let data = '';

      response.on('data', (chunk) => {
        data += chunk;
      });

      response.on('end', () => {
        results[index] = data;
        completed += 1;
        maybePrintResults();
      });

      response.on('error', (error) => {
        console.error(error.message);
      });
    })
    .on('error', (error) => {
      console.error(error.message);
    });
});
