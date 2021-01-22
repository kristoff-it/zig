// SPDX-License-Identifier: MIT
// Copyright (c) 2015-2021 Zig Contributors
// This file is part of [zig](https://ziglang.org/), which is MIT licensed.
// The MIT license requires this copyright notice to be included in all copies
// and substantial portions of the software.

const std = @import("../../std.zig");
const atomic = @import("../atomic.zig");

const testing = std.testing;
const builtin = std.builtin;
const assert = std.debug.assert;
const helgrind: ?type = if (builtin.valgrind_support) std.valgrind.helgrind else null;

pub fn Mutex(comptime Futex: anytype) type {
    return extern struct {
        state: State = .unlocked,

        const Self = @This();
        const State = enum(u32) {
            unlocked,
            locked,
            contended,
        };

        pub fn deinit(self: *Self) void {
            if (helgrind) |hg| {
                hg.annotateHappensBeforeForgetAll(@ptrToInt(self));
            }

            self.* = undefined;
        }

        pub fn tryAcquire(self: *Self) ?Held {
            if (atomic.compareAndSwap(
                &self.state,
                .unlocked,
                .locked,
                .Acquire,
                .Relaxed,
            )) |failed| {
                return null;
            }

            if (helgrind) |hg| {
                hg.annotateHappensAfter(@ptrToInt(self));
            }

            return Held{ .mutex = self };
        }

        pub fn tryAcquireFor(self: *Self, duration: u64) error{TimedOut}!Held {
            return self.acquireInner(Futex.now() + duration);
        }

        pub fn tryAcquireUntil(self: *Self, deadline: u64) error{TimedOut}!Held {
            return self.acquireInner(deadline);
        }

        pub fn acquire(self: *Self) Held {
            return self.acquireInner(null) catch unreachable;
        }

        fn acquireInner(self: *Self, deadline: ?u64) error{TimedOut}!Held {
            switch (atomic.swap(&self.state, .locked, .Acquire)) {
                .unlocked => {},
                else => |state| try self.acquireSlow(state, deadline),
            }

            if (helgrind) |hg| {
                hg.annotateHappensAfter(@ptrToInt(self));
            }

            return Held{ .mutex = self };
        }

        fn acquireSlow(self: *Self, current_state: State, deadline: ?u64) error{TimedOut}!void {
            @setCold(true);
            var state = 

            var adaptive_spin: usize = 100;
            while (adaptive_spin > 0) : (adaptive_spin -= 1) {
                state = atomic.tryCompareAndSwap(
                    &self.state,
                    .unlocked,
                    current_state,
                    .Acquire,
                    .Relaxed,
                ) orelse return;

                if (state == .contended) {
                    break;
                }

                var spin = std.math.min(32, std.math.max(8, adaptive_spin));
                while (spin > 0) : (spin -= 1) {
                    atomic.spinLoopHint();
                }
            }

            while (true) {
                const state = atomic.swap(&self.state, .contended, .Acquire);
                if (state == .unlocked) {
                    return;
                }

                const ptr = @ptrCast(*const u32, &self.state);
                const expect = @enumToInt(State.contended);
                try Futex.wait(ptr, expect, deadline);
            }
        }

        pub const Held = extern struct {
            mutex: *Self,

            pub fn release(self: Held) void {
                if (helgrind) |hg| {
                    hg.annotateHappensBefore(@ptrToInt(self));
                }

                switch (atomic.swap(&self.mutex.state, .unlocked, .Release)) {
                    .unlocked => unreachable,
                    .locked => {},
                    .contended => self.releaseSlow(),
                }
            }

            fn releaseSlow(self: Held) void {
                @setCold(true);

                const ptr = @ptrCast(*const u32, &self.mutex.state);
                Futex.notifyOne(ptr);
            }
        };
    };
}

/// This has the sematics as `Mutex`, however it does not actually do any
/// synchronization. Operations are safety-checked no-ops.
pub const DebugMutex = extern struct {
    is_locked: @TypeOf(init) = init,

    const Self = @This();
    const init = if (std.debug.runtime_safety) false else {};

    pub fn deinit(self: *Self) void {
        self.* = undefined;
    }

    pub fn tryAcquire(self: *Self) ?Held {
        if (std.debug.runtime_safety) {
            if (self.is_locked) return null;
            self.is_locked = true;
        }

        return Held{ .mutex = self };
    }

    pub fn tryAcquireFor(self: *Self, duration: u64) error{TimedOut}!Held {
        return self.tryAcquire() orelse {
            std.time.sleep(duration);
            return error.TimedOut;
        };
    }

    pub fn tryAcquireUntil(self: *Self, deadline: u64) error{TimedOut}!Held {
        return self.tryAcquire() orelse {
            const now = std.time.now();
            if (now < deadline) {
                std.time.sleep(deadline - now);
            }
            return error.TimedOut;
        };
    }

    pub fn acquire(self: *Self) Held {
        return self.tryAcquire() orelse @panic("deadlock detected");
    }

    pub const Held = extern struct {
        mutex: *Self,

        pub fn release(self: Held) void {
            if (std.debug.runtime_safety) {
                assert(self.mutex.is_locked);
                self.mutex.is_locked = false;
            }
        }
    };
};

test "Mutex" {
    inline for (.{
        .{DebugMutex},
        .{Mutex(std.sync.futex.os)},
        .{Mutex(std.sync.futex.spin)},
        .{Mutex(std.sync.futex.event)},
    }) |config| {
        try testMutexConfig(config);
    }
}

