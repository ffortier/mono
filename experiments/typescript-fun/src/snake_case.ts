type Alpha_ = 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | 'h' | 'i' | 'j' | 'k' | 'l' | 'm' | 'n' | 'o' | 'p' | 'q' | 'r' | 's' | 't' | 'u' | 'v' | 'w' | 'x' | 'y' | 'z' | '_';
type Num_ = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9';

type Alpha<C extends string, R extends string> = C extends Alpha_ ? `${C}${R}` : never;
type Num<C extends string, R extends string> = C extends Num_ ? `${C}${R}` : never;

type AlphaNum<C extends string, R extends string> = Alpha<C, R> | Num<C, R>;

type SnakeCase_<Prefix extends string, S extends string>
    = S extends "" ? Prefix
    : S extends AlphaNum<infer C, infer R> ? SnakeCase_<`${Prefix}${C}`, R>
    : never;

export type SnakeCase<S extends string>
    = S extends "" ? S
    : S extends Alpha<infer C, infer R> ? SnakeCase_<C, R>
    : never;
