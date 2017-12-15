const builtin = @import("builtin");
const TypeId = builtin.TypeId;
const assert = @import("../debug.zig").assert;

pub const e = 2.71828182845904523536028747135266249775724709369995;
pub const pi = 3.14159265358979323846264338327950288419716939937510;

// float.h details
pub const f64_true_min = 4.94065645841246544177e-324;
pub const f64_min = 2.22507385850720138309e-308;
pub const f64_max = 1.79769313486231570815e+308;
pub const f64_epsilon = 2.22044604925031308085e-16;
pub const f64_toint = 1.0 / f64_epsilon;

pub const f32_true_min = 1.40129846432481707092e-45;
pub const f32_min = 1.17549435082228750797e-38;
pub const f32_max = 3.40282346638528859812e+38;
pub const f32_epsilon = 1.1920928955078125e-07;
pub const f32_toint = 1.0 / f32_epsilon;

pub const nan_u32 = u32(0x7F800001);
pub const nan_f32 = @bitCast(f32, nan_u32);

pub const inf_u32 = u32(0x7F800000);
pub const inf_f32 = @bitCast(f32, inf_u32);

pub const nan_u64 = u64(0x7FF << 52) | 1;
pub const nan_f64 = @bitCast(f64, nan_u64);

pub const inf_u64 = u64(0x7FF << 52);
pub const inf_f64 = @bitCast(f64, inf_u64);

pub const nan = @import("nan.zig").nan;
pub const snan = @import("nan.zig").snan;
pub const inf = @import("inf.zig").inf;

pub fn approxEq(comptime T: type, x: T, y: T, epsilon: T) -> bool {
    assert(@typeId(T) == TypeId.Float);
    fabs(x - y) < epsilon
}

// TODO: Hide the following in an internal module.
pub fn forceEval(value: var) {
    const T = @typeOf(value);
    switch (T) {
        f32 => {
            var x: f32 = undefined;
            const p = @ptrCast(&volatile f32, &x);
            *p = x;
        },
        f64 => {
            var x: f64 = undefined;
            const p = @ptrCast(&volatile f64, &x);
            *p = x;
        },
        else => {
            @compileError("forceEval not implemented for " ++ @typeName(T));
        },
    }
}

pub fn raiseInvalid() {
    // Raise INVALID fpu exception
}

pub fn raiseUnderflow() {
    // Raise UNDERFLOW fpu exception
}

pub fn raiseOverflow() {
    // Raise OVERFLOW fpu exception
}

pub fn raiseInexact() {
    // Raise INEXACT fpu exception
}

pub fn raiseDivByZero() {
    // Raise INEXACT fpu exception
}

pub const isNan = @import("isnan.zig").isNan;
pub const isSignalNan = @import("isnan.zig").isSignalNan;
pub const fabs = @import("fabs.zig").fabs;
pub const ceil = @import("ceil.zig").ceil;
pub const floor = @import("floor.zig").floor;
pub const trunc = @import("trunc.zig").trunc;
pub const round = @import("round.zig").round;
pub const frexp = @import("frexp.zig").frexp;
pub const frexp32_result = @import("frexp.zig").frexp32_result;
pub const frexp64_result = @import("frexp.zig").frexp64_result;
pub const modf = @import("modf.zig").modf;
pub const modf32_result = @import("modf.zig").modf32_result;
pub const modf64_result = @import("modf.zig").modf64_result;
pub const copysign = @import("copysign.zig").copysign;
pub const isFinite = @import("isfinite.zig").isFinite;
pub const isInf = @import("isinf.zig").isInf;
pub const isPositiveInf = @import("isinf.zig").isPositiveInf;
pub const isNegativeInf = @import("isinf.zig").isNegativeInf;
pub const isNormal = @import("isnormal.zig").isNormal;
pub const signbit = @import("signbit.zig").signbit;
pub const scalbn = @import("scalbn.zig").scalbn;
pub const pow = @import("pow.zig").pow;
pub const sqrt = @import("sqrt.zig").sqrt;
pub const cbrt = @import("cbrt.zig").cbrt;
pub const acos = @import("acos.zig").acos;
pub const asin = @import("asin.zig").asin;
pub const atan = @import("atan.zig").atan;
pub const atan2 = @import("atan2.zig").atan2;
pub const hypot = @import("hypot.zig").hypot;
pub const exp = @import("exp.zig").exp;
pub const exp2 = @import("exp2.zig").exp2;
pub const expm1 = @import("expm1.zig").expm1;
pub const ilogb = @import("ilogb.zig").ilogb;
pub const ln = @import("ln.zig").ln;
pub const log = @import("log.zig").log;
pub const log2 = @import("log2.zig").log2;
pub const log10 = @import("log10.zig").log10;
pub const log1p = @import("log1p.zig").log1p;
pub const fma = @import("fma.zig").fma;
pub const asinh = @import("asinh.zig").asinh;
pub const acosh = @import("acosh.zig").acosh;
pub const atanh = @import("atanh.zig").atanh;
pub const sinh = @import("sinh.zig").sinh;
pub const cosh = @import("cosh.zig").cosh;
pub const tanh = @import("tanh.zig").tanh;
pub const cos = @import("cos.zig").cos;
pub const sin = @import("sin.zig").sin;
pub const tan = @import("tan.zig").tan;

