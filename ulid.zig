const std = @import("std");
const time = std.time;
const rand = std.rand;
const mem = std.mem;

const encoding = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";
const random_len: usize = 16;
const time_len: usize = 10;

var rng: rand.DefaultCsprng = undefined;
var rng_seeded = false;
var seed_buf: [8]u8 = undefined;

pub fn ulidAlloc(allocator: *mem.Allocator) ![]const u8 {
    var out = try allocator.alloc(u8, random_len + time_len);
    try ulid(out);
    return out;
}

pub fn ulid(out: []u8) !void {
    try initRng();

    var count: usize = 0;
    while (count < random_len) : (count += 1) {
        const r = rng.random.uintAtMost(usize, encoding.len - 1);
        out[out.len - count - 1] = encoding[r];
    }

    var now = @as(usize, time.milliTimestamp());
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
    var count: u8 = 0;
    while (count < 10) : (count += 1) {
        var u = try ulidAlloc(allocator);
        defer allocator.free(u);
        std.debug.warn("got this: {}\n", .{u});
    }
    std.debug.warn("\n", .{});
}
