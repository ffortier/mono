// https://projecteuler.net/problem=1

// Multiples of 3 or 5

// If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9. The sum of these multiples is 23.
// Find the sum of all the multiples of 3 or 5 below 1000.

import { assertEquals } from "jsr:@std/assert";

const findSum = (n: number) => {
    let sum = 0;

    for (let i = 0; i < n; i += 3) sum += i % 5 == 0 ? 0 : i;
    for (let i = 0; i < n; i += 5) sum += i;

    return sum;
};

assertEquals(findSum(10), 23);

console.log(findSum(1000));
