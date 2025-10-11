"use strict";

const http = require("http");
const https = require("https");

const url = process.argv[2];

if (!url) {
  console.error("Usage: node http-client.js <url>");
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

try {
  const client = getModule(url);
  client
    .get(url, (response) => {
      response.setEncoding("utf8");
      response.on("data", (chunk) => {
        console.log(chunk);
      });
      response.on("error", (err) => {
        console.error(`Response error: ${err.message}`);
      });
    })
    .on("error", (err) => {
      console.error(`Request error: ${err.message}`);
      process.exit(1);
    });
} catch (error) {
  console.error(error.message);
  process.exit(1);
}
