package io.github.ffortier.jasm.core.binary;

import java.nio.ByteBuffer;

public sealed interface Instruction permits Instruction.UNREACHABLE,
        Instruction.NOP,
        Instruction.BLOCK,
        Instruction.LOOP,
        Instruction.IF,
        Instruction.ELSE,
        Instruction.END,
        Instruction.BR,
        Instruction.BR_IF,
        Instruction.BR_TABLE,
        Instruction.RETURN,
        Instruction.CALL,
        Instruction.CALL_INDIRECT,
        Instruction.DROP,
        Instruction.SELECT,
        Instruction.LOCAL_GET,
        Instruction.LOCAL_SET,
        Instruction.LOCAL_TEE,
        Instruction.GLOBAL_GET,
        Instruction.GLOBAL_SET,
        Instruction.I32_LOAD,
        Instruction.I64_LOAD,
        Instruction.F32_LOAD,
        Instruction.F64_LOAD,
        Instruction.I32_LOAD8_S,
        Instruction.I32_LOAD8_U,
        Instruction.I32_LOAD16_S,
        Instruction.I32_LOAD16_U,
        Instruction.I64_LOAD8_S,
        Instruction.I64_LOAD8_U,
        Instruction.I64_LOAD16_S,
        Instruction.I64_LOAD16_U,
        Instruction.I64_LOAD32_S,
        Instruction.I64_LOAD32_U,
        Instruction.I32_STORE,
        Instruction.I64_STORE,
        Instruction.F32_STORE,
        Instruction.F64_STORE,
        Instruction.I32_STORE8,
        Instruction.I32_STORE16,
        Instruction.I64_STORE8,
        Instruction.I64_STORE16,
        Instruction.I64_STORE32,
        Instruction.MEMORY_SIZE,
        Instruction.MEMORY_GROW,
        Instruction.I32_CONST,
        Instruction.I64_CONST,
        Instruction.F32_CONST,
        Instruction.F64_CONST,
        Instruction.I32_EQZ,
        Instruction.I32_EQ,
        Instruction.I32_NE,
        Instruction.I32_LT_S,
        Instruction.I32_LT_U,
        Instruction.I32_GT_S,
        Instruction.I32_GT_U,
        Instruction.I32_LE_S,
        Instruction.I32_LE_U,
        Instruction.I32_GE_S,
        Instruction.I32_GE_U,
        Instruction.I64_EQZ,
        Instruction.I64_EQ,
        Instruction.I64_NE,
        Instruction.I64_LT_S,
        Instruction.I64_LT_U,
        Instruction.I64_GT_S,
        Instruction.I64_GT_U,
        Instruction.I64_LE_S,
        Instruction.I64_LE_U,
        Instruction.I64_GE_S,
        Instruction.I64_GE_U,
        Instruction.F32_EQ,
        Instruction.F32_NE,
        Instruction.F32_LT,
        Instruction.F32_GT,
        Instruction.F32_LE,
        Instruction.F32_GE,
        Instruction.F64_EQ,
        Instruction.F64_NE,
        Instruction.F64_LT,
        Instruction.F64_GT,
        Instruction.F64_LE,
        Instruction.F64_GE,
        Instruction.I32_CLZ,
        Instruction.I32_CTZ,
        Instruction.I32_POPCNT,
        Instruction.I32_ADD,
        Instruction.I32_SUB,
        Instruction.I32_MUL,
        Instruction.I32_DIV_S,
        Instruction.I32_DIV_U,
        Instruction.I32_REM_S,
        Instruction.I32_REM_U,
        Instruction.I32_AND,
        Instruction.I32_OR,
        Instruction.I32_XOR,
        Instruction.I32_SHL,
        Instruction.I32_SHR_S,
        Instruction.I32_SHR_U,
        Instruction.I32_ROTL,
        Instruction.I32_ROTR,
        Instruction.I64_CLZ,
        Instruction.I64_CTZ,
        Instruction.I64_POPCNT,
        Instruction.I64_ADD,
        Instruction.I64_SUB,
        Instruction.I64_MUL,
        Instruction.I64_DIV_S,
        Instruction.I64_DIV_U,
        Instruction.I64_REM_S,
        Instruction.I64_REM_U,
        Instruction.I64_AND,
        Instruction.I64_OR,
        Instruction.I64_XOR,
        Instruction.I64_SHL,
        Instruction.I64_SHR_S,
        Instruction.I64_SHR_U,
        Instruction.I64_ROTL,
        Instruction.I64_ROTR,
        Instruction.F32_ABS,
        Instruction.F32_NEG,
        Instruction.F32_CEIL,
        Instruction.F32_FLOOR,
        Instruction.F32_TRUNC,
        Instruction.F32_NEAREST,
        Instruction.F32_SQRT,
        Instruction.F32_ADD,
        Instruction.F32_SUB,
        Instruction.F32_MUL,
        Instruction.F32_DIV,
        Instruction.F32_MIN,
        Instruction.F32_MAX,
        Instruction.F32_COPYSIGN,
        Instruction.F64_ABS,
        Instruction.F64_NEG,
        Instruction.F64_CEIL,
        Instruction.F64_FLOOR,
        Instruction.F64_TRUNC,
        Instruction.F64_NEAREST,
        Instruction.F64_SQRT,
        Instruction.F64_ADD,
        Instruction.F64_SUB,
        Instruction.F64_MUL,
        Instruction.F64_DIV,
        Instruction.F64_MIN,
        Instruction.F64_MAX,
        Instruction.F64_COPYSIGN {

    public static Instruction read(ByteBuffer bb) {
        final var opcode = WebAssemblyOpcode.from(Byte.toUnsignedInt(bb.get()));

        return opcode.read(bb);
    }

    interface Indexable<T extends Index> {
        T index();
    }

    interface MemoryInstruction {
        Memarg memarg();
    }

    WebAssemblyOpcode opcode();

    record UNREACHABLE() implements Instruction {
        public static UNREACHABLE read(ByteBuffer bb) {
            return new UNREACHABLE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.UNREACHABLE;
        }
    }

    record NOP() implements Instruction {
        public static NOP read(ByteBuffer bb) {
            return new NOP();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.NOP;
        }
    }

    record BLOCK() implements Instruction {
        public static BLOCK read(ByteBuffer bb) {
            return new BLOCK();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.BLOCK;
        }
    }

    record LOOP() implements Instruction {
        public static LOOP read(ByteBuffer bb) {
            return new LOOP();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.LOOP;
        }
    }

    record IF() implements Instruction {
        public static IF read(ByteBuffer bb) {
            return new IF();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.IF;
        }
    }

    record ELSE() implements Instruction {
        public static ELSE read(ByteBuffer bb) {
            return new ELSE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.ELSE;
        }
    }

    record END() implements Instruction {
        public static END read(ByteBuffer bb) {
            return new END();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.END;
        }
    }

    record BR() implements Instruction {
        public static BR read(ByteBuffer bb) {
            return new BR();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.BR;
        }
    }

    record BR_IF() implements Instruction {
        public static BR_IF read(ByteBuffer bb) {
            return new BR_IF();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.BR_IF;
        }
    }

    record BR_TABLE() implements Instruction {
        public static BR_TABLE read(ByteBuffer bb) {
            return new BR_TABLE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.BR_TABLE;
        }
    }

    record RETURN() implements Instruction {
        public static RETURN read(ByteBuffer bb) {
            return new RETURN();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.RETURN;
        }
    }

    record CALL() implements Instruction {
        public static CALL read(ByteBuffer bb) {
            return new CALL();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.CALL;
        }
    }

    record CALL_INDIRECT() implements Instruction {
        public static CALL_INDIRECT read(ByteBuffer bb) {
            return new CALL_INDIRECT();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.CALL_INDIRECT;
        }
    }

    record DROP() implements Instruction {
        public static DROP read(ByteBuffer bb) {
            return new DROP();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.DROP;
        }
    }

    record SELECT() implements Instruction {
        public static SELECT read(ByteBuffer bb) {
            return new SELECT();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.SELECT;
        }
    }

    record LOCAL_GET(Index.LocalIdx index) implements Instruction, Indexable<Index.LocalIdx> {
        public static LOCAL_GET read(ByteBuffer bb) {
            return new LOCAL_GET(new Index.LocalIdx(BinaryReader.leb128(bb)));
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.LOCAL_GET;
        }
    }

    record LOCAL_SET(Index.LocalIdx index) implements Instruction, Indexable<Index.LocalIdx> {
        public static LOCAL_SET read(ByteBuffer bb) {
            return new LOCAL_SET(new Index.LocalIdx(BinaryReader.leb128(bb)));
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.LOCAL_SET;
        }
    }

    record LOCAL_TEE() implements Instruction {
        public static LOCAL_TEE read(ByteBuffer bb) {
            return new LOCAL_TEE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.LOCAL_TEE;
        }
    }

    record GLOBAL_GET(Index.GlobalIdx index) implements Instruction, Indexable<Index.GlobalIdx> {
        public static GLOBAL_GET read(ByteBuffer bb) {
            return new GLOBAL_GET(new Index.GlobalIdx(BinaryReader.leb128(bb)));
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.GLOBAL_GET;
        }
    }

    record GLOBAL_SET(Index.GlobalIdx index) implements Instruction, Indexable<Index.GlobalIdx> {
        public static GLOBAL_SET read(ByteBuffer bb) {
            return new GLOBAL_SET(new Index.GlobalIdx(BinaryReader.leb128(bb)));
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.GLOBAL_SET;
        }
    }

    record I32_LOAD(Memarg memarg) implements Instruction, MemoryInstruction {
        public static I32_LOAD read(ByteBuffer bb) {
            return new I32_LOAD(Memarg.read(bb));
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_LOAD;
        }
    }

    record I64_LOAD() implements Instruction {
        public static I64_LOAD read(ByteBuffer bb) {
            return new I64_LOAD();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_LOAD;
        }
    }

    record F32_LOAD() implements Instruction {
        public static F32_LOAD read(ByteBuffer bb) {
            return new F32_LOAD();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_LOAD;
        }
    }

    record F64_LOAD() implements Instruction {
        public static F64_LOAD read(ByteBuffer bb) {
            return new F64_LOAD();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_LOAD;
        }
    }

    record I32_LOAD8_S() implements Instruction {
        public static I32_LOAD8_S read(ByteBuffer bb) {
            return new I32_LOAD8_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_LOAD8_S;
        }
    }

    record I32_LOAD8_U() implements Instruction {
        public static I32_LOAD8_U read(ByteBuffer bb) {
            return new I32_LOAD8_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_LOAD8_U;
        }
    }

    record I32_LOAD16_S() implements Instruction {
        public static I32_LOAD16_S read(ByteBuffer bb) {
            return new I32_LOAD16_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_LOAD16_S;
        }
    }

    record I32_LOAD16_U() implements Instruction {
        public static I32_LOAD16_U read(ByteBuffer bb) {
            return new I32_LOAD16_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_LOAD16_U;
        }
    }

    record I64_LOAD8_S() implements Instruction {
        public static I64_LOAD8_S read(ByteBuffer bb) {
            return new I64_LOAD8_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_LOAD8_S;
        }
    }

    record I64_LOAD8_U() implements Instruction {
        public static I64_LOAD8_U read(ByteBuffer bb) {
            return new I64_LOAD8_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_LOAD8_U;
        }
    }

    record I64_LOAD16_S() implements Instruction {
        public static I64_LOAD16_S read(ByteBuffer bb) {
            return new I64_LOAD16_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_LOAD16_S;
        }
    }

    record I64_LOAD16_U() implements Instruction {
        public static I64_LOAD16_U read(ByteBuffer bb) {
            return new I64_LOAD16_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_LOAD16_U;
        }
    }

    record I64_LOAD32_S() implements Instruction {
        public static I64_LOAD32_S read(ByteBuffer bb) {
            return new I64_LOAD32_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_LOAD32_S;
        }
    }

    record I64_LOAD32_U() implements Instruction {
        public static I64_LOAD32_U read(ByteBuffer bb) {
            return new I64_LOAD32_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_LOAD32_U;
        }
    }

    record I32_STORE(Memarg memarg) implements Instruction, MemoryInstruction {
        public static I32_STORE read(ByteBuffer bb) {
            return new I32_STORE(Memarg.read(bb));
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_STORE;
        }
    }

    record I64_STORE() implements Instruction {
        public static I64_STORE read(ByteBuffer bb) {
            return new I64_STORE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_STORE;
        }
    }

    record F32_STORE() implements Instruction {
        public static F32_STORE read(ByteBuffer bb) {
            return new F32_STORE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_STORE;
        }
    }

    record F64_STORE() implements Instruction {
        public static F64_STORE read(ByteBuffer bb) {
            return new F64_STORE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_STORE;
        }
    }

    record I32_STORE8() implements Instruction {
        public static I32_STORE8 read(ByteBuffer bb) {
            return new I32_STORE8();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_STORE8;
        }
    }

    record I32_STORE16() implements Instruction {
        public static I32_STORE16 read(ByteBuffer bb) {
            return new I32_STORE16();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_STORE16;
        }
    }

    record I64_STORE8() implements Instruction {
        public static I64_STORE8 read(ByteBuffer bb) {
            return new I64_STORE8();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_STORE8;
        }
    }

    record I64_STORE16() implements Instruction {
        public static I64_STORE16 read(ByteBuffer bb) {
            return new I64_STORE16();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_STORE16;
        }
    }

    record I64_STORE32() implements Instruction {
        public static I64_STORE32 read(ByteBuffer bb) {
            return new I64_STORE32();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_STORE32;
        }
    }

    record MEMORY_SIZE() implements Instruction {
        public static MEMORY_SIZE read(ByteBuffer bb) {
            return new MEMORY_SIZE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.MEMORY_SIZE;
        }
    }

    record MEMORY_GROW() implements Instruction {
        public static MEMORY_GROW read(ByteBuffer bb) {
            return new MEMORY_GROW();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.MEMORY_GROW;
        }
    }

    record I32_CONST(int value) implements Instruction {
        public static I32_CONST read(ByteBuffer bb) {
            return new I32_CONST(BinaryReader.i32(bb));
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_CONST;
        }
    }

    record I64_CONST() implements Instruction {
        public static I64_CONST read(ByteBuffer bb) {
            return new I64_CONST();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_CONST;
        }
    }

    record F32_CONST() implements Instruction {
        public static F32_CONST read(ByteBuffer bb) {
            return new F32_CONST();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_CONST;
        }
    }

    record F64_CONST() implements Instruction {
        public static F64_CONST read(ByteBuffer bb) {
            return new F64_CONST();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_CONST;
        }
    }

    record I32_EQZ() implements Instruction {
        public static I32_EQZ read(ByteBuffer bb) {
            return new I32_EQZ();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_EQZ;
        }
    }

    record I32_EQ() implements Instruction {
        public static I32_EQ read(ByteBuffer bb) {
            return new I32_EQ();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_EQ;
        }
    }

    record I32_NE() implements Instruction {
        public static I32_NE read(ByteBuffer bb) {
            return new I32_NE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_NE;
        }
    }

    record I32_LT_S() implements Instruction {
        public static I32_LT_S read(ByteBuffer bb) {
            return new I32_LT_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_LT_S;
        }
    }

    record I32_LT_U() implements Instruction {
        public static I32_LT_U read(ByteBuffer bb) {
            return new I32_LT_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_LT_U;
        }
    }

    record I32_GT_S() implements Instruction {
        public static I32_GT_S read(ByteBuffer bb) {
            return new I32_GT_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_GT_S;
        }
    }

    record I32_GT_U() implements Instruction {
        public static I32_GT_U read(ByteBuffer bb) {
            return new I32_GT_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_GT_U;
        }
    }

    record I32_LE_S() implements Instruction {
        public static I32_LE_S read(ByteBuffer bb) {
            return new I32_LE_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_LE_S;
        }
    }

    record I32_LE_U() implements Instruction {
        public static I32_LE_U read(ByteBuffer bb) {
            return new I32_LE_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_LE_U;
        }
    }

    record I32_GE_S() implements Instruction {
        public static I32_GE_S read(ByteBuffer bb) {
            return new I32_GE_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_GE_S;
        }
    }

    record I32_GE_U() implements Instruction {
        public static I32_GE_U read(ByteBuffer bb) {
            return new I32_GE_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_GE_U;
        }
    }

    record I64_EQZ() implements Instruction {
        public static I64_EQZ read(ByteBuffer bb) {
            return new I64_EQZ();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_EQZ;
        }
    }

    record I64_EQ() implements Instruction {
        public static I64_EQ read(ByteBuffer bb) {
            return new I64_EQ();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_EQ;
        }
    }

    record I64_NE() implements Instruction {
        public static I64_NE read(ByteBuffer bb) {
            return new I64_NE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_NE;
        }
    }

    record I64_LT_S() implements Instruction {
        public static I64_LT_S read(ByteBuffer bb) {
            return new I64_LT_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_LT_S;
        }
    }

    record I64_LT_U() implements Instruction {
        public static I64_LT_U read(ByteBuffer bb) {
            return new I64_LT_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_LT_U;
        }
    }

    record I64_GT_S() implements Instruction {
        public static I64_GT_S read(ByteBuffer bb) {
            return new I64_GT_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_GT_S;
        }
    }

    record I64_GT_U() implements Instruction {
        public static I64_GT_U read(ByteBuffer bb) {
            return new I64_GT_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_GT_U;
        }
    }

    record I64_LE_S() implements Instruction {
        public static I64_LE_S read(ByteBuffer bb) {
            return new I64_LE_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_LE_S;
        }
    }

    record I64_LE_U() implements Instruction {
        public static I64_LE_U read(ByteBuffer bb) {
            return new I64_LE_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_LE_U;
        }
    }

    record I64_GE_S() implements Instruction {
        public static I64_GE_S read(ByteBuffer bb) {
            return new I64_GE_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_GE_S;
        }
    }

    record I64_GE_U() implements Instruction {
        public static I64_GE_U read(ByteBuffer bb) {
            return new I64_GE_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_GE_U;
        }
    }

    record F32_EQ() implements Instruction {
        public static F32_EQ read(ByteBuffer bb) {
            return new F32_EQ();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_EQ;
        }
    }

    record F32_NE() implements Instruction {
        public static F32_NE read(ByteBuffer bb) {
            return new F32_NE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_NE;
        }
    }

    record F32_LT() implements Instruction {
        public static F32_LT read(ByteBuffer bb) {
            return new F32_LT();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_LT;
        }
    }

    record F32_GT() implements Instruction {
        public static F32_GT read(ByteBuffer bb) {
            return new F32_GT();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_GT;
        }
    }

    record F32_LE() implements Instruction {
        public static F32_LE read(ByteBuffer bb) {
            return new F32_LE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_LE;
        }
    }

    record F32_GE() implements Instruction {
        public static F32_GE read(ByteBuffer bb) {
            return new F32_GE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_GE;
        }
    }

    record F64_EQ() implements Instruction {
        public static F64_EQ read(ByteBuffer bb) {
            return new F64_EQ();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_EQ;
        }
    }

    record F64_NE() implements Instruction {
        public static F64_NE read(ByteBuffer bb) {
            return new F64_NE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_NE;
        }
    }

    record F64_LT() implements Instruction {
        public static F64_LT read(ByteBuffer bb) {
            return new F64_LT();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_LT;
        }
    }

    record F64_GT() implements Instruction {
        public static F64_GT read(ByteBuffer bb) {
            return new F64_GT();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_GT;
        }
    }

    record F64_LE() implements Instruction {
        public static F64_LE read(ByteBuffer bb) {
            return new F64_LE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_LE;
        }
    }

    record F64_GE() implements Instruction {
        public static F64_GE read(ByteBuffer bb) {
            return new F64_GE();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_GE;
        }
    }

    record I32_CLZ() implements Instruction {
        public static I32_CLZ read(ByteBuffer bb) {
            return new I32_CLZ();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_CLZ;
        }
    }

    record I32_CTZ() implements Instruction {
        public static I32_CTZ read(ByteBuffer bb) {
            return new I32_CTZ();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_CTZ;
        }
    }

    record I32_POPCNT() implements Instruction {
        public static I32_POPCNT read(ByteBuffer bb) {
            return new I32_POPCNT();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_POPCNT;
        }
    }

    record I32_ADD() implements Instruction {
        public static I32_ADD read(ByteBuffer bb) {
            return new I32_ADD();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_ADD;
        }
    }

    record I32_SUB() implements Instruction {
        public static I32_SUB read(ByteBuffer bb) {
            return new I32_SUB();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_SUB;
        }
    }

    record I32_MUL() implements Instruction {
        public static I32_MUL read(ByteBuffer bb) {
            return new I32_MUL();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_MUL;
        }
    }

    record I32_DIV_S() implements Instruction {
        public static I32_DIV_S read(ByteBuffer bb) {
            return new I32_DIV_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_DIV_S;
        }
    }

    record I32_DIV_U() implements Instruction {
        public static I32_DIV_U read(ByteBuffer bb) {
            return new I32_DIV_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_DIV_U;
        }
    }

    record I32_REM_S() implements Instruction {
        public static I32_REM_S read(ByteBuffer bb) {
            return new I32_REM_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_REM_S;
        }
    }

    record I32_REM_U() implements Instruction {
        public static I32_REM_U read(ByteBuffer bb) {
            return new I32_REM_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_REM_U;
        }
    }

    record I32_AND() implements Instruction {
        public static I32_AND read(ByteBuffer bb) {
            return new I32_AND();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_AND;
        }
    }

    record I32_OR() implements Instruction {
        public static I32_OR read(ByteBuffer bb) {
            return new I32_OR();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_OR;
        }
    }

    record I32_XOR() implements Instruction {
        public static I32_XOR read(ByteBuffer bb) {
            return new I32_XOR();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_XOR;
        }
    }

    record I32_SHL() implements Instruction {
        public static I32_SHL read(ByteBuffer bb) {
            return new I32_SHL();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_SHL;
        }
    }

    record I32_SHR_S() implements Instruction {
        public static I32_SHR_S read(ByteBuffer bb) {
            return new I32_SHR_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_SHR_S;
        }
    }

    record I32_SHR_U() implements Instruction {
        public static I32_SHR_U read(ByteBuffer bb) {
            return new I32_SHR_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_SHR_U;
        }
    }

    record I32_ROTL() implements Instruction {
        public static I32_ROTL read(ByteBuffer bb) {
            return new I32_ROTL();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_ROTL;
        }
    }

    record I32_ROTR() implements Instruction {
        public static I32_ROTR read(ByteBuffer bb) {
            return new I32_ROTR();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I32_ROTR;
        }
    }

    record I64_CLZ() implements Instruction {
        public static I64_CLZ read(ByteBuffer bb) {
            return new I64_CLZ();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_CLZ;
        }
    }

    record I64_CTZ() implements Instruction {
        public static I64_CTZ read(ByteBuffer bb) {
            return new I64_CTZ();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_CTZ;
        }
    }

    record I64_POPCNT() implements Instruction {
        public static I64_POPCNT read(ByteBuffer bb) {
            return new I64_POPCNT();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_POPCNT;
        }
    }

    record I64_ADD() implements Instruction {
        public static I64_ADD read(ByteBuffer bb) {
            return new I64_ADD();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_ADD;
        }
    }

    record I64_SUB() implements Instruction {
        public static I64_SUB read(ByteBuffer bb) {
            return new I64_SUB();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_SUB;
        }
    }

    record I64_MUL() implements Instruction {
        public static I64_MUL read(ByteBuffer bb) {
            return new I64_MUL();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_MUL;
        }
    }

    record I64_DIV_S() implements Instruction {
        public static I64_DIV_S read(ByteBuffer bb) {
            return new I64_DIV_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_DIV_S;
        }
    }

    record I64_DIV_U() implements Instruction {
        public static I64_DIV_U read(ByteBuffer bb) {
            return new I64_DIV_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_DIV_U;
        }
    }

    record I64_REM_S() implements Instruction {
        public static I64_REM_S read(ByteBuffer bb) {
            return new I64_REM_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_REM_S;
        }
    }

    record I64_REM_U() implements Instruction {
        public static I64_REM_U read(ByteBuffer bb) {
            return new I64_REM_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_REM_U;
        }
    }

    record I64_AND() implements Instruction {
        public static I64_AND read(ByteBuffer bb) {
            return new I64_AND();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_AND;
        }
    }

    record I64_OR() implements Instruction {
        public static I64_OR read(ByteBuffer bb) {
            return new I64_OR();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_OR;
        }
    }

    record I64_XOR() implements Instruction {
        public static I64_XOR read(ByteBuffer bb) {
            return new I64_XOR();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_XOR;
        }
    }

    record I64_SHL() implements Instruction {
        public static I64_SHL read(ByteBuffer bb) {
            return new I64_SHL();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_SHL;
        }
    }

    record I64_SHR_S() implements Instruction {
        public static I64_SHR_S read(ByteBuffer bb) {
            return new I64_SHR_S();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_SHR_S;
        }
    }

    record I64_SHR_U() implements Instruction {
        public static I64_SHR_U read(ByteBuffer bb) {
            return new I64_SHR_U();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_SHR_U;
        }
    }

    record I64_ROTL() implements Instruction {
        public static I64_ROTL read(ByteBuffer bb) {
            return new I64_ROTL();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_ROTL;
        }
    }

    record I64_ROTR() implements Instruction {
        public static I64_ROTR read(ByteBuffer bb) {
            return new I64_ROTR();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.I64_ROTR;
        }
    }

    record F32_ABS() implements Instruction {
        public static F32_ABS read(ByteBuffer bb) {
            return new F32_ABS();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_ABS;
        }
    }

    record F32_NEG() implements Instruction {
        public static F32_NEG read(ByteBuffer bb) {
            return new F32_NEG();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_NEG;
        }
    }

    record F32_CEIL() implements Instruction {
        public static F32_CEIL read(ByteBuffer bb) {
            return new F32_CEIL();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_CEIL;
        }
    }

    record F32_FLOOR() implements Instruction {
        public static F32_FLOOR read(ByteBuffer bb) {
            return new F32_FLOOR();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_FLOOR;
        }
    }

    record F32_TRUNC() implements Instruction {
        public static F32_TRUNC read(ByteBuffer bb) {
            return new F32_TRUNC();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_TRUNC;
        }
    }

    record F32_NEAREST() implements Instruction {
        public static F32_NEAREST read(ByteBuffer bb) {
            return new F32_NEAREST();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_NEAREST;
        }
    }

    record F32_SQRT() implements Instruction {
        public static F32_SQRT read(ByteBuffer bb) {
            return new F32_SQRT();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_SQRT;
        }
    }

    record F32_ADD() implements Instruction {
        public static F32_ADD read(ByteBuffer bb) {
            return new F32_ADD();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_ADD;
        }
    }

    record F32_SUB() implements Instruction {
        public static F32_SUB read(ByteBuffer bb) {
            return new F32_SUB();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_SUB;
        }
    }

    record F32_MUL() implements Instruction {
        public static F32_MUL read(ByteBuffer bb) {
            return new F32_MUL();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_MUL;
        }
    }

    record F32_DIV() implements Instruction {
        public static F32_DIV read(ByteBuffer bb) {
            return new F32_DIV();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_DIV;
        }
    }

    record F32_MIN() implements Instruction {
        public static F32_MIN read(ByteBuffer bb) {
            return new F32_MIN();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_MIN;
        }
    }

    record F32_MAX() implements Instruction {
        public static F32_MAX read(ByteBuffer bb) {
            return new F32_MAX();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_MAX;
        }
    }

    record F32_COPYSIGN() implements Instruction {
        public static F32_COPYSIGN read(ByteBuffer bb) {
            return new F32_COPYSIGN();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F32_COPYSIGN;
        }
    }

    record F64_ABS() implements Instruction {
        public static F64_ABS read(ByteBuffer bb) {
            return new F64_ABS();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_ABS;
        }
    }

    record F64_NEG() implements Instruction {
        public static F64_NEG read(ByteBuffer bb) {
            return new F64_NEG();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_NEG;
        }
    }

    record F64_CEIL() implements Instruction {
        public static F64_CEIL read(ByteBuffer bb) {
            return new F64_CEIL();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_CEIL;
        }
    }

    record F64_FLOOR() implements Instruction {
        public static F64_FLOOR read(ByteBuffer bb) {
            return new F64_FLOOR();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_FLOOR;
        }
    }

    record F64_TRUNC() implements Instruction {
        public static F64_TRUNC read(ByteBuffer bb) {
            return new F64_TRUNC();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_TRUNC;
        }
    }

    record F64_NEAREST() implements Instruction {
        public static F64_NEAREST read(ByteBuffer bb) {
            return new F64_NEAREST();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_NEAREST;
        }
    }

    record F64_SQRT() implements Instruction {
        public static F64_SQRT read(ByteBuffer bb) {
            return new F64_SQRT();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_SQRT;
        }
    }

    record F64_ADD() implements Instruction {
        public static F64_ADD read(ByteBuffer bb) {
            return new F64_ADD();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_ADD;
        }
    }

    record F64_SUB() implements Instruction {
        public static F64_SUB read(ByteBuffer bb) {
            return new F64_SUB();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_SUB;
        }
    }

    record F64_MUL() implements Instruction {
        public static F64_MUL read(ByteBuffer bb) {
            return new F64_MUL();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_MUL;
        }
    }

    record F64_DIV() implements Instruction {
        public static F64_DIV read(ByteBuffer bb) {
            return new F64_DIV();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_DIV;
        }
    }

    record F64_MIN() implements Instruction {
        public static F64_MIN read(ByteBuffer bb) {
            return new F64_MIN();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_MIN;
        }
    }

    record F64_MAX() implements Instruction {
        public static F64_MAX read(ByteBuffer bb) {
            return new F64_MAX();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_MAX;
        }
    }

    record F64_COPYSIGN() implements Instruction {
        public static F64_COPYSIGN read(ByteBuffer bb) {
            return new F64_COPYSIGN();
        }

        public WebAssemblyOpcode opcode() {
            return WebAssemblyOpcode.F64_COPYSIGN;
        }
    }

}
