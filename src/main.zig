const rl  = @import("raylib");
const rlm = @import("raylib-math");
const std = @import("std");
const obj = @import("types.zig");
const phs = @import("physics.zig");

const DEBUG = true;

// NOTE
// Coordinate system starts at top left corner, whitch means THE Y AXIS IS FLIPPED!!!

// MAIN
pub fn main() anyerror!void
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.InitWindow(screenWidth, screenHeight, "raylib-zig [core] example - 2d camera");
    // rl.SetWindowState(rl.ConfigFlags.FLAG_WINDOW_RESIZABLE);
    defer rl.CloseWindow(); // Close window and OpenGL context

    var camera = rl.Camera2D {
        .target = rl.Vector2 { .x = 0, .y = 0 },
        .offset = rl.Vector2 { .x = screenWidth / 2, .y = screenHeight / 2 },
        .rotation = 0,
        .zoom = 1,
    };

    // var map: Map = Map { .tiles = undefined };
    var objects = [_]obj.Object{
        .{ .box = .{ .x = 0, .y = 0, .width = 300, .height = 20, },   .texture = null },
        .{ .box = .{ .x = 100, .y = 0, .width = 20, .height = 200, }, .texture = null }
    };

    var map: obj.Map = .{ .tiles = &objects };


    var player: obj.Player = .{ 
        .box = .{ .x = 20, .y = 300, .width = 20, .height = 20 }, 
        .velocity = .{ .x = 0, .y = 0 }, 
    };
    
    // dirty object fixer upper
    player.box.y = -player.box.y;

    for (map.tiles) |*tile| {
        tile.box.y = -tile.box.height;
    }

    // freefly
    var fly = true;

    rl.SetTargetFPS(60); // Set our game to run at 60 frames-per-second


    // Main game loop ================================================================
    while (!rl.WindowShouldClose()) // Detect window close button or ESC key
    {
        // handle user input
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_RIGHT)) { player.velocity.x += 1.5; } // move right
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_LEFT )) { player.velocity.x -= 1.5; } // move left

        if (rl.IsKeyPressed(rl.KeyboardKey.KEY_F)) { fly = !fly; }
        if (fly) {
            if (rl.IsKeyDown(rl.KeyboardKey.KEY_UP)) { player.velocity.y   += 1.5; }
            if (rl.IsKeyDown(rl.KeyboardKey.KEY_DOWN)) { player.velocity.y -= 1.5; }
            phs.movement.FreeFly(&player);
        } else {
            if (rl.IsKeyPressed(rl.KeyboardKey.KEY_UP)) { player.velocity.y = 15; } // jump
            phs.ApplyForces(&player);
        }

        // run collisions
        phs.ApplyPlayerCollisions(&player, map);

        // camera setup
        camera.target = rl.Vector2 { .x = player.box.x + player.box.width / 2, .y = player.box.y + player.box.height / 2 };
        // input related to camera
        camera.zoom += rl.GetMouseWheelMove() * 0.05;


        // DEBUG
        // try stdout.print("player position: x = {d}, y = {d}\n", .{player.box.x, player.box.y});
        // std.log.debug("player position: x = {d}, y = {d}, velocity: x = {d}, y = {d}", .{player.box.x, player.box.y, player.velocity.x, player.velocity.y});    


        {
            // init drawing
            rl.BeginDrawing();
            
            // clear screen with WHITE
            defer rl.ClearBackground(rl.RAYWHITE);

            {
                // init camera
                camera.Begin();

                rl.DrawCircleV( .{ .x = 0, .y = 0 } , 4, rl.BLUE);

                // draw player
                rl.DrawRectangleRec(player.box, rl.RED);

                for (map.tiles) |tile| {
                    rl.DrawRectangleRec(tile.box, rl.GRAY);

                    // DEBUG
                    if (DEBUG) {
                        var midpoint: rl.Vector2 = .{ .x = tile.box.x + (tile.box.width / 2), .y = tile.box.y + (tile.box.height / 2) };
                        rl.DrawCircleV( midpoint, 4, rl.GREEN);

                        var col_rec = rl.GetCollisionRec(player.box, tile.box);
                        rl.DrawRectangleRec(col_rec, rl.BLUE);

                        rl.DrawCircleV( .{ .x = tile.box.x, .y = tile.box.y }, 4, rl.ORANGE );
                    }

                }

                camera.End();
            }

            rl.EndDrawing();
        }
       
    }

    
}
