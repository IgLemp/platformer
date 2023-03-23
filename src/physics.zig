const rl  = @import("raylib");
const rlm = @import("raylib-math");
const obj = @import("types.zig");

// constants
const GRAVITY: f32 = -10;
const FRICTION: f32 = 10;



pub fn apply_forces(player: *obj.Player) void {
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

 pub const movement = struct {
    pub fn free_fly(player: *obj.Player) void {
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
};



pub fn apply_player_collisions(player: *obj.Player, map: obj.Map) void {

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