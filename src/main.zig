const std = @import("std");
const Directory = @import("fs/directory.zig").Directory;

pub fn main(init: std.process.Init) !void {
    var dir = Directory{ .io = init.io };
    try dir.init("test_dir", std.Io.Dir.cwd());
    defer dir.deinit();

    while (try dir.next_file()) |nf| {
        const fname, const mapped_file = nf;
        std.debug.print("{s}\n{s}\n\n", .{ fname, mapped_file.content });
    }

    // Prints to stderr, unbuffered, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}
