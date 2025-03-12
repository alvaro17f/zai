const std = @import("std");
const Provider = @import("../types/provider.zig").Provider;

const Env = struct {
    api_key: []const u8,
    model: []const u8,
};

pub fn getEnvironmentVariables(allocator: std.mem.Allocator, provider: Provider) !Env {
    const api_key = std.posix.getenv(provider.api_key) orelse {
        @panic(try std.fmt.allocPrint(allocator, "{s} environment variable not set", .{provider.api_key}));
    };

    const model = std.posix.getenv(provider.model) orelse {
        @panic(try std.fmt.allocPrint(allocator, "{s} environment variable not set", .{provider.model}));
    };

    return .{
        .api_key = api_key,
        .model = model,
    };
}
