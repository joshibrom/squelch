const Profile = @import("../../types/profile.zig").Profile;
const renderer = @import("../renderer.zig");

const RenderedCollection = renderer.RenderedCollection;
const RenderWrapper = renderer.RenderWrapper;
const RenderMode = renderer.RenderMode;
const Text = renderer.Text;

const TextRender = RenderWrapper(Text, Text, Text);
const StandardRender = RenderWrapper([]const u8, TextRender, []const u8);

pub fn hero(profile: Profile) RenderWrapper(TextRender, StandardRender, RenderMode) {
    const name_elem = name(profile);
    const title_elem = title(profile);
    const tagline_elem = tagline(profile);
    return renderer.RenderWrapper(@TypeOf(name_elem), @TypeOf(title_elem), @TypeOf(tagline_elem)){
        .start = name_elem,
        .inner = title_elem,
        .end = tagline_elem,
    };
}

fn name(profile: Profile) TextRender {
    return renderer.TextTag("<h1>", profile.name, "</h1>");
}

fn title(profile: Profile) StandardRender {
    const strong = renderer.TextTag("<strong>", profile.title, "</strong>");
    return renderer.RenderWrapper([]const u8, @TypeOf(strong), []const u8){
        .start = "<p>",
        .inner = strong,
        .end = "</p>",
    };
}

fn tagline(profile: Profile) RenderMode {
    return renderer.RenderMode{ .boldable = .{ .content = profile.tagline } };
}

fn links(profile: Profile) RenderedCollection {
    const links = 
}
