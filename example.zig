const std = @import("std");
const ulid = @import("./ulid.zig");

pub fn main() void {
    var id = ulid.ulid();
    std.debug.warn("{}\n", .{id});
}
