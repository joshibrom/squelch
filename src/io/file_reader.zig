const std = @import("std");

pub const FileReader = struct {
    file: std.fs.File,
    addr: []align(std.heap.page_size_min) u8 = undefined,
    content: []const u8 = undefined,

    pub fn init(self: *@This()) !void {
        const file_len = @as(usize, @intCast((try self.file.stat()).size));
        self.addr = try std.posix.mmap(
            null,
            file_len,
            std.posix.PROT.READ,
            .{ .TYPE = .PRIVATE },
            self.file.handle,
            0,
        );
        self.content = @as([*]const u8, @ptrCast(self.addr))[0..file_len];
    }

    pub fn deinit(self: *@This()) void {
        self.file.close();
        std.posix.munmap(self.addr);
        self.file = undefined;
        self.content = undefined;
    }
};

pub fn read_file(file_path: []const u8) !FileReader {
    var reader = FileReader{
        .file = try std.fs.cwd().openFile(
            file_path,
            .{ .mode = .read_only },
        ),
    };
    try reader.init();
    return reader;
}
