const std = @import("std");
const print = std.debug.print;

fn is_digit(s: u8) bool {
    switch (s) {
        '0'...'9' => return true,
        else => return false,
    }
}

fn get_digit_from_line(line: []const u8) i32 {
    var first = @as(i32, 0);
    var second = @as(i32, 0);
    for (line) |s| {
        if (is_digit(s)) {
            if (first == 0)
                first = s - '0';
            second = s - '0';
        }
    }

    return first * 10 + second;
}

pub fn main() !void {
    const gha = std.heap.page_allocator;

    var stdin = std.io.getStdIn().reader();
    // var stdout = std.io.getStdOut().writer();

    const text = try stdin.readAllAlloc(gha, 4096);
    defer gha.free(text);

    var total: i32 = 0;
    var split_result = std.mem.split(u8, text, "\n");
    while (split_result.next()) |line| {
        total += get_digit_from_line(line);
    }
    print("Celebration values: {}\n", .{total});
}
