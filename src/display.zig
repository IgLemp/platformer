const rl = @import("raylib");

pub fn DrawRectangleRecWS(rec: rl.Rectangle, color: rl.Color) void { rl.DrawRectangleRec(.{ .x = rec.x, .y = rec.y - rec.height, .width = rec.width, .height = rec.height }, color); }