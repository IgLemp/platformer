const rl  = @import("raylib");
const std = @import("std");

pub const Object = struct {
    box: rl.Rectangle,
    texture: ?*rl.Texture2D,
};

pub const Player = struct {
    box: rl.Rectangle,
    detection_box: DetectionBox,
    velocity: rl.Vector2,
    // max_velocity: f32,
};

pub const DetectionBox = struct {
    x:     *f32,
    y:     *f32,
    width:  f32,
    height: f32
};

pub const Map = struct {
    tiles: *std.ArrayList(Object),
};