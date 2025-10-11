"use strict";

const http = require("http");
const https = require("https");

const urls = process.argv.slice(2, 5);

if (urls.length < 3) {
  console.error("Usage: node async-http-collect.js <url1> <url2> <url3>");
  process.exit(1);
}

const getModule = (targetUrl) => {
  if (targetUrl.startsWith("https://")) {
    return https;
  }
  if (targetUrl.startsWith("http://")) {
    return http;
  }
  throw new Error("Unsupported protocol. Use http:// or https://");
};

const fetch = (targetUrl) =>
  new Promise((resolve, reject) => {
    let data = "";
    try {
      const client = getModule(targetUrl);
      client
        .get(targetUrl, (response) => {
          response.setEncoding("utf8");
          response.on("data", (chunk) => {
            data += chunk;
          });
          response.on("end", () => resolve(data));
          response.on("error", reject);
        })
        .on("error", reject);
    } catch (error) {
      reject(error);
    }
  });

Promise.all(urls.map(fetch))
  .then((results) => {
    results.forEach((content) => console.log(content));
  })
  .catch((error) => {
    console.error(`Request error: ${error.message}`);
    process.exit(1);
  });