test "math" {
    _ = @import("nan.zig");
    _ = @import("isnan.zig");
    _ = @import("fabs.zig");
    _ = @import("ceil.zig");
    _ = @import("floor.zig");
    _ = @import("trunc.zig");
    _ = @import("round.zig");
    _ = @import("frexp.zig");
    _ = @import("modf.zig");
    _ = @import("copysign.zig");
    _ = @import("isfinite.zig");
    _ = @import("isinf.zig");
    _ = @import("isnormal.zig");
    _ = @import("signbit.zig");
    _ = @import("scalbn.zig");
    _ = @import("pow.zig");
    _ = @import("sqrt.zig");
    _ = @import("cbrt.zig");
    _ = @import("acos.zig");
    _ = @import("asin.zig");
    _ = @import("atan.zig");
    _ = @import("atan2.zig");
    _ = @import("hypot.zig");
    _ = @import("exp.zig");
    _ = @import("exp2.zig");
    _ = @import("expm1.zig");
    _ = @import("ilogb.zig");
    _ = @import("ln.zig");
    _ = @import("log.zig");
    _ = @import("log2.zig");
    _ = @import("log10.zig");
    _ = @import("log1p.zig");
    _ = @import("fma.zig");
    _ = @import("asinh.zig");
    _ = @import("acosh.zig");
    _ = @import("atanh.zig");
    _ = @import("sinh.zig");
    _ = @import("cosh.zig");
    _ = @import("tanh.zig");
    _ = @import("sin.zig");
    _ = @import("cos.zig");
    _ = @import("tan.zig");
}


pub fn min(x: var, y: var) -> @typeOf(x + y) {
    if (x < y) x else y
}

test "math.min" {
    assert(min(i32(-1), i32(2)) == -1);
}

pub fn max(x: var, y: var) -> @typeOf(x + y) {
    if (x > y) x else y
}

test "math.max" {
    assert(max(i32(-1), i32(2)) == 2);
}

error Overflow;
pub fn mul(comptime T: type, a: T, b: T) -> %T {
    var answer: T = undefined;
    if (@mulWithOverflow(T, a, b, &answer)) error.Overflow else answer
}

error Overflow;
pub fn add(comptime T: type, a: T, b: T) -> %T {
    var answer: T = undefined;
    if (@addWithOverflow(T, a, b, &answer)) error.Overflow else answer
}

error Overflow;
pub fn sub(comptime T: type, a: T, b: T) -> %T {
    var answer: T = undefined;
    if (@subWithOverflow(T, a, b, &answer)) error.Overflow else answer
}

pub fn negate(x: var) -> %@typeOf(x) {
    return sub(@typeOf(x), 0, x);
}

error Overflow;
pub fn shlExact(comptime T: type, a: T, shift_amt: Log2Int(T)) -> %T {
    var answer: T = undefined;
    if (@shlWithOverflow(T, a, shift_amt, &answer)) error.Overflow else answer
}

