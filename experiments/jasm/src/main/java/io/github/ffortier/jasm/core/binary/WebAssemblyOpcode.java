package io.github.ffortier.jasm.core.binary;

import java.nio.ByteBuffer;
import java.util.function.Function;

public enum WebAssemblyOpcode {
    // Control Flow Operators
    UNREACHABLE(0x00, Instruction.UNREACHABLE::read),
    NOP(0x01, Instruction.NOP::read),
    BLOCK(0x02, Instruction.BLOCK::read),
    LOOP(0x03, Instruction.LOOP::read),
    IF(0x04, Instruction.IF::read),
    ELSE(0x05, Instruction.ELSE::read),
    END(0x0b, Instruction.END::read),
    BR(0x0c, Instruction.BR::read),
    BR_IF(0x0d, Instruction.BR_IF::read),
    BR_TABLE(0x0e, Instruction.BR_TABLE::read),
    RETURN(0x0f, Instruction.RETURN::read),

    // Call Operators
    CALL(0x10, Instruction.CALL::read),
    CALL_INDIRECT(0x11, Instruction.CALL_INDIRECT::read),

    // Parametric Operators
    DROP(0x1a, Instruction.DROP::read),
    SELECT(0x1b, Instruction.SELECT::read),

    // Variable Access
    LOCAL_GET(0x20, Instruction.LOCAL_GET::read),
    LOCAL_SET(0x21, Instruction.LOCAL_SET::read),
    LOCAL_TEE(0x22, Instruction.LOCAL_TEE::read),
    GLOBAL_GET(0x23, Instruction.GLOBAL_GET::read),
    GLOBAL_SET(0x24, Instruction.GLOBAL_SET::read),

    // Memory Related Operators
    I32_LOAD(0x28, Instruction.I32_LOAD::read),
    I64_LOAD(0x29, Instruction.I64_LOAD::read),
    F32_LOAD(0x2a, Instruction.F32_LOAD::read),
    F64_LOAD(0x2b, Instruction.F64_LOAD::read),
    I32_LOAD8_S(0x2c, Instruction.I32_LOAD8_S::read),
    I32_LOAD8_U(0x2d, Instruction.I32_LOAD8_U::read),
    I32_LOAD16_S(0x2e, Instruction.I32_LOAD16_S::read),
    I32_LOAD16_U(0x2f, Instruction.I32_LOAD16_U::read),
    I64_LOAD8_S(0x30, Instruction.I64_LOAD8_S::read),
    I64_LOAD8_U(0x31, Instruction.I64_LOAD8_U::read),
    I64_LOAD16_S(0x32, Instruction.I64_LOAD16_S::read),
    I64_LOAD16_U(0x33, Instruction.I64_LOAD16_U::read),
    I64_LOAD32_S(0x34, Instruction.I64_LOAD32_S::read),
    I64_LOAD32_U(0x35, Instruction.I64_LOAD32_U::read),
    I32_STORE(0x36, Instruction.I32_STORE::read),
    I64_STORE(0x37, Instruction.I64_STORE::read),
    F32_STORE(0x38, Instruction.F32_STORE::read),
    F64_STORE(0x39, Instruction.F64_STORE::read),
    I32_STORE8(0x3a, Instruction.I32_STORE8::read),
    I32_STORE16(0x3b, Instruction.I32_STORE16::read),
    I64_STORE8(0x3c, Instruction.I64_STORE8::read),
    I64_STORE16(0x3d, Instruction.I64_STORE16::read),
    I64_STORE32(0x3e, Instruction.I64_STORE32::read),
    MEMORY_SIZE(0x3f, Instruction.MEMORY_SIZE::read),
    MEMORY_GROW(0x40, Instruction.MEMORY_GROW::read),

    // Constants
    I32_CONST(0x41, Instruction.I32_CONST::read),
    I64_CONST(0x42, Instruction.I64_CONST::read),
    F32_CONST(0x43, Instruction.F32_CONST::read),
    F64_CONST(0x44, Instruction.F64_CONST::read),

