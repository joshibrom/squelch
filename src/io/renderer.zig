const std = @import("std");

const FileReader = @import("file_reader.zig").FileReader;

pub const PartialCollection = struct {
    header: FileReader,
    footer: FileReader,

    pub fn deinit(self: *@This()) void {
        self.header.deinit();
        self.footer.deinit();
    }
};

pub fn RenderWrapper(comptime Inner: type) type {
    return struct {
        inner: Inner,
        start: ?[]const u8,
        end: ?[]const u8,

        pub fn write(self: @This(), writer: *std.Io.Writer) !void {
            if (self.start) |s| {
                try writer.writeAll(s);
            }

            try self.inner.write(writer);

            if (self.end) |e| {
                try writer.write(e);
            }
        }
    };
}

pub const Boldable = struct {
    content: []const u8,

    pub fn write(self: @This(), writer: *std.Io.Writer) !void {
        var i: usize = 0;
        var inside_bold = false;

        while (i < self.content.len) {
            if (i + 1 < self.content.len and std.mem.eql(u8, self.content[i .. i + 2], "**")) {
                const tag = if (inside_bold) "</strong>" else "<strong>";
                try writer.writeAll(tag);
                inside_bold = !inside_bold;
                i += 2;
            } else {
                try writer.writeByte(self.content[i]);
                i += 1;
            }
        }
    }
};

pub const Text = struct {
    content: []const u8,

    pub fn write(self: @This(), writer: *std.Io.Writer) !void {
        try writer.writeAll(self.content);
    }
};

pub const RenderModeT = enum { boldable, text };

pub const RenderMode = union(RenderModeT) {
    boldable: Boldable,
    text: Text,

    pub fn write(self: @This(), writer: *std.Io.Writer) !void {
        switch (self) {
            .boldable => |s| try s.write(writer),
            .text => |s| try s.write(writer),
        }
    }
};
