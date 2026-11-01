const std = @import("std");

const mapped_file = @import("mapped_file.zig");
const MappedFile = mapped_file.MappedFile;

pub const DirectoryMapper = struct {
    const Self = @This();

    io: std.Io,
    walker: std.Io.Dir.Walker,

    pub fn init(io: std.Io, base_dir: std.Io.Dir, allocator: std.mem.Allocator) !Self {
        return Self{
            .io = io,
            .walker = try base_dir.walk(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.walker.deinit();
    }

    pub fn map_next_file(self: *Self) !?struct { []const u8, MappedFile } {
        const file = try self.next_file() orelse return null;

        return .{ file.path, try MappedFile.init(self.io, file.dir, file.basename) };
    }

    fn next_file(self: *Self) !?std.Io.Dir.Walker.Entry {
        while (try self.walker.next(self.io)) |entry| {
            if (entry.kind == .file) return entry;
        }

        return null;
    }
};
