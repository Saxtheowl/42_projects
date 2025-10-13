'use strict';

const values = process.argv.slice(2).map(Number);
const sum = values.reduce((accumulator, value) => accumulator + (Number.isNaN(value) ? 0 : value), 0);

console.log(sum);
