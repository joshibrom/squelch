const std = @import("std");

const reader = @import("io/file_reader.zig");
const renderer = @import("io/renderer.zig");

const project_handler = @import("types/project.zig");

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

fn initPartials() !renderer.PartialCollection {
    return .{
        .header = try reader.read_file("content/partials/header.html"),
        .footer = try reader.read_file("content/partials/footer.html"),
    };
}

pub fn main() !void {
    var stdout_buf: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    var partials = try initPartials();
    defer partials.deinit();

    var projects_dir = try std.fs.cwd().openDir("content/projects", .{ .iterate = true });
    defer projects_dir.close();
    var projects_iter = projects_dir.iterate();
    while (try projects_iter.next()) |entry| {
        switch (entry.kind) {
            .file => {
                var fname_buf: [128]u8 = undefined;
                var file_reader = try reader.read_file(try std.fmt.bufPrint(&fname_buf, "content/projects/{s}", .{entry.name}));
                defer file_reader.deinit();

                const project = project_handler.Project.parse(file_reader.content);

                const article_wrapper = renderer.RenderWrapper([]const u8, renderer.RenderMode, []const u8){
                    .start = "<article>",
                    .inner = .{ .text = .{ .content = project.content } },
                    .end = "</article>",
                };

                const doc = renderer.Document(article_wrapper);
                try doc.write(stdout);
                try stdout.flush();
            },
            else => {},
        }
    }
}
