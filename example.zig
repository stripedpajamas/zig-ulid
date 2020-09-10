const std = @import("std");
const Ulid = @import("./ulid.zig");

pub fn main() !void {
    var allocator = std.testing.allocator;

    var ulid1 = try Ulid.ulidAllocNow(allocator);
    defer allocator.free(ulid1);
    std.debug.warn("Ulid (alloc'd): {}\n", .{ulid1});

    var ulid2 = try Ulid.ulidAlloc(allocator, 273);
    defer allocator.free(ulid2);
    std.debug.warn("Ulid (alloc'd; custom seed time): {}\n", .{ulid2});

    var ulid3: [26]u8 = undefined;
    try Ulid.ulidNow(&ulid3);
    std.debug.warn("Ulid (no alloc): {}\n", .{ulid3});

    var ulid4: [26]u8 = undefined;
    try Ulid.ulid(&ulid4, 273);
    std.debug.warn("Ulid (no alloc; custom seed time): {}\n", .{ulid4});
}
