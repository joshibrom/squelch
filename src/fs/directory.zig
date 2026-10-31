const std = @import("std");

const mapped_file = @import("mapped_file.zig");
const MappedFile = mapped_file.MappedFile;

pub const Directory = struct {
    const Self = @This();

    io: std.Io,
    dir: std.Io.Dir = undefined,
    dir_iter: std.Io.Dir.Iterator = undefined,
    current_child: ?*Self = null,

    pub fn init(self: *Self, dirname: []const u8, parent_dir: std.Io.Dir) !void {
        self.dir = try parent_dir.openDir(
            self.io,
            dirname,
            .{ .iterate = true },
        );
        self.dir_iter = self.dir.iterate();
    }

    pub fn deinit(self: *Self) void {
        self.dir_iter = undefined;
        self.dir.close(self.io);
        if (self.current_child) |child| {
            child.deinit();
        }
        self.current_child = null;
    }

    pub fn next_file(self: *Self) !?struct { []const u8, MappedFile } {
        if (self.current_child) |child| {
            return child.next_file();
        }

        var entry = (try self.dir_iter.next(self.io)) orelse return null;
        while (entry.kind != .directory and entry.kind != .file) {
            entry = (try self.dir_iter.next(self.io)) orelse return null;
        }

        return switch (entry.kind) {
            .directory => blk: {
                self.current_child = @constCast(&Self{ .io = self.io });
                try self.current_child.?.init(entry.name, self.dir);
                break :blk self.current_child.?.next_file();
            },
            .file => blk: {
                var mf = MappedFile{
                    .io = self.io,
                    .file = try self.dir.openFile(
                        self.io,
                        entry.name,
                        .{ .mode = .read_write },
                    ),
                };
                try mf.init();

                break :blk .{ entry.name, mf };
            },

            else => unreachable,
        };
    }
};
