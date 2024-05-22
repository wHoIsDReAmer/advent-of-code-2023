const std = @import("std");
const builtIn = @import("builtin");
const gha = std.heap.page_allocator;

const split = std.mem.split;
const print = std.debug.print;
const eql = std.mem.eql;

const Game = struct {
    id: i32,
    red: i32,
    green: i32,
    blue: i32,

    pub fn is_possible() bool {
        return true;
    }
};

const Ball = enum {
    red,
    green,
    blue,

    fn parse(bStr: []const u8) Ball {
        if (eql(u8, bStr, "red")) {
            return Ball.red;
        } else if (eql(u8, bStr, "green")) {
            return Ball.green;
        } else if (eql(u8, bStr, "blue")) {
            return Ball.blue;
        }

        // default
        return Ball.red;
    }
};

fn parse_game(line: []const u8) void {
    // parse "Game %d:"
    const id = @as(i32, line[5..6][0]) - '0';

    if (builtIn.mode == std.builtin.OptimizeMode.Debug)
        print("id: {}\n", .{id});

    // parse palls list seperated by ;
    var subsets = split(u8, line[8..], "; ");

    while (subsets.next()) |rawBalls| {
        var balls = split(u8, rawBalls, ", ");

        while (balls.next()) |ball| {
            var sizeAndBall = split(u8, ball, " ");
            const size = sizeAndBall.next();
            const ballValue = sizeAndBall.next();

            if (builtIn.mode == std.builtin.OptimizeMode.Debug) {
                // print("{s}\n", .{ball});
                print("size: {s}, ball: {s}\n", .{ size.?, ballValue.? });
            }
        }
    }

    // return Game{
    //     .id = id,
    // };
}

/// Must be there are only 12 red, 13 green, 14 blue
pub fn main() void {
    parse_game("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green");
}
