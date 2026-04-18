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

pub const RenderMode = enum {
    File,
    String,
    BoldableString,

    fn write(comptime self: @This(), writer: *std.io.Writer, content: []const u8) !void {
        try switch (self) {
            .String => writeString(writer, content),
            .BoldableString => writeBoldableString(writer, content),
            else => @compileError("Unsupported rendering mode"),
        };
    }

    fn writeString(writer: *std.io.Writer, content: []const u8) !void {
        try writer.writeAll(content);
    }

    fn writeBoldableString(writer: *std.io.Writer, input: []const u8) !void {
        var i: usize = 0;
        var inside_bold = false;

        while (i < input.len) {
            if (i + 1 < input.len and std.mem.eql(u8, input[i .. i + 2], "**")) {
                const tag = if (inside_bold) "</strong>" else "<strong>";
                try writer.writeAll(tag);
                inside_bold = !inside_bold;
                i += 2;
            } else {
                try writer.writeByte(input[i]);
                i += 1;
            }
        }
    }
};

pub fn render(comptime mode: RenderMode, writer: *std.io.Writer, content: []const u8) !void {
    try mode.write(writer, content);
    try writer.writeAll("\n");
    try writer.flush();
}
