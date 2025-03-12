const Providers = enum {
    openai,
    openrouter,
};

pub const Config = struct {
    provider: Providers,
    model: []const u8,
};