/// Shifts left. Overflowed bits are truncated.
/// A negative shift amount results in a right shift.
pub fn shl(comptime T: type, a: T, shift_amt: var) -> T {
    const abs_shift_amt = absCast(shift_amt);
    const casted_shift_amt = if (abs_shift_amt >= T.bit_count) return 0 else Log2Int(T)(abs_shift_amt);

    if (@typeOf(shift_amt).is_signed) {
        if (shift_amt >= 0) {
            return a << casted_shift_amt;
        } else {
            return a >> casted_shift_amt;
        }
    }

    return a << casted_shift_amt;
}

test "math.shl" {
    assert(shl(u8, 0b11111111, usize(3)) == 0b11111000);
    assert(shl(u8, 0b11111111, usize(8)) == 0);
    assert(shl(u8, 0b11111111, usize(9)) == 0);
    assert(shl(u8, 0b11111111, isize(-2)) == 0b00111111);
}

/// Shifts right. Overflowed bits are truncated.
/// A negative shift amount results in a lefft shift.
pub fn shr(comptime T: type, a: T, shift_amt: var) -> T {
    const abs_shift_amt = absCast(shift_amt);
    const casted_shift_amt = if (abs_shift_amt >= T.bit_count) return 0 else Log2Int(T)(abs_shift_amt);

    if (@typeOf(shift_amt).is_signed) {
        if (shift_amt >= 0) {
            return a >> casted_shift_amt;
        } else {
            return a << casted_shift_amt;
        }
    }

    return a >> casted_shift_amt;
}

test "math.shr" {
    assert(shr(u8, 0b11111111, usize(3)) == 0b00011111);
    assert(shr(u8, 0b11111111, usize(8)) == 0);
    assert(shr(u8, 0b11111111, usize(9)) == 0);
    assert(shr(u8, 0b11111111, isize(-2)) == 0b11111100);
}

pub fn Log2Int(comptime T: type) -> type {
    @IntType(false, log2(T.bit_count))
}

test "math overflow functions" {
    testOverflow();
    comptime testOverflow();
}

fn testOverflow() {
    assert(%%mul(i32, 3, 4) == 12);
    assert(%%add(i32, 3, 4) == 7);
    assert(%%sub(i32, 3, 4) == -1);
    assert(%%shlExact(i32, 0b11, 4) == 0b110000);
}


error Overflow;
pub fn absInt(x: var) -> %@typeOf(x) {
    const T = @typeOf(x);
    comptime assert(@typeId(T) == builtin.TypeId.Int); // must pass an integer to absInt
    comptime assert(T.is_signed); // must pass a signed integer to absInt
    if (x == @minValue(@typeOf(x)))
        return error.Overflow;
    {
        @setDebugSafety(this, false);
        return if (x < 0) -x else x;
    }
}

test "math.absInt" {
    testAbsInt();
    comptime testAbsInt();
}
fn testAbsInt() {
    assert(%%absInt(i32(-10)) == 10);
    assert(%%absInt(i32(10)) == 10);
}

pub const absFloat = @import("fabs.zig").fabs;

error DivisionByZero;
error Overflow;
pub fn divTrunc(comptime T: type, numerator: T, denominator: T) -> %T {
    @setDebugSafety(this, false);
    if (denominator == 0)
        return error.DivisionByZero;
    if (@typeId(T) == builtin.TypeId.Int and T.is_signed and numerator == @minValue(T) and denominator == -1)
        return error.Overflow;
    return @divTrunc(numerator, denominator);
}

test "math.divTrunc" {
    if (builtin.os == builtin.Os.windows and builtin.arch == builtin.Arch.i386) {
        // TODO get this test passing
        // https://github.com/zig-lang/zig/issues/537
        return;
    }
    testDivTrunc();
    comptime testDivTrunc();
}
fn testDivTrunc() {
    assert(%%divTrunc(i32, 5, 3) == 1);
    assert(%%divTrunc(i32, -5, 3) == -1);
    if (divTrunc(i8, -5, 0)) |_| unreachable else |err| assert(err == error.DivisionByZero);
    if (divTrunc(i8, -128, -1)) |_| unreachable else |err| assert(err == error.Overflow);

    assert(%%divTrunc(f32, 5.0, 3.0) == 1.0);
    assert(%%divTrunc(f32, -5.0, 3.0) == -1.0);
}

