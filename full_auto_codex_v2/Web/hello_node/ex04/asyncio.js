'use strict';

const fs = require('fs');

const [, , filePath] = process.argv;

if (!filePath) {
  console.error('Usage: node asyncio.js <file>');
  process.exit(1);
}

fs.readFile(filePath, 'utf8', (error, data) => {
  if (error) {
    console.error(error.message);
    return;
  }

  const newlineCount = data.split('\n').length - 1;
  console.log(newlineCount);
});