    // Comparison Operators
    I32_EQZ(0x45, Instruction.I32_EQZ::read),
    I32_EQ(0x46, Instruction.I32_EQ::read),
    I32_NE(0x47, Instruction.I32_NE::read),
    I32_LT_S(0x48, Instruction.I32_LT_S::read),
    I32_LT_U(0x49, Instruction.I32_LT_U::read),
    I32_GT_S(0x4a, Instruction.I32_GT_S::read),
    I32_GT_U(0x4b, Instruction.I32_GT_U::read),
    I32_LE_S(0x4c, Instruction.I32_LE_S::read),
    I32_LE_U(0x4d, Instruction.I32_LE_U::read),
    I32_GE_S(0x4e, Instruction.I32_GE_S::read),
    I32_GE_U(0x4f, Instruction.I32_GE_U::read),
    I64_EQZ(0x50, Instruction.I64_EQZ::read),
    I64_EQ(0x51, Instruction.I64_EQ::read),
    I64_NE(0x52, Instruction.I64_NE::read),
    I64_LT_S(0x53, Instruction.I64_LT_S::read),
    I64_LT_U(0x54, Instruction.I64_LT_U::read),
    I64_GT_S(0x55, Instruction.I64_GT_S::read),
    I64_GT_U(0x56, Instruction.I64_GT_U::read),
    I64_LE_S(0x57, Instruction.I64_LE_S::read),
    I64_LE_U(0x58, Instruction.I64_LE_U::read),
    I64_GE_S(0x59, Instruction.I64_GE_S::read),
    I64_GE_U(0x5a, Instruction.I64_GE_U::read),
    F32_EQ(0x5b, Instruction.F32_EQ::read),
    F32_NE(0x5c, Instruction.F32_NE::read),
    F32_LT(0x5d, Instruction.F32_LT::read),
    F32_GT(0x5e, Instruction.F32_GT::read),
    F32_LE(0x5f, Instruction.F32_LE::read),
    F32_GE(0x60, Instruction.F32_GE::read),
    F64_EQ(0x61, Instruction.F64_EQ::read),
    F64_NE(0x62, Instruction.F64_NE::read),
    F64_LT(0x63, Instruction.F64_LT::read),
    F64_GT(0x64, Instruction.F64_GT::read),
    F64_LE(0x65, Instruction.F64_LE::read),
    F64_GE(0x66, Instruction.F64_GE::read),

