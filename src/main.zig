const std = @import("std");
const eql = std.mem.eql;

pub fn main() !void {
    // the actual allocator structure. this is the structure that manages mem
    // allocation
    var general_purpose_alloc = std.heap.GeneralPurposeAllocator(.{}){};

    // an interface for allocating memory. pass by value everywhere.
    const alloc = general_purpose_alloc.allocator();

    const args = try std.process.argsAlloc(alloc);

    const action = parse_args(args) catch |e| switch (e) {
        error.MissingAction => return print_usage(),
        error.InvalidAction => |_| {
            std.log.err("invalid action", .{});
            print_usage();
            return;
        },
    };

    switch (action) {
        .Help => {
            print_help();
        },
        .New => |name| {
            std.log.info("name: {s}", .{name});
        },
    }

    // free args
    std.process.argsFree(alloc, args);
}

const ArgsError = error{
    MissingAction,
    InvalidAction,
};

fn parse_args(args: []const [:0]u8) ArgsError!Action {
    if (args.len < 2) {
        return error.MissingAction;
    }

    const action_str = args[1];
    const action = parse_action(action_str) orelse {
        return error.InvalidAction;
    };

    return switch (action) {
        .Help => Action{ .Help = undefined },
        .New => Action{ .New = args[2] },
    };
}

fn print_help() void {
    std.log.info("help: prints this message", .{});
    std.log.info("new <title>: creates a new note", .{});
}

fn parse_action(action: [:0]u8) ?ActionKind {
    if (eql(u8, action, "help")) {
        return .Help;
    } else if (eql(u8, action, "new")) {
        return .New;
    }
    return null;
}

fn print_usage() void {
    std.log.err("usage: todo <command>", .{});
    std.log.err("use `todo help` to see a list of commands", .{});
}

const ActionKind = enum {
    Help,
    New,
};

const Action = union(ActionKind) {
    Help: void,
    New: [:0]u8,
};
