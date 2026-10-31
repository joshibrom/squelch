const std = @import("std");

pub const MappedFile = struct {
    const Self = @This();

    io: std.Io,
    file: std.Io.File,
    mapping: std.Io.File.MemoryMap = undefined,
    content: []const u8 = undefined,

    pub fn init(self: *Self) !void {
        var mm = try self.file.createMemoryMap(self.io, .{
            .len = @intCast(try self.file.length(self.io)),
        });
        try mm.read(self.io);

        self.mapping = mm;
        self.content = self.mapping.memory;
    }

    pub fn deinit(self: *Self) void {
        self.mapping.destroy(self.io);
        self.file.close(self.io);
        self.file = undefined;
        self.mapping = undefined;
        self.content = undefined;
    }
};

pub fn read_file(file_path: []const u8, io: std.Io) !MappedFile {
    var mf = MappedFile{
        .io = io,
        .file = try std.Io.Dir.cwd().openFile(io, file_path, .{
            .mode = .read_write, // File must be in RW mode to map
        }),
    };
    try mf.init();

    return mf;
}
