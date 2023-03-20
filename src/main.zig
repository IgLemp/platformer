const rl = @import("raylib");
const rlm = @import("raylib-math");
const std = @import("std");


const Object = struct {
    box: rl.Rectangle,
    texture: ?rl.Texture2D,
};

const Player = struct {
    box: rl.Rectangle,
    velocity: rl.Vector2,
    // max_velocity: f32,
};

const Map = struct {
    tiles: []Object,
};


const GRAVITY: f32 = -10;
const FRICTION: f32 = 10;
fn apply_player_phisics(player: *Player) void {
    // apply gravity
    player.velocity.y += GRAVITY * rl.GetFrameTime();
    player.box.y -= player.velocity.y;

    // apply friction
    if (player.velocity.x > 0) { player.velocity.x -= FRICTION * rl.GetFrameTime(); }
    if (player.velocity.x < 0) { player.velocity.x += FRICTION * rl.GetFrameTime(); }
    if (player.velocity.x >= -1 and player.velocity.x <= 1) { player.velocity.x = 0; }
    player.box.x += player.velocity.x;

    // clamp velocities to not reach light speed in a second
    player.velocity.x = rlm.Clamp(player.velocity.x, -4, 4);
    player.velocity.y = rlm.Clamp(player.velocity.y, -8, 8);
}


fn free_fly(player: *Player) void {
    // apply friction for X
    if (player.velocity.x > 0) { player.velocity.x -= FRICTION * rl.GetFrameTime(); }
    if (player.velocity.x < 0) { player.velocity.x += FRICTION * rl.GetFrameTime(); }
    if (player.velocity.x >= -1 and player.velocity.x <= 1) { player.velocity.x = 0; }
    player.box.x += player.velocity.x;

    // apply friction for Y
    if (player.velocity.y > 0) { player.velocity.y -= FRICTION * rl.GetFrameTime(); }
    if (player.velocity.y < 0) { player.velocity.y += FRICTION * rl.GetFrameTime(); }
    if (player.velocity.y >= -1 and player.velocity.y <= 1) { player.velocity.y = 0; }
    player.box.y -= player.velocity.y;

    // clamp velocities to not reach light speed in a second
    player.velocity.x = rlm.Clamp(player.velocity.x, -4, 4);
    player.velocity.y = rlm.Clamp(player.velocity.y, -4, 4);
}


fn apply_player_collisions(player: *Player, map: Map) void {

    // for every tile
    for (map.tiles) |tile| {

        // check if any collision occured
        if ( rl.CheckCollisionRecs(player.box, tile.box) ) {
            // get collision rectangle
            var collision_rectangle = rl.GetCollisionRec(player.box, tile.box);
            
            // extract ranges
            var range: rl.Vector2 = .{ .x = collision_rectangle.width, .y = collision_rectangle.height };

            // calculate midpoints
            var player_midpoint: rl.Vector2 = .{ .x = player.box.x + (player.box.width / 2), .y = player.box.y + (player.box.height / 2) };
            var tile_midpoint:   rl.Vector2 = .{ .x = tile.box.x + (tile.box.width / 2), .y = tile.box.y + (tile.box.height / 2) };


            var player_on_top   = if (player_midpoint.y > tile_midpoint.y) true else false;
            var player_on_right = if (player_midpoint.x > tile_midpoint.x) true else false;

            // check on whitch side a collision occured and apply proper collisions
            if (range.x > range.y) {
                if (player_on_top) { player.box.y = tile.box.y + tile.box.height; } else { player.box.y = tile.box.y - player.box.height; }
                player.velocity.y = 0;
            }
            else {
                if (player_on_right) { player.box.x = tile.box.x + tile.box.width; } else { player.box.x = tile.box.x - player.box.width; }
                player.velocity.x = 0;
            }
        }
    }
}

// fn load_level(comptime file_path: []const u8) void {
    // // TODO
// }

// NOTE
// Coordinate system starts at top left corner, whitch means THE Y AXIS IS FLIPPED!!!

// TODO
// Setup level loading
// Setup texture loading

// DEBUG
// pub fn main() anyerror!void {
//     load_level("./resources/scene.dat");
// }



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
    var objects = [_]Object{
        .{ .box = .{ .x = 0, .y = 0, .width = 300, .height = 20, },   .texture = null },
        .{ .box = .{ .x = 100, .y = 0, .width = 20, .height = 200, }, .texture = null }
    };

    var map: Map = .{ .tiles = &objects };


    var player: Player = .{ 
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
        // run game logic       
        apply_player_collisions(&player, map);


    // handle user input
    if (rl.IsKeyDown(rl.KeyboardKey.KEY_RIGHT)) { player.velocity.x += 1.5; } // move right
    if (rl.IsKeyDown(rl.KeyboardKey.KEY_LEFT )) { player.velocity.x -= 1.5; } // move left

    if (rl.IsKeyPressed(rl.KeyboardKey.KEY_F)) { fly = !fly; }
    if (fly) {
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_UP)) { player.velocity.y   += 1.5; }
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_DOWN)) { player.velocity.y -= 1.5; }
        free_fly(&player);
    } else {
        if (rl.IsKeyPressed(rl.KeyboardKey.KEY_UP)) { player.velocity.y = 15; } // jump
        apply_player_phisics(&player);
    }

        camera.target = rl.Vector2 { .x = player.box.x + player.box.width / 2, .y = player.box.y + player.box.height / 2 };
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
                    var midpoint: rl.Vector2 = .{ .x = tile.box.x + (tile.box.width / 2), .y = tile.box.y + (tile.box.height / 2) };
                    rl.DrawCircleV( midpoint, 4, rl.GREEN);

                    var col_rec = rl.GetCollisionRec(player.box, tile.box);
                    rl.DrawRectangleRec(col_rec, rl.BLUE);

                    rl.DrawCircleV( .{ .x = tile.box.x, .y = tile.box.y }, 4, rl.ORANGE );
                }

                camera.End();
            }

            rl.EndDrawing();
        }
       
    }

    
}
