'use strict';

const fs = require('fs');

const [, , filePath] = process.argv;

if (!filePath) {
  console.error('Usage: node io.js <file>');
  process.exit(1);
}

const content = fs.readFileSync(filePath, 'utf8');
const newlineCount = content.split('\n').length - 1;

console.log(newlineCount);
