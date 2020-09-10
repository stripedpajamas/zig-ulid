const std = @import("std");
const Ulid = @import("./ulid.zig").Ulid;

pub fn main() !void {
    var ulid = try Ulid.init(std.testing.allocator);
    var id = ulid.ulid();
    std.debug.warn("A ulid: {}\n", .{id});
}
