const std = @import("std");
const Ulid = @import("./ulid.zig");

pub fn main() !void {
    var id = Ulid.ulidAlloc(std.testing.allocator);
    std.debug.warn("A ulid: {}\n", .{id});
}
