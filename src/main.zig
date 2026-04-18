const std = @import("std");

const Link = struct {
    title: []const u8,
    href: []const u8,
};

const Profile = struct {
    const Callsign = struct {
        service: []const u8,
        callsign: []const u8,
    };
    name: []const u8,
    title: []const u8,
    tagline: []const u8,
    links: []const Link,
    callsigns: []const Callsign,
};

const my_profile = Profile{
    .name = "Joshua Ibrom",
    .title = "Web Application Developer III & MSCS Student",
    .tagline = "I build minimalist web infrastructure and explore **systems-level programming**. Currently focused on high-performing tooling with **Zig** and **Rust**.",
    .links = &[_]Link{
        .{ .title = "GitHub", .href = "https://github.com/joshibrom" },
        .{ .title = "LinkedIn", .href = "https://linkedin.com/in/joshua-ibrom" },
        .{ .title = "Email", .href = "mailto:joshuaibrom@gmail.com" },
    },
    .callsigns = &[_]Profile.Callsign{
        .{ .service = "GMRS", .callsign = "WSIZ578" },
    },
};

fn writeBolding(writer: *std.io.Writer, input: []const u8) !void {
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

pub fn main() !void {
    var stdout_buf: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    try writeBolding(stdout, my_profile.tagline);
    try stdout.writeAll("\n");
    try stdout.flush();
}
