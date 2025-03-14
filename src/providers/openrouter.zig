const std = @import("std");
const writer = std.io.getStdOut().writer();
const http = @import("../utils/http.zig");
const style = @import("../utils/style.zig");
const Config = @import("../types/config.zig").Config;
const Provider = @import("../types/provider.zig").Provider;
const getEnvironmentVariables = @import("../utils/env.zig").getEnvironmentVariables;

const provider = Provider{
    .url = "https://openrouter.ai/api/v1/chat/completions",
    .api_key = "OPENROUTER_API_KEY",
    .model = "OPENROUTER_MODEL",
};

const OpenRouter = struct {
    choices: []struct {
        message: struct {
            content: []const u8,
            reasoning: []const u8 = "not a reasoning model",
        },
    },
};

pub fn openrouter(message: []const u8, _: Config) !void {
    const alloc = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(alloc);
    const allocator = arena.allocator();
    defer arena.deinit();

    const env = try getEnvironmentVariables(allocator, provider);

    const api_key = env.api_key;
    const model = env.model;

    try writer.print(
        \\
        \\model: {s}{s}{s}
        \\
    , .{
        style.Red,
        model,
        style.Reset,
    });

    const authorization = try std.fmt.allocPrint(allocator, "Bearer {s}", .{api_key});

    const payload = try std.json.stringifyAlloc(allocator, .{
        .model = model,
        .messages = .{
            .{
                .role = "system",
                .content = "You are a helpful assistant.",
            },
            .{
                .role = "user",
                .content = message,
            },
        },
    }, .{ .whitespace = .minified, .emit_null_optional_fields = true });

    var client = std.http.Client{ .allocator = allocator };
    const response = try http.fetch(.POST, provider.url, &.{
        .{ .name = "Authorization", .value = authorization },
        .{ .name = "HTTP-Referer", .value = "zai" },
        .{ .name = "X-Title", .value = "zai" },
        .{ .name = "Content-Type", .value = "application/json" },
    }, &client, allocator, payload);

    const result = try std.json.parseFromSlice(OpenRouter, allocator, response.items, .{ .ignore_unknown_fields = true });

    const answer = result.value.choices[0].message;
    const reasoning = answer.reasoning;
    const text = answer.content;

    try writer.print(
        \\
        \\{s}{s}{s}{s}
        \\
        \\{s}{s}{s}
        \\
        \\{s}{s}{s}
        \\
    , .{
        style.Green,
        style.Underline,
        message,
        style.Reset,
        style.Blue,
        reasoning,
        style.Reset,
        style.Yellow,
        text,
        style.Reset,
    });
}