fn testMutexConfig(config: anytype) !void {
    const TestMutex = config[0];

    {
        var mutex = TestMutex{};
        defer mutex.deinit();

        var held = mutex.tryAcquire() orelse unreachable;
        testing.expectEqual(mutex.tryAcquire(), null);
        held.release();

        held = mutex.acquire();
        defer held.release();

        const delay = 1 * std.time.ns_per_ms;
        testing.expectError(error.TimedOut, mutex.tryAcquireFor(delay));
        testing.expectError(error.TimedOut, mutex.tryAcquireUntil(std.time.now() + delay));
    }

    if (std.io.is_async) return;
    if (std.builtin.single_threaded) return;

    const Contention = struct {
        index: usize = 0,
        case: Case = undefined,
        start_event: std.sync.ResetEvent = .{},
        counters: [num_counters]Counter = undefined,

        const Self = @This();
        const num_counters = 100;
        const counters_init = [_]Counter{Counter{}} ** num_counters;

        const Counter = struct {
            mutex: TestMutex = .{},
            remaining: u128 = 10000,

            fn tryDecr(self: *Counter) bool {
                const held = self.mutex.acquire();
                defer held.release();

                if (self.remaining == 0) {
                    return false;
                }

                self.remaining -= 1;
                return true;
            }
        };

        const Case = union(enum){
            random: Random,
            high: High,
            forced: Forced,
            low: Low,

            /// The common case of many threads generally not touching other thread's Mutexes
            const Low = struct {
                fn setup(_: @This(), self: *Self) void {
                    self.counters = counters_init;
                    self.index = 0;
                }

                fn run(_: @This(), self: *Self) void {
                    const local_index = atomic.fetchAdd(&self.index, 1, .SeqCst);
                    const local_counter = &self.counters[local_index];
                    const check_remote_every = 100;

                    var iter: usize = 0;
                    var seed: usize = undefined;
                    var prng = std.rand.DefaultPrng.init(@ptrToInt(&seed));

                    while (local_counter.tryDecr()) : (iter += 1) {
                        if (iter % check_remote_every == 0) {
                            const remote_index = prng.random.uintLessThan(usize, self.counters.len);
                            const remote_counter = &self.counters[remote_index];
                            _ = remote_counter.tryDecr();
                        }
                    }
                }
            };

            /// The extreme case of many threads fighting over the same Mutex.
            const High = struct {
                fn setup(_: @This(), self: *Self) void {
                    self.counters[0] = Counter{};
                    self.counters[0].remaining = 500_000;
                }

                fn run(_: @This(), self: *Self) void {
                    while (self.counters[0].tryDecr()) {
                        atomic.spinLoopHint();
                    }
                }
            };

            /// The slightly-less extreme case of many threads fighting over the same Mutex.
            /// But they all eventually do an equal amount of work.
            const Forced = struct {
                const local_iters = 100_000;

                fn setup(_: @This(), self: *Self) void {
                    self.counters[0] = Counter{};
                    self.counters[0].remaining = local_iters * num_counters;
                }

                fn run(_: @This(), self: *Self) void {
                    var iters: usize = local_iters;
                    while (iters > 0) : (iters -= 1) {
                        _ = self.counters[0].tryDecr();
                    }
                }
            };
            
            /// Stresses the common use-case of random Mutex contention.
            const Random = struct {
                fn setup(_: @This(), self: *Self) void {
                    self.counters = counters_init;
                }

                /// Each thread iterates the counters array starting from a random position.
                /// On each iteration, it tries to lock & decrement the value of each counter is comes across.
                /// When it is unable to decrement on any counter, it terminates (seeing that they've all reached 0).
                fn run(_: @This(), self: *Self) void {
                    var seed: usize = undefined;
                    var prng = std.rand.DefaultPrng.init(@ptrToInt(&seed));

                    while (true) {
                        var did_decr = false;
                        var iter = self.counters.len;
                        var index = prng.random.int(usize) % iter;

                        while (iter > 0) : (iter -= 1) {
                            const counter = &self.counters[index];
                            index = (index + 1) % self.counters.len;
                            did_decr = counter.tryDecr() or did_decr;
                        }

                        if (!did_decr) {
                            break;
                        }
                    }
                }
            };
        };

        fn run(self: *Self) void {
            self.start_event.wait();

            switch (self.case) {
                .random => |case| case.run(self),
                .high => |case| case.run(self),
                .forced => |case| case.run(self),
                .low => |case| case.run(self),
            }
        }

        fn execute(self: *Self) !void {
            const allocator = testing.allocator;
            const threads = try allocator.alloc(*std.Thread, 10);
            defer allocator.free(threads);

            defer {
                self.start_event.deinit();
                for (self.counters) |*counter| {
                    counter.mutex.deinit();
                }
            }

            for ([_]Case{ .high, .random, .forced }) |contention_case| {
                self.case = contention_case;
                switch (self.case) {
                    .random => |case| case.setup(self),
                    .high => |case| case.setup(self),
                    .forced => |case| case.setup(self),
                    .low => |case| case.setup(self),
                }

                self.start_event.reset();
                for (threads) |*t| {
                    t.* = try std.Thread.spawn(self, Self.run);
                }

                self.start_event.set();
                for (threads) |t| {
                    t.wait();
                }
            }
        }
    };

    var contention = Contention{};
    try contention.execute();
}