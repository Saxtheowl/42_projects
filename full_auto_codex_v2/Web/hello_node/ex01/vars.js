'use strict';

const entries = [
  '42',
  42,
  new Number(42),
  {},
  true,
  undefined
];

const articleFor = (typeName) => {
  return /^[aeiou]/i.test(typeName) ? 'an' : 'a';
};

entries.forEach((value) => {
  const typeName = typeof value;
  const article = articleFor(typeName);
  // Align output with the expected subject formatting.
  console.log(`${String(value)} is ${article} ${typeName}.`);
});
