# Typing

Useless typescript experiments

## Snake Case Literals

```typescript
function test<S extends string>(key: SnakeCase<S>) {

}

test("hello");
test("hello_world");
test("hello_world_123");
test("HelloWorld"); // fail to compile
```

## String Arithmetic

```typescript
type T = Add<'34', '95'>
// '129'
```

## Brainfuck Interpreter

> While using TypeScript's type system to model a Brainfuck interpreter is an interesting intellectual exercise, it's important to acknowledge the limitations of this approach. As mentioned earlier, it's not a practical solution for real-world scenarios due to its complexity and performance overhead.
>
> -- <cite>Gemini</cite>

```typescript
type T = BrainFuck<`++++++++[>+++++++++<-]>.+++++++++++++++++++++++++++++.+++++
                    ++..+++.>++++[>++++++++<-]>.>+++++[<+++++++++++>-]<.>++++[<
                    ++++++>-]<.+++.------.--------.>+++[>+++++++++++<-]>.`>
// 'Hello World!'
```

## Game of Life
> This is a fascinating approach to simulating the Game of Life using TypeScript's type system. By leveraging type-level computations, you can effectively model the rules of the game and derive the next generation of the board at compile time.
>
> -- <cite>Gemini</cite>

```typescript
type Blinker = {
    0: [0, 0, 0, 0, 0],
    1: [0, 0, 1, 0, 0],
    2: [0, 0, 1, 0, 0],
    3: [0, 0, 1, 0, 0],
    4: [0, 0, 0, 0, 0],
}

type A = Blinker;
// {
//     0: [0, 0, 0, 0, 0],
//     1: [0, 0, 1, 0, 0],
//     2: [0, 0, 1, 0, 0],
//     3: [0, 0, 1, 0, 0],
//     4: [0, 0, 0, 0, 0],
// }

type B = Gol<A>;
// {
//     0: [0, 0, 0, 0, 0],
//     1: [0, 0, 0, 0, 0],
//     2: [0, 1, 1, 1, 0],
//     3: [0, 0, 0, 0, 0],
//     4: [0, 0, 0, 0, 0],
// }

type C = Gol<B>;
// {
//     0: [0, 0, 0, 0, 0],
//     1: [0, 0, 1, 0, 0],
//     2: [0, 0, 1, 0, 0],
//     3: [0, 0, 1, 0, 0],
//     4: [0, 0, 0, 0, 0],
// }
```

## Elementary Cellular Automaton (Wolfram)

```typescript
type Init = '00000000100000000';
type A = Wolfram<Rule<90>, Init>;
type B = Wolfram<Rule<90>, A>;
type C = Wolfram<Rule<90>, B>;
type D = Wolfram<Rule<90>, C>;
type E = Wolfram<Rule<90>, D>;
type F = Wolfram<Rule<90>, E>;
type G = Wolfram<Rule<90>, F>;

// '        #        '
// '       # #       '
// '      #   #      '
// '     # # # #     '
// '    #       #    '
// '   # #     # #   '
// '  #   #   #   #  '
// ' # # # # # # # # '
```