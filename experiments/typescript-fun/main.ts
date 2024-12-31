import './src/arithmetic.ts'
import { BrainFuck } from './src/brainfuck.ts'
import { Gol } from './src/gol.ts'
import { SnakeCase } from './src/snake_case.ts'
import { Wolfram, Rule } from './src/wolfram.ts'

// Snake case
function test<S extends string>(key: SnakeCase<S>) {

}

test("hello");
test("hello_world");
test("hello_world_123");

// Wolfram
type Init = '        #        ';
type A = Wolfram<Rule<90>, Init>;
type B = Wolfram<Rule<90>, A>;
type C = Wolfram<Rule<90>, B>;
type D = Wolfram<Rule<90>, C>;
type E = Wolfram<Rule<90>, D>;
type F = Wolfram<Rule<90>, E>;
type G = Wolfram<Rule<90>, F>;

// Game of Life
namespace glider {
    type Glider = {
        0: [0, 0, 0, 0, 0],
        1: [0, 0, 1, 0, 0],
        2: [0, 0, 0, 1, 0],
        3: [0, 1, 1, 1, 0],
        4: [0, 0, 0, 0, 0],
    }

    type A = Glider;
    type B = Gol<A>;
    type C = Gol<B>;
    type D = Gol<C>;
    type E = Gol<D>;
}

namespace blinker {
    type Blinker = {
        0: [0, 0, 0, 0, 0],
        1: [0, 0, 1, 0, 0],
        2: [0, 0, 1, 0, 0],
        3: [0, 0, 1, 0, 0],
        4: [0, 0, 0, 0, 0],
    }

    type A = Blinker;
    type B = Gol<A>;
    type C = Gol<B>;
    type D = Gol<C>;
    type E = Gol<D>;
}

// Brainfuck
const hello = `++++++++[>+++++++++<-]>.+++++++++++++++++++++++++++++.+++++++..+++.>++++[>++++++++<-]>.>+++++[<+++++++++++>-]<.>++++[<++++++>-]<.+++.------.--------.>+++[>+++++++++++<-]>.`;

type Hello = BrainFuck<typeof hello>;

const h: Hello = 'Hello World!';

// Arithmetic
const a1: Add<'3', '4'> = '7';
const a2: Add<'3', '9'> = '12';
const a3: Add<'34', '35'> = '69';
const a4: Add<'34', '95'> = '129';

console.log("Done!");
