const std = @import("std");

pub const Project = struct {
    const Self = @This();

    title: []const u8 = undefined,
    description: []const u8 = undefined,
    content: []const u8,

    pub fn parse(input: []const u8) Self {
        const frontmatter, const content = splitToParts(input);
        var this = Self{ .content = content };
        var line_end: usize = 0;
        while (line_end < frontmatter.len) {
            const line_start = line_end;
            while (frontmatter[line_end] != '\n') {
                line_end += 1;
            }
            this.parseFrontmatterLine(frontmatter[line_start..line_end]);
            line_end += 1;
        }
        return this;
    }

    fn splitToParts(input: []const u8) struct { []const u8, []const u8 } {
        var frontmatter_end: usize = 0;
        var content_start: usize = frontmatter_end;

        var idx: usize = 0;
        const delim = "---\n";
        while (idx < input.len) : (idx += 1) {
            if (input[idx] == delim[0] and idx + delim.len < input.len and std.mem.eql(u8, input[idx .. idx + delim.len], delim)) {
                frontmatter_end = idx;
                content_start = frontmatter_end + delim.len;
                break;
            }
        }
        return .{ input[0..frontmatter_end], input[content_start..] };
    }

    fn parseFrontmatterLine(self: *Self, line: []const u8) void {
        const fields = [_]struct { name: []const u8, field: *[]const u8 }{
            .{ .name = "TITLE", .field = &self.title },
            .{ .name = "DESCRIPTION", .field = &self.description },
        };
        for (fields) |field| {
            if (line.len >= field.name.len + 2 and std.mem.eql(u8, line[0..field.name.len], field.name)) {
                field.field.* = line[field.name.len + 2 ..];
                break;
            }
        }
    }
};
