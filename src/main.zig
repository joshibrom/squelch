const std = @import("std");

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

    const file = try std.fs.cwd().openFile("src/main.zig", .{});
    defer file.close();

    const stat = try file.stat();
    const fsize = stat.size;

    const addr = try std.posix.mmap(
        null,
        fsize,
        std.posix.PROT.READ,
        .{ .TYPE = .PRIVATE },
        file.handle,
        0,
    );
    defer std.posix.munmap(addr);

    const data = @as([*]const u8, @ptrCast(addr))[0..fsize];

    try renderer.render(.String, stdout, data);
}
