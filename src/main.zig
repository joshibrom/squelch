const std = @import("std");
const mapped_file = @import("fs/mapped_file.zig");

pub fn main(init: std.process.Init) !void {
    var file = try mapped_file.read_file("src/main.zig", init.io);
    defer file.deinit();

    std.debug.print("{s}\n", .{file.content});

    // Prints to stderr, unbuffered, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}
