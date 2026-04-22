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

pub fn RenderWrapper(comptime Start: type, comptime Inner: type, comptime End: type) type {
    return struct {
        start: ?Start = null,
        inner: Inner,
        end: ?End = null,

        pub fn write(self: @This(), writer: *std.Io.Writer) !void {
            if (self.start) |s| {
                switch (@TypeOf(s)) {
                    []const u8, []u8 => try writer.writeAll(s),
                    else => try s.write(writer),
                }
            }

            try self.inner.write(writer);

            if (self.end) |e| {
                switch (@TypeOf(e)) {
                    []const u8, []u8 => try writer.writeAll(e),
                    else => try e.write(writer),
                }
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

pub const ImportCollectionType = enum { foo, bar, both };

pub fn ImportCollection(comptime collection_type: ImportCollectionType) type {
    return struct {
        const IMPORT_FOO = "<script src=\"foo\"></script>";
        const IMPORT_BAR = "<script src=\"bar\" defer></script>";

        pub fn write(self: @This(), writer: *std.Io.Writer) !void {
            _ = self;
            const list = switch (collection_type) {
                .foo => &[_][]const u8{IMPORT_FOO},
                .bar => &[_][]const u8{IMPORT_BAR},
                .both => &[_][]const u8{ IMPORT_FOO, IMPORT_BAR },
            };
            for (list) |import_str| {
                try writer.writeAll(import_str);
            }
        }
    };
}

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

pub fn Document(children: anytype) RenderWrapper(Text, @TypeOf(children), Text) {
    return .{
        .start = .{ .content = "<!DOCTYPE html><html lang=\"en\">" },
        .inner = children,
        .end = .{ .content = "</html>" },
    };
}

pub fn Head(title: []const u8, description: []const u8, extra: anytype) RenderWrapper(
    Text,
    RenderWrapper(
        RenderWrapper(Text, Text, Text),
        RenderWrapper(Text, Text, Text),
        @TypeOf(extra),
    ),
    Text,
) {
    const title_tag = TextTag(
        "<title>",
        title,
        " | Joshua Ibrom</title>",
    );
    const description_tag = TextTag(
        "<meta name=\"description\" content=\"",
        description,
        "\" />",
    );
    // FIXME: end cannot be null
    return .{
        .start = .{ .content = "<head>" },
        .inner = .{
            .start = description_tag,
            .inner = title_tag,
            .end = extra,
        },
        .end = .{ .content = "</head>" },
    };
}

fn TextTag(tag_open: []const u8, title: []const u8, tag_close: []const u8) RenderWrapper(Text, Text, Text) {
    return .{
        .start = .{ .content = tag_open },
        .inner = .{ .content = title },
        .end = .{ .content = tag_close },
    };
}