error DivisionByZero;
error Overflow;
pub fn divFloor(comptime T: type, numerator: T, denominator: T) -> %T {
    @setDebugSafety(this, false);
    if (denominator == 0)
        return error.DivisionByZero;
    if (@typeId(T) == builtin.TypeId.Int and T.is_signed and numerator == @minValue(T) and denominator == -1)
        return error.Overflow;
    return @divFloor(numerator, denominator);
}

test "math.divFloor" {
    if (builtin.os == builtin.Os.windows and builtin.arch == builtin.Arch.i386) {
        // TODO get this test passing
        // https://github.com/zig-lang/zig/issues/537
        return;
    }
    testDivFloor();
    comptime testDivFloor();
}
fn testDivFloor() {
    assert(%%divFloor(i32, 5, 3) == 1);
    assert(%%divFloor(i32, -5, 3) == -2);
    if (divFloor(i8, -5, 0)) |_| unreachable else |err| assert(err == error.DivisionByZero);
    if (divFloor(i8, -128, -1)) |_| unreachable else |err| assert(err == error.Overflow);

    assert(%%divFloor(f32, 5.0, 3.0) == 1.0);
    assert(%%divFloor(f32, -5.0, 3.0) == -2.0);
}

error DivisionByZero;
error Overflow;
error UnexpectedRemainder;
pub fn divExact(comptime T: type, numerator: T, denominator: T) -> %T {
    @setDebugSafety(this, false);
    if (denominator == 0)
        return error.DivisionByZero;
    if (@typeId(T) == builtin.TypeId.Int and T.is_signed and numerator == @minValue(T) and denominator == -1)
        return error.Overflow;
    const result = @divTrunc(numerator, denominator);
    if (result * denominator != numerator)
        return error.UnexpectedRemainder;
    return result;
}

test "math.divExact" {
    if (builtin.os == builtin.Os.windows and builtin.arch == builtin.Arch.i386) {
        // TODO get this test passing
        // https://github.com/zig-lang/zig/issues/537
        return;
    }
    testDivExact();
    comptime testDivExact();
}
fn testDivExact() {
    assert(%%divExact(i32, 10, 5) == 2);
    assert(%%divExact(i32, -10, 5) == -2);
    if (divExact(i8, -5, 0)) |_| unreachable else |err| assert(err == error.DivisionByZero);
    if (divExact(i8, -128, -1)) |_| unreachable else |err| assert(err == error.Overflow);
    if (divExact(i32, 5, 2)) |_| unreachable else |err| assert(err == error.UnexpectedRemainder);

    assert(%%divExact(f32, 10.0, 5.0) == 2.0);
    assert(%%divExact(f32, -10.0, 5.0) == -2.0);
    if (divExact(f32, 5.0, 2.0)) |_| unreachable else |err| assert(err == error.UnexpectedRemainder);
}

error DivisionByZero;
error NegativeDenominator;
pub fn mod(comptime T: type, numerator: T, denominator: T) -> %T {
    @setDebugSafety(this, false);
    if (denominator == 0)
        return error.DivisionByZero;
    if (denominator < 0)
        return error.NegativeDenominator;
    return @mod(numerator, denominator);
}

test "math.mod" {
    testMod();
    comptime testMod();
}
fn testMod() {
    assert(%%mod(i32, -5, 3) == 1);
    assert(%%mod(i32, 5, 3) == 2);
    if (mod(i32, 10, -1)) |_| unreachable else |err| assert(err == error.NegativeDenominator);
    if (mod(i32, 10, 0)) |_| unreachable else |err| assert(err == error.DivisionByZero);

    assert(%%mod(f32, -5, 3) == 1);
    assert(%%mod(f32, 5, 3) == 2);
    if (mod(f32, 10, -1)) |_| unreachable else |err| assert(err == error.NegativeDenominator);
    if (mod(f32, 10, 0)) |_| unreachable else |err| assert(err == error.DivisionByZero);
}

