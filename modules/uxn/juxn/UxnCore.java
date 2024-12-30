package juxn;

import juxn.devices.Device;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class UxnCore {
    private final ByteBuffer ram = ByteBuffer.allocate(0x10000).order(ByteOrder.BIG_ENDIAN);
    private final Stack wst = new Stack();
    private final Stack rst = new Stack();
    private final Device[] devices;
    private Stack src;
    private int r2;
    private int rk;

    public UxnCore(Device[] devices) {
        this.devices = devices;
    }

    private int rel(int val) {
        return val > 0x80 ? val - 256 : val;
    }

    public Device[] devices() {
        return devices;
    }

    public ByteBuffer ram() {
        return ram;
    }

    public void load(byte[] program) {
        ram.put(0x100, program);
    }

    public void eval(int pc) {
        if (pc == 0 || Byte.toUnsignedInt(ram.get(0x0f)) != 0)
            return;

        int instr;

        while ((instr = Byte.toUnsignedInt(ram.get(pc++))) != 0) {
            Stack dst;

            final var rr = (instr & 0x40);

            this.r2 = (instr & 0x20);
            this.rk = (instr & 0x80);

            if (rr != 0) {
                this.src = this.rst;
                dst = this.wst;
            } else {
                this.src = this.wst;
                dst = this.rst;
            }

            if (rk != 0) {
                src.ptrk = src.ptr;
            }

            final var opcode = (instr & 0x1f);
            final var opcodeFull = (opcode - ((opcode == 0 ? 1 : 0) * (instr >> 5)));

            int a, b, c;

            switch (opcodeFull) {
                /* Literals/Calls */
                case -0x0: /* BRK */
                    return;
                case -0x1: /* JCI */
                    if (this.pop1() == 0) {
                        pc = this.move(2, pc);
                        break;
                    }
                case -0x2: /* JMI */
                    pc = this.move(this.peek2(pc) + 2, pc);
                    break;
                case -0x3: /* JSI */
                    this.rst.push2(move(2, pc));
                    pc = this.move(this.peek2(pc) + 2, pc);
                    break;
                // Stack
                case -0x4: /* LIT */
                case -0x6: /* LITr */
                case -0x5: /* LIT2 */
                case -0x7: /* LIT2r */
                    this.pushx(this.peekx(pc));
                    pc = this.move((this.r2 != 0 ? 1 : 0) + 1, pc);
                    break;
                case 0x01: /* INC */
                    this.pushx(this.popx() + 1);
                    break;
                case 0x02: /* POP */
                    this.popx();
                    break;
                case 0x03: /* NIP */
                    a = this.popx();
                    this.popx();
                    this.pushx(a);
                    break;
                case 0x04: /* SWP */
                    a = this.popx();
                    b = this.popx();
                    this.pushx(a);
                    this.pushx(b);
                    break;
                case 0x05: /* ROT */
                    a = this.popx();
                    b = this.popx();
                    c = this.popx();
                    this.pushx(b);
                    this.pushx(a);
                    this.pushx(c);
                    break;
                case 0x06: /* DUP */
                    a = this.popx();
                    this.pushx(a);
                    this.pushx(a);
                    break;
                case 0x07: /* OVR */
                    a = this.popx();
                    b = this.popx();
                    this.pushx(b);
                    this.pushx(a);
                    this.pushx(b);
                    break;
                // Logic
                case 0x08: /* EQU */
                    a = this.popx();
                    b = this.popx();
                    this.push1(b == a ? 1 : 0);
                    break;
                case 0x09: /* NEQ */
                    a = this.popx();
                    b = this.popx();
                    this.push1(b != a ? 1 : 0);
                    break;
                case 0x0a: /* GTH */
                    a = this.popx();
                    b = this.popx();
                    this.push1(b > a ? 1 : 0);
                    break;
                case 0x0b: /* LTH */
                    a = this.popx();
                    b = this.popx();
                    this.push1(b < a ? 1 : 0);
                    break;
                case 0x0c: /* JMP */
                    pc = this.jump(this.popx(), pc);
                    break;
                case 0x0d: /* JCN */
                    a = this.popx();
                    if (this.pop1() != 0)
                        pc = this.jump(a, pc);
                    break;
                case 0x0e: /* JSR */
                    dst.push2(pc);
                    pc = this.jump(this.popx(), pc);
                    break;
                case 0x0f: /* STH */
                    if (this.r2 != 0) {
                        dst.push2(this.pop2());
                    } else {
                        dst.push1(this.pop1());
                    }
                    break;
                // Memory
                case 0x10: /* LDZ */
                    this.pushx(this.peekx(this.pop1()));
                    break;
                case 0x11: /* STZ */
                    this.pokex(this.pop1(), this.popx());
                    break;
                case 0x12: /* LDR */
                    this.pushx(this.peekx((pc + rel(this.pop1()))));
                    break;
                case 0x13: /* STR */
                    this.pokex((pc + rel(this.pop1())), this.popx());
                    break;
                case 0x14: /* LDA */
                    this.pushx(this.peekx(this.pop2()));
                    break;
                case 0x15: /* STA */
                    this.pokex(this.pop2(), this.popx());
                    break;
                case 0x16: /* DEI */
                    this.pushx(this.devr(this.pop1()));
                    break;
                case 0x17: /* DEO */
                    this.devw(this.pop1(), this.popx());
                    break;
                // Arithmetic
                case 0x18: /* ADD */
                    a = this.popx();
                    b = this.popx();
                    this.pushx(b + a);
                    break;
                case 0x19: /* SUB */
                    a = this.popx();
                    b = this.popx();
                    this.pushx(b - a);
                    break;
                case 0x1a: /* MUL */
                    a = this.popx();
                    b = this.popx();
                    this.pushx(b * a);
                    break;
                case 0x1b: /* DIV */
                    a = this.popx();
                    b = this.popx();
                    this.pushx(a != 0 ? b / a : 0);
                    break;
                case 0x1c: /* AND */
                    a = this.popx();
                    b = this.popx();
                    this.pushx(b & a);
                    break;
                case 0x1d: /* ORA */
                    a = this.popx();
                    b = this.popx();
                    this.pushx(b | a);
                    break;
                case 0x1e: /* EOR */
                    a = this.popx();
                    b = this.popx();
                    this.pushx(b ^ a);
                    break;
                case 0x1f: /* SFT */
                    a = this.pop1();
                    b = this.popx();
                    this.pushx(b >> (a & 0xf) << (a >> 4));
                    break;
                default:
                    throw new UnsupportedOperationException("Unsupported opcode %02x".formatted(opcodeFull));
            }
        }
    }

    private void devw(int addr, int val) {
        final var portOffset = addr & 0x0f;
        final var basePort = addr >> 4;

        if (this.r2 != 0) {
            ram.putShort(addr, (short) val);
        } else {
            ram.put(addr, (byte) val);
        }

        devices[basePort].out(portOffset, addr, this);
    }

    private int devr(int addr) {
        final var portOffset = addr & 0x0f;
        final var basePort = addr >> 4;

        devices[basePort].in(portOffset, addr, this);

        if (this.r2 != 0) {
            return Short.toUnsignedInt(ram.getShort(addr));
        } else {
            return Byte.toUnsignedInt(ram.get(addr));
        }
    }

    private int jump(int addr, int pc) {
        return this.r2 != 0 ? addr : this.move(rel(addr), pc);
    }

    private void pokex(int addr, int x) {
        if (this.r2 != 0)
            this.poke2(addr, x);
        else
            this.poke1(addr, x);
    }

    private void poke1(int addr, int x) {
        this.ram.put(addr, (byte) x);
    }

    private void poke2(int addr, int x) {
        this.ram.putShort(addr, (short) x);
    }

    private int pop2() {
        return src.pop2();
    }

    private void pushx(int val) {
        if (this.r2 != 0)
            this.push2(val);
        else
            this.push1(val);
    }

    private void push2(int val) {
        src.push2(val);
    }

    private void push1(int val) {
        src.push1(val);
    }

    private int peekx(int addr) {
        return this.r2 != 0 ? this.peek2(addr) : this.peek1(addr);
    }

    private int peek1(int addr) {
        return Byte.toUnsignedInt(ram.get(addr));
    }

    private int popx() {
        return this.r2 != 0 ? this.src.pop2() : this.src.pop1();
    }

    private int peek2(int addr) {
        return Short.toUnsignedInt(ram.getShort(addr));
    }

    private int move(int distance, int pc) {
        return (pc + distance) & 0xffff;
    }

    private int pop1() {
        return src.pop1();
    }

    class Stack {
        private final ByteBuffer ram = ByteBuffer.allocate(0x100);
        private int ptr = 0;
        private int ptrk = 0;

        public int pop1() {
            return Byte.toUnsignedInt(ram.get((UxnCore.this.rk != 0 ? --this.ptrk : --this.ptr) & 0xff));
        }

        public int pop2() {
            return (pop1() | pop1() << 8);
        }

        public void push1(int val) {
            ram.put(this.ptr++ & 0xff, (byte) val);
        }

        public void push2(int val) {
            push1((val >> 8));
            push1(val);
        }
    }
}
