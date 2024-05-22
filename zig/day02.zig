const std = @import("std");
const builtIn = @import("builtin");
const gha = std.heap.page_allocator;

const split = std.mem.split;
const print = std.debug.print;
const eql = std.mem.eql;
const startsWith = std.mem.startsWith;

const Game = struct {
    id: i32,
    red: i32,
    green: i32,
    blue: i32,

    pub fn is_possible(g: Game) bool {
        return g.red <= 12 and g.green <= 14 and g.blue <= 15;
    }
};

const BallError = error{BallNotFound};
const Ball = enum {
    red,
    green,
    blue,

    fn parse(bStr: []const u8) !Ball {
        if (startsWith(u8, bStr, "red")) {
            return Ball.red;
        } else if (startsWith(u8, bStr, "green")) {
            return Ball.green;
        } else if (startsWith(u8, bStr, "blue")) {
            return Ball.blue;
        }

        // default
        return BallError.BallNotFound;
    }
};

fn parse_game(line: []const u8) !Game {
    // parse "Game %d:"
    const id = @as(i32, line[5..6][0]) - '0';
    if (builtIn.mode == std.builtin.OptimizeMode.Debug)
        print("id: {}\n", .{id});

    var game = Game{ .id = id, .red = 0, .blue = 0, .green = 0 };

    // parse palls list seperated by ;
    var subsets = split(u8, line[8..], "; ");

    while (subsets.next()) |rawBalls| {
        var balls = split(u8, rawBalls, ", ");

        while (balls.next()) |ball| {
            var sizeAndBall = split(u8, ball, " ");
            const sizeBuf = sizeAndBall.next().?;
            const ballValue = sizeAndBall.next().?;
            if (builtIn.mode == std.builtin.OptimizeMode.Debug) {
                // print("{s}\n", .{ball});
                print("size: {s}, ball: {s}\n", .{ sizeBuf, ballValue });
            }

            const size = try std.fmt.parseInt(i32, sizeBuf, 10);
            const parsedBall = try Ball.parse(ballValue);

            switch (parsedBall) {
                Ball.red => game.red += size,
                Ball.green => game.green += size,
                Ball.blue => game.blue += size,
            }
        }
    }

    return game;
}

/// Must be there are only 12 red, 13 green, 14 blue
pub fn main() !void {
    var stdin = std.io.getStdIn().reader();
    const line = try stdin.readAllAlloc(gha, 4096);

    var total: i32 = 0;
    var lines = split(u8, line, "\n");
    while (lines.next()) |l| {
        if (l.len == 0)
            continue;

        const game = try parse_game(l);
        if (game.is_possible())
            total += game.id;
    }

    print("the sum of the IDs {}", .{total});
}