error DivisionByZero;
error NegativeDenominator;
pub fn rem(comptime T: type, numerator: T, denominator: T) -> %T {
    @setDebugSafety(this, false);
    if (denominator == 0)
        return error.DivisionByZero;
    if (denominator < 0)
        return error.NegativeDenominator;
    return @rem(numerator, denominator);
}

test "math.rem" {
    testRem();
    comptime testRem();
}
fn testRem() {
    assert(%%rem(i32, -5, 3) == -2);
    assert(%%rem(i32, 5, 3) == 2);
    if (rem(i32, 10, -1)) |_| unreachable else |err| assert(err == error.NegativeDenominator);
    if (rem(i32, 10, 0)) |_| unreachable else |err| assert(err == error.DivisionByZero);

    assert(%%rem(f32, -5, 3) == -2);
    assert(%%rem(f32, 5, 3) == 2);
    if (rem(f32, 10, -1)) |_| unreachable else |err| assert(err == error.NegativeDenominator);
    if (rem(f32, 10, 0)) |_| unreachable else |err| assert(err == error.DivisionByZero);
}

/// Returns the absolute value of the integer parameter.
/// Result is an unsigned integer.
pub fn absCast(x: var) -> @IntType(false, @typeOf(x).bit_count) {
    const uint = @IntType(false, @typeOf(x).bit_count);
    if (x >= 0)
        return uint(x);

    return uint(-(x + 1)) + 1;
}

test "math.absCast" {
    assert(absCast(i32(-999)) == 999);
    assert(@typeOf(absCast(i32(-999))) == u32);

    assert(absCast(i32(999)) == 999);
    assert(@typeOf(absCast(i32(999))) == u32);

    assert(absCast(i32(@minValue(i32))) == -@minValue(i32));
    assert(@typeOf(absCast(i32(@minValue(i32)))) == u32);
}

/// Returns the negation of the integer parameter.
/// Result is a signed integer.
error Overflow;
pub fn negateCast(x: var) -> %@IntType(true, @typeOf(x).bit_count) {
    if (@typeOf(x).is_signed)
        return negate(x);

    const int = @IntType(true, @typeOf(x).bit_count);
    if (x > -@minValue(int))
        return error.Overflow;

    if (x == -@minValue(int))
        return @minValue(int);

    return -int(x);
}

test "math.negateCast" {
    assert(%%negateCast(u32(999)) == -999);
    assert(@typeOf(%%negateCast(u32(999))) == i32);

    assert(%%negateCast(u32(-@minValue(i32))) == @minValue(i32));
    assert(@typeOf(%%negateCast(u32(-@minValue(i32)))) == i32);

    if (negateCast(u32(@maxValue(i32) + 10))) |_| unreachable else |err| assert(err == error.Overflow);
}

/// Cast an integer to a different integer type. If the value doesn't fit, 
/// return an error.
error Overflow;
pub fn cast(comptime T: type, x: var) -> %T {
    comptime assert(@typeId(T) == builtin.TypeId.Int); // must pass an integer
    if (x > @maxValue(T)) {
        return error.Overflow;
    } else {
        return T(x);
    }
}

pub fn floorPowerOfTwo(comptime T: type, value: T) -> T {
    var x = value;

    comptime var i = 1;
    inline while(T.bit_count > i) : (i *= 2) {
        x |= (x >> i);
    }

    return x - (x >> 1);
}

test "math.floorPowerOfTwo" {
    testFloorPowerOfTwo();
    comptime testFloorPowerOfTwo();
}

fn testFloorPowerOfTwo() {
    assert(floorPowerOfTwo(u32, 63) == 32);
    assert(floorPowerOfTwo(u32, 64) == 64);
    assert(floorPowerOfTwo(u32, 65) == 64);
    assert(floorPowerOfTwo(u4, 7) == 4);
    assert(floorPowerOfTwo(u4, 8) == 8);
    assert(floorPowerOfTwo(u4, 9) == 8);
}
