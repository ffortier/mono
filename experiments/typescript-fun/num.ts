type Sized_<T extends number, Ls extends number[]>
    = Ls['length'] extends T ? Ls
    : Sized_<T, [...Ls, Ls['length']]>;

export type Sized<T extends number> = Sized_<T, []>;

export type Successor<T extends number, TT extends number = number, Default = never>
    = [...Sized<T>, T]['length'] extends TT ? [...Sized<T>, T]['length']
    : Default;

export type Predecessor<T extends number, TT extends number = number, Default = never>
    = Sized<T> extends [infer L, ...infer Ls] ? Ls['length'] extends TT ? Ls['length'] : never
    : Default;

type ParseInt_<T extends string, I extends number>
    = T extends `${I}` ? I
    : ParseInt_<T, Successor<I>>;

export type ParseInt<T>
    = T extends number ? T
    : T extends string ? ParseInt_<T, 0>
    : never;
