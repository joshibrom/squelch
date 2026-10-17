pub const Link = struct {
    title: []const u8,
    href: []const u8,
};

pub const Profile = struct {
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

pub const my_profile = Profile{
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
