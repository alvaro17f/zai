const std = @import("std");
const eql = std.mem.eql;
const style = @import("utils/style.zig");
const openrouter = @import("providers/openrouter.zig").openrouter;
const Config = @import("types/config.zig").Config;

const version = "0.1.0";

fn printHelp() void {
    std.debug.print(
        \\
        \\ ***************************************************
        \\  ZAI - Artificial Intelligence
        \\ ***************************************************
        \\ [message] : Get a response from ZAI
        \\ -h, help : Display this help message
        \\ -v, version : Display the current version
        \\
        \\ Example:
        \\ $ zai name the members of the beatles
        \\
    , .{});
}

fn printVersion() void {
    std.debug.print("{s}\nZAI version: {s}{s}\n{s}", .{ style.Gray, style.Cyan, version, style.Reset });
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const config = Config{
        .provider = .openrouter,
        .model = "qwen/qwq-32b:free",
    };

    if (args.len <= 1) {
        return printHelp();
    }

    for (args[1..], 0..) |arg, idx| {
        if (arg[0] == '-') {
            for (arg[1..]) |flag| {
                switch (flag) {
                    'h' => {
                        return printHelp();
                    },
                    'v' => {
                        return printVersion();
                    },
                    else => return std.debug.print("{s}Error: Unknown flag \"-{c}\"\n{s}", .{ style.Red, flag, style.Reset }),
                }
            }
        } else if (idx == 0 and args.len <= 2) {
            for (args[1..]) |argument| {
                if (eql(u8, argument, "help")) {
                    return printHelp();
                }
                if (eql(u8, argument, "version")) {
                    return printVersion();
                }
            }
        }

        const combinedArgs = try std.mem.join(allocator, " ", args[1..]);
        defer allocator.free(combinedArgs);

        switch (config.provider) {
            .openrouter => {
                return try openrouter(combinedArgs, config);
            },
            .openai => {
                return try openrouter(combinedArgs, config);
            },
        }
    }
}
