function latticePath_(
    x: number,
    y: number,
    memo: Record<string, number>,
): number {
    if (x == 0 && y == 0) {
        return 1;
    }

    const key = `${x}-${y}`;

    if (key in memo) return memo[key];

    let sum = 0;

    if (x > 0) {
        sum += latticePath_(x - 1, y, memo);
    }

    if (y > 0) {
        sum += latticePath_(x, y - 1, memo);
    }

    return memo[key] = sum;
}

function latticePath(n: number) {
    const memo: Record<string, number> = {};

    for (let x = 0; x <= n; x++) {
        for (let y = 0; y <= n; y++) {
            latticePath_(x, y, memo);
        }
    }

    return memo[`${n}-${n}`];
}

console.log(latticePath(20));
