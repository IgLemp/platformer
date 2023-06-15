const rl  = @import("raylib");
const rlm = @import("raylib-math");
const std = @import("std");
const obj = @import("types.zig");
const phs = @import("physics.zig");
const utils = @import("utils.zig");

const DEBUG = true;

// NOTE
// Coordinate system starts at top left corner, whitch means THE Y AXIS IS FLIPPED!!! (for on screen coordinates)

// MAIN
pub fn main() anyerror!void
{
    // MEMORY ALLOCATOR
    //--------------------------------------------------------------------------------------
    var gpAlloc = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpAlloc.allocator();

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


    var objects = std.ArrayList(obj.Object).init(allocator);
    try objects.append(.{ .box = .{ .x = 0,   .y = 0, .width = 300, .height = 20,  }, .texture = null }); 
    try objects.append(.{ .box = .{ .x = 100, .y = 0, .width = 20,  .height = 200, }, .texture = null });

    var map: obj.Map = .{ .tiles = &objects };


    var player: obj.Player = .{ 
        .box = .{ .x = 20, .y = 300, .width = 20, .height = 20 }, 
        .detection_box = undefined,
        .velocity = .{ .x = 0, .y = 0 }, 
    };

    player.detection_box = .{ .x = &player.box.x, .y = &player.box.y, .width = 22, .height = 22 };
    
    var texture = rl.LoadTexture("./resources/log.png");
    var player_texture = rl.LoadTexture("./resources/cursor.png");

    // freefly
    var fly = true;

    rl.SetTargetFPS(60); // Set our game to run at 60 frames-per-second

    var mouse_ws_position: rl.Vector2 = undefined;
    var mouse_ws_end_position: rl.Vector2 = undefined;
    var mouse_position: rl.Vector2 = undefined;

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
            phs.ApplyForces(&player);
        }

        // run collisions
        phs.ApplyPlayerCollisions(&player, map);

        // camera setup
        camera.target = rl.Vector2 { .x = player.box.x + player.box.width / 2, .y = -(player.box.y + player.box.height / 2) };
        // input related to camera
        camera.zoom += rl.GetMouseWheelMove() * 0.05 * camera.zoom;


        // DEBUG
        // try stdout.print("player position: x = {d}, y = {d}\n", .{player.box.x, player.box.y});
        // std.log.debug("player position: x = {d}, y = {d}, velocity: x = {d}, y = {d}", .{player.box.x, player.box.y, player.velocity.x, player.velocity.y});    
        // std.log.debug("{}", .{player.detection_box});
        // std.debug.print("camera terget: x = {d}, y = {d}\n", .{camera.target.x, camera.target.y});
        
        mouse_position = rl.GetMousePosition();

        if (rl.IsMouseButtonPressed( .MOUSE_BUTTON_LEFT)) { mouse_ws_position     = utils.GetMousePositionInWS(camera, screenWidth, screenHeight); }
        if (rl.IsMouseButtonDown( .MOUSE_BUTTON_LEFT))    { mouse_ws_end_position = utils.GetMousePositionInWS(camera, screenWidth, screenHeight); }

        // if (mouse_ws_end_position.x < mouse_ws_position.x) { mouse_ws_position.x = mouse_ws_end_position.x; }
        // if (mouse_ws_end_position.y < mouse_ws_position.y) { mouse_ws_position.y = mouse_ws_end_position.y; }


        // if (rl.IsMouseButtonReleased( .MOUSE_BUTTON_LEFT )) { 
        //     var box_wh = .{ .x = mouse_ws_position.x - mouse_ws_end_position.x, .y = mouse_ws_position.y - mouse_ws_end_position.y };
        //     try map.tiles.append( .{ .box = .{ .x = mouse_ws_position.x, .y = mouse_ws_position.y, .width = box_wh.x, .height = box_wh.y, }, .texture = null } );
        //     std.debug.print("box cords: x = {d}, y = {d}, w = {d}, h = {d}", .{mouse_ws_position.x, mouse_ws_position.y, box_wh.x, box_wh.y});
        // }


        {
            // init drawing
            rl.BeginDrawing();
            
            // clear screen with WHITE
            defer rl.ClearBackground(rl.RAYWHITE);

            {
                // init camera
                camera.Begin();
                defer camera.End();

                defer rl.DrawCircleV( .{ .x = 0, .y = 0 }, 4, rl.BLUE);

                // what have I done
                rl.DrawTextureV(texture, .{ .x = -100, .y = -200}, rl.WHITE);
                    
                rl.DrawCircleV( .{ .x = mouse_ws_position.x, .y = -mouse_ws_position.y}, 10, rl.RED);
                rl.DrawCircleV( .{ .x = mouse_ws_end_position.x, .y = -mouse_ws_end_position.y}, 10, rl.BLUE);

                // draw player =====
                // var playerRenderBox = .{ .x = player.box.x, .y = -player.box.y - player.box.height, .width = player.box.width, .height = player.box.height };
                // _ = playerRenderBox;
                // defer rl.DrawRectangleRec( playerRenderBox, rl.RED);
                defer rl.DrawTextureV( player_texture, .{ .x = player.box.x, .y = -player.box.y - player.box.height }, rl.WHITE);
                // rl.DrawRectangleRec(.{ .x = player.detection_box.x.* - 5 , .y = player.detection_box.y.* - 5, .width = player.detection_box.width, .height = player.detection_box.height }, rl.RED);


                // tile drawing
                for (map.tiles.items) |tile| {
                    var disp_tile = .{ .x = tile.box.x, .y = tile.box.y - tile.box.height, .width = tile.box.width, .height = tile.box.height };
                    rl.DrawRectangleRec(disp_tile, rl.GRAY);

                    // DEBUG
                    if (DEBUG) {
                        // draw block midpoints
                        var midpoint: rl.Vector2 = .{ .x = tile.box.x + (tile.box.width / 2), .y = -(tile.box.y + (tile.box.height / 2)) };
                        rl.DrawCircleV( midpoint, 4, rl.GREEN);

                        // draw collision rectangles (with player)
                        var col_rec = rl.GetCollisionRec(player.box, tile.box);
                        rl.DrawRectangleRec(col_rec, rl.BLUE);

                        // draw tile origin points
                        rl.DrawCircleV( .{ .x = tile.box.x, .y = -tile.box.y }, 4, rl.ORANGE );

                        // draw collision rectangle (with player collision box)
                        rl.DrawRectangleRec( rl.GetCollisionRec( .{ .x = player.detection_box.x.* - 1, .y = -player.detection_box.y.* - 1 - player.box.height, .width = player.detection_box.width, .height = player.detection_box.height}, disp_tile ), rl.BLUE);
                    }

                    if (!fly) {
                        if (rl.IsKeyPressed(rl.KeyboardKey.KEY_UP) and 
                            rl.CheckCollisionRecs( .{ .x = player.detection_box.x.* - 1, .y = player.detection_box.y.* - 1, .width = player.detection_box.width, .height = player.detection_box.height}, tile.box )
                        ) { player.velocity.y = 15; } // jump
                    }

                }
            }

            rl.EndDrawing();
        }
       
    }

    
}
