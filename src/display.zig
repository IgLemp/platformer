const rl = @import("raylib");

// functions for drawing shapes from WS coordinates

// RECTANGLES ===============
pub inline fn DrawRectangleWS(posX: c_int, posY: c_int, width: c_int, height: c_int, color: rl.Color) void 
    { rl.DrawRectangle(posX, -(posY + height), width, height, color); }

pub inline fn DrawRectangleVWS(position: rl.Vector2, size: rl.Vector2, color: rl.Color) void
    { rl.DrawRectangleV(.{ .x = position.x, .y = -(position.y + size.y) }, size, color); }

pub inline fn DrawRectangleRecWS(rec: rl.Rectangle, color: rl.Color) void
    { rl.DrawRectangleRec(.{ .x = rec.x, .y = -(rec.y + rec.height), .width = rec.width, .height = rec.height}, color); }


// CIRCLES ===============
pub inline fn DrawCircleVWS(center: rl.Vector2, radius: f32, color: rl.Color) void
    { rl.DrawCircleV(.{ .x = center.x, .y = -center.y }, radius, color); }


// TEXTURES ===============
pub inline fn DrawTextureVWS(texture: rl.Texture2D, position: rl.Vector2, tint: rl.Color) void
    { rl.DrawTextureV(texture, .{ .x = position.x, .y = -position.y}, tint); }

pub inline fn DrawTextureRecWS(texture: rl.Texture2D, source: rl.Rectangle, position: rl.Vector2, tint: rl.Color) void
    { rl.DrawTextureRec(texture, .{ .x = source.x, .y = -source.y, .width = source.width, .height = source.height }, .{ .x = position.x, .y = -position.y }, tint); }
