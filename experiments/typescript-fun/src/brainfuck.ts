import { Sized, Successor, Predecessor } from './num.ts'

type AsciiTable = [
    '\x00', '\x01', '\x02', '\x03', '\x04', '\x05', '\x06', '\x07', '\x08', '\x09', '\x0a', '\x0b', '\x0c', '\x0d', '\x0e', '\x0f',
    '\x10', '\x11', '\x12', '\x13', '\x14', '\x15', '\x16', '\x17', '\x18', '\x19', '\x1a', '\x1b', '\x1c', '\x1d', '\x1e', '\x1f',
    '\x20', '\x21', '\x22', '\x23', '\x24', '\x25', '\x26', '\x27', '\x28', '\x29', '\x2a', '\x2b', '\x2c', '\x2d', '\x2e', '\x2f',
    '\x30', '\x31', '\x32', '\x33', '\x34', '\x35', '\x36', '\x37', '\x38', '\x39', '\x3a', '\x3b', '\x3c', '\x3d', '\x3e', '\x3f',
    '\x40', '\x41', '\x42', '\x43', '\x44', '\x45', '\x46', '\x47', '\x48', '\x49', '\x4a', '\x4b', '\x4c', '\x4d', '\x4e', '\x4f',
    '\x50', '\x51', '\x52', '\x53', '\x54', '\x55', '\x56', '\x57', '\x58', '\x59', '\x5a', '\x5b', '\x5c', '\x5d', '\x5e', '\x5f',
    '\x60', '\x61', '\x62', '\x63', '\x64', '\x65', '\x66', '\x67', '\x68', '\x69', '\x6a', '\x6b', '\x6c', '\x6d', '\x6e', '\x6f',
    '\x70', '\x71', '\x72', '\x73', '\x74', '\x75', '\x76', '\x77', '\x78', '\x79', '\x7a', '\x7b', '\x7c', '\x7d', '\x7e', '\x7f',
    '\x80', '\x81', '\x82', '\x83', '\x84', '\x85', '\x86', '\x87', '\x88', '\x89', '\x8a', '\x8b', '\x8c', '\x8d', '\x8e', '\x8f',
    '\x90', '\x91', '\x92', '\x93', '\x94', '\x95', '\x96', '\x97', '\x98', '\x99', '\x9a', '\x9b', '\x9c', '\x9d', '\x9e', '\x9f',
    '\xa0', '\xa1', '\xa2', '\xa3', '\xa4', '\xa5', '\xa6', '\xa7', '\xa8', '\xa9', '\xaa', '\xab', '\xac', '\xad', '\xae', '\xaf',
    '\xb0', '\xb1', '\xb2', '\xb3', '\xb4', '\xb5', '\xb6', '\xb7', '\xb8', '\xb9', '\xba', '\xbb', '\xbc', '\xbd', '\xbe', '\xbf',
    '\xc0', '\xc1', '\xc2', '\xc3', '\xc4', '\xc5', '\xc6', '\xc7', '\xc8', '\xc9', '\xca', '\xcb', '\xcc', '\xcd', '\xce', '\xcf',
    '\xd0', '\xd1', '\xd2', '\xd3', '\xd4', '\xd5', '\xd6', '\xd7', '\xd8', '\xd9', '\xda', '\xdb', '\xdc', '\xdd', '\xde', '\xdf',
    '\xe0', '\xe1', '\xe2', '\xe3', '\xe4', '\xe5', '\xe6', '\xe7', '\xe8', '\xe9', '\xea', '\xeb', '\xec', '\xed', '\xee', '\xef',
    '\xf0', '\xf1', '\xf2', '\xf3', '\xf4', '\xf5', '\xf6', '\xf7', '\xf8', '\xf9', '\xfa', '\xfb', '\xfc', '\xfd', '\xfe', '\xff',
]

type AsciiLookup<I extends AsciiTable[number]> = {
    [P in Bytes]: AsciiTable[P] extends I ? P : never
}[Bytes]

type Bytes = Sized<256>[number];

type ZeroMem = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];

type Ascii_ = AsciiTable[number];
type Ascii<C extends Ascii_, R extends string> = `${C}${R}`;

type OpCode_ = '<' | '>' | '[' | ']' | '+' | '-' | '.' | ',';
type OpCode<C extends OpCode_, R extends string> = `${C}${R}`;

type Tokenize_<S extends string, B extends OpCode_[]>
    = S extends '' ? B
    : S extends OpCode<infer C, infer R> ? Tokenize_<R, [...B, C]>
    : S extends Ascii<infer C, infer R> ? Tokenize_<R, B>
    : never;

