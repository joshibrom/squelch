const std = @import("std");

const reader = @import("file_reader.zig");
const renderer = @import("renderer.zig");

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

pub fn main() !void {
    var stdout_buf: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    var file_reader_1 = try reader.read_file("src/main.zig");
    defer file_reader_1.deinit();
    var file_reader_2 = try reader.read_file("src/file_reader.zig");
    defer file_reader_2.deinit();

    try renderer.render(.String, stdout, file_reader_1.content);
    try renderer.render(.String, stdout, file_reader_2.content);
}
