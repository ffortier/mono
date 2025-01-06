import { Sized } from './num.js'

type One = '#'
type Zero = ' '
type Bit = Zero | One;

type ChopBit<B extends Bit, R extends string> = `${B}${R}`;
type ChopBlock<B0 extends Bit, B1 extends Bit, B2 extends Bit, R extends string> = `${B0}${B1}${B2}${R}`;

type Increment<Binary extends string, Result extends string = ''>
    = Binary extends '' ? `${Result}${One}`
    : Binary extends ChopBit<infer Bit, infer R> ? Bit extends Zero ? `${Result}${One}${R}` : Increment<R, `${Result}${Zero}`>
    : never;

type Byte = Sized<8>[number];

type Encode<I extends number, Bin extends string, Counter extends unknown[] = []>
    = Counter['length'] extends I ? Bin
    : Encode<I, Increment<Bin>, [...Counter, I]>;

type At_<B extends Bit, Bin extends string, I extends number, Counter extends unknown[]>
    = Counter['length'] extends I ? B
    : Bin extends ChopBit<infer B1, infer R> ? At_<B1, R, I, [1, ...Counter]>
    : never;

type At<Bin extends string, I extends number>
    = Bin extends ChopBit<infer B, infer R> ? At_<B, R, I, []>
    : never;

type Rule_<Bin extends string> = {
    [I in Byte]: At<Bin, I> extends One ? Encode<I, '   '> : never
}[Byte];

type Rule<N extends number> = Rule_<Encode<N, '        '>>;

type Get<Rule, B0 extends Bit, B1 extends Bit, B2 extends Bit>
    = `${B0}${B1}${B2}` extends Rule ? One : Zero;

type Wolfram_<Rule, S extends string, Result extends string>
    = S extends ChopBlock<infer B0, infer B1, infer B2, infer Rest> ? Wolfram_<Rule, `${B1}${B2}${Rest}`, `${Result}${Get<Rule, B0, B1, B2>}`>
    : Result;

type Wolfram<Rule, S extends string> = Wolfram_<Rule, `${Zero}${S}${Zero}`, ''>;

type Init = '        #        ';
type A = Wolfram<Rule<90>, Init>;
type B = Wolfram<Rule<90>, A>;
type C = Wolfram<Rule<90>, B>;
type D = Wolfram<Rule<90>, C>;
type E = Wolfram<Rule<90>, D>;
type F = Wolfram<Rule<90>, E>;
type G = Wolfram<Rule<90>, F>;
