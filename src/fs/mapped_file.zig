const std = @import("std");

pub const MappedFile = struct {
    const Self = @This();

    io: std.Io,
    file: std.Io.File,
    mapping: std.Io.File.MemoryMap,

    pub fn init(io: std.Io, parent_dir: std.Io.Dir, filename: []const u8) !Self {
        const file = try parent_dir.openFile(
            io,
            filename,
            .{ .mode = .read_write },
        );
        errdefer file.close(io);
        return Self{ .io = io, .file = file, .mapping = blk: {
            var mm = try file.createMemoryMap(
                io,
                .{ .len = @intCast(try file.length(io)) },
            );
            errdefer mm.destroy(io);
            try mm.read(io);
            break :blk mm;
        } };
    }

    pub fn deinit(self: *Self) void {
        self.mapping.destroy(self.io);
        self.file.close(self.io);
    }

    pub fn get_content(self: *const Self) []const u8 {
        return self.mapping.memory;
    }
};
