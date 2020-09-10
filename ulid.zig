const std = @import("std");
const time = std.time;
const rand = std.rand;
const mem = std.mem;
const assert = std.debug.assert;
const ArrayList = std.ArrayList;

pub const Ulid = struct {
    const encoding = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";
    const random_len: usize = 16;
    const time_len: usize = 10;

    allocator: *mem.Allocator,
    rng: rand.DefaultCsprng,

    pub fn init(allocator: *mem.Allocator) !Ulid {
        var buf: [8]u8 = undefined;
        try std.crypto.randomBytes(&buf);
        const seed = mem.readIntLittle(u64, &buf);

        return Ulid{
            .allocator = allocator,
            .rng = rand.DefaultCsprng.init(seed),
        };
    }

    pub fn ulid(self: *Ulid) ![]const u8 {
        var out = try self.allocator.alloc(u8, random_len + time_len);
        self.addRandom(out);
        self.addTime(out);
        return out;
    }

    fn addRandom(self: *Ulid, out: []u8) void {
        var count: usize = 0;
        while (count < random_len) : (count += 1) {
            const r = self.rng.random.uintAtMost(usize, encoding.len - 1);
            out[out.len - count - 1] = encoding[r];
        }
    }

    fn addTime(self: *Ulid, out: []u8) void {
        var now = @as(usize, time.milliTimestamp());

        var count: usize = 0;
        while (count < time_len) : (count += 1) {
            var mod = now % encoding.len;
            out[out.len - count - random_len - 1] = encoding[mod];
            now = (now - mod) / encoding.len;
        }
    }
};

test "ulid" {
    var allocator = std.testing.allocator;
    var ulid = try Ulid.init(allocator);
    var u = try ulid.ulid();
    defer allocator.free(u);
    std.debug.warn("\ngot this: {}\n", .{u});
}
