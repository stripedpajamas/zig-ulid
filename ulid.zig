const std = @import("std");
const time = std.time;
const rand = std.rand;
const mem = std.mem;
const assert = std.debug.assert;

const encoding = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";
const random_len: usize = 16;
const time_len: usize = 10;

var rng: rand.DefaultCsprng = undefined;
var rng_seeded = false;
var seed_buf: [8]u8 = undefined;

pub fn ulidAllocNow(allocator: *mem.Allocator) ![]const u8 {
    return ulidAlloc(allocator, null);
}

pub fn ulidAlloc(allocator: *mem.Allocator, seedTime: ?u64) ![]const u8 {
    var out = try allocator.alloc(u8, random_len + time_len);
    try ulid(out, seedTime);
    return out;
}

pub fn ulidNow(out: []u8) !void {
    try ulid(out, null);
}

pub fn ulid(out: []u8, seedTime: ?u64) !void {
    try initRng();

    var now_time = seedTime orelse time.milliTimestamp();

    var count: usize = 0;
    while (count < random_len) : (count += 1) {
        const r = rng.random.uintAtMost(usize, encoding.len - 1);
        out[out.len - count - 1] = encoding[r];
    }

    var now = @as(usize, now_time);
    while (count < random_len + time_len) : (count += 1) {
        var mod = now % encoding.len;
        out[out.len - count - 1] = encoding[mod];
        now = (now - mod) / encoding.len;
    }
}

fn initRng() !void {
    if (rng_seeded) return;
    var buf: [8]u8 = undefined;
    try std.crypto.randomBytes(&buf);
    const seed = mem.readIntLittle(u64, &buf);
    rng = rand.DefaultCsprng.init(seed);
    rng_seeded = true;
}

test "ulid" {
    var allocator = std.testing.allocator;

    // should return correct length
    var id = try ulidAllocNow(allocator);
    defer allocator.free(id);
    assert(id.len == 26);

    // should properly enocde time
    var id_custom_time: [26]u8 = undefined;
    try ulid(&id_custom_time, 1469918176385);
    var time_component = id_custom_time[0..10];
    std.testing.expectEqualSlices(u8, time_component, "01ARYZ6S41");
}