type Tokenize<S extends string> = Tokenize_<S, []>;

type SplitInput_<S extends string, B extends Bytes[]>
    = S extends '' ? B
    : S extends Ascii<infer C, infer R> ? SplitInput_<R, [...B, AsciiLookup<C>]>
    : never;

type SplitInput<S extends string> = SplitInput_<S, []>;

type Joined<Ls extends Bytes[], P extends string = ''>
    = Ls extends [] ? P
    : Ls extends ByteArray<infer C, infer Rs> ? Joined<Rs, `${P}${AsciiTable[C]}`>
    : never;

type ByteArray<B extends Bytes, Bs extends Bytes[]> = [B, ...Bs];

type Splice<Es extends Bytes[], I extends number, L extends Bytes, Rs extends Bytes[] = []>
    = Es extends ByteArray<infer E, infer Es1> ? I extends 0 ? [...Rs, L, ...Es1] : Splice<Es1, Predecessor<I>, L, [...Rs, E]>
    : never;

type ClosingBracket<Program extends OpCode_[], PC extends number, Depth extends number = 0>
    = Program[PC] extends ']' ? Depth extends 0 ? Successor<PC, Bytes> : ClosingBracket<Program, Successor<PC>, Predecessor<Depth>>
    : Program[PC] extends '[' ? ClosingBracket<Program, Successor<PC>, Successor<Depth>>
    : ClosingBracket<Program, Successor<PC>, Depth>;

type OpeningBracket<Program extends OpCode_[], PC extends number, Depth extends number = 0>
    = Program[PC] extends '[' ? Depth extends 0 ? Successor<PC> : OpeningBracket<Program, Predecessor<PC>, Predecessor<Depth>>
    : Program[PC] extends ']' ? OpeningBracket<Program, Predecessor<PC>, Successor<Depth>>
    : OpeningBracket<Program, Predecessor<PC>, Depth>;

type JumpForwardIfZero<Program extends OpCode_[], Mem extends Bytes[], Input extends Bytes[], Output extends Bytes[], PC extends number, CC extends number>
    = Mem[CC] extends 0 ? BrainFuck_<Program, Mem, Input, Output, ClosingBracket<Program, Successor<PC>>, CC>
    : BrainFuck_<Program, Mem, Input, Output, Successor<PC>, CC>

type JumpBackIfNonZero<Program extends OpCode_[], Mem extends Bytes[], Input extends Bytes[], Output extends Bytes[], PC extends number, CC extends number>
    = Mem[CC] extends 0 ? BrainFuck_<Program, Mem, Input, Output, Successor<PC>, CC>
    : BrainFuck_<Program, Mem, Input, Output, OpeningBracket<Program, Predecessor<PC>>, CC>;

type BrainFuck_<Program extends OpCode_[], Mem extends Bytes[], Input extends Bytes[], Output extends Bytes[], PC extends number, CC extends number>
    = PC extends Program['length'] ? Joined<Output>
    : Program[PC] extends '<' ? BrainFuck_<Program, Mem, Input, Output, Successor<PC>, Predecessor<CC>>
    : Program[PC] extends '>' ? BrainFuck_<Program, Mem, Input, Output, Successor<PC>, Successor<CC>>
    : Program[PC] extends '.' ? BrainFuck_<Program, Mem, Input, [...Output, Mem[CC]], Successor<PC>, CC>
    : Program[PC] extends ',' ? Input extends ByteArray<infer I, infer Is> ? BrainFuck_<Program, Splice<Mem, CC, I>, Is, Output, Successor<PC>, CC> : never
    : Program[PC] extends '+' ? BrainFuck_<Program, Splice<Mem, CC, Successor<Mem[CC], Bytes>>, Input, Output, Successor<PC>, CC>
    : Program[PC] extends '-' ? BrainFuck_<Program, Splice<Mem, CC, Predecessor<Mem[CC], Bytes>>, Input, Output, Successor<PC>, CC>
    : Program[PC] extends '[' ? JumpForwardIfZero<Program, Mem, Input, Output, PC, CC>
    : Program[PC] extends ']' ? JumpBackIfNonZero<Program, Mem, Input, Output, PC, CC>
    : never;

export type BrainFuck<Program extends string, Mem extends Bytes[] = ZeroMem, Input extends string = "">
    = BrainFuck_<Tokenize<Program>, Mem, SplitInput<Input>, [], 0, 0>;

