"use strict";

const samples = [
  "42",
  42,
  new Number(42),
  {},
  true,
  undefined,
];

const articleFor = (type) => {
  return /^[aeiou]/.test(type) ? "an" : "a";
};

for (const sample of samples) {
  const type = typeof sample;
  const article = articleFor(type);
  console.log(`${String(sample)} is ${article} ${type}.`);
}
