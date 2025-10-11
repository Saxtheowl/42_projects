"use strict";

const fs = require("fs");

const filePath = process.argv[2];

if (!filePath) {
  console.error("Usage: node io.js <file>");
  process.exit(1);
}

try {
  const content = fs.readFileSync(filePath, "utf8");
  const newlineCount = content.split("\n").length - 1;
  console.log(newlineCount);
} catch (error) {
  console.error(`Cannot read file: ${error.message}`);
  process.exit(1);
}
