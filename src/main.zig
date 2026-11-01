const std = @import("std");
const DirectoryMapper = @import("fs/directory.zig").DirectoryMapper;

pub fn main(init: std.process.Init) !void {
    var dir =
        try std.Io.Dir.cwd().openDir(
            init.io,
            "test_dir",
            .{ .iterate = true },
        );
    defer dir.close(init.io);
    var dm = try DirectoryMapper.init(
        init.io,
        dir,
        init.gpa,
    );
    defer dm.deinit();

    while (try dm.map_next_file()) |next_file| {
        const fname, var mapped_file = next_file;
        defer mapped_file.deinit();
        std.debug.print("{s}\n{s}\n\n", .{ fname, mapped_file.get_content() });
    }

    // Prints to stderr, unbuffered, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}
