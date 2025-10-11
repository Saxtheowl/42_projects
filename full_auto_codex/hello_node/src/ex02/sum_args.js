"use strict";

const args = process.argv.slice(2);

let total = 0;
for (const current of args) {
  const value = Number(current);
  if (Number.isNaN(value)) {
    console.error(`Invalid number: ${current}`);
    process.exitCode = 1;
    process.exit(1);
  }
  total += value;
}

console.log(total);
