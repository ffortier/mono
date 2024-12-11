type Num = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9';
type Digit = CharToNum<Num>;
type CharToNum<I extends Num> = { '0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9 }[I];
type Successor<I extends Digit> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0][I];
type Predecessor<I extends Digit> = [9, 0, 1, 2, 3, 4, 5, 6, 7, 8][I];

type Numeric<P extends Num, R extends string> = `${P}${R}`;

type AddDigit_<A extends Digit, B extends Digit, Carry extends 0 | 1 = 0>
    = B extends 0 ? [A, Carry]
    : A extends 9 ? AddDigit_<Successor<A>, Predecessor<B>, 1>
    : AddDigit_<Successor<A>, Predecessor<B>, Carry>;

type Reverse_<P extends string, N extends string>
    = N extends '' ? P
    : N extends Numeric<infer U, infer N1> ? Reverse_<`${U}${P}`, N1>
    : never;

type Reverse<N extends string> = Reverse_<'', N>;

type LargestFirst<A extends string, B extends string>
    = B extends '' ? true
    : A extends '' ? false
    : A extends Numeric<infer Pa, infer Ra> ? B extends Numeric<infer Pb, infer Rb> ? LargestFirst<Ra, Rb> : never : never;

type Bool<V> = V extends 0 | 1 ? V : never;
type NumVal<V> = V extends Digit ? V : never;

type Add_<A extends string, B extends string, Carry extends 0 | 1, Sum extends string>
    = B extends ''
    /**/ ? A extends ''
    /****/ ? Carry extends 1 ? `1${Sum}` : Sum
    /**/ : Carry extends 0 ? `${A}${Sum}`
    /****/ : Add_<A, '1', 0, Sum>
    : A extends Numeric<infer Pa, infer Ra>
    /**/ ? B extends Numeric<infer Pb, infer Rb>
    /****/ ? AddDigit_<CharToNum<Pa>, CharToNum<Pb>> extends [infer S, infer C1] ? Add_<Ra, Rb, Bool<C1>, `${NumVal<S>}${Sum}`> : never
    /**/ : never
    : never;

type Add<A extends string, B extends string>
    = LargestFirst<A, B> extends true ? Add_<Reverse<A>, Reverse<B>, 0, ''>
    : Add_<Reverse<B>, Reverse<A>, 0, ''>;

// tests
function assert<T extends never>() { }

type TypeEqual<A, B> = Exclude<A, B> | Exclude<B, A>;

assert<TypeEqual<Successor<0>, 1>>();
assert<TypeEqual<Successor<9>, 0>>();
assert<TypeEqual<Predecessor<0>, 9>>();
assert<TypeEqual<Predecessor<9>, 8>>();

assert<TypeEqual<AddDigit_<0, 0>, [0, 0]>>();
assert<TypeEqual<AddDigit_<0, 3>, [3, 0]>>();
assert<TypeEqual<AddDigit_<9, 3>, [2, 1]>>();

assert<TypeEqual<CharToNum<'0'>, 0>>();
assert<TypeEqual<CharToNum<'9'>, 9>>();

assert<TypeEqual<Reverse<'123'>, '321'>>();

assert<TypeEqual<Numeric<'6', '789'>, '6789'>>();
assert<TypeEqual<Numeric<'9', ''>, '9'>>();

assert<TypeEqual<LargestFirst<'123', '12'>, true>>();
assert<TypeEqual<LargestFirst<'123', '123'>, true>>();
assert<TypeEqual<LargestFirst<'123', '1234'>, false>>();

assert<TypeEqual<Add<'3', '4'>, '7'>>();
assert<TypeEqual<Add<'3', '9'>, '12'>>();
assert<TypeEqual<Add<'34', '35'>, '69'>>();
assert<TypeEqual<Add<'34', '95'>, '129'>>();
