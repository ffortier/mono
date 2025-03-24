function isPrime(n: number): boolean {
    const max = Math.floor(Math.sqrt(n));

    for (let i = 2; i <= max; i++) {
        if (n % i == 0) return false;
    }

    return true;
}

function* primes() {
    let n = 1;

    for (;;) {
        while (!isPrime(++n));
        yield n;
    }
}

function test(i: number, knownPrimes: readonly number[]): boolean {
    for (const prime of knownPrimes.slice(1)) {
        const raw = Math.sqrt((i - prime) / 2);

        if (raw === Math.floor(raw)) {
            return true;
        }
    }

    return false;
}

const knownPrimes: number[] = [2];
const iterator = primes();

for (let i = 3;; i += 2) {
    while (knownPrimes[0] < i) {
        knownPrimes.unshift(iterator.next().value as number);
    }

    if (knownPrimes[0] != i && !test(i, knownPrimes)) {
        console.log(i);
        break;
    }
}
