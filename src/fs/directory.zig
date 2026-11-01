const std = @import("std");

const mapped_file = @import("mapped_file.zig");
const MappedFile = mapped_file.MappedFile;

pub const DirectoryMapper = struct {
    const Self = @This();

    io: std.Io,
    dir: std.Io.Dir,
    walker: std.Io.Dir.Walker = undefined,

    pub fn init(self: *Self, allocator: std.mem.Allocator) !void {
        self.walker = try self.dir.walk(allocator);
    }

    pub fn deinit(self: *Self) void {
        self.walker.deinit();
        self.walker = undefined;
    }

    pub fn map_next_file(self: *Self) !?struct { []const u8, MappedFile } {
        const file = try self.next_file() orelse return null;

        var mf = MappedFile{
            .io = self.io,
            .file = try file.dir.openFile(
                self.io,
                file.basename,
                .{ .mode = .read_write },
            ),
        };
        try mf.init();

        return .{ file.path, mf };
    }

    fn next_file(self: *Self) !?std.Io.Dir.Walker.Entry {
        while (try self.walker.next(self.io)) |entry| {
            if (entry.kind == .file) return entry;
        }

        return null;
    }
};
