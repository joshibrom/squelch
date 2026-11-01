const std = @import("std");
const Directory = @import("fs/directory.zig").DirectoryMapper;

pub fn main(init: std.process.Init) !void {
    var dir = Directory{
        .io = init.io,
        .dir = try std.Io.Dir.cwd().openDir(
            init.io,
            "test_dir",
            .{ .iterate = true },
        ),
    };
    try dir.init(init.gpa);
    defer dir.deinit();

    while (try dir.map_next_file()) |next_file| {
        const fname, var mapped_file = next_file;
        defer mapped_file.deinit();
        std.debug.print("{s}\n{s}\n\n", .{ fname, mapped_file.content });
    }

    // Prints to stderr, unbuffered, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}
