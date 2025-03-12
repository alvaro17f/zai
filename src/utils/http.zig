const std = @import("std");
const writer = std.io.getStdOut().writer();

pub fn fetch(method: std.http.Method, url: []const u8, headers: []const std.http.Header, client: *std.http.Client, allocator: std.mem.Allocator, payload: []const u8) !std.ArrayList(u8) {
    var response_body = std.ArrayList(u8).init(allocator);

    try writer.print("Sending request...\n", .{}); //TODO: animate this loading message

    _ = try client.fetch(.{
        .method = method,
        .location = .{ .url = url },
        .extra_headers = headers,
        .response_storage = .{ .dynamic = &response_body },
        .payload = payload,
    });

    return response_body;
}