    // Numeric Operators
    I32_CLZ(0x67, Instruction.I32_CLZ::read),
    I32_CTZ(0x68, Instruction.I32_CTZ::read),
    I32_POPCNT(0x69, Instruction.I32_POPCNT::read),
    I32_ADD(0x6a, Instruction.I32_ADD::read),
    I32_SUB(0x6b, Instruction.I32_SUB::read),
    I32_MUL(0x6c, Instruction.I32_MUL::read),
    I32_DIV_S(0x6d, Instruction.I32_DIV_S::read),
    I32_DIV_U(0x6e, Instruction.I32_DIV_U::read),
    I32_REM_S(0x6f, Instruction.I32_REM_S::read),
    I32_REM_U(0x70, Instruction.I32_REM_U::read),
    I32_AND(0x71, Instruction.I32_AND::read),
    I32_OR(0x72, Instruction.I32_OR::read),
    I32_XOR(0x73, Instruction.I32_XOR::read),
    I32_SHL(0x74, Instruction.I32_SHL::read),
    I32_SHR_S(0x75, Instruction.I32_SHR_S::read),
    I32_SHR_U(0x76, Instruction.I32_SHR_U::read),
    I32_ROTL(0x77, Instruction.I32_ROTL::read),
    I32_ROTR(0x78, Instruction.I32_ROTR::read),
    I64_CLZ(0x79, Instruction.I64_CLZ::read),
    I64_CTZ(0x7a, Instruction.I64_CTZ::read),
    I64_POPCNT(0x7b, Instruction.I64_POPCNT::read),
    I64_ADD(0x7c, Instruction.I64_ADD::read),
    I64_SUB(0x7d, Instruction.I64_SUB::read),
    I64_MUL(0x7e, Instruction.I64_MUL::read),
    I64_DIV_S(0x7f, Instruction.I64_DIV_S::read),
    I64_DIV_U(0x80, Instruction.I64_DIV_U::read),
    I64_REM_S(0x81, Instruction.I64_REM_S::read),
    I64_REM_U(0x82, Instruction.I64_REM_U::read),
    I64_AND(0x83, Instruction.I64_AND::read),
    I64_OR(0x84, Instruction.I64_OR::read),
    I64_XOR(0x85, Instruction.I64_XOR::read),
    I64_SHL(0x86, Instruction.I64_SHL::read),
    I64_SHR_S(0x87, Instruction.I64_SHR_S::read),
    I64_SHR_U(0x88, Instruction.I64_SHR_U::read),
    I64_ROTL(0x89, Instruction.I64_ROTL::read),
    I64_ROTR(0x8a, Instruction.I64_ROTR::read),
    F32_ABS(0x8b, Instruction.F32_ABS::read),
    F32_NEG(0x8c, Instruction.F32_NEG::read),
    F32_CEIL(0x8d, Instruction.F32_CEIL::read),
    F32_FLOOR(0x8e, Instruction.F32_FLOOR::read),
    F32_TRUNC(0x8f, Instruction.F32_TRUNC::read),
    F32_NEAREST(0x90, Instruction.F32_NEAREST::read),
    F32_SQRT(0x91, Instruction.F32_SQRT::read),
    F32_ADD(0x92, Instruction.F32_ADD::read),
    F32_SUB(0x93, Instruction.F32_SUB::read),
    F32_MUL(0x94, Instruction.F32_MUL::read),
    F32_DIV(0x95, Instruction.F32_DIV::read),
    F32_MIN(0x96, Instruction.F32_MIN::read),
    F32_MAX(0x97, Instruction.F32_MAX::read),
    F32_COPYSIGN(0x98, Instruction.F32_COPYSIGN::read),
    F64_ABS(0x99, Instruction.F64_ABS::read),
    F64_NEG(0x9a, Instruction.F64_NEG::read),
    F64_CEIL(0x9b, Instruction.F64_CEIL::read),
    F64_FLOOR(0x9c, Instruction.F64_FLOOR::read),
    F64_TRUNC(0x9d, Instruction.F64_TRUNC::read),
    F64_NEAREST(0x9e, Instruction.F64_NEAREST::read),
    F64_SQRT(0x9f, Instruction.F64_SQRT::read),
    F64_ADD(0xa0, Instruction.F64_ADD::read),
    F64_SUB(0xa1, Instruction.F64_SUB::read),
    F64_MUL(0xa2, Instruction.F64_MUL::read),
    F64_DIV(0xa3, Instruction.F64_DIV::read),
    F64_MIN(0xa4, Instruction.F64_MIN::read),
    F64_MAX(0xa5, Instruction.F64_MAX::read),
    F64_COPYSIGN(0xa6, Instruction.F64_COPYSIGN::read),
    ;

    private final int value;
    private Function<ByteBuffer, ? extends Instruction> read;

    WebAssemblyOpcode(int value, Function<ByteBuffer, ? extends Instruction> read) {
        this.value = value;
        this.read = read;
    }

    public int value() {
        return value;
    }

    public Instruction read(ByteBuffer bb) {
        return this.read.apply(bb);
    }

    public String toString() {
        return "%s(%02x)".formatted(this.name(), this.value());
    }

    public static WebAssemblyOpcode from(int b) {
        for (final var opcode : WebAssemblyOpcode.values()) {
            if (opcode.value == b) {
                return opcode;
            }
        }
        throw new IllegalArgumentException("Unknown opcode %x".formatted(b));
    }
}